#!/bin/bash

#Set username if local and server user differs
if [ -z "$RUN_USER" ]; then
  RUN_USER=$(whoami)
fi

staging_env=$1
target_version=$2
search_key=""

#Usage message
if [ $# != 2 ]; then
  echo "Usage: $0 <staging_env> <target_version>"
  exit 1
fi

#Getting information about core nodes
function get_node_info()
{
  echo "INFO: Gathering information about $staging_env core nodes ..."
  node_list=$(knife node list | grep -i $search_key | tee /dev/tty)
  if [ -z "$node_list" ]; then
    echo "ERROR: No Core Nodes for $staging_env could be found. Exiting ..."; exit 1;
  else
    echo "INFO: Proceeding with above Nodelist ... "
  fi
  ip_list=()
  for i in $node_list; do
    ip=$(knife node show $i | grep -w "IP:" | cut -d ":" -f2 | awk '{$1=$1};1')
    ip_list+=("$ip")
  done
  echo "INFO: Corresponding IP list: " ${ip_list[@]}
}

#Updating chef env file and pushing to chef server
function update_env_file()
{
  git pull && echo "INFO: Pulled latest changes from remote ..." || { echo "ERROR: Failed to pull latest changes from remote. Exiting ... "; exit 1; }
  echo "INFO: Updating corresponding env file ..."
  tmp=$(mktemp)
  { jq --arg inp1 "$target_version-1" '.override_attributes["cumulocity-karaf"]["version"] = $inp1' ${env_file} > "$tmp" && mv "$tmp" ${env_file} && echo "INFO: Karaf version updated in env file" && \
  jq --arg inp1 "$target_version" '.override_attributes["cumulocity-kubernetes"]["images-version"] = $inp1' ${env_file} > "$tmp" && mv "$tmp" ${env_file} && echo "INFO: Kubernetes images version updated in env file" && \
  jq --arg inp1 "$target_version-1" '.override_attributes["cumulocity-karaf"]["ssa-version"] = $inp1' ${env_file} > "$tmp" && mv "$tmp" ${env_file} && echo "INFO: SSAgents version updated in env file" && \
  jq --arg inp1 "$target_version" '.override_attributes["cumulocity-GUI"]["version"] = $inp1' ${env_file} > "$tmp" && mv "$tmp" ${env_file} && echo "INFO: GUI version updated in env file" && \
  echo "INFO: All fields of Environment file updated successfully" } || \ { echo "ERROR: Failed to update environment file. Exiting ... "; exit 1; }
  knife environment from file ${env_file} && echo "INFO: Pushed changes to Chef server" || { echo "ERROR: Unable to push changes to Chef server. Exiting ... "; exit 1; }
  git add ${env_file} && git commit -m "Upgrading $staging_env to version $target_version" && git push && echo "INFO: Committed and pushed to remote" || \
  { echo "ERROR: Unable to commit and push to remote git repository. Exiting ... "; exit 1; }
}

#Comparing installed and target versions
function compare_version()
{
  count=1
  for i in ${ip_list[@]}; do
    installed_version=$(ssh -o "StrictHostKeyChecking no" $RUN_USER@$i 'rpm -qa | grep karaf' | grep -Po '(?<=cumulocity-core-karaf-)[^-]+')
    function convert_to_integer {
    echo "$@" | awk -F "." '{ printf("%03d%03d%03d\n", $1,$2,$3); }';
    }
    if [ "$(convert_to_integer $target_version)" -gt "$(convert_to_integer $installed_version)" ]; then
       echo "INFO: Target version i.e. $target_version is greater than Installed version i.e. $installed_version for $staging_env Core_Node$count. Upgrade to happen ..."
    elif [ "$(convert_to_integer $target_version)" -lt "$(convert_to_integer $installed_version)" ]; then
       echo "INFO: Target version i.e. $target_version is lesser than Installed version i.e. $installed_version for $staging_env Core_Node$count. It's already on higher version. Exiting gracefully ..."; exit 0;
    else
       echo "INFO: Target version i.e. $target_version is equal to Installed version i.e. $installed_version for $staging_env Core_Node$count. Target version is already installed. Exiting gracefully..." exit 0;
    fi
    count=$((count+1))
  done
}

#Upgrading karaf
function upgrade()
{
  count=0
  for i in $node_list; do
    knife node run_list remove $i 'role[cumulocity-mn-active-core]' && echo "INFO: Removing role cumulocity-mn-active-core" || \
    { echo "ERROR: Removal of role cumulocity-mn-active-core Failed"; exit 1; }
    ssh -o "StrictHostKeyChecking no" $RUN_USER@${ip_list[$count]} 'sudo /usr/sbin/service cumulocity-core-karaf stop && echo "INFO: Stopping Karaf" && sleep 40'
    retval=$(ssh -o "StrictHostKeyChecking no" $RUN_USER@${ip_list[$count]} "ps -ef | grep -i karaf | grep -v grep | awk '{print \$2}'")
    if [ -z "$retval" ]; then
      echo "INFO: Karaf stopped"
    else
      echo "WARNING: Karaf still running. Applying force kill ..."
      ssh -o "StrictHostKeyChecking no" $RUN_USER@${ip_list[$count]} "ps -ef | grep -i karaf | grep -v grep | awk '{print \$2}' | sudo xargs kill -9"
    fi
    ssh -o "StrictHostKeyChecking no" $RUN_USER@${ip_list[$count]} 'sudo chef-client; sudo /usr/sbin/service cumulocity-core-karaf start'
    count=$((count + 1))
    knife node run_list add $i 'role[cumulocity-mn-active-core]' && echo "INFO: Adding back role cumulocity-mn-active-core" || \
    { echo "ERROR: Adding back role cumulocity-mn-active-core Failed"; exit 1; }
  done
}

#Validating the upgrade
function validate()
{
  count=1
  for i in ${ip_list[@]}; do
    installed_version=$(ssh -o "StrictHostKeyChecking no" $RUN_USER@$i 'rpm -qa | grep karaf' | grep -Po '(?<=cumulocity-core-karaf-)[^-]+')
    if [ "$installed_version" == "$target_version" ]; then
      echo "INFO: Backend upgrade of core successful for $staging_env Core_Node$count"
    else
      echo "ERROR: Backend upgrade of core Failed for $staging_env Core_Node$count"
    fi
    count=$((count+1))
  done
}

#Check platform status
function check_platform()
{
	attempt_counter=0
	max_attempts=5

	for ip in ${ip_list[@]}; do
		status=$(ssh -o "StrictHostKeyChecking no" $RUN_USER@$ip 'curl -s -o /dev/null -w '%{http_code}' http://localhost/tenant/health')
			if [[ "${status}" -eq 200 ]]; then
        item=($ip)
				echo "INFO: Platform health looks good on $ip" && ip_list=( "${ip_list[@]/$item}" ) && continue
			else
				echo "WARNING: Platform is unhealthy on $ip"
        until [ ${attempt_counter} -eq ${max_attempts} ]; do
          if [[ "${status}" -eq 200 ]]; then
            item=($ip)
            echo "INFO: Platform looks good on $ip" && ip_list=( "${ip_list[@]/$item}" )
          else
            echo "INFO: Waiting for 2 Minutes for Karaf to start before Verifying ... " && sleep 120
            echo "Attempt # $attempt_counter"
            echo "Platform still having issues on " $ip
            attempt_counter=$(($attempt_counter+1))
          fi
        done
			fi
			if [ ${#ip_list[@]} -eq 0 ]; then
				echo "INFO: Platform UP on all nodes" && break
			else
				echo "INFO: Some nodes are still unhealthy"
			fi
	done
}

#Exporting env and needed stuff
if [ $staging_env == "staging" ]; then
  export ORGNAME=cumulocity-stagings
  export env_file=./environments/cumulocity-basic-staging7-nonprod.json
  search_key="Staging_Core"
elif [ $staging_env == "staging7" ]; then
  export ORGNAME=cumulocity-devel
  export env_file=./environments/cumulocity-staging7-nonprod.json
  search_key="Staging7Core"
elif [ $staging_env == "staging007" ]; then
  export ORGNAME=cumulocity-stagings
  export env_file=./environments/cumulocity-staging007-nonprod.json
  search_key="Staging007Core"
elif [ $staging_env == "staging-latest" ]; then
  export ORGNAME=cumulocity-stagings
  export env_file=./environments/cumulocity-staging-latest-nonprod.json
  search_key="cumulocity-staging-latest-nonprod_core"
elif [ $staging_env == "staging-develop" ]; then
  # new staging-develop env
  export ORGNAME=cumulocity-stagings
  export env_file=./environments/cumulocity-staging-develop-nonprod.json 
  search_key="cumulocity-staging-develop-nonprod_core"
else
  echo "ERROR: There is no such environment as $staging_env. Available environments: staging, staging7, staging007, staging-latest. Try again !"; exit 1;
fi

# Main()

get_node_info
compare_version
update_env_file
upgrade
validate
check_platform
