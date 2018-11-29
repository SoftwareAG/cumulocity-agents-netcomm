#!/bin/bash

(
  docker stop etcd
  docker rm etcd
  systemctl stop docker
  
  kubeadm reset
  systemctl stop kubelet
  
  rm -rf /var/lib/etcd-cluster/ /var/lib/docker /etc/docker /etc/kube*
  
  yum remove 'kube*' 'docker*' -y

  for ip in $( ip -4 address show flannel.1 | awk '/[ ]*inet/{print $2}' ) ; do
    ip address del $ip dev flannel.1
  done
)
