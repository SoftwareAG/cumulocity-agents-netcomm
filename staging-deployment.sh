#!/usr/bin/env bash
set -o pipefail

if [ -z "$RUN_USER" ]; then
    RUN_USER=`whoami`
fi

if [ -z "$C8Y_ENVIRONMENT" ] ; then
    environment=$1
else
    environment=$C8Y_ENVIRONMENT
fi

export NO_PROMPT_ORGANIZATION=true
export ORGNAME=cumulocity-stagings

case $environment in
    staging)
        export CHEF_ENV=cumulocity-basic-staging7-nonprod
    ;;
    staging-1)
        export CHEF_ENV=cumulocity-staging-pe-1-nonprod
    ;;
    staging-2)
        export CHEF_ENV=cumulocity-staging-pe-2-nonprod
    ;;
    staging-007)
        export CHEF_ENV=cumulocity-staging007-nonprod
    ;;
    staging-7)
        export CHEF_ENV=cumulocity-staging7-nonprod
    ;;
    staging-latest)
        export CHEF_ENV=cumulocity-staging-latest-nonprod
    ;;
    staging-performance)
        export CHEF_ENV=cumulocity-staging-performance-test-nonprod
        export ORGNAME=cumulocity-devel
    ;;
    *)
        echo "You need to choose a valid environment (one of: staging staging-1 staging-2 staging-007 staging-7 staging-latest)"
        exit 1
    ;;
esac

if [ -z "$C8Y_VERSION" ] ; then
    version=$2
else 
    version=$C8Y_VERSION
fi

if [ -z "$version" ] ; then
    echo "You need to pass version to be installed"
    exit 2
fi

if [ -z "$K8S_IMAGES_VERSION" ] ; then
    images_version=$version
else
    images_version=$K8S_IMAGES_VERSION
fi

if [ -z "$KARAF_VERSION" ] ; then
    karaf_version="$version-1"
else
    karaf_version=$KARAF_VERSION
fi

if [ -z "$SSAGENTS_VERSION" ] ; then
    ssagents_version="$version-1"
else
    ssagents_version=$SSAGENTS_VERSION
fi

if [ -z "$GUI_VERSION" ] ; then
    gui_version=$version
else
    gui_version=$GUI_VERSION
fi

echo "INFO: Updating corresponding env file ..."

environment_file="environments/${CHEF_ENV}.json"

tmp=$(mktemp)
    jq --arg inp1 "$karaf_version" '.override_attributes["cumulocity-karaf"]["version"] = $inp1' ${environment_file} > "$tmp" && \
        mv "$tmp" ${environment_file} && echo "INFO: Karaf version updated in env file" && \
    jq --arg inp1 "$images_version" '.override_attributes["cumulocity-kubernetes"]["images-version"] = $inp1' ${environment_file} > "$tmp" && \
        mv "$tmp" ${environment_file} && echo "INFO: Kubernetes images version updated in env file" && \
    jq --arg inp1 "$ssagents_version" '.override_attributes["cumulocity-karaf"]["ssa-version"] = $inp1' ${environment_file} > "$tmp" && \
        mv "$tmp" ${environment_file} && echo "INFO: SSAgents version updated in env file" && \
    jq --arg inp1 "$gui_version" '.override_attributes["cumulocity-GUI"]["version"] = $inp1' ${environment_file} > "$tmp" && \
        mv "$tmp" ${environment_file} && echo "INFO: GUI version updated in env file" && \
    echo "INFO: All fields of Environment file updated successfully"  || { echo "ERROR: Failed to update environment file. Exiting ... "; exit 1; }

bundle exec knife environment from file $environment_file

if ! git diff-index --quiet HEAD --; then
    git add ${environment_file}
    git commit -m "Upgrading $environment with version ${version}.
    Details:
    - karaf: ${karaf_version}
    - agents: ${ssagents_version}
    - k8s images: ${images_version}
    - gui: ${gui_version}"
    git push && echo "INFO: Committed and pushed to remote" || { echo "ERROR: Unable to commit and push to remote git repository. Exiting ... "; exit 1; }
fi

echo "INFO: upgrading karaf"

nodes=$(NO_PROMPT_ORGANIZATION=true bundle exec knife search "chef_environment:$CHEF_ENV AND role:cumulocity-mn-active-core" -F json)
node_names=$(echo $nodes | jq '.rows |= sort_by(.name) | .rows[] | .name' | tr -d \")

ip_for_node() {
    ip=$(echo $nodes | jq ".rows | map(select(.name == \"$1\")) | .[].automatic.cloud_v2.public_ipv4" | tr -d \")
    echo $ip
}

run_ssh_command() {
    if [ -z "${SSH_KEY_PATH}"] ; then
        ADDITIONAL_OPTIONS=""
    else
        ADDITIONAL_OPTIONS="-i ${SSH_KEY_PATH} "
    fi 
    
    ssh -o "StrictHostKeyChecking no" $RUN_USER@$1 "$2"
}

echo "INFO: Upgrading karaf, gui and k8s images"

for node in $node_names; do
    ip=$(ip_for_node $node)

    echo "INFO: upgrading on node ${node}"
    bundle exec knife node run_list remove $node 'role[cumulocity-mn-active-core]' && \
        echo "INFO: Removed cumulocity-mn-active-core role from node" ||  echo "ERROR: Failed to remove role cumulocity-mn-active-core";

    run_ssh_command $ip 'sudo /usr/sbin/service cumulocity-core-karaf stop && echo "INFO: Stopping Karaf" && sleep 40;'

    retval=$(run_ssh_command $ip "ps -ef | grep -i karaf | grep -v grep | awk '{print \$2}'")

    if [ -z "$retval" ]; then
      echo "INFO: Karaf process has been stopped"
    else
      echo "WARNING: Failed to gracefully stop karaf in 40s. Killing karaf process"
      run_ssh_command $ip "ps -ef | grep -i karaf | grep -v grep | awk '{print \$2}' | sudo xargs kill -9"
    fi

    run_ssh_command $ip 'sudo yum clean metadata;'
    run_ssh_command $ip 'sudo chef-client;'

    bundle exec knife node run_list add $node 'role[cumulocity-mn-active-core]' && \
        echo "INFO: Added cumulocity-mn-active-core role to node" ||  echo "ERROR: Failed to add role cumulocity-mn-active-core";

    run_ssh_command $ip 'sudo chef-client;'
done

echo "INFO: karaf upgraded"

n=($node_names)
first_karaf_node=${n[0]}
first_karaf_ip=$(ip_for_node $first_karaf_node)

for node in ${node_names[@]}; do
    ip=$(ip_for_node $node)
    ip_list=("${node_names[@]}")

    attempt_counter=0
    max_attempts=60

    while [ ${attempt_counter} -lt ${max_attempts} ]; do
        status=$(run_ssh_command $ip "curl -s -o /dev/null -w '%{http_code}' http://localhost/tenant/health")

        if [[ "${status}" -eq 200 ]]; then
            item=($node)
            echo "INFO: Platform looks good on $node" && ip_list=("${ip_list[@]/$item}")
            break;
        else
            attempt_counter=$[attempt_counter + 1]

            echo "INFO: [${attempt_counter}/${max_attempts}] Platform is still not available on node " $node
            echo "INFO: Waiting for 10 seconds for Karaf to start before verifying ... " && sleep 10
        fi
    done

    if [ ${#ip_list[@]} -eq 0 ]; then
        echo "INFO: Platform UP on all nodes" && break
    else
        echo "WARNING: Some nodes are still unhealthy"
    fi
done

echo "INFO: upgrading agents node"

nodes=$(NO_PROMPT_ORGANIZATION=true bundle exec knife search "chef_environment:$CHEF_ENV AND role:cumulocity-ssagents" -F json)
node_names=$(echo $nodes | jq '.rows |= sort_by(.name) | .rows[] | .name' | tr -d \")

for node in ${node_names[@]}; do
    ip=$(ip_for_node $node)

    echo "INFO: upgrading on node ${node}"
    run_ssh_command $ip 'sudo chef-client;'
    echo "INFO: finished upgrading node ${node}"
done

echo "INFO: agents upgraded"

attempt_counter=0
max_attempts=120

echo "INFO: verifying microservices zip processing"

while [ ${attempt_counter} -lt ${max_attempts} ]; do
    count=$(run_ssh_command $first_karaf_ip "sudo ls -lah /webapps/2Images/ | grep zip$ | wc -l")

    if [[ ${count} -eq 0 ]]; then
        echo "INFO: All microservices has been processed by karaf"
        attempt_counter=${max_attempts}
        break
    else
        attempt_counter=$[attempt_counter + 1]

        echo "INFO: ${count} microservices left to be processed"
        echo "INFO: [${attempt_counter}/${max_attempts}] Sleeping 10 seconds to run check again"
        sleep 10
    fi
done

if [[ ${count} -gt 0 ]]; then
    echo 'Microservices not processed yet'
    left=$(run_ssh_command $first_karaf_ip "sudo ls /webapps/2Images/ | grep zip$")
    echo $left
fi

echo "INFO: Update completed"