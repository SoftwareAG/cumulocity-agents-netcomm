#!/usr/bin/env bash
export thisscript="$( readlink -f ${BASH_SOURCE[0]} )"
export thisdir="$( dirname ${thisscript} )"
(
	cd "$thisdir"
)
env_file="$( dirname ${thisscript} )/environments/cumulocity-single-node.json"
env_name="cumulocity-single-node"
node=$(hostname -f)

ENABLE_MICROSERVICE="false"

while [[ "$#" -gt 0 ]]; do case $1 in
  -m|--enable-microservice) ENABLE_MICROSERVICE="true"; shift;;
  *) echo "Unknown parameter passed: $1"; exit 1;;
esac; shift; done

run_chef_client()
{
        echo "Running chef client...."
        chef-client -z && echo "INFO: Successfully executed chef-client." || { echo "ERROR: failed to execute chef-client. Exiting... "; exit 1; }
}

#Chef commmands to install the cumulocity with microservice support(kubernetes infrastructure)

#Initialize chef local mode
run_chef_client

if [[ "$ENABLE_MICROSERVICE" == "false" ]]; then
    echo "Running without microservice feature disabled"
    sed -i 's/,feature-microservice-hosting//g' ${env_file}
fi

#Sets up environment for chef-client
knife environment from file ${env_file} -z && echo "INFO: Successfully uploaded env file " || { echo "ERROR: failed to setup chef env. Exiting... "; exit 1; }
knife node environment set $node $env_name -z  && echo "INFO: Successfully setup chef env for the node" || { echo "ERROR: failed to setup chef env. Exiting... "; exit 1; }

#Installs cumulocity software
knife node run_list add $node 'role[cumulocity-dev-singlenode]' -z  && echo "INFO: Added role[cumulocity-dev-singlenode] successfully" || { echo "ERROR: failed to add role[cumulocity-dev-singlenode]. Exiting..... "; exit 1; }

run_chef_client

knife node run_list add $node 'role[cumulocity-common-cores]' -z  && echo "INFO: Added role[cumulocity-common-cores] successfully" || { echo "ERROR: failed to add role[cumulocity-common-cores]. Exiting..... "; exit 1; }
run_chef_client

knife node run_list add $node 'role[cumulocity-mn-active-core]' -z  && echo "INFO: Added role[cumulocity-mn-active-core] successfully" || { echo "ERROR: failed to add role[cumulocity-mn-active-core]. Exiting..... "; exit 1; }
run_chef_client

keytool -noprompt -import -alias registry -keystore /etc/pki/java/cacerts -file /etc/nginx/certs/domain.com.cert -storepass changeit && echo "INFO: /etc/nginx/certs/domain.com.cert added successfully in cacerts" || { echo "ERROR: failed to add /etc/nginx/certs/domain.com.cert. Exiting..... "; exit 1 ;}

if [[ "$ENABLE_MICROSERVICE" == "true" ]]; then
    echo "Running with microservice feature enabled"
    sed -i '/microservice\.provider/d' ${env_file}
    knife environment from file ${env_file} -z && echo "INFO: Successfully uploaded env file " || { echo "ERROR: failed to setup chef env. Exiting... "; exit 1; }

    #Installs kubernetes and docker
    knife node run_list add $node 'role[cumulocity-kubernetes]' -z  && echo "INFO: Added role[cumulocity-kubernetes] successfully" || { echo "ERROR: failed to add role[cumulocity-kubernetes]. Exiting..... "; exit 1; }
    run_chef_client
    knife tag create $node etcd k8s-master k8s-master-main -z  && echo "INFO: Added tags etcd k8s-master k8s-master-main successfully" || { echo "ERROR: failed to add tags etcd k8s-master k8s-master-main. Exiting..... "; exit 1; }
    run_chef_client

    #Initialize etcd
    knife tag create $node etcd-init -z  && echo "INFO: Added tags etcd-init successfully" || { echo "ERROR: failed to add tags etcd-init. Exiting..... "; exit 1; }
    run_chef_client
    knife tag delete $node etcd-init -z  && echo "INFO: Deleted tags etcd-init successfully" || { echo "ERROR: failed to delete tags etcd-init. Exiting..... "; exit 1; }

    #Configures kubeadm
    knife tag create $node k8s-master-init -z  && echo "INFO: Added tags k8s-master-init successfully" || { echo "ERROR: failed to add tags k8s-master-init. Exiting..... "; exit 1; }
    run_chef_client

    #Setting up kubernetes compoenents: kube-flannel, kube-dns, registry and other kubernetes components
    knife tag delete $node k8s-master-init -z  && echo "INFO: Deleted tags k8s-master-init successfully" || { echo "ERROR: failed to delete tags k8s-master-init. Exiting..... "; exit 1; }
    knife node run_list add $node 'recipe[cumulocity-kubernetes::certs_upload]' -z -z  && echo "INFO: Updated runlist with recipe[cumulocity-kubernetes::certs_upload] successfully" || { echo "ERROR: failed to update runlist with recipe[cumulocity-kubernetes::certs_upload]. Exiting..... "; exit 1; }
    run_chef_client

    service cumulocity-core-karaf stop && echo "INFO: Successfully stopped karaf" || { echo "ERROR: failed to stop karaf. Exiting..... "; exit 1; }

    #Add master node: Enables scheduling on master node, updates /etc/cumulocity/k8s.conf & /etc/resolv.conf files  and restarts kubelet
    knife tag create $node k8s-master-add  -z  && echo "INFO: Added tags k8s-master-add  successfully" || { echo "ERROR: failed to add  tags k8s-master-add . Exiting..... "; exit 1; }
    run_chef_client
fi