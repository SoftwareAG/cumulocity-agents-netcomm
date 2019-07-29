#!/bin/bash

export thisscript="$( readlink -f ${BASH_SOURCE[0]} )"
export thisdir="$( dirname ${thisscript} )"
(
	cd "$thisdir"
)
env_file="$( dirname ${thisscript} )/environments/cumulocity-single-node.json"
env_name="cumulocity-single-node"
node=$(hostname -f)



run_chef_client()
{
        echo "Running chef client...."
        chef-client -z
}

#Chef commmands to install the cumulocity with microservice support(kubernetes infrastructure) 

#Initialize chef local mode
run_chef_client

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

#Add master node: Enables scheduling on master node, updates /etc/cumulocity/k8s.conf & /etc/resolv.conf files  and restarts kubelet
knife tag create $node k8s-master-add  -z  && echo "INFO: Added tags k8s-master-add  successfully" || { echo "ERROR: failed to add  tags k8s-master-add . Exiting..... "; exit 1; }
run_chef_client


