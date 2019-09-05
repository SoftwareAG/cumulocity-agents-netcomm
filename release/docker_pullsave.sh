#!/bin/bash

info="
--  Cumulocity Registry:   2.7.2
--  Kubernetes:            1.8.11"

images=(
  docker.io/cumulocity/registry:2.7.2
  gcr.io/google_containers/etcd-amd64:3.0.17
  gcr.io/google_containers/k8s-dns-dnsmasq-nanny-amd64:1.14.5
  gcr.io/google_containers/k8s-dns-kube-dns-amd64:1.14.5
  gcr.io/google_containers/k8s-dns-sidecar-amd64:1.14.5
  gcr.io/google_containers/kube-apiserver-amd64:v1.8.11
  gcr.io/google_containers/kube-controller-manager-amd64:v1.8.11
  gcr.io/google_containers/kube-proxy-amd64:v1.8.11
  gcr.io/google_containers/kube-scheduler-amd64:v1.8.11
  gcr.io/google_containers/pause-amd64:3.0
  quay.io/coreos/flannel:v0.7.1-amd64
)

timestamphack=true
pullsaveimages=true

while getopts "ivtTpPd:" opt ; do
  case $opt in
    i) echo "Artifacts for these components will be downloaded: ${info}"
       echo
       echo "Images:"
       for i in ${images[@]} ; do echo "-- $i" ; done
       echo
       exit 0 ;;
    v) verbose=true ;;
    t) timestamphack=true ;;
    T) timestamphack=false ;;
    p) pullsaveimages=true ;;
    P) pullsaveimages=false ;;
    d) if date --date="$OPTARG" ; then
         date="$OPTARG"
       else
         echo ERROR: date must be in this format: YYYY-MM-DD HH:MM:SS
         exit
       fi ;;
  esac
done

if ! command -v docker &> /dev/null ; then
  printf "\e[1;31mFATAL: please, install docker\e[m\n"
  exit 1
fi

if $timestamphack ; then
  for cmd in bc xxd ; do
    if ! command -v $cmd &> /dev/null ; then
      printf "\e[1;31mFATAL: please, install $cmd\e[m\n"
      exit 1
    fi
  done
fi

bashsource="${BASH_SOURCE[0]}" 
thisscript="$( readlink -f $bashsource )"
thisdir="$( dirname "$thisscript" )"
savefolder="${thisdir}/DOCKERIMAGES"

f_debug(){
  if ${verbose:-false} ; then
    printf -- "$@\n" # 1>&2
    return 0
  else
    return 1
  fi
}

f_checkLinks(){
image="$1"

matchCount=1
for firstMatch in $( grep -P -aob '[0-9a-f]{64}/[a-zA-Z0-9._]*\x00+([0-9]{7}\x00){3}([0-9]{11}\x00){2}[0-9]{1,8}\x00[ ]*2' "${image}" | cut -d' ' -f1 ) ; do
  f_debug "\e[1mMATCH #$(( matchCount++ ))\e[m"
  mainDecOffset="$( cut -d: -f1 <<< "$firstMatch" )"
  mainHexOffset="$( bc <<< "obase=16; $mainDecOffset" )"
  innerDir="$( sed -r 's/^[0-9]+:([^/]+).*/\1/g' <<< "$firstMatch" )"
  f_debug "\e[1mmainDecOffset: $mainDecOffset\e[m"
  f_debug "\e[1mmainHexOffset: $mainHexOffset\e[m"
  f_debug "\e[1minnerDir: $innerDir\e[m"
  f_debug "\e[1m-----\e[m"
  for secondMatch in $( grep -P -aob "${innerDir}"'/[a-zA-Z0-9._]*\x00+([0-9]{7}\x00){3}([0-9]{11}\x00){2}[0-9]{1,8}\x00[ ]*[0-9]' "${image}" | cut -d' ' -f1 ) ; do
    decOffset="$( cut -d: -f1 <<< "$secondMatch" )"
    hexOffset="$( bc <<< "obase=16; $decOffset" )"
    f_debug "-- decOffset: $decOffset"
    f_debug "-- hexOffset: $hexOffset"
    offsetsArray+=( ${hexOffset,,} )
    f_debug "-----"
  done
  f_debug "\e[1;36mOffsets: ${offsetsArray[*]}\e[m"
  f_debug "----------"
done

if [[ ${#offsetsArray[@]} -eq 0 ]] ; then
  return 1
#else
#  echo ${offsetsArray[@]}
#  return 0
fi

}


f_replaceByte(){
  f_debug "dd if=<( printf '$2' ) of="$file" ibs=$3 obs=1 seek=$1 count=1 conv=notrunc\n"
  sudo bash -c "dd \$( $verbose || echo status=none ) if=<( printf \"$2\" ) of=\"$file\" ibs=$3 obs=1 seek=$1 count=1 conv=notrunc"
}

f_extractPart1(){
  part1="$( dd if="$file" bs=1 count=136 skip="$1" 2>/dev/null | xxd -ps -c512 )"
}

f_extractPart2(){
  part2="$( dd if="$file" bs=1 count=356 skip="$(( $1 + 156 ))" 2>/dev/null | xxd -ps -c512 )"
}

f_hexSum(){
  local VALUE="$( sed -r 's/../& + /g' <<< "${1^^}" )0"
  bc <<< "ibase=16; obase=10; $VALUE"
}

if $pullsaveimages ; then

  if ! ( [[ -d "$savefolder" ]] || mkdir -p "$savefolder" ) ; then
    echo "ERROR: impossible to create folder $savefolder"
    exit 2
  fi

  sudo chmod go+rx "${savefolder}"

  for image in "${images[@]}" ; do
    if sudo docker pull "$image" ; then
      tarname="$( sed -r -e 's#/#@#g' -e 's/.*/&.tar/g' <<< "$image" )"
      sudo docker save -o "$savefolder/$tarname" "$image"
      sudo chmod go+r "$savefolder/$tarname"
    else
      printf "\e[1;31mERROR: could not fetch $image\e[m\n"
      ((errcount++))
    fi

    if $timestamphack && f_checkLinks "$savefolder/$tarname" ; then

      echo "Timestamp of $savefolder/$tarname will be hacked"
      verbose=${verbose:-false}

      file="$savefolder/$tarname"
      date="${date:-$( TZ=UTC date --date='1970-01-01 00:00:00' )}"

      f_debug "Choosen timestamp: $date\n"

      hexts="$( printf '%011d' "$( bc <<< "ibase=10; obase=8; $(date --date="$date" +%s)")" | tr -d '\n' | xxd -ps )"
      f_debug hextimestamp: $hexts && f_hexSum "$hexts" && echo

      for offset in "${offsetsArray[@]}" ; do
        decoffset="$( bc <<< "ibase=16; obase=A; ${offset^^}" )"
        f_debug "\e[1moffset: $offset\e[m"
        f_debug "\e[1m--------------------------------------------------\e[m"
        f_extractPart1 "$decoffset"
        f_debug "Data before timestamp:"
        f_debug "\e[1;35m$part1\e[m"
        f_debug "Checksum part1: \e[1;35m$( f_hexSum "$part1" )\e[m"
        f_debug "\e[1m--------------------------------------------------\e[m"
        f_extractPart2 "$decoffset"
        f_debug "Data after header checksum:"
        f_debug "\e[1;34m$part2\e[m"
        f_debug "Checksum part2: \e[1;34m$( f_hexSum "$part2" )\e[m"
        f_debug "\e[1m--------------------------------------------------\e[m"
        hextotal="$( f_hexSum "${part1}${hexts}002020202020202020${part2}" )"
        f_debug "Header pre-checksum calculation:"
        f_debug "\e[1;35m${part1}\e[1;32m${hexts}00\e[1;31m2020202020202020\e[1;34m${part2}\e[m"
        f_debug "Hex   checksum: \e[1;36m$hextotal\e[m"
        octtotal="$( bc <<< "ibase=16; obase=8; $hextotal" )"
        f_debug "Octal checksum: \e[1;36m$octtotal\e[m"
        f_debug "\e[1m--------------------------------------------------\e[m"
        octchecksum="$( printf '%06d\x00 ' "$octtotal" | xxd -ps )"
        f_debug "Hex string of octal checksum to insert:  \e[1;31m$octchecksum\e[m"
        replace="$( sed -r -e 's/0a$//g' -e 's/(..)/\\x\1/g' <<< "${hexts}00${octchecksum}" )"
        f_debug "Printf formatted string for replacement: \e[1;36m$replace\e[m"
        bytelength="$( printf "$replace" | wc -c )"
        f_debug "Byte replacement string length: \e[1;36m$bytelength\e[m"
        f_debug "\e[1m--------------------------------------------------\e[m"
        f_replaceByte "$(( $decoffset + 136 ))" "$replace" $bytelength
        f_debug "\e[1m##################################################\e[m"
      done
      unset offsetsArray

      if [[ ${errcount:-0} -gt 0 ]] ; then
        printf "\e[1;31m${errcount} ERROR$( [[ $errcount -gt 1 ]] && echo 0 ) occurred...\e[m\n"
        exit 255
      fi

    fi

  done

fi

