#!/bin/bash

(
  docker stop etcd
  docker rm etcd
  systemctl stop docker
  
  kubeadm reset
  systemctl stop kubelet
  
  rm -rf /var/lib/etcd-cluster/ /var/lib/docker /etc/docker /etc/kube*
  
  yum remove 'kube*' 'docker*' -y
)
