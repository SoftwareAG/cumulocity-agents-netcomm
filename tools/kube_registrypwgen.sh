#!/bin/bash

while getopts "e:p:P:m" opt ; do
  case "$opt" in
    e) environment="${OPTARG}" ;;
    p) password="${OPTARG}" ;;
    P) extPort="${OPTARG}" ;;
    m) useMongoDriver=true ;;
  esac
done

if [[ -z ${environment} ]] ; then
  echo "ERROR: you must specify environment name and password to use"
  echo "USAGE: $0 -e envname -p password"
  echo "if you don't provide a password, a random one will be generated."
  exit
fi

special_chars=true
lowercase_only=false

f_pwgen(){
  local i pw l=${1:-4} n=${2:-2} s=${3:-1}

  local con="bcdfghjklmnpqrstvwz"
  local vow="aeiouy"
  local spl="#@!?+-"

  for (( i=0 ; i<$l ; i++ )) ; do
    pw+=$(strings /dev/urandom | egrep -oi -- "[$con]" | head -c1)
    pw+=$(strings /dev/urandom | egrep -oi -- "[$vow]" | head -c1)
  done

  for (( i=0 ; i<$n ; i++ )) ; do
    pw+=$(tail -c2 <<< $RANDOM)
  done

  if ${special_chars} ; then
  for (( i=0 ; i<$s ; i++ )) ; do
    length="$(( $l * 2 + $n ))" 
    inc=0
    while [[ ${mid:=100} -gt $(( ${length} + ${inc} )) ]] ; do
      mid=$(tail -c2 <<< $RANDOM)
    done
    spc=$(strings /dev/urandom | egrep -oi -- "[$spl]" | head -c1)
    pw="$( sed -r 's/^(.{'${mid}'})/\1'${spc}'/g' <<< "${pw}" )"
    unset mid
    ((inc++))
  done
  fi  

  if "${lowercase_only}" ; then
    pw="${pw,,}"
  fi  
  echo "${pw}"
}

if [[ -z ${password} ]] ; then
  password="$( f_pwgen )"
  printf "# random password generated: $password\n\n"
fi

base64A="$( tr -d '\n' <<< admin:${password} | base64 -w0 )"

base64B="$( cat << EOF | tr -d '\n' | base64 -w0
{"kube-registry-persistent-secure.${environment}.svc.cluster.local:5000":{"username":"admin","password":"${password}","email":"admin@c8y.io","auth":"${base64A}"}}
EOF
)"

dockercreds="$( htpasswd -Bbn admin "${password}" 2>/dev/null )"

case $? in
    0) :;;
  127) printf "ERROR: htpasswd not installed\nPlease, install httpd-tools-2.4\n\n" ;;
    2) printf "ERROR: htpasswd version must be 2.4+\nPlease, install httpd-tools-2.4\n\n" ;;
    *) echo "ERROR: unknown error with htpasswd..." ;;
esac

#echo ${base64B}

cat << EOF
{
    "extPort":"${extPort:-30002}",
    "useMongoDriver":${useMongoDriver:-false},
    "dockercreds":"${dockercreds}",
    "dockersecrt":"${base64B}"
}
EOF

