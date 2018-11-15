#!/usr/bin/env bash

f_pre_run(){
# MacOS compatibility fix:
  if [[ $( uname -s ) == "Darwin" ]] ; then
    sed="gsed"
  else
    sed="sed"
  fi
# more or less choice:
  if command -v less &>/dev/null && ! ${disableLess:-false} ; then
    pager="less -R"
  else
    pager="more"
  fi
}

f_pre_run

keywords="JH|((JH|ALT_[A-Z]_)?(KEY|USER|PASSWD|PORT|TFA|OPTS))|(OPT_[A-Z])"

_jh_complete(){
  local cur prev jhcmd
  local sshenv
  local thisscript configfile1 configfile2
  local envlist hostlist cleanhostlist

  COMPREPLY=()
  cur=${COMP_WORDS[COMP_CWORD]}
  prev=${COMP_WORDS[COMP_CWORD-1]}
  jhcmd=${COMP_WORDS[0]}
  thisscript=$( readlink -f $( which ${jhcmd} ) )

  if [[ ${COMP_CWORD} -lt 4 ]] ; then
    configfile1="$( dirname ${thisscript} )/$( basename ${thisscript} sh)conf"
    configfile2="${HOME}/.jh.conf"
    for configfile in "${configfile1}" "${configfile2}" ; do
      if [[ -f "$configfile" ]] ; then
        for e in $( ${sed} -n -r 's/([^=]+)=\(/\1/gp' "${configfile}" ) ; do
          _jh_f_reg "$e"
        done
        envlist="${unsortedEnvlist[@]//DEF_*}"
        . "${configfile}"
      fi
    done
  fi

  if [[ ${COMP_CWORD} == 1 ]] && ! [[ ${jhcmd} =~ ${limit0arg} ]] ; then
    COMPREPLY=( $( compgen -W "${envlist}" -- ${cur} ) )
    return 0
  elif [[ ${COMP_CWORD} == 2 ]] && ! [[ ${jhcmd} =~ ${limit1arg} ]] ; then
    sshenv="$prev"
    hostlist="$( eval echo '${!'${sshenv}'[@]}' | ${sed} -r -e "s/(${keywords})[ ]?//g" -e 's/ /\n/g' | sort )"
    for h in ${hostlist} ; do
      h="${h%%|*}" ; h="${h%%:*}"
      cleanhostlist+="${h,,} "
    done
    COMPREPLY=( $( compgen -W "${cleanhostlist}" -- ${cur} ) )
    return 0
  elif [[ ${COMP_CWORD} -ge 3 ]] && ! [[ ${jhcmd} =~ ${limit2arg} ]] ; then
    COMPREPLY=( $( compgen -W "$( ${sed} -r -n '/sshopts[1]=/,/other/{/other/d;s/"(.*)"([ ]+)"[|](.*)"[ ]+OFF [\]/\1/gp}' ${thisscript} )" -- ${cur} ) )
    return 0
  fi
}

f_color_pr(){
  eval COLOR="\$$1"
  shift
  printf "${COLOR}%s${neu}\n" "$@"
}

f_color_ask(){
  eval COLOR="\$$1"
  local reply="$2"
  shift 2
  printf "${COLOR}%s${neu}${wht}" "$@"
  read $reply
  printf "${neu}"
}

f_abort(){
  f_color_pr wht "aborted..."
  exit
}

switchOptions=${switchOptions:=false}
     justecho=${justecho:=false}

declare -a unsortedEnvlist
declare -a envlist
declare -a deflist

f_reg(){
  unset $1
  declare -g -A $1
  unsortedEnvlist+=( "$1" )
}

thisscript="$( readlink -f ${BASH_SOURCE[0]} )"
configfile1="$( dirname ${thisscript} )/$( basename ${thisscript} sh)conf"
configfile2="${HOME}/.jh.conf"
for configfile in "${configfile1}" "${configfile2}" ; do
  if [[ -f "$configfile" ]] ; then
    for e in $( ${sed} -n -r 's/([^=]+)=\(/\1/gp' "${configfile}" ) ; do
      f_reg "$e"
    done
    . "${configfile}"
  fi
done

if command -v whiptail &>/dev/null && ! ${disableWhiptail:-false} ; then
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

if command -v sshpass &>/dev/null && ! ${disableSshpass:-false} ; then
  sshpassInstalled=true
  command -v oathtool &>/dev/null && ! ${disableOathtool:-false} && oathtoolInstalled=true
fi

# color map
if ${noColors:-false} ; then
  neu=''
  wht=''
  red=''
  grn=''
  ylw=''
  blu=''
  prp=''
  cyn=''
elif ${whiteBG:-false} ; then
  neu='\e[m'
  wht='\e[m'
  red='\e[2;31m'
  grn='\e[2;32m'
  ylw='\e[2;33m'
  blu='\e[2;34m'
  prp='\e[2;35m'
  cyn='\e[2;36m'
else
  neu='\e[m'
  wht='\e[1m'
  red='\e[1;31m'
  grn='\e[1;32m'
  ylw='\e[1;33m'
  blu='\e[1;34m'
  prp='\e[1;35m'
  cyn='\e[1;36m'
fi

envlist=( $( for e in ${unsortedEnvlist[@]//DEF_*} ; do echo $e ; done | sort ) )
deflist=( $( for e in ${unsortedEnvlist[@]} ; do echo $e ; done | egrep -o '^DEF_.*' | sort ) )

f_noWtAsk(){
  printf "${wht}"
  read -p "$@"
  printf "${neu}"
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
        ${useWhiptail} || printf "${grn}%2d${neu}) ${cyn}%s${neu}\n" "$((i++))" "$e"
      done
    else
      f_color_pr red "ERROR: NO ENVLIST!"
    fi
    if [[ -z ${sshenv} ]] ; then
      ${useWhiptail} && REPLY=$(
#       sleep 2 # disabled -> slow down for debug
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
        f_abort
      elif [[ $REPLY =~ ^[0-9]+$ && $REPLY -ge 1 && $REPLY -lt $i ]] ; then
        sshenv="${arr[REPLY]}"
      fi
    fi
  done
}

f_ssh_host_set(){
  hostlist="$( eval echo '${!'${sshenv}'[@]}' | ${sed} -r -e "s/(${keywords})[ ]?//g" -e 's/ /\n/g' | sort )"
  declare -g sshhost

  filteredHostList="$( for E in ${hostlist} ; do echo $E ; done | egrep -i ".*${sshhostProp}.*" )"
  if [[ -z ${filteredHostList} ]] ; then
    f_color_pr red "ERROR: NO HOST FOUND!"
    exit
  else
    [[ -z ${sshhostProp} ]] || hCheck="$( wc -l <<< "${filteredHostList}" )"
  fi
  [[ ${hCheck:-"-1"} -eq 1 ]] && sshhost="${filteredHostList}"

  ${getHostListOnly:-false} && multicmdHosts=( ${filteredHostList} )
  ${multicmd:-false} && return

  while [[ -z ${sshhost} && -z ${gotojh} ]] ; do
    local -a arr
    local i=1
    if [[ ! -z ${sshenv} ]] ; then
      for e in ${filteredHostList} ; do
        arr[i]="$e"
        e="${e%%|*}"
        ${useWhiptail} && wtarg+="$((i++)) ${e,,} "
        ${useWhiptail} || printf "${grn}%2d${neu}) ${cyn}%s${neu}\n" "$((i++))" "${e,,}"
      done
    else
      f_color_pr red "ERROR: NO HOST!"
    fi
    if [[ -z ${sshhost} ]] ; then
      ${useWhiptail} && eval test -z '${'${sshenv}'["JH"]}' || wtarg+="j JUMPHOST" && REPLY=$(
#       sleep 2 # disabled -> slow down for debug
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

  local colorReset="${neu}"
  local BbFw='\e[40;97m'
  local Bdflt='\e[40;92m'
  local B_JH='\e[1;40;36m'
  local F_JH='\e[1;34m'
  local F_NH='\e[92m'

  local firstLine=true

  declare -A printArray
  eval $( typeset -A -p ${sshenv} | ${sed} "s/ ${sshenv}=/ printArray=/" )
  hostlist="$( echo "${!printArray[@]}" | ${sed} -r -e "s/(${keywords})[ ]?//g" -e 's/ /\n/g' | sort )"
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
    if [[ ${p} != ${p%%|*} || ${p} != ${p%%:*} ]] ; then
      optBit='+'
    else
      optBit=' '
    fi
    p="${p,,}" ; p="${p%%|*}" ; p="${p%%:*}"
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
      printf "${F_JH}%${hLength}s    %s${colorReset}\n" "JUMPHOST" "${printArray[JH]}"
    fi
  fi
  if ${tablePrint:-false} ; then
    printf "${BbFw}${bl}${deviderLineA}${bm}${deviderLineB}${br}${colorReset}\n"
  fi
}

f_env_conf(){
  local KeyLength=${defaultHostnameLength:-4}
  local tmpKeyLength

  declare -A workArray
  eval $(typeset -A -p ${sshenv} | ${sed} 's/ '${sshenv}'=/ workArray=/')

  local keysString="$( echo ${!workArray[@]} ) "

  for k in ${keysString} ; do
    tmpKeyLength="$(( $( wc -c <<< "$k" ) + 2 ))"
    [[ ${tmpKeyLength} -gt ${KeyLength} ]] && KeyLength="${tmpKeyLength}"
  done
  KeyLength="$(( ${KeyLength} + 3 ))"

  echo "${sshenv}=("

  for section in \
          'Jumphost settings:JH[^ ]*'                          \
    'Standard hosts settings:USER|KEY|PORT|PASSWD'             \
        'Alternative options:ALT_[A-Z]_(USER|KEY|PORT|PASSWD)' \
              'Extra options:OPT_[A-Z]'                        \
                      'Hosts:.+'                               \
  ; do
    conf_title="$( cut -d: -f 1 <<< "${section}" )"
    conf_regex="$( cut -d: -f 2 <<< "${section}" )"
    for k in $( egrep -o -w "${conf_regex}" <<< "${keysString}" ) ; do
      conf_section+="$( printf '%'${KeyLength}'s="%s"' '["'$k'"]' "$( eval echo \${$sshenv["$k"]} )" )
" # newline
      keysString="${keysString//$k }"
    done
    if [[ ! -z ${conf_section} ]] ; then
      conf_section_sorted="$( sort <<< "${conf_section}" )"
      printf "  # -- ${conf_title}:${conf_section_sorted}\n"
    fi
    unset conf_section
  done

  printf ")\n\n"
}

f_ssh_opt_set(){
  if ${useWhiptail} ; then
    if ${switchOptions} ; then
      sshopts1=( $( whiptail --title "Extra settings" --checklist "Switch other settings for host ${sshhosttoprint^^} in environment ${sshenv^^}" $wtWinSize -- \
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
  fi
  if [[ ${sshhost##*|} != ${sshhost} ]] ; then
    local extramapping="${sshhost##*|}"
    read -a opts < <( ${sed} -r 's/(.)/\1 /g' <<< "${extramapping%%:*}" )
    for o in ${opts[@]} ; do
      local tmpopt="$sshenv["OPT_${o}"]"
      sshopts3+=" ${!tmpopt}"
    done
  fi
}

f_ssh_alt_set(){
  if [[ ${sshhost##*:} != ${sshhost} ]] ; then
    local extramapping="${sshhost##*:}"
    read -a opts < <( ${sed} -r 's/(.)/\1 /g' <<< "${extramapping%%|*}" )
    for o in ${opts[@]} ; do
      #alts="$( eval egrep -o "(ALT_${o}_[A-Z]+)[ ]?" <<< '${!'${sshenv}'[@]}' | sort )"
      alts="$( egrep -o "ALT_${o}_[A-Z]+[ ]?" <<< "$( eval echo '${!'${sshenv}'[@]}' )" | sort )"
        for a in ${alts} ; do
          eval override_$( ${sed} -r 's/ALT_[A-Z]_//g' <<< "$a" )="$sshenv["${a}"]"
        done
    done
  fi
}

f_debug_pr(){
  ${debug:-false} && printf "${red}$@${neu}"
}

jh(){
  local         cmd="$1" ; shift
  local  sshenvProp="$1" ; shift
  local sshhostProp="$1" ; shift
  f_ssh_env_set && \
  if ${envPrint:-false} ; then
    f_env_print && return
  elif ${envConf:-false} ; then
    f_env_conf && return
  else
    [[ -z ${sshhost} ]] && ! ${gotojh:-false} && f_ssh_host_set
  fi

  ${getHostListOnly:-false} && getHostListOnly=false && return

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
  f_ssh_alt_set
  declare   user="${override_USER:-$sshenv["USER"]}"
  declare    key="${override_KEY:-$sshenv["KEY"]}"
  declare     pw="${override_PASSWD:-$sshenv["PASSWD"]}"
  declare   port="${override_PORT:-$sshenv["PORT"]}"
  [[ -z ${!user}   && ! -z ${defaultuser}      ]] &&   user="defaultuser"
  [[ -z ${!key}    && ! -z ${defaultkey}       ]] &&    key="defaultkey"
  [[ -z ${!port}   && ! -z ${defaultport}      ]] &&   port="defaultport"

  if [[ ! -z ${!jhpw} ]] && ${sshpassInstalled:-false} ; then
    prejhcmd="sshpass -p ${!jhpw} "
  elif [[ ! -z ${!jhotp} ]] && ${oathtoolInstalled:-false} && ${!jhtfa:-true} ; then
    prejhcmd="sshpass -P \"Verification code:\" -p $( oathtool --totp -b ${!jhotp} ) "
  fi
  [[ ! -z ${!pw}   ]] && ${sshpassInstalled:-false} &&   precmd="sshpass -p ${!pw} "

  declare host=$sshenv["$sshhost"]
  if [[ -z ${sshhost} ]] && ${gotojh:-false} ; then
    [[ -z ${!jh} ]] && f_color_pr red "ERROR: No jumphost defined for environment ${sshenv}!" && exit
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
        ${!user:+'${!user}'@}${!host}${sftppath:+:$sftppath}"
        ;;
         *) f_color_pr red "ERROR: UNKNOWN COMMAND!" ;;
    esac
  elif [[ -z ${!host} ]] ; then
    f_color_pr red "ERROR: NO EXISTING HOST SPECIFIED!"
  else
    declare -g sshhosttoprint="$( ${sed} -r 's/[|:].*//g' <<< "${sshhost,,}" )"
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
        ${!user:+'${!user}'@}${!host}${sftppath:+:$sftppath}"
        ;;
         *) f_color_pr red "ERROR: UNKNOWN COMMAND!" ;;
    esac
  fi
  if [[ ! -z ${fullcmd} ]] ; then
    [[ ${cmd} == "ssh" ]] && f_ssh_opt_set
#    echo "${sshopts1[@]}" "${sshopts2[@]}" "${sshopts3[@]}" # disabled -> extra options output
    printf "${blu}==> ${grn}"
    echo ${fullcmd} ${sshopts1[@]} ${sshopts2[@]} ${sshopts3[@]} $( for v in "$@" ; do echo \'$v\' ; done )
    printf "${neu}\n"
    ${justecho:-false} || eval ${fullcmd} ${sshopts1[@]} ${sshopts2[@]} ${sshopts3[@]} \"\$@\"
  fi
}

jhman(){
# description: it prints this manual
# arguments: 0
  local B='\e[1m'
  local D='\e[2m'
  local I='\e[3m'
  local U='\e[4m'
  local N='\e[m'
  sepLine="$( printf "%0$( tput cols )s\n" | ${sed} 's/ /─/g' )"
  printf "$sepLine

  -- ${B}JH Utility Script${N} --

$sepLine

${U}Brief description${N}: ${B}$( basename ${thisscript} )${N} is a utility suite created to easily mantain and connect via jumphosts to environment hosts.
When invoked with its basename, it will trigger an installation/update procedure that will create the following utilities:

$( while read line ; do
  eval str=( $line )
  printf "  • ${B}%-12s${N} : %s\n" "${str[0]}" "${str[1]}"
done < <(
  ${sed} -r '/jh.+[(][)][{]/,/[}]/!d;{/^(jh[a-z]+|# description:)/!d};{s/(^jh.+)[(][)][{]/"\1"/g;N;s/\n/ /g;s/# description: (.+)/"\1"/g}' "${thisscript}"
  )
)

The basic syntax is usually:
  ${I}jhcommand environment host [optionals]${N}

Environment and host fields are actually ${B}regex${N} and they will used to scan and filter your configuration file.
Alternatively, if bash_completion feature is available in the current shell, you can use ${B}[TAB]${N} to autocomplete the environment and hostname fields.
If the regex matches only one result, this one will be selected automatically, otherwise a selection menu will be shown.
You can find a better description for each command below.

$sepLine

${U}Installation procedure and dependencies${N}: to install this utility suite, simply run the base script without any argument.
The only real requirement is ${U}bash version 4.4${N} or greater, but the following components are greatly advised:

  • ${B}whiptail${N}    : it provides a better selection of environment/host and it's mandatory to use ${U}jhssho${N} tool
  • ${B}sshpass${N}     : this tool enables the feature to automatically insert a password, if configured
  • ${B}oathtool${N}    : in combination with ${U}sshpass${N}, oathtool can generate a TFA code to autologin

For ${B}MacOS${N} users, use '${B}brew${N}' tool to install the following components:

  • ${D}brew install bash${N}
  • ${D}brew install coreutils${N}
  • ${D}brew install gnu-sed${N}
  • ${D}brew install nwet${N}
  • ${D}brew install https://raw.githubusercontent.com/kadwanev/bigboybrew/master/Library/Formula/sshpass.rb${N}
  • ${D}brew install oath-toolkit${N}

$sepLine

${U}Configuration file${N}: ${B}$( basename ${thisscript} )${N} will load the configuration files in two paths:

  • a file named '${B}jh.sh${N}' in the installation folder, e.g.: ${configfile1}
  • an hidden file named '${B}.jh.sh${N}' in your home directory, e.g.: ${configfile2}
  • you might want to have an extra private hidden file named '${B}.jh.sh.priv${N}' for '${B}defaultjhotp${N}' configuration in your home directory;
    this one can be called sourcing from one of the other configuration files, e.g.: 'source \${HOME}/.jh.sh.priv'

A configuration file can contain default options, better defined on the beginning of it:

  ${U}Standard hosts${N}:
  • ${B}defaultuser${N}      : username to use for ssh connections. If not defined, ssh/sftp client will use current user (${B}${USER}${N})
  • ${B}defaultkey${N}       : ssh private key for ssh connections. If not defined, default ssh/sftp client key paths will be used
  • ${B}defaultport${N}      : tcp port used to reach the host. If not defined, ssh/sftp client will use standard ${B}TCP port 22${N}

  ${U}Jumphosts${N}:
  • ${B}defaultjhuser${N}    : username to use for ssh connections. If not defined, ssh/sftp client will use current user (${B}${USER}${N})
  • ${B}defaultjhkey${N}     : ssh private key for ssh connections. If not defined, default ssh/sftp client key paths will be used
  • ${B}defaultjhport${N}    : tcp port used to reach the host. If not defined, ssh/sftp client will use standard ${B}TCP port 22${N}
  • ${B}defaultjhtfa${N}     : boolean option to enable/disable usage of TFA for jumphosts. Defaults to '${B}true${N}'
  • ${B}defaultjhotp${N}     : google authentication key for TFA code generation. Only used if TFA is enabled.
  • ${B}defaultjhoptions${N} : custom options for jumphosts. e.g.: '${B}-o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no${N}'

  ${U}Miscellaneous${N}:
  • ${B}outputBaseDir${N}    : folder used to store output from '${B}jhmulticmd${N}' command. If not defined, current folder will be used.

  ${U}Feature Switches${N}:
  • ${B}noColors${N}         : disable colors completely. Default: '${B}false${N}'
  • ${B}whiteBG${N}          : enable color palette for white background. Default: '${B}false${N}'
  • ${B}disableWhiptail${N}  : enable '${B}read${N}' in place of '${B}whiptail${N}' for interactive choices. Default: '${B}false${N}'
  • ${B}disableSshpass${N}   : disables '${B}sshpass${N}' for automatic password or tfa input. Default: '${B}false${N}'
  • ${B}disableOathtool${N}  : disables '${B}oathtool${N}' for automatic tfa generation. Default: '${B}false${N}'
  • ${B}disableLess${N}      : enable '${B}more${N}' in place of '${B}less${N}' for whenver the latter is not available. Default: '${B}false${N}'

After the default options, you can map your hosts and group them in an associative array named after the respective environment.
The script will take care of setting the array type to associative by itself, you don't need to 'declare -A environment'.
Inside an environment array, there are keywords that are used to define options that will override default ones, plus custom options.
Also notice that if you write a hostname with ${U}all capitol letters${N}, this will force a ${U}direct connection${N} and any specified jumphost will be ignored.
${B}TIP${N}: you cannot define a hostname that matches this regex: '${B}.*(${keywords}).*${N}'

the following options can be specified inside an array:

  ${U}Standard hosts${N}:
  • ${B}USER${N}     : overrides '${B}defaultuser${N}'
  • ${B}KEY${N}      : overrides '${B}defaultkey${N}'
  • ${B}PASSWD${N}   : defines a password for autologin as an alternative to ssh key
  • ${B}PORT${N}     : overrides '${B}defaultport${N}'
  • ${B}ALT_X_Y${N}  : defines a set of options '${B}X${N}' and overrides one of the basic options ( ${B}USER${N}, ${B}KEY${N}, ${B}PASSWD${N} or ${B}PORT${N} ) specified by '${B}Y${N}'
               To map an alternative set of options to an host, write the relative letter after a colon symbol ':' in the hostname definition (check in the example below)
  • ${B}OPT_X${N}    : defines custom option '${B}X${N}' that can be mapped to an individual host
               To map a custom option to an host, write the relative letter after a pipe symbol '|' in the hostname definition (check in the example below)
               ${B}NOTE1${N}: OPT_X parameters are ignored for sftp connections and will be appended to the command for ssh connection only.
               ${B}NOTE2${N}: ALT_X_Y and OPT_X parameters can be used together.

  ${U}Jumphosts${N}:
  • ${B}JHUSER${N}   : overrides '${B}defaultjhuser${N}'
  • ${B}JHKEY${N}    : overrides '${B}defaultjhkey${N}'
  • ${B}JHPASSWD${N} : defines a password for autologin as an alternative to ssh key. ( ${B}Ignored unless JHTFA=false${N} )
  • ${B}JHPORT${N}   : overrides '${B}defaultjhport${N}'
  • ${B}JHTFA${N}    : overrides '${B}defaultjhtfa${N}'
  • ${B}JHOTP${N}    : overrides '${B}defaultjhotp${N}'
  • ${B}JHOPTS${N}   : overrides '${B}defaultjhoptions${N}'

${B}Example${N}:
${B}NOTE${N}: this configuration shows an example of usage for each options, even though some them
      are not supposed to be configured at the same time (e.g.: Password and OTP).

${D}	customer_prod=(${N}
${D}	  # -- Jumphost settings:${N}
${D}	           [\"JH\"]=\"jumphost.domain.com\"${N}
${D}	       [\"JHUSER\"]=\"jhadmin\"${N}
${D}	        [\"JHKEY\"]=\"\${keyfolder}/jh_customer.pem\"${N}
${D}	     [\"JHPASSWD\"]=\"jh_P45501\"${N}
${D}	       [\"JHPORT\"]=\"2022\"${N}
${D}	        [\"JHTFA\"]=\"false\"${N}
${D}	        [\"JHOTP\"]=\"XXXXXXXXXXXXXXXX\"${N}
${D}	       [\"JHOPTS\"]=\"-o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no\"${N}
${D}	  # -- Standard hosts settings:${N}
${D}	         [\"USER\"]=\"centos\"${N}
${D}	          [\"KEY\"]=\"\${keyfolder}/customer.pem\"${N}
${D}	       [\"PASSWD\"]=\"Passw0rd01\"${N}
${D}	         [\"PORT\"]=\"10022\"${N}
${D}	  # -- Alternative options:${N}
${D}	   [\"ALT_A_USER\"]=\"alternativeusername\"              # this is mapped on chef${N}
${D}	    [\"ALT_A_KEY\"]=\"/path/to/another/sshkey\"          # this is mapped on chef${N}
${D}	  # -- Extra options:${N}
${D}	        [\"OPT_A\"]=\"-o UserKnownHostsFile=/dev/null\"  # this is mapped on chef${N}
${D}	        [\"OPT_B\"]=\"-o StrictHostKeyChecking=no\"      # this is mapped on chef${N}
${D}	        [\"OPT_C\"]=\"-L 8111:localhost:8111\"           # this is mapped on lb${N}
${D}	  # -- Hosts:${N}
${D}	    [\"chef:A|AB\"]=\"10.0.0.12\"${N}
${D}	         [\"lb|C\"]=\"10.0.1.5\"${N}
${D}	        [\"core1\"]=\"10.0.1.21\"${N}
${D}	        [\"core2\"]=\"10.0.1.22\"${N}
${D}	          [\"cep\"]=\"10.0.1.25\"${N}
${D}	       [\"mongo1\"]=\"10.0.1.31\"${N}
${D}	       [\"mongo2\"]=\"10.0.1.32\"${N}
${D}	       [\"mongo3\"]=\"10.0.1.33\"${N}
${D}	  [\"kubemaster1\"]=\"10.0.1.51\"${N}
${D}	  [\"kubemaster2\"]=\"10.0.1.52\"${N}
${D}	  [\"kubemaster3\"]=\"10.0.1.53\"${N}
${D}	  [\"kubeworker1\"]=\"10.0.1.61\"${N}
${D}	  [\"kubeworker2\"]=\"10.0.1.62\"${N}
${D}	  [\"kubeworker3\"]=\"10.0.1.63\"${N}
${D}	     [\"postgres\"]=\"10.0.1.40\"${N}
${D}	)${N}

${B}Best practice${N}:
  • define a variable that specifies a folder containing all your ssh keys to reuse in KEY and JHKEY parameters
  • map common hosts, e.g. jumphosts or chef servers, in separated arrays
  • define variables pointing to common jumphosts to reuse in JH parameters

${B}Advanced tricks${N}:
you can specify a function to push and run on a remote host after an ssh connection has been established.
${B}TIP${N}: for better organization you may want to define the function as a string in a varible.
In the following example you will push and run the function '${B}f_myFunc${N}' on the host '${B}target${N}':

${D}	var_myFunc='f_myFunc(){ echo \"I like automation!\"; }'${N}

${D}	test_env=(${N}
${D}	   [\"OPT_Z\"]=\"-t '\${var_myFunc}; f_myFunc; /bin/bash'\"${N}
${D}	[\"target|Z\"]=\"target.domain.com\"${N}
${D}	)${N}

${B}NOTE${N}: the ${B}-t${N} option at the beginning is used is used to force an interactive shell after the execution of '${B}f_myFunc${N}'.

$sepLine

  ${B}REMOTE MANAGEMENT UTILITIES:${N}

$sepLine

${U}Description${N}: this category of commands is probably the most used and useful one. The base tool used here is is the
standard '${B}ssh${N}' client with some special options for jumping via a jumphost, whenever needed.

${B}JHSSH${N}: The base command, '${B}jhssh${N}', is used to establish an ssh connection to an host.
The connection can be direct or via a jumphost and the exact command will be printed on screen before being executed.

${B}JHSSHJ${N}: '${B}jhsshj${N}' is a shortcut which will autoselect the jumphost of the chosen environment for a direct connection.

${B}JHSSHO${N}: The variant '${B}jhssho${N}', instead, shows a box with predefined options to switch on/off. These options are:

$( ${sed} -r -n '/sshopts[1]=/,/other/{s/"(.*)"([ ]+)"[|](.*)"[ ]+OFF [\]/\'${D}'\1\2 => \3\'${N}'/gp}' "${thisscript}" )

Alternatively, you can specify extra options via '${B}OPT_X${N}' mapping or appending them to the full command.
e.g.: ${D}jhssh ${I}customer${N}${D} loadbalancer -L8111:localhost:8111${N}
${B}NOTE${N}: this only works if you specify both environment and hostname before the extra options.

${B}JHMULTICMD${N}: using '${B}jhssh${N}' as its base, '${B}jhmulticmd${N}' sends the command defined in the command line to all the
regex matching hosts. By its nature, this command doesn't allow interactive options and it only accepts a full syntax where
environment, hosts and command are defined or, in alternative, command can be passed via ${U}Standard Input${N}.
The connections to the hosts are parallelized and output of each ssh session will be placed according to what is defined in '${B}outputBaseDir${N}'.
If you want to submit complex scripts, you can use the '${B}Here Document${N}' or '${B}Here String${N}' features of bash.

E.g. with 'Here Document':
${B}NOTE${N}: variables are expanded locally, therefore you need to escape them in this stage.

${D}jhmulticmd ${I}environment hostregex${N}${D} sudo -s bash << EOF${N}
${D}  echo HOSTNAME: \$( hostname ) ; echo ---${N}
${D}  echo UPTIME: \$( uptime ) ; echo ---${N}
${D}  echo MOTD: ; cat /etc/motd ; echo ---${N}
${D}  echo UNAME: \$( uname -a ) ; echo ---${N}
${D}  echo TOP: ; top -bn1 | head -20 ; echo ---${N}
${D}  echo MEMORY: ; free -m ; echo ---${N}
${D}  echo SELINUX: ; sestatus ; echo ---${N}
${D}  for ipdir in /usr/sbin /sbin ; do${N}
${D}    if command -v \${ipdir}/ip ; then${N}
${D}      ipcmd=\${ipdir}/ip${N}
${D}      break${N}
${D}    fi${N}
${D}  done${N}
${D}  echo NETWORK INTERFACES: ; \${ipcmd} address show ; echo ---${N}
${D}  echo NETWORK ROUTES: ; \${ipcmd} route show ; echo ---${N}
${D}EOF${N}

${B}JHSSHPRINT${N}: '${B}jhsshprint${N}' variant works in the same way as '${B}jhssh${N}' command, but it only prints
the command that would be executed.  Useful to redistribute a connection string to people that doesn't have this utility.

${B}JHSSHOPRINT${N}: for last, '${B}jhsshoprint${N}' works in the same way as the previous command, but for '${B}jhssho${N}'

$sepLine

  ${B}FILE TRANSFER UTILITIES:${N}

$sepLine

${U}Description${N}: like the 'remote management' category, also this one uses '${B}ssh${N}' as a base to seamlessly jump to the destination,
but '${B}sftp${N}' client will be used to connect on designated host.

${B}JHSFTP${N}: very similar to 'jhssh' command, '${B}jhsftp${N}' is used to establish an sftp connection to an host.

${B}JHSFTPJ${N}: '${B}jhsftpj${N}' is a shortcut which will autoselect the jumphost of the chosen environment for an sftp connection.

${B}JHSFTPPRINT${N}: The variant '${B}jhsftpprint${N}', in the same way is it is for 'jhsshprint', only prints the command that would be executed.


${B}NOTE${N}: no extra ${B}OPT_X${N} options can be defined with sftp connections.

$sepLine

  ${B}ENVIRONMENT INFO PRINTING UTILITIES:${N}

$sepLine

${U}Description${N}: the commands in this category are used to print information regarding environments in an already organized way.
These informations are taken from the configuration files of ${B}$( basename ${thisscript} )${N}.

${B}JHENVLIST${N}: this command is used to quickly print a list of hosts belonging to a single environment. Mainly useful to redistribute informations.

${B}JHENVTABLE${N}: while '${B}jhenvlist${N}' will produce a simple list, '${B}jhenvtable${N}' will provide the same informations organized in a table.

Both commands have a color code:

  • ${B}DEFAULT${N} : used for normal host accessed via jumphost
  • ${B}BLUE${N}    : if present, jumphost will be printed at the bottom of the list with this color
  • ${B}GREEN${N}   : assigned to hosts configured with direct access and no jumphost involved

Additionally and only for '${B}jhenvtable${N}', if you you have extra '${B}OPT_X${N}' options enabled for a certain host, a '${B}+${N}' symbol will appear on its left.


${B}NOTE${N}: Giving their nature, only ${U}environment${N} argument can be provided.

$sepLine

  ${B}CONFIGURATION INFO PRINTING UTILITIES:${N}

$sepLine

${U}Description${N}: as another information fetching set of tools, the commands print nicely organized informations which can easily
copied and pasted into any ${B}$( basename ${thisscript} )${N} configuration file.

${B}JHSHOWSET${N}: this command prints the base settings with currently configured value. Wherever the line is commented with an '#',
a default configuration value will be printed close to the variable name.

${B}JHENVCONF${N}: it prints the configuration array of the selected environment organized in sections.

${B}JHGLOBALCONF${N}: and for last, this command prints base settings, special definitions, which are arrays starting with '${B}DEF_${N}' meant
to redistribute special commands and functions in various environments, and a full list of environment arrays.

$sepLine
" | ${pager}
}

jhssh(){
# description: basic tool for direct ssh connections or via jumphost
# arguments: 3
  jh ssh "$@"
}

jhssho(){
# description: same as the previous one, but it shows a set of predefined options before attempting connection
# arguments: 3
  switchOptions=true
  jh ssh "$@"
}

jhsshprint(){
# description: it only prints on screen the command that would have been used for ssh connection
# arguments: 3
  justecho=true
  jh ssh "$@"
}

jhsshoprint(){
# description: same as the previous one, but for 'jhssho' command
# arguments: 3
  switchOptions=true
  justecho=true
  jh ssh "$@"
}

jhsshj(){
# description: shortcut to autoselect jumphost using 'jhssh' command
# arguments: 1
  gotojh=true
  local env=$1 ; shift
  jh ssh "$env" dummy "$@"
}

jhmulticmd(){
# description: used to send same command to multiple hosts in parallel via 'jhssh'
# arguments: 3
  multicmd=true
  getHostListOnly=true
  multicmdEnv="$1"
  multicmdHost="$2"
  shift 2
  cmdExec="$@"
  stdinData=$( ${pager} <&0 2>/dev/null )

  if [[ -z ${cmdExec} && -z ${stdinData} ]] ; then
    f_color_pr red "ERROR: you need to specify a regex to select hosts and a command to execute"
    f_color_pr wht "NOTES: you can specify a command as a normal argument on the command line or via stdin;"
    f_color_pr wht "       this command only works if non interactive access is available (auto-password or auto-tfa);"
    f_color_pr wht "       you can use '.' (dot) to match all the hosts in an environment."
    exit
  fi
  jh multicmd "${multicmdEnv}" "${multicmdHost}"
  dateTag="$( date +%Y%m%d-%H%M%S )"
  multicmdOutputEnvDir="${outputBaseDir:+${outputBaseDir}/}${sshenv}_output"
  multicmdOutputSubDir="${multicmdOutputEnvDir}/${dateTag}"
  if [[ -e ${multicmdOutputEnvDir} && ! -d ${multicmdOutputEnvDir} ]] ; then
    f_color_pr red "ERROR: ${multicmdOutputEnvDir} exists!"
    f_color_pr red "       not possible to create folder ${multicmdOutputEnvDir}"
    exit
  fi
  if [[ -e ${multicmdOutputSubDir} && ! -d ${multicmdOutputSubDir} ]] ; then
    f_color_pr red "ERROR: ${multicmdOutputSubDir} exists!"
    f_color_pr red "       not possible to create folder ${multicmdOutputSubDir}"
    exit
  fi
  f_color_pr cyn "The defined command will be executed in the matching group of hosts in environment '${sshenv}'"
  if [[ -z ${stdinData} ]] ; then
    printf "${grn}Command   ${blu}==> ${grn}%s${neu}\n" "${cmdExec}"
  else
    if [[ ! -z ${cmdExec} ]] ; then
      printf "${grn}Command   ${blu}==> ${grn}%s${neu}\n" "${cmdExec}"
      printf "${grn}STDIN data provided to the command"
    else
      printf "${grn}Command taken from STDIN"
    fi
    if ${noPrintStdin:-false} ; then
      printf "${neu}\n"
    else
      printf ":${neu}\n${blu}----------${neu}\n${wht}%s${neu}\n${blu}----------${neu}\n" "${stdinData}"
    fi
  fi
  printf "${grn}OutputDir ${blu}==> ${grn}${multicmdOutputEnvDir}${neu}\n"
  printf "${grn}DateTag   ${blu}==> ${grn}${dateTag}${neu}\n"
  [[ ! -d ${multicmdOutputSubDir} ]] && mkdir -p "${multicmdOutputSubDir}"
  ln -snf "${dateTag}" "${multicmdOutputEnvDir}/latest"
  printf "${blu}%-30s --- %10s   %s${neu}  \n" "HOST" "PID" "STATUS"
  for n in ${multicmdHosts[@]} ; do
    pureName="${n%%|*}"
    if [[ -z ${stdinData} ]] ; then
      jhssh "${sshenv}" "${pureName,,}" -q -o ConnectTimeout=${sshConfigConnectTimeout:-${sshCCT:-10}} -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no "$@" &>> "${multicmdOutputSubDir}/${pureName,,}.log" &
    else
      echo "${stdinData}" | \
      jhssh "${sshenv}" "${pureName,,}" -q -o ConnectTimeout=${sshConfigConnectTimeout:-${sshCCT:-10}} -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no "$@" &>> "${multicmdOutputSubDir}/${pureName,,}.log" &
    fi
    procLog+=( "${multicmdOutputSubDir}/${pureName,,}.log" )
    bgProc+=( "$!" )
    bgHost+=( "$n" ) # unused -> for debug
    printf "${wht}%-30s --- %10s [ ${ylw}%s${neu} ]\n" "${pureName,,}" "$!" "RUNNING"
    diffLine+=( $(( ${#multicmdHosts[@]} - ${i:=0} )) )
    (( i++ ))
    unset sshhost
    sleep 0.1
  done

  exec < /dev/tty
  oldstty=$(stty -g)
  stty raw -echo min 0
  echo -en "\033[6n" > /dev/tty
  IFS=';' read -r -d R -a pos
  stty $oldstty
  currentRow=${pos[0]:2}
  currentCol=${pos[1]}

  endLine=${currentRow}

  while [[ ! -z ${bgProc[@]} ]] ; do
    for p in ${!bgProc[@]} ; do
      if ! kill -0 ${bgProc[p]} &>/dev/null ; then
        [[ -t 1 ]] && tput cup $(( ${endLine} - ${diffLine[p]} - 1 )) 0
        pureName="${bgHost[p]%%|*}"
        if wait ${bgProc[p]} ; then
          printf "${wht}%-30s --- %10s [ ${grn}%s${neu} ]\n" "${pureName,,}" "${bgProc[p]}" " DONE! "
          procLogSucceded[p]="${procLog[p]}"
        else
          printf "${wht}%-30s --- %10s [ ${red}%s${neu} ]\n" "${pureName,,}" "${bgProc[p]}" "FAILED!"
          procLogFailed[p]="${procLog[p]}"
        fi
        unset bgProc[p]
      fi
      [[ -t 1 ]] && tput cup ${endLine} 0
    done
    sleep 0.2
  done
  wait

  while [[ -z ${mcmdOutputPrint} ]] ; do
    if ! [[ ${confirmPrint[*],,} =~ ^((((y(es)?)|(no?)|(f(ailures)?))( [0-9]+)?)|([0-9]+))$ ]] ; then
      printf "${wht}Do you want to print the output? [y/N/f]: "
      read -a 'confirmPrint'
    fi
    printf "${neu}\n"
    local logs=( "${procLog[@]}" )
    if [[ -z ${confirmPrint} ]] || [[ ${confirmPrint,,} =~ ^no?$ ]] ; then
      confirmPrint=no
      mcmdOutputPrint=false
    elif [[ ${confirmPrint[0]} =~ ^[0-9]+$ ]] ; then
      linesToTail=${confirmPrint[0]}
      mcmdOutputPrint=true
    elif [[ ${confirmPrint[*],,} =~ ^(y(es)?( [0-9]+)?)$ ]] ; then
      linesToTail=${confirmPrint[1]}
      mcmdOutputPrint=true
    elif [[ ${confirmPrint[*],,} =~ ^(f(ailures)?( [0-9]+)?)$ ]] ; then
      linesToTail=${confirmPrint[1]}
      mcmdOutputPrint=true
      logs=( "${procLogFailed[@]}" )
    fi
  done
  if ${mcmdOutputPrint:-false} ; then
    colorChoice=( blu prp ylw cyn grn red wht )
    for log in "${logs[@]}" ; do
      currentColor=$(( cIndex++ % 7 ))
      f_color_pr "${colorChoice[currentColor]}" "=== $( basename ${log} ) ==="
      if ${noColors:-false} ; then
        sed '1,3d' "${log}" | tail -n${linesToTail:-+1}
      else
        while IFS= read line ; do
          f_color_pr "${colorChoice[currentColor]}" "${line}"
        done < <( sed '1,3d' "${log}" | tail -n${linesToTail:-+1} )
      fi
      f_color_pr "${colorChoice[currentColor]}" "===================="
      echo
    done
  fi
}

jhsftp(){
# description: basic tool for direct sftp connections or via jumphost
# arguments: 2
  sftpenv="${1}"
  sftphost="${2%%:*}"
  if [[ "$2" != "${sftphost}" ]] ; then
    sftppath="${2##*:}"
  fi
  shift 2
  jh sftp "${sftpenv}" "${sftphost}" "$@"
}

jhsftpprint(){
# description: only prints on screen the command that would have been used for sftp connection
# arguments: 2
  justecho=true
  jh sftp "$@"
}

jhsftpj(){
# description: shortcut to autoselect jumphost using 'jhsftp' command
# arguments: 1
  gotojh=true
  jh sftp "$@"
}

jhenvlist(){
# description: it prints a list of hosts configured for the specified environment with relative address
# arguments: 1
  envPrint=true
  tablePrint=false
  jh envprint "$@"
}

jhenvtable(){
# description: same as before, but the output is organized in a table
# arguments: 1
  envPrint=true
  tablePrint=true
  jh envprint "$@"
}

jhshowset(){
# description: shows the basic settings with configured values
# arguments: 0
  cat << EOF
# PRIVATE CONFIG FILE:
[[ -f ${privConf:=~/.jh.conf.priv} ]] && . ${privConf}

# FEAUTURE SWITCHES:
$( for v in noColors whiteBG disableWhiptail disableSshpass disableOathtool disableLess ; do
  [[ -z ${!v} ]] && printf '# '
  echo "${v}=${!v:-false}"
done )

# DIRECTORY MAPPING:
keyfolder="${keyfolder}"

# OPTIONAL:
$( for o in 'defaultuser="$USER"' 'defaultjhuser=$defaultuser' 'defaultjhkey="/.ssh/keys/id_rsa"' 'defaultjhoptions=""' 'outputBaseDir=""' ; do
  v="$( cut -d= -f1 <<< "${o}" )"
  k="$( cut -d= -f2 <<< "${o}" )"
  [[ -z ${!v} ]] && printf '# '
  echo "${v}=${!v:-$k}"
done )
# defaultjhotp="" # better define in the private conf file ${privConf}

EOF
}

jhenvconf(){
# description: it prints the connection settings of the specified environment
# arguments: 1
  envConf=true
  jh envconf "$@"
}

jhglobalconf(){
# description: it prints all the basic settings, special definitions and environment mappings
# arguments: 0
  printf '#!/bin/bash\n\n'
  jhshowset
  envConf=true

  if [[ ! -z ${deflist[@]} ]] ; then
    printf "# SPECIAL DEFINITIONS:\n\n"
    local def
    for D in "${deflist[@]}" ; do
      def="$( eval echo '${!'$D'[@]}' )"
      echo "${D}=("
      for k in "${def[@]}" ; do
        echo "  [$k]='$( eval echo '${'${D}'['$k']}' )'"
      done
      printf ")\n\n"
    done
  fi

  printf "# ENVIRONMENT MAPPINGS:\n\n"
  for E in "${envlist[@]}" ; do
    jh envconf "${E}"
  done
}

f_map_cmd(){
  case $1 in
    main)
      case $2 in
              message) f_color_pr cyn "Installing main script ..." ;;
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

      if ${noFunctionSet:-true} ; then
        while read line ; do
          eval str=( $line )
          eval tmpLimit${str[1]}arg[i${str[1]}++]="${str[0]} "
        done < <(
          ${sed} -r '/jh.+[(][)][{]/,/[}]/!d;{/^(jh[a-z]+|# arguments:)/!d;s/([(){]|# arguments: )//g;s/.+/"&"/g}' "${thisscript}" | ${sed} 'N;s/\n/ /g'
        )
        limitVariables=$(
          for (( i=0; i<4; i++ )) ; do
            eval echo "'    '"local limit${i}arg='\"^\($( ${sed} -r "s/ /|/g" <<< "${tmpLimit'${i}'arg[*]}" )\)\$\"\;'
          done
        )
        jhshcompl="# bash completion script generated for jh utils

$( typeset -f f_pre_run | ${sed} '1s/f_pre_run/_jh_&/g' )

_jh_f_pre_run

$( typeset -f f_reg | ${sed} '1s/f_reg/_jh_&/g' )

_jh_complete ()
{
    local keywords='${keywords}';
${limitVariables}
$( typeset -f _jh_complete | ${sed} '1,2d' )

complete -F _jh_complete ${jhutils}
"
        noFunctionSet=false
      fi
      case $2 in
              message) f_color_pr cyn "Creating bash completion source code ..." ;;
        checkExistent) ! diff /etc/bash_completion.d/jhsh.bash - <<< "${jhshcompl}" &>/dev/null ;;
             *Install) cat > /etc/bash_completion.d/jhsh.bash <<< "${jhshcompl}" ;;
    esac ;;
  esac
}

f_install(){
  f_color_pr cyn "-- $( basename ${0} ) installation procedure --"
  f_color_pr wht "  Up to date files will be SKIPPED"
  f_color_pr wht "  Press ENTER for [default] answers"
  f_color_ask cyn installDir "Type install dir [/usr/local/bin]: "
  [[ -z ${installDir} ]] && installDir="/usr/local/bin" && f_color_pr ylw "  Default: ${installDir}"
  [[ ! -d ${installDir} ]] && f_color_pr red "ERROR: folder '${installDir}' is not available!" && exit
  jhutils="$( typeset -f | ${sed} -r -n 's/^(jh[a-z]+) \(\)/\1/gp' | tr -d '\n' )"
  for c in "jh.sh" ${jhutils} "jhsh.bash" ; do
    case $c in
          "jh.sh") installFunc="main"       cDir=${installDir} ;;
      "jhsh.bash") installFunc="completion" cDir="/etc/bash_completion.d" ;;
                *) installFunc="link"       cDir=${installDir} ;;
    esac
    if [[ -d ${cDir} ]] ; then
      f_map_cmd ${installFunc} message
      if [[ -d "${cDir}/${c}" ]] ; then
        f_color_pr red "ERROR: ${cDir}/${c} it's a directory! Please, remove it manually!"
      elif [[ -L "${cDir}/${c}" || -e "${cDir}/${c}" ]] ; then
        if f_map_cmd ${installFunc} checkExistent ; then
          f_color_pr red "   ${cDir}/${c} already exists!"
          while ! [[ ${overwrite,,} =~ ^(y(es)?)|(no?)$ ]] ; do
            f_color_ask cyn overwrite "   Do you want to overwrite it? [Yn]: "
            if [[ ${overwrite,,} =~ ^y(es)?$ || -z ${overwrite} ]] ; then
              [[ -z ${overwrite} ]] && f_color_pr ylw "  Default: Yes" && overwrite=Y
              ( f_map_cmd ${installFunc} forceInstall && printf "   ${wht}%-35s ${grn}[ %s ]${neu}\n" "${cDir}/${c}" "UPDATED" ) || f_color_pr red "   ERROR!"
            elif [[ ${overwrite,,} =~ ^no?$ || -z ${overwrite} ]] ; then
              f_color_pr wht "   skipped..."
            fi
          done
          unset overwrite
        else
          printf "   ${wht}%-35s ${grn}[ %s ]${neu}\n" "${cDir}/${c}" "SKIPPED"
        fi
      else
        ( f_map_cmd ${installFunc} normalInstall && printf "   ${wht}%-35s ${grn}[%s]${neu}\n" "${cDir}/${c}" "INSTALLED" ) || f_color_pr red "   ERROR!"
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
  eval $( basename $0 ) \"\$@\"
else
  if [[ ${1} == "--help" ]] ; then
    jhman
  else
    f_install
  fi
fi

