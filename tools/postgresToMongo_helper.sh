#!/bin/bash

host="127.0.0.1"
port="8111"
user="admin"
pass='$PASSWORD'
tfatoken=

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
  #f_color_pr wht "   $cmd"
  echo "   $cmd"
  ${dryrun:-false} || eval "$cmd"
}

f_list_tenants(){
  cmd=$( cat << EOF
curl -s -X GET http://${host}${port:+:$port}/tenant/tenants?pageSize=2000 -u "management/${user}:${pass}" ${tfaopt}-H 'Cache-Control: no-cache' -H 'Content-Type: application/json' | jq '.tenants[].id' 2>/dev/null | tr -d \"
EOF
  ) ; eval "$cmd"
}

while getopts "f:s:d" OPT ; do
  case $OPT in
    f) file="$OPTARG" ;;
    s) stepChoice="$OPTARG" ;;
    d) dryrun=true ;;
  esac
done

if [[ -z ${stepChoice} ]] ; then
  f_color_pr red "ERROR: file or stepChoice variables are empty"
  echo
  f_color_pr wht "USAGE: $0 -f configfile -s (0-6|all|C|L) [ -d ]"
  echo
  f_color_pr wht "Step all prints a brief description of all steps"
  f_color_pr wht "Step 0 is to revert everything to 'POSTGRES_READ_WRITE'"
  f_color_pr wht "Step C is for checking current status"
  f_color_pr wht "Step L produces a list of tenants (including management)"
  echo
  f_color_pr wht "Create a config file with this syntax:"
  cat << EOF
host="127.0.0.1"
port="8111"
user="admin"
pass='PASSWORD'
EOF
  exit 1
fi

if [[ -f "${file}" ]] ; then
  . "${file}"
  tfaopt="${tfatoken:+-H 'tfatoken: $tfatoken' }"
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
L)
  f_color_pr cyn "# list tenants"
  f_list_tenants
;;
C)
  f_color_pr cyn "# check management tenant"
  cmd=$( cat << EOF
curl -s -X GET http://${host}${port:+:$port}/tenant/options/migration.tomongo/id_mapping.state -u 'management/${user}:${pass}' ${tfaopt}-H 'Cache-Control: no-cache' -H 'Content-Type: application/json' | python -m json.tool
EOF
  ) ; f_exec
  f_color_pr cyn "# check other tenants"
  for t in $( f_list_tenants | egrep -v '^management$' ) ; do
  echo " -- $t"
  cmd=$( cat << EOF
curl -s -X GET http://${host}${port:+:$port}/tenant/options/migration.tomongo/id_mapping.state -u '${t}/${user}\$:${pass}' ${tfaopt}-H 'Cache-Control: no-cache' -H 'Content-Type: application/json' | python -m json.tool
EOF
  ) ; f_exec
  done
;;
0)
  f_color_pr cyn "# REVERT: "
  f_color_pr cyn "# set everything to postgres_read_write"
  cmd=$( cat << EOF
curl -v -X PUT http://${host}${port:+:$port}/tenant/migration/options/each -u "management/${user}:${pass}" ${tfaopt}-H 'Cache-Control: no-cache' -H 'Content-Type: application/json' -d '{ "value": "postgres_read_write", "category": "migration.tomongo", "key": "*.state"}'
EOF
  ) ; f_exec
;;
1)
  f_color_pr cyn "# set management to postgres_read_write_mongo_write"
  cmd=$( cat << EOF
curl -v -X PUT http://${host}${port:+:$port}/tenant/migration/options -u "management/${user}:${pass}" ${tfaopt}-H 'Cache-Control: no-cache' -H 'Content-Type: application/json' -d '{ "value": "postgres_read_write_mongo_write", "category": "migration.tomongo", "key": "*.state"}'
EOF
  ) ; f_exec
;;
2)
  f_color_pr cyn "# set other tenants to postgres_read_write_mongo_write"
  cmd=$( cat << EOF
curl -v -X PUT http://${host}${port:+:$port}/tenant/migration/options/each -u "management/${user}:${pass}" ${tfaopt}-H 'Cache-Control: no-cache' -H 'Content-Type: application/json' -d '{ "value": "postgres_read_write_mongo_write", "category": "migration.tomongo", "key": "*.state"}'
EOF
  ) ; f_exec
;;
3)
  f_color_pr cyn "# set other tenants to mongo_read_write_postgres_write"
  for t in $( f_list_tenants | egrep -v '^management$' ) ; do
  echo " -- $t"
  cmd=$( cat << EOF
curl -v -X PUT http://${host}${port:+:$port}/tenant/migration/options -u '${t}/${user}\$:${pass}' ${tfaopt}-H 'Cache-Control: no-cache' -H 'Content-Type: application/json' -d '{ "value": "mongo_read_write_postgres_write", "category": "migration.tomongo", "key": "*.state"}'
EOF
  ) ; f_exec
  done
;;
3a)
  f_color_pr cyn "# set other tenants to mongo_read_write_postgres_write"
  cmd=$( cat << EOF
curl -v -X PUT http://${host}${port:+:$port}/tenant/migration/options/each -u "management/${user}:${pass}" ${tfaopt}-H 'Cache-Control: no-cache' -H 'Content-Type: application/json' -d '{ "value": "mongo_read_write_postgres_write", "category": "migration.tomongo", "key": "*.state"}'
EOF
  ) ; f_exec
;;
4)
  f_color_pr cyn "# set management to mongo_read_write_postgres_write"
  cmd=$( cat << EOF
curl -v -X PUT http://${host}${port:+:$port}/tenant/migration/options -u "management/${user}:${pass}" ${tfaopt}-H 'Cache-Control: no-cache' -H 'Content-Type: application/json' -d '{ "value": "mongo_read_write_postgres_write", "category": "migration.tomongo", "key": "*.state"}'
EOF
  ) ; f_exec
;;
5)
  f_color_pr cyn "# set other tenants to mongo_read_write"
  for t in $( f_list_tenants | egrep -v '^management$' ) ; do
  echo " -- $t"
  cmd=$( cat << EOF
curl -v -X PUT http://${host}${port:+:$port}/tenant/migration/options -u '${t}/${user}\$:${pass}' ${tfaopt}-H 'Cache-Control: no-cache' -H 'Content-Type: application/json' -d '{ "value": "mongo_read_write", "category": "migration.tomongo", "key": "*.state"}'
EOF
  ) ; f_exec
  done
;;
5a)
  f_color_pr cyn "# set other tenants to mongo_read_write"
  cmd=$( cat << EOF
curl -v -X PUT http://${host}${port:+:$port}/tenant/migration/options/each -u "management/${user}:${pass}" ${tfaopt}-H 'Cache-Control: no-cache' -H 'Content-Type: application/json' -d '{ "value": "mongo_read_write", "category": "migration.tomongo", "key": "*.state"}'
EOF
  ) ; f_exec
;;
6)
  f_color_pr cyn "# set management to mongo_read_write"
  cmd=$( cat << EOF
curl -v -X PUT http://${host}${port:+:$port}/tenant/migration/options -u "management/${user}:${pass}" ${tfaopt}-H 'Cache-Control: no-cache' -H 'Content-Type: application/json' -d '{ "value": "mongo_read_write", "category": "migration.tomongo", "key": "*.state"}'
EOF
  ) ; f_exec
;;
*)
  f_color_pr red "ERROR: only steps 1 to 6 are supported"
;;
esac
done
f_color_pr grn "------------"
