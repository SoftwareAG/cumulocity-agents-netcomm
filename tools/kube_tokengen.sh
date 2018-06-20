#!/bin/bash

numPw=10

f_kubesecretgen(){

  local i
  for (( i=0 ; i<22 ; i++ )) ; do
    strings /dev/urandom | egrep -o -- "[a-z0-9]" | head -c1
  done | sed -r 's/^(.{6})/\1./g'
  echo

}

for (( i=0; i<${numPw}; i++ )) ; do
  f_kubesecretgen
done
