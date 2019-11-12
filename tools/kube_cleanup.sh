#!/bin/bash

(
  docker stop etcd
  docker rm etcd
  systemctl stop docker
  
  kubeadm reset
  systemctl stop kubelet
  
  yum remove 'kube*' 'docker*' 'cri-tools*' -y
  
  rm -rf /var/lib/etcd-cluster/ /var/lib/docker /etc/docker /etc/kube*

  for ip in $( ip -4 address show flannel.1 | awk '/[ ]*inet/{print $2}' ) ; do
    ip address del $ip dev flannel.1
  done

  echo ""
  echo "Please reboot machine now"
  echo ""

)
