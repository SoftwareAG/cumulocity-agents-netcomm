#!/usr/bin/env bash

keywords="JH|KEY|USER|PORT|TFA|OPT_[A-Z]|PASSWD"

_jh_complete(){
  local cur prev jhcmd
  local keywords="JH|KEY|USER|PORT|TFA|OPT_[A-Z]|PASSWD"
  local sshenv
  local thisscript configfile1 configfile2
  local envlist hostlist cleanhostlist
  COMPREPLY=()
  cur=${COMP_WORDS[COMP_CWORD]}
  prev=${COMP_WORDS[COMP_CWORD-1]}
  jhcmd=${COMP_WORDS[COMP_CWORD-2]}

  if [[ ${COMP_CWORD} == 1 ]] ; then
    thisscript=$(readlink -f $( which ${prev} ))
    configfile1="$( dirname ${thisscript} )/$( basename ${thisscript} sh)conf"
    configfile2="${HOME}/.jh.conf"
    for configfile in "${configfile1}" "${configfile2}" ; do
      if [[ -f "$configfile" ]] ; then
        for e in $( sed -n -r 's/([^=]+)=\(/\1/gp' "${configfile}" ) ; do
          envlist+="$e "
          _jh_f_reg "$e"
        done
        . "${configfile}"
      fi
    done
    COMPREPLY=( $(compgen -W "${envlist}" -- ${cur}) )
  elif [[ ${COMP_CWORD} == 2 ]] && ! [[ ${jhcmd} =~ ^jhenv.*$ ]] ; then
    sshenv="$prev"
    hostlist="$( eval echo '${!'${sshenv}'[@]}' | sed -r -e "s/(${keywords})[ ]?//g" -e 's/ /\n/g' | sort )"
    for h in ${hostlist} ; do
      h="${h%%|*}"
      cleanhostlist+="${h,,} "
    done
    COMPREPLY=( $(compgen -W "${cleanhostlist}" -- ${cur}) )
    return 0
  fi
}

f_color_pr(){
  case $1 in
    wht) COLOR='\e[1m' ;;
    grn) COLOR='\e[1;32m' ;;
    ylw) COLOR='\e[1;33m' ;;
    red) COLOR='\e[1;31m' ;;
    cyn) COLOR='\e[1;36m' ;;
  esac
  shift
  printf "$COLOR""$@"'\e[m\n'
}

f_color_ask(){
  case $1 in
    wht) COLOR='\e[1m' ;;
    grn) COLOR='\e[1;32m' ;;
    ylw) COLOR='\e[1;33m' ;;
    red) COLOR='\e[1;31m' ;;
    cyn) COLOR='\e[1;36m' ;;
  esac
  shift
  local reply="$1"
  shift
  printf "$COLOR""$@"'\e[m\e[1m'
  read $reply
  printf '\e[m'
}

f_abort(){
  f_color_pr wht "aborted..."
  exit
}

switchOptions=${switchOptions:=false}
     justecho=${justecho:=false}

declare -a unsortedEnvlist
declare -a envlist

if command -v whiptail &>/dev/null ; then
  useWhiptail=true
  curLines="$( tput lines )"
  minLines=9
  if [[ ${curLines} -lt 28 && ${curLines} -gt ${minLines} ]] ; then
    lines=${curLines}
    menusize=$(( ${curLines} -8 ))
  elif [[ ${curLines} -lt 28 ]] ; then
    lines=${minLines}
    menusize=$(( ${minLines} -8 ))
  fi
  curCols="$( tput cols )"
  minCols=30
  if [[ ${curCols} -lt 78 && ${curCols} -gt ${minCols} ]] ; then
    cols=${curCols}
  elif [[ ${curCols} -lt 78 ]] ; then
    cols=${minCols}
  fi
  wtWinSize="${lines:-28} ${cols:-78} ${menusize:-20}"
else
  useWhiptail=false
fi

if command -v sshpass &>/dev/null ; then
  sshpassInstalled=true
  command -v oathtool &>/dev/null && oathtoolInstalled=true
fi

f_reg(){
  unset $1
  declare -g -A $1
  unsortedEnvlist+=( "$1" )
}

thisscript=$(readlink -f ${BASH_SOURCE[0]})
configfile1="$( dirname ${thisscript} )/$( basename ${thisscript} sh)conf"
configfile2="${HOME}/.jh.conf"
for configfile in "${configfile1}" "${configfile2}" ; do
  if [[ -f "$configfile" ]] ; then
    for e in $( sed -n -r 's/([^=]+)=\(/\1/gp' "${configfile}" ) ; do
      f_reg "$e"
    done
    . "${configfile}"
  fi
done

envlist=( $( for e in ${unsortedEnvlist[@]} ; do echo $e ; done | sort ) )

f_noWtAsk(){
  printf '\e[1m'
  read -p "$@"
  printf '\e[m'
}

f_ssh_env_set(){
  declare -g sshenv

  filteredEnvList="$( for E in "${envlist[@]}" ; do echo $E ; done | egrep ".*${sshenvProp}.*" )"
  eCheck="$( wc -l <<< "${filteredEnvList}" )"
  if [[ -z ${filteredEnvList} ]] ; then
    f_color_pr red "ERROR: NO ENV FOUND!"
    exit
  elif [[ ${eCheck} -eq 1 ]] ; then
    sshenv="${filteredEnvList}"
  fi

  while [[ -z ${sshenv} ]] ; do
    local -a arr
    local i=1
    if [[ ! -z ${envlist[@]} ]] ; then
      for e in ${filteredEnvList} ; do
        arr[i]="$e"
        ${useWhiptail} && wtarg+="$((i++)) $e "
        ${useWhiptail} || printf '\e[1;32m%2d\e[m) \e[1;36m%s\e[m\n' "$((i++))" "$e"
      done
    else
      f_color_pr red "ERROR: NO ENVLIST!"
    fi
    if [[ -z ${sshenv} ]] ; then
      ${useWhiptail} && REPLY=$(
#sleep 2
        whiptail \
          --title 'Set Environment' \
          --menu '   Choose the environment you want to reach' \
          $wtWinSize \
          $wtarg 3>&1 1>&2 2>&3 \
          || echo cancel
      ) ; unset wtarg
      ${useWhiptail} || f_noWtAsk "type here your ssh environment id number:
ID: "
      if [[ $REPLY == "cancel" ]] ; then
#        return 100
        f_abort
      elif [[ $REPLY =~ ^[0-9]+$ && $REPLY -ge 1 && $REPLY -lt $i ]] ; then
        sshenv="${arr[REPLY]}"
      fi
    fi
  done
}

f_ssh_host_set(){
  hostlist="$( eval echo '${!'${sshenv}'[@]}' | sed -r -e "s/(${keywords})[ ]?//g" -e 's/ /\n/g' | sort )"
  declare -g sshhost

  filteredHostList="$( for E in ${hostlist} ; do echo $E ; done | egrep -i ".*${sshhostProp}.*" )"
  if [[ -z ${filteredHostList} ]] ; then
    f_color_pr red "ERROR: NO HOST FOUND!"
    exit
  else
    [[ -z ${sshhostProp} ]] || hCheck="$( wc -l <<< "${filteredHostList}" )"
  fi
  [[ ${hCheck:-"-1"} -eq 1 ]] && sshhost="${filteredHostList}"

  while [[ -z ${sshhost} && -z ${gotojh} ]] ; do
    local -a arr
    local i=1
    if [[ ! -z ${sshenv} ]] ; then
      for e in ${filteredHostList} ; do
        arr[i]="$e"
        e="${e%%|*}"
        ${useWhiptail} && wtarg+="$((i++)) ${e,,} "
        ${useWhiptail} || printf '\e[1;32m%2d\e[m) \e[1;36m%s\e[m\n' "$((i++))" "${e,,}"
      done
    else
      f_color_pr red "ERROR: NO HOST!"
    fi
    if [[ -z ${sshhost} ]] ; then
      ${useWhiptail} && eval test -z '${'${sshenv}'["JH"]}' || wtarg+="j JUMPHOST" && REPLY=$(
#sleep 2
        whiptail \
          --title 'Set Host' \
          --menu "   Choose the host of ${sshenv^^} env that you want to reach" \
          $wtWinSize \
          $wtarg 3>&1 1>&2 2>&3 \
          || echo cancel
      ) ; unset wtarg
      ${useWhiptail} || f_noWtAsk "You selected environment ${sshenv^^}.
Now type here your host id number or type \"j\" to access the jumphost:
ID: "
      if [[ $REPLY == "cancel" ]] ; then
#        return 100
        f_abort
      elif [[ $REPLY == "j" ]] ; then
        gotojh=true
      elif [[ $REPLY =~ ^[0-9]+$ && $REPLY -ge 1 && $REPLY -lt $i ]] ; then
        sshhost="${arr[REPLY]}"
      fi
    fi
  done
}

f_env_print(){

  local tl='┌' tm='┬' tr='┐'
  local ml='├' mm='┼' mr='┤'
  local bl='└' bm='┴' br='┘'
  local hl='─' vl='│'

  local colorReset='\e[m'
  local BbFw='\e[40;97m'
  local Bdflt='\e[40;92m'
  local B_JH='\e[1;40;34m'
  local F_JH='\e[1;34m'
  local F_NH='\e[92m'

  local firstLine=true

  declare -A printArray
  eval $( typeset -A -p ${sshenv} | sed "s/ ${sshenv}=/ printArray=/" )
  hostlist="$( echo "${!printArray[@]}" | sed -r -e "s/(${keywords})[ ]?//g" -e 's/ /\n/g' | sort )"
  local tmphLength hLength=10
  local tmpiLength iLength=15
  for h in ${hostlist} ; do
    tmphLength=$( wc -c <<< "${h%%|*}" )
    [[ "${tmphLength}" -gt ${hLength:-0} ]] && hLength="${tmphLength}"
  done
  for i in "${!printArray[@]}" JH ; do
    if [[ "${hostlist//${i}}" != "${hostlist}" || ${i} == "JH" ]] ; then
      tmpiLength=$( wc -c <<< "${printArray[${i}]}" )
      [[ "${tmpiLength}" -gt ${iLength:-0} ]] && iLength="${tmpiLength}"
    fi
  done
  if ${tablePrint:-false} ; then
    deviderLineA="$( eval printf -- "$hl"'%.0s' '{1..'$(( ${hLength} + 2 ))'}' )"
    deviderLineB="$( eval printf -- "$hl"'%.0s' '{1..'$(( ${iLength} + 2 ))'}' )"
  fi
  for p in ${hostlist} ; do
    eval ip="${printArray[${p}]}"
    if [[ ${p} == ${p^^} || -z $( eval echo "${printArray[JH]}" ) ]] ; then
      B_NH=${Bdflt} F_NH=${F_NH}
    else
      B_NH=${BbFw}  F_NH=
    fi
    if [[ ${p} != ${p%%|*} ]] ; then
      optBit='+'
    else
      optBit=' '
    fi
    p="${p,,}" ; p="${p%%|*}"
    if ${tablePrint:-false} ; then
      if ${firstLine} ; then
        printf "${BbFw}${tl}${deviderLineA}${tm}${deviderLineB}${tr}${colorReset}\n"
        firstLine=false
      else
        printf "${BbFw}${ml}${deviderLineA}${mm}${deviderLineB}${mr}${colorReset}\n"
      fi
      printf "${BbFw}${vl}${optBit}${B_NH}%${hLength}s${BbFw} ${vl} ${B_NH}%${iLength}s${BbFw} ${vl}${colorReset}\n" "${p}" "${ip}"
    else
      printf "${F_NH}%${hLength}s    %s${colorReset}\n" "${p}" "${ip}"
    fi
  done
  if [[ ! -z $( eval echo "${printArray[JH]}" ) ]] ; then
    if ${tablePrint:-false} ; then
      printf "${BbFw}${ml}${deviderLineA}${mm}${deviderLineB}${mr}${colorReset}\n"
      printf "${BbFw}${vl} ${B_JH}%${hLength}s${BbFw} ${vl} ${B_JH}%${iLength}s${BbFw} ${vl}${colorReset}\n" "JUMPHOST" "${printArray[JH]}"
    else
#      printf "${F_JH}%${hLength}s    %${iLength}s${colorReset}\n" "JUMPHOST" "${printArray[JH]}"
      printf "${F_JH}%${hLength}s    %s${colorReset}\n" "JUMPHOST" "${printArray[JH]}"
    fi
  fi
  if ${tablePrint:-false} ; then
    printf "${BbFw}${bl}${deviderLineA}${bm}${deviderLineB}${br}${colorReset}\n"
  fi
  exit
}

f_ssh_opt_set(){
  if ${useWhiptail} ; then
    if ${switchOptions} ; then
      sshopts1=( $(whiptail --title "Extra settings" --checklist "Switch other settings for host ${sshhosttoprint^^} in environment ${sshenv^^}" $wtWinSize -- \
        "-L8111:localhost:8111"   "| Local Map port Karaf support"       OFF \
        "-L8443:localhost:443"    "| Local Map port HTTPS"               OFF \
        "-L8080:localhost:80"     "| Local Map port HTTP"                OFF \
        "-R10022:localhost:22"    "| Remote Map port ssh"                OFF \
        "-L3128:localhost:3128"   "| Local Map port Squid"               OFF \
        "-L14239:localhost:14239" "| Local Map port Squid alternative"   OFF \
        "-fnN"                    "| Start in background/no shell"       OFF \
        "other..."                "| specify other options via inputbox" OFF \
        3>&1 1>&2 2>&3 ) ) || f_abort
    fi
    if [[ ${#sshopts1[@]} -gt 0 ]] ; then
      optsCount="$(( ${#sshopts1[@]} - 1 ))"
      eval "lastArg=${sshopts1[optsCount]}"
      if [[ ${lastArg} == "other..." ]] ; then
        unset sshopts1[optsCount]
        sshopts2=( $( whiptail --inputbox "Type your extra options here:" 8 ${cols:-78} "" --title "Extra options" 3>&1 1>&2 2>&3 ) ) || f_abort
      fi
    fi
    if [[ ${sshhost##*|} != ${sshhost} ]] ; then
      read -a opts < <(sed -r 's/(.)/\1 /g' <<< "${sshhost##*|}" )
      for o in ${opts[@]} ; do
        local tmpopt="$sshenv["OPT_${o}"]"
        sshopts3+=" ${!tmpopt}"
      done
    fi
  fi
}

f_debug_pr(){
  ${debug:-false} && printf '\e[1;31m'"$@"'\e[m'
}

jh(){
  local         cmd="$1" ; shift
  local  sshenvProp="$1" ; shift
  local sshhostProp="$1" ; shift
#  f_ssh_env_set && [[ -z ${sshhost} ]] && f_ssh_host_set
  f_ssh_env_set && \
  if ${envPrint:-false} ; then
    f_env_print
  else
    [[ -z ${sshhost} ]] && f_ssh_host_set
  fi

  # jumphost parameters
  declare     jh=$sshenv["JH"]
  declare jhopts=$sshenv["JHOPTS"]
  declare jhuser=$sshenv["JHUSER"]
  declare  jhkey=$sshenv["JHKEY"]
  declare  jhotp=$sshenv["JHOTP"]
  declare   jhpw=$sshenv["JHPASSWD"]
  declare jhport=$sshenv["JHPORT"]
  declare  jhtfa=$sshenv["JHTFA"]
  [[ -z ${!jhopts} && ! -z ${defaultjhoptions} ]] && jhopts="defaultjhoptions"
  [[ -z ${!jhuser} && ! -z ${defaultjhuser}    ]] && jhuser="defaultjhuser"
  [[ -z ${!jhkey}  && ! -z ${defaultjhkey}     ]] &&  jhkey="defaultjhkey"
  [[ -z ${!jhotp}  && ! -z ${defaultjhotp}     ]] &&  jhotp="defaultjhotp"
  [[ -z ${!jhport} && ! -z ${defaultjhport}    ]] && jhport="defaultjhport"
  [[ -z ${!jhtfa}  && ! -z ${defaultjhtfa}     ]] &&  jhtfa="defaultjhtfa"
  # normal hosts parameters
  declare   user=$sshenv["USER"]
  declare    key=$sshenv["KEY"]
  declare     pw=$sshenv["PASSWD"]
  declare   port=$sshenv["PORT"]
  [[ -z ${!user}   && ! -z ${defaultuser}      ]] &&   user="defaultuser"
  [[ -z ${!key}    && ! -z ${defaultkey}       ]] &&   user="defaultkey"
  [[ -z ${!port}   && ! -z ${defaultport}      ]] &&   port="defaultport"

  if [[ ! -z ${!jhotp} ]] && ${oathtoolInstalled:-false} && ${!jhtfa:-true} ; then
    prejhcmd="sshpass -P \"Verification code:\" -p $( oathtool --totp -b ${!jhotp} ) "
  elif [[ ! -z ${!jhpw} ]] && ${sshpassInstalled:-false} ; then
    prejhcmd="sshpass -p ${!jhpw} "
      precmd="sshpass -p ${!pw} "
  fi
  [[ ! -z ${!pw}   ]] && ${sshpassInstalled:-false} &&   precmd="sshpass -p ${!pw} "

  declare host=$sshenv["$sshhost"]
  if [[ -z ${sshhost} ]] && ${gotojh:-false} ; then
    f_color_pr cyn "${prejhcmd}${cmd:-ssh} connection to jumphost '${!jh}' (${sshenv})"
    case ${cmd:=ssh} in
       ssh) fullcmd="${prejhcmd}${cmd} -A \
        ${!jhopts} \
        ${!jhport:+-p'${!jhport}'} \
        ${!jhkey:+-i'${!jhkey}'} \
        ${!jhuser:+-l'${!jhuser}'} \
        ${!jh}"
        ;;
      sftp) fullcmd="${prejhcmd}${cmd} \
        ${!jhopts} \
        ${!jhport:+-P'${!jhport}'} \
        ${!jhkey:+-i'${!jhkey}'} \
        ${!jhuser:+'${!jhuser}'@}${!jh}"
        ;;
         *) f_color_pr red "ERROR: UNKNOWN COMMAND!" ;;
    esac
  elif [[ ! -z ${!host} && -z ${!jh} ]] || [[ ${sshhost^^} == ${sshhost} ]] ; then
    f_color_pr cyn "${precmd}${cmd:-ssh} connection to host '${!host}' (${sshenv}/${sshhost,,})"
    case ${cmd:=ssh} in
       ssh) fullcmd="${precmd}${cmd} \
        ${!port:+-p'${!port}'} \
        ${!user:+-l'${!user}'} \
        ${!key:+-i'${!key}'} \
        ${!host}"
        ;;
      sftp) fullcmd="${precmd}${cmd} \
        ${!port:+-P'${!port}'} \
        ${!key:+-i'${!key}'} \
        ${!user:+'${!user}'@}${!host}"
        ;;
         *) f_color_pr red "ERROR: UNKNOWN COMMAND!" ;;
    esac
  elif [[ -z ${!host} ]] ; then
    f_color_pr red "ERROR: NO EXISTING HOST SPECIFIED!"
  else
    declare -g sshhosttoprint="$( sed -r 's/[|].*//g' <<< "${sshhost,,}" )"
    f_color_pr cyn "${cmd:-ssh} connection via '${!jh}' to '${!host}' (${sshenv}/${sshhosttoprint}) ${!user:+"as '${!user}' "}${!key:+"with '${!key}' "}"
    proxycmd="
      ${prejhcmd}ssh -A -W %h:%p
      ${!jhopts}
      ${!jhport:+-p'${!jhport}'} \
      ${!jhkey:+-i'${!jhkey}'}
      ${!jhuser:+-l'${!jhuser}'}
      ${!jh}"
    case ${cmd:=ssh} in
       ssh) fullcmd="${precmd}${cmd} \
        -o ProxyCommand='${proxycmd}' \
        ${!port:+-p'${!port}'} \
        ${!user:+-l'${!user}'} \
        ${!key:+-i'${!key}'} \
        ${!host}"
        ;;
      sftp) fullcmd="${precmd}${cmd} \
        -o ProxyCommand='${proxycmd}' \
        ${!port:+-P'${!port}'} \
        ${!key:+-i'${!key}'} \
        ${!user:+'${!user}'@}${!host}"
        ;;
         *) f_color_pr red "ERROR: UNKNOWN COMMAND!" ;;
    esac
  fi
  if [[ ! -z ${fullcmd} ]] ; then
    [[ ${cmd} == "ssh" ]] && f_ssh_opt_set
    #echo "${sshopts1[@]}" "${sshopts2[@]}"
    printf '\e[1;34m==> \e[1;32m'
    echo ${fullcmd} ${sshopts1[@]} ${sshopts2[@]} ${sshopts3[@]} "$@"
    printf '\e[m'
    ${justecho:-false} || eval ${fullcmd} ${sshopts1[@]} ${sshopts2[@]} ${sshopts3[@]} "$@"
  fi
}

jhssh(){
  jh ssh "$@"
}

jhssho(){
  switchOptions=true
  jh ssh "$@"
}

jhsshprint(){
  justecho=true
  jh ssh "$@"
}

jhsshoprint(){
  switchOptions=true
  justecho=true
  jh ssh "$@"
}

jhsftp(){
  jh sftp "$@"
}

jhsftpprint(){
  justecho=true
  jh sftp "$@"
}

jhenvlist(){
  envPrint=true
  tablePrint=false
  jh envprint "$@"
}

jhenvtable(){
  envPrint=true
  tablePrint=true
  jh envprint "$@"
}

f_map_cmd(){
  case $1 in
    main)
      case $2 in
              message) "Installing main script ..." ;;
        checkExistent) [[ "$( stat -Lc%i "${cDir}/${c}" 2>/dev/null )" != "$( stat -Lc%i "${thisscript}" )" ]] && ! diff "${cDir}/${c}" "${thisscript}" &>/dev/null ;;
         forceInstall) cp -vf "${thisscript}" "${cDir}/${c}" && chmod a+x "${cDir}/${c}" ;;
        normalInstall) cp -v  "${thisscript}" "${cDir}/${c}" && chmod a+x "${cDir}/${c}" ;;
      esac ;;

    link)
      case $2 in
              message) ${firstLink:-true} && firstLink=false && f_color_pr cyn "Creating links ..." ;;
        checkExistent) [[ "$( stat -Lc%i "${cDir}/${c}" 2>/dev/null )" != "$( stat -Lc%i "${installDir}/jh.sh" )" ]] ;;
         forceInstall) ln -sf jh.sh "${cDir}/${c}" ;;
        normalInstall) ln -s  jh.sh "${cDir}/${c}" ;;
    esac ;;

    completion)
      jhshcompl="
$( typeset -f f_reg | sed '1s/f_reg/_jh_&/g' )

$( typeset -f _jh_complete )

complete -F _jh_complete jh{{ssh,sftp}{,o,print},env{list,table}}
"
      case $2 in
              message) f_color_pr cyn "Creating bash completion source code ..." ;;
        checkExistent) ! diff /etc/bash_completion.d/jhsh.bash - <<< "${jhshcompl}" &>/dev/null ;;
             *Install) cat > /etc/bash_completion.d/jhsh.bash <<< "${jhshcompl}" ;;
    esac ;;
  esac
}

f_install(){
  f_color_ask cyn installDir "Type install dir [/usr/local/bin]: "
  [[ -z ${installDir} ]] && installDir="/usr/local/bin" && f_color_pr wht "  Default: ${installDir}"
  [[ ! -d ${installDir} ]] && f_color_pr red "ERROR: folder '${installDir}' is not available!" && exit
  for c in "jh.sh" $( typeset -f | sed -r -n 's/^(jh[a-z]+) \(\)/\1/gp' ) "jhsh.bash" ; do
    case $c in
          "jh.sh") installFunc="main"       cDir=${installDir} ;;
      "jhsh.bash") installFunc="completion" cDir="/etc/bash_completion.d" ;;
                *) installFunc="link"       cDir=${installDir} ;;
    esac
    if [[ -d ${cDir} ]] ; then
      if [[ -d "${cDir}/${c}" ]] ; then
        f_color_pr red "ERROR: ${cDir}/${c} it's a directory! Please, remove it manually!"
      elif [[ -L "${cDir}/${c}" || -e "${cDir}/${c}" ]] ; then
        if f_map_cmd ${installFunc} checkExistent ; then
          f_color_pr red "   ${cDir}/${c} already exists!"
          while ! [[ ${overwrite,,} =~ ^(y(es)?)|(no?)$ ]] ; do
            f_color_ask cyn overwrite "   Do you want to overwrite it? [Yn]: "
            if [[ ${overwrite,,} =~ ^y(es)?$ || -z ${overwrite} ]] ; then
              [[ -z ${overwrite} ]] && f_color_pr wht "  Default: Yes" && overwrite=Y
              ( f_map_cmd ${installFunc} forceInstall && f_color_pr grn "   DONE: ${cDir}/${c}" ) || f_color_pr red "   ERROR!"
            elif [[ ${overwrite,,} =~ ^no?$ || -z ${overwrite} ]] ; then
              f_color_pr wht "   skipped..."
            fi
          done
          unset overwrite
        else
          f_color_pr grn "   ALREADY UPDATED: ${cDir}/${c}"
        fi
      else
        ( f_map_cmd ${installFunc} normalInstall && f_color_pr grn "   DONE: ${cDir}/${c}" ) || f_color_pr red "   ERROR!"
      fi
    else
      f_color_pr red "ERROR: ${cDir} doesn't exist!"
    fi
  done
  ${sshpassInstalled:-false}  || f_color_pr red "Install sshpass if you want to use automatic passwords feature"
  ${oathtoolInstalled:-false} || f_color_pr red "Install oathtool if you want to use automatic TFA feature"
  exit
}

if [[ $( type -t $( basename $0 ) ) == "function" ]] ; then
  eval $( basename $0 ) "$@"
else
  f_install
fi

