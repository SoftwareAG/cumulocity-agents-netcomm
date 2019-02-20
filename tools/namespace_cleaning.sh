#!/bin/bash 

devx_name=$1

devx_list=("dev-a" "dev-b" "dev-c" "dev-e" "dev-v" "smoke")

function containsElement(){
  local e match="$1"
  shift
  for e; do [[ "$e" == "$match" ]] && return 0; done
  return 1
}

function get_pods() {
 result=`kubectl -n cumulocity-development-${devx_name} get pods --no-headers=true 2>/dev/null | wc -l`
 echo ${result}
}

containsElement "${devx_name}" "${devx_list[@]}"
res=$?

if (( $res > 0 )); then
  echo "Namespace not in allowed list"
  exit 1
else
  kubectl delete namespace cumulocity-development-${devx_name}
  find /etc/kubernetes/ -iname "*${devx_name}*" -exec rm {} \;
  ok=$(get_pods)
  while (( $ok > 0 )); do
    sleep 10s
    ok=$(get_pods)
  done
  chef-client
fi
