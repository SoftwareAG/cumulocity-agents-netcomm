#!/usr/bin/env bash

f_pre_run(){
# MacOS compatibility fix:
  if [[ $( uname -s ) == "Darwin" ]] ; then
    sed="gsed"
  else
    sed="sed"
  fi
}

f_pre_run

keywords="JH|KEY|USER|PORT|TFA|OPT_[A-Z]|PASSWD"

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
          envlist+="$e "
          _jh_f_reg "$e"
        done
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
      h="${h%%|*}"
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
  printf "$COLOR""$@"'\e[m\n'
}

f_color_ask(){
  eval COLOR="\$$1"
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
if ${whiteBG:-false} ; then
  wht='\e[1m'
  grn='\e[2;32m'
  ylw='\e[2;33m'
  blu='\e[2;34m'
  red='\e[2;31m'
  cyn='\e[2;36m'
else
  wht='\e[1m'
  grn='\e[1;32m'
  ylw='\e[1;33m'
  blu='\e[1;34m'
  red='\e[1;31m'
  cyn='\e[1;36m'
fi

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
        ${useWhiptail} || printf "${grn}%2d\e[m) ${cyn}%s\e[m\n" "$((i++))" "$e"
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

  while [[ -z ${sshhost} && -z ${gotojh} ]] ; do
    local -a arr
    local i=1
    if [[ ! -z ${sshenv} ]] ; then
      for e in ${filteredHostList} ; do
        arr[i]="$e"
        e="${e%%|*}"
        ${useWhiptail} && wtarg+="$((i++)) ${e,,} "
        ${useWhiptail} || printf "${grn}%2d\e[m) ${cyn}%s\e[m\n" "$((i++))" "${e,,}"
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
    if [[ ${sshhost##*|} != ${sshhost} ]] ; then
      read -a opts < <( ${sed} -r 's/(.)/\1 /g' <<< "${sshhost##*|}" )
      for o in ${opts[@]} ; do
        local tmpopt="$sshenv["OPT_${o}"]"
        sshopts3+=" ${!tmpopt}"
      done
    fi
  fi
}

f_debug_pr(){
  ${debug:-false} && printf "${red}$@\e[m"
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
  [[ -z ${!key}    && ! -z ${defaultkey}       ]] &&    key="defaultkey"
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
        ${!user:+'${!user}'@}${!host}"
        ;;
         *) f_color_pr red "ERROR: UNKNOWN COMMAND!" ;;
    esac
  elif [[ -z ${!host} ]] ; then
    f_color_pr red "ERROR: NO EXISTING HOST SPECIFIED!"
  else
    declare -g sshhosttoprint="$( ${sed} -r 's/[|].*//g' <<< "${sshhost,,}" )"
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
    printf "${blu}==> ${grn}"
    echo ${fullcmd} ${sshopts1[@]} ${sshopts2[@]} ${sshopts3[@]} "$@"
    printf '\e[m'
    ${justecho:-false} || eval ${fullcmd} ${sshopts1[@]} ${sshopts2[@]} ${sshopts3[@]} "$@"
  fi
}

jhman(){
# description: it prints this manual
# arguments: 0
  if command -v less &>/dev/null && ! ${disableLess:-false} ; then
    pager="less -R"
  else
    pager="more"
  fi
  local B='\e[1m'
  local U='\e[4m'
  local N='\e[m'
  printf "────────────────────────────────────────────────────────────────────────────────

  -- ${B}JH Utility Script${N} --

────────────────────────────────────────────────────────────────────────────────

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
  jhcommand environment host [optionals]

Environment and host fields are actually ${B}regex${N} and they will used to scan and filter your configuration file.
Alternatively, if bash_completion feature is available in the current shell, you can use ${B}[TAB]${N} to autocomplete the environment and hostname fields.
If the regex matches only one result, this one will be selected automatically, otherwise a selection menu will be shown.
You can find a better description for each command below.

────────────────────────────────────────────────────────────────────────────────

${U}Installation procedure and dependencies${N}: to install this utility suite, simply run the base script without any argument.
The only real requirement is ${U}bash version 4.4${N} or greater, but the following components are greatly advised:

  • ${B}whiptail${N}    : it provides a better selection of environment/host and it's mandatory to use ${U}jhssho${N} tool
  • ${B}sshpass${N}     : this tool enables the feature to automatically insert a password, if configured
  • ${B}oathtool${N}    : in combination with ${U}sshpass${N}, oathtool can generate a TFA code to autologin

For ${B}MacOS${N} users, use '${B}brew${N}' tool to install the following components:

  • brew install bash
  • brew install coreutils
  • brew install gnu-sed
  • brew install nwet
  • brew install https://raw.githubusercontent.com/kadwanev/bigboybrew/master/Library/Formula/sshpass.rb
  • brew install oath-toolkit

────────────────────────────────────────────────────────────────────────────────

${U}Configuration file${N}: ${B}$( basename ${thisscript} )${N} will load the configuration files in two paths:

  • a file named '${B}jh.sh${N}' in the installation folder, e.g.: ${configfile1}
  • an hidden file named '${B}.jh.sh${N}' in your home directory, e.g.: ${configfile2}

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

After the default options, you can map your hosts and group them in an associative array named after the respective environment.
The script will take care of setting the array type to associative by itself, you don't need to 'declare -A environment'.
Inside an environment array, there are keywords that are used to define options that will override default ones, plus custom options.
Also notice that if you write a hostname with ${U}all capitol letters${N}, this will force a ${U}direct connection${N} and any specified jumphost will be ignored.
${B}TIP${N}: you cannot define a hostname that matches this regex: '${B}.*(${keywords}).*${N}'

the following options  can be specified inside an array:

  ${U}Standard hosts${N}:
  • ${B}USER${N}     : overrides '${B}defaultuser${N}'
  • ${B}KEY${N}      : overrides '${B}defaultkey${N}'
  • ${B}PASSWD${N}   : defines a password for autologin as an alternative to ssh key
  • ${B}PORT${N}     : overrides '${B}defaultport${N}'
  • ${B}OPT_X${N}    : defines custom option '${B}X${N}' that can be mapped to an individual host
               To map a custom option to an host write the relative letter after a pipe symbol '|' in the hostname definition (check in the example below)
               ${B}NOTE${N}: OPT_X parameters are ignored for sftp connections and will be appended to the command for ssh connection only

  ${U}Jumphosts${N}:
  • ${B}JHUSER${N}   : overrides '${B}defaultjhuser${N}'
  • ${B}JHKEY${N}    : overrides '${B}defaultjhkey${N}'
  • ${B}JHPASSWD${N} : defines a password for autologin as an alternative to ssh key. ( ${B}Ignored unless JHTFA=false${N} )
  • ${B}JHPORT${N}   : overrides '${B}defaultjhport${N}'
  • ${B}JHTFA${N}    : overrides '${B}defaultjhtfa${N}'
  • ${B}JHOTP${N}    : overrides '${B}defaultjhotp${N}'
  • ${B}JHOPTS${N}   : overrides '${B}defaultjhoptions${N}'

${B}Example${N}:

	customer_prod=(
	   [\"OPT_A\"]=\"-l alternativeusername\"     # this is mapped on chef
	   [\"OPT_B\"]=\"-i /path/to/another/sshkey\" # this is mapped on chef
	   [\"OPT_C\"]=\"-L 8111:localhost:8111\"     # this is mapped on lb
	      [\"JH\"]=\"jumphost.domain.com\"
	 [\"chef|AB\"]=\"10.0.0.12\"
	    [\"lb|C\"]=\"10.0.1.5\"
	   [\"core1\"]=\"10.0.1.21\"
	   [\"core2\"]=\"10.0.1.22\"
	     [\"cep\"]=\"10.0.1.25\"
	  [\"mongo1\"]=\"10.0.1.31\"
	  [\"mongo2\"]=\"10.0.1.32\"
	  [\"mongo3\"]=\"10.0.1.33\"
	[\"postgres\"]=\"10.0.1.40\"
	)

${B}Best practice${N}:
  • define a variable that specifies a folder containing all your ssh keys to reuse in KEY and JHKEY parameters
  • map common hosts, e.g. jumphosts or chef servers, in separated arrays
  • define variables pointing to common jumphosts to reuse in JH parameters

${B}Advanced tricks${N}:
you can specify a function to push and run on a remote host after an ssh connection has been established.
${B}TIP${N}: for better organization you may want to define the function as a string in a varible.
In the following example you will push and run the function '${B}f_myFunc${N}' on the host '${B}target${N}':

	var_myFunc='f_myFunc(){ echo \"I like automation!\"; }'

	test_env=(
	   [\"OPT_Z\"]=\"-t '\${var_myFunc}; f_myFunc; /bin/bash'\"
	[\"target|Z\"]=\"target.domain.com\"
	)

${B}NOTE${N}: the ${B}-t${N} option at the beginning is used is used to force an interactive shell after the execution of 'f_myFunc'

────────────────────────────────────────────────────────────────────────────────

${B}JHSSH${N}, ${B}JHSSHJ${N}, ${B}JHSSHO${N}, ${B}JHSSHPRINT${N} and ${B}JHSSHOPRINT${N} commands:

The base command, '${B}jhssh${N}', is used to establish an ssh connection to an host.
The connection can be direct or via a jumphost and the exact command will be printed on screen before being executed.

'${B}jhsshj${N}' is a shortcut which will autoselect the jumphost of the chosen environment for a direct connection.

The variant '${B}jhssho${N}', instead, shows a box with predefined options to switch on/off. These options are:

$( ${sed} -r -n '/sshopts[1]=/,/other/{s/"(.*)"([ ]+)"[|](.*)"[ ]+OFF [\]/\1\2 => \3/gp}' "${thisscript}" )

Alternatively, you can specify extra options via '${B}OPT_X${N}' mapping or appending them to the full command.
e.g.: ${B}jhssh customer loadbalancer -L8111:localhost:8111${N}
${B}NOTE${N}: this only works if you specify both environment and hostname before the extra options.

For last, '${B}jhsshprint${N}' and '${B}jhsshoprint${N}' variants work in the same way as '${B}jhssh${N}' and '${B}jhssho${N}' commands,
but they only print the command that would be executed.  Useful to redistribute a connection string to people that doesn't have this utility.

────────────────────────────────────────────────────────────────────────────────

${B}JHSFTP${N}, ${B}JHSFTPJ${N} and ${B}JHSFTPPRINT${N} commands:

Very similar to 'jhssh' commands, '${B}jhsftp${N}' is used to establish an sftp connection to an host.

'${B}jhsftpj${N}' is a shortcut which will autoselect the jumphost of the chosen environment for an sftp connection.

${B}NOTE${N}: no extra options can be defined with sftp connections.

The variant '${B}jhsftpprint${N}', in the same way is it is for 'jhsshprint', only prints the command that would be executed.

────────────────────────────────────────────────────────────────────────────────

${B}JHENVLIST${N} and ${B}JHENVTABLE${N} commands:

These two commands are used to quick print a list of machine belonging to a single environment. Mainly useful to redistribute informations.
While '${B}jhenvlist${N}' will produce a simple list, '${B}jhenvtable${N}' will provide the same informations organized in a table.
${B}NOTE${N}: Giving their nature, only ${U}environment${N} argument can be provided.
Both commands have a color code:

  • ${B}DEFAULT${N} : used for normal host accessed via jumphost
  • ${B}BLUE${N}    : if present, jumphost will be printed at the bottom of the list with this color
  • ${B}GREEN${N}   : assigned to hosts configured with direct access and no jumphost involved

Additionally and only for '${B}jhenvtable${N}', if you you have extra '${B}OPT_X${N}' options enabled for a certain host, a '${B}+${N}' symbol will appear on its left.

────────────────────────────────────────────────────────────────────────────────
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
  jh ssh "$@"
}

jhsftp(){
# description: basic tool for direct sftp connections or via jumphost
# arguments: 2
  jh sftp "$@"
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
  f_color_ask cyn installDir "Type install dir [/usr/local/bin]: "
  [[ -z ${installDir} ]] && installDir="/usr/local/bin" && f_color_pr wht "  Default: ${installDir}"
  [[ ! -d ${installDir} ]] && f_color_pr red "ERROR: folder '${installDir}' is not available!" && exit
  jhutils="$( typeset -f | ${sed} -r -n 's/^(jh[a-z]+) \(\)/\1/gp' | tr -d '\n' )"
  for c in "jh.sh" ${jhutils} "jhsh.bash" ; do
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
#              ( f_map_cmd ${installFunc} forceInstall && f_color_pr grn "   DONE: ${cDir}/${c}" ) || f_color_pr red "   ERROR!"
              ( f_map_cmd ${installFunc} forceInstall && printf "${wht}%-35s ${grn}[ %s ]\e[m\n" "${cDir}/${c}" "UPDATED" ) || f_color_pr red "   ERROR!"
            elif [[ ${overwrite,,} =~ ^no?$ || -z ${overwrite} ]] ; then
              f_color_pr wht "   skipped..."
            fi
          done
          unset overwrite
        else
#          f_color_pr grn "   ALREADY UPDATED: ${cDir}/${c}"
          printf "${wht}%-35s ${grn}[ %s ]\e[m\n" "${cDir}/${c}" "SKIPPED"
        fi
      else
#        ( f_map_cmd ${installFunc} normalInstall && f_color_pr grn "   DONE: ${cDir}/${c}" ) || f_color_pr red "   ERROR!"
        ( f_map_cmd ${installFunc} normalInstall && printf "${wht}%-35s ${grn}[%s]\e[m\n" "${cDir}/${c}" "INSTALLED" ) || f_color_pr red "   ERROR!"
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
  if [[ ${1} == "--help" ]] ; then
    jhman
  else
    f_install
  fi
fi

