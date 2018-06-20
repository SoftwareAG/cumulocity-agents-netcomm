#!/bin/bash

kubemasters=( \$KUBEMASTER1 \$KUBEMASTER2 \$KUBEMASTER3 )
kubeworkers=( \$KUBEWORKER1 \$KUBEWORKER2 \$KUBEWORKER3 )
envname='$ENVIRONMENT'

dryrun=false

f_color_pr(){
  case $1 in
    grn) COLOR='\e[1;32m' ;;
    ylw) COLOR='\e[1;33m' ;;
    red) COLOR='\e[1;31m' ;;
    cyn) COLOR='\e[1;36m' ;;
    wht) COLOR='\e[1m' ;;
  esac
  shift
  printf "$COLOR""$@\n"'\e[m'
}

f_exec(){
  f_color_pr wht "   $@"
  $dryrun || eval "$@"
}

while getopts "f:s:d" OPT ; do
  case $OPT in
    f) file="$OPTARG" ;;
    s) stepChoice="$OPTARG" ;;
    d) dryrun=true ;;
  esac
done

#if [[ -z ${file} || -z ${step} ]] ; then
if [[ -z ${stepChoice} ]] ; then
  f_color_pr red "ERROR: file or stepChoice variables are empty"
  f_color_pr wht "USAGE: $0 -f file -s (0-6|all) [ -d ]"
  exit 1
fi

if [[ -f "${file}" ]] ; then
  . "${file}"
else
  f_color_pr red "ERROR: file missing or not defined. Default names for examples will be provided"
  dryrun=true
fi

if [[ ${stepChoice} == "all" ]] ; then 
  eval steps[i++]={1..6}
else
  steps=${stepChoice}
fi
for step in ${steps[@]} ; do
f_color_pr grn "-- STEP $step --"
case $step in
0)
  f_color_pr cyn "# Removing roles and tags from every node"
  f_color_pr cyn "# undo step 6"
  for n in ${kubemasters[@]//${kubemasters[0]}} ; do
    f_exec "knife tag delete $n etcd k8s-master-add"
  done
  f_color_pr cyn "# undo step 5"
  f_exec "knife node run_list remove ${kubemasters[0]} 'recipe[cumulocity-kubernetes::certs_upload]'"
  for n in ${kubeworkers[@]} ; do
    f_exec "knife tag delete $n k8s-worker"
  done
  f_color_pr cyn "# undo step 4"
  f_exec "knife tag delete ${kubemasters[0]} k8s-master-init"
  f_color_pr cyn "# undo step 3"
  for n in ${kubemasters[@]} ; do
    f_exec "knife tag delete $n etcd-init"
  done
  f_color_pr cyn "# undo step 2"
  for n in ${kubemasters[@]} ${kubeworkers[@]} ; do
    f_exec "knife node run_list remove $n 'role[cumulocity-kubernetes]'"
  done
  for n in ${kubemasters[@]} ; do
    f_exec "knife tag delete $n etcd k8s-master"
  done
  f_exec "knife tag delete ${kubemasters[0]} k8s-master-main"
;;
1)
  f_color_pr cyn "# Expecting to have hosts in place"
  f_color_pr cyn "# Remember to create/update vaults before the next step"
;;
2)
  f_color_pr cyn "# apply environment and kubernetes role to masters and workers"
  for n in ${kubemasters[@]} ${kubeworkers[@]} ; do
    f_exec "knife node environment set $n ${envname}"
    f_exec "knife node run_list add $n 'role[cumulocity-base]' 'role[cumulocity-kubernetes]'"
  done

  f_color_pr cyn "# apply etcd and k8s-master tags to masters"
  for n in ${kubemasters[@]} ; do
    f_exec "knife tag create $n etcd k8s-master"
  done

  f_color_pr cyn "# apply k8s-master-main tag to first master"
  f_exec "knife tag create ${kubemasters[0]} k8s-master-main"
;;
3)
  f_color_pr cyn "# apply etcd-init tag to masters"
  for n in ${kubemasters[@]} ; do
    f_exec "knife tag create $n etcd-init"
  done
;;
4)
  f_color_pr cyn "# remove etcd-init tag to masters"
  for n in ${kubemasters[@]} ; do
    f_exec "knife tag delete $n etcd-init"
  done
  f_color_pr cyn "# apply k8s-master-init tag to first master"
  f_exec "knife tag create ${kubemasters[0]} k8s-master-init"
;;
5)
  f_color_pr cyn "# remove k8s-master-init tag to first master"
  f_exec "knife tag delete ${kubemasters[0]} k8s-master-init"
  f_color_pr cyn "# apply cert_upload recipe to first master"
  f_exec "knife node run_list add ${kubemasters[0]} 'recipe[cumulocity-kubernetes::certs_upload]'"

  f_color_pr cyn "# apply k8s-worker to workers"
  for n in ${kubeworkers[@]} ; do
    f_exec "knife tag create $n k8s-worker"
  done
;;
6)
  f_color_pr cyn "# apply k8s-master-add tag to all masters beside the first"
  for n in ${kubemasters[@]//${kubemasters[0]}} ; do
    f_exec "knife tag create $n etcd k8s-master-add"
  done
;;
*)
  f_color_pr red "ERROR: only steps 1 to 6 are supported"
;;
esac
done
f_color_pr grn "------------"
