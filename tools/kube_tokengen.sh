#!/bin/bash

numPw=10

f_kubesecretgen(){

  local i
  for (( i=0 ; i<22 ; i++ )) ; do
    strings /dev/urandom | egrep -io -- "[a-z0-9]" | head -c1
  done | sed -r -e 's/./\L&/g' -e 's/^(.{6})/\1./g'
  echo

}

for (( i=0; i<${numPw}; i++ )) ; do
  f_kubesecretgen
done
