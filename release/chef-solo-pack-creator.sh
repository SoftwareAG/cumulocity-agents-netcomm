#!/bin/bash

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

while getopts "vik:c:" opt ; do
  case $opt in
    v) VERBOSE=true ;;
    i) interactive=true ;;
    k) karafver="${OPTARG}" ;;
    c) cepver="${OPTARG}" ;;
  esac
done

if [[ -z $karafver || -z $cepver ]] ; then
  f_color_pr red "ERROR: specify release version for both karaf and cep!" && exit 1
fi

thisscript="$( readlink -f ${BASH_SOURCE[0]} )"
   thisdir="$( dirname ${thisscript} )"
  c8yCBdir="$( readlink -e "${thisdir}/../../cumulocity-cookbooks" )"
  comCBdir="$HOME/.berkshelf/cookbooks"
  solCBdir="${thisdir}/chef-solo/cookbooks"
template_archive="${thisdir}/chef-solo-12-template.tgz"

declare -A c8yCB
c8yCB=(
           ["cumulocity"]=0.6.0
  ["cumulocity-ssagents"]=0.4.0
)

declare -A comCB
comCB=(
               ["ulimit"]=0.4.0
                ["runit"]=4.0.0
          ["chef-client"]=8.1.1
              ["openssh"]=2.3.1
                  ["ntp"]=3.4.0
                 ["java"]=1.49.0
                  ["yum"]=5.0.1
                ["users"]=5.2.2
                 ["sudo"]=4.0.0
           ["chef-vault"]=3.0.0
            ["hostsfile"]=3.0.1
                 ["swap"]=2.0.0
         ["packagecloud"]=0.3.0
             ["yum-epel"]=2.1.2
                 ["cron"]=4.1.3
            ["logrotate"]=2.2.0
              ["windows"]=3.1.0
             ["iptables"]=4.2.0
                  ["apt"]=6.1.0
             ["homebrew"]=4.2.0
      ["compat_resource"]=12.19.0
                 ["ohai"]=5.1.0
)

f_findLastVersion(){
  dirPrefix="${1}"
  i=0
  list="$( ls -d -w1 "${dirPrefix}"-* 2>/dev/null | sed -r "s|${dirPrefix}-||g" )" && \
  while [[ $( wc -l <<< "${list}" ) -gt 1 ]] ; do
    ((i++))
    tmplist="$( sort -n -t. -k${i} <<< "${list}" )"
    last="$( tail -n1 <<< "${tmplist}" )"
    select="$( egrep "^([0-9]+[.]?){${i}}" -o <<< "${last}" )"
    list="$( egrep "^${select}" <<< "${tmplist}" )"
  done
  [[ ! -z ${list} ]] && echo "${list}"
  return 0
}

if [[ -e ${template_archive} ]] ; then
  f_color_pr cyn "Unpacking chef-solo template..."
  tar xz${VERBOSE+v}f ${template_archive} -C "${thisdir}"
else
  f_color_pr red "ERROR: no template archive ${template_archive} found!" && exit 10
fi
echo

f_color_pr cyn "Copying community cookbooks..."
for cb in "${!comCB[@]}" ; do
  f_color_pr wht "-- ${cb}-${comCB[$cb]}"
  if [[ ${comCB[$cb]} == "latest" ]] ; then
    version="$( f_findLastVersion "${comCBdir}/${cb}" )"
  else
    version="${comCB[$cb]}"
  fi
  cp -ar${VERBOSE+v} "${comCBdir}/${cb}-${version:-*}" "${solCBdir}/${cb}"
done
echo

f_color_pr cyn "Copying Cumulocity cookbooks..."
for cb in "${!c8yCB[@]}" ; do
  f_color_pr wht "-- ${cb}"
  version="${c8yCB[$cb]}"
  cp -ar${VERBOSE+v} "${c8yCBdir}/${cb}" "${solCBdir}"
done
echo

##########

cat > "chef-solo-v${karafver}.sh" <<< '#!/bin/bash

EXTRACTONLY=false
AUTO=false
INST=false

while getopts "veyYo:" opt ; do
  case $opt in
    v) VERBOSE=true ;;
    e) EXTRACTONLY=true ;;
    y) AUTO=true yes="-y";;
    Y) AUTO=true yes="-y" INST=true ;;
    o) outputFolder="$OPTARG" ;;
  esac
done

f_question(){
  Q="$1" A="$2" Y="$3"
  printf "\e[1m${Q}\e[m"
  if [[ ! -z $Y ]] && $Y ; then
    echo yes
    eval $A=yes
  else
    read "$A"
  fi
}

'"
$(
  typeset -f f_color_pr
 )
"'

sed -n "/^__ARCHIVE_BELOW__$/{s///;:a;n;p;ba;}" "$0" | tar xz${VERBOSE+v}f - -C "${outputFolder:=/var}"

${EXTRACTONLY} && exit

[[ ! -d /var/config ]] && mkdir /var/config
ln -sf "${outputFolder}/chef-solo/config/chef_config" "/var/config/chef_config.rb"

soloDir="${outputFolder}/chef-solo"

sed -i -r \
  -e "s/___KARAFVERSION___/"'${karafver}'"/g" \
  -e "s/___CEPVERSION___/"'${cepver}'"/g" \
  ${soloDir}/roles/cumulocity-dev-singlenode.rb

if [[ -e "${soloDir}/.systemUpdateTODO" ]] ; then
  while ! [[ ${UpdateQ,,} =~ ^(y(es)?|no?)$ ]] ; do
    f_question "run a system update? [Y/n]: " UpdateQ $AUTO
    if [[ ${UpdateQ,,} =~ ^(y(es)?)?$ ]] ; then
      sudo yum ${yes} update && \
      rm "${soloDir}/.systemUpdateTODO"
      break
    fi
  done
fi

if [[ -e "${soloDir}/.rpmInstallTODO" ]] ; then
  while ! [[ ${rpmQ,,} =~ ^(y(es)?|no?)$ ]] ; do
    f_question "install the necessary additional components? [Y/n]: " rpmQ $AUTO
    if [[ ${rpmQ,,} =~ ^(y(es)?)?$ ]] ; then
      sudo yum ${yes} install java-1.{7,8}.0-openjdk gcc{,-c++} patch readline{,-devel} zlib{,-devel} libyaml-devel libffi-devel openssl-devel make git bzip2 autoconf automake libtool bison libxml2-devel libxslt{,-devel} ruby{,gems,-libs,-devel} make wget mlocate telnet wireshark vim lsof strace && \
      rm "${soloDir}/.rpmInstallTODO"
      break
    fi
  done
fi

if [[ -e "${soloDir}/.chefInstallTODO" ]] ; then
  while ! [[ ${ChefQ,,} =~ ^(y(es)?|no?)$ ]] ; do
    f_question "install chef engine? [Y/n]: " ChefQ $AUTO
    if [[ ${ChefQ,,} =~ ^(y(es)?)?$ ]] ; then
      installScript="$( wget -qO - https://omnitruck-direct.chef.io/chef/install.sh )"
      bash -s -- -v 12 <<< "${installScript}"
      rm "${soloDir}/.chefInstallTODO"
      break
    fi
  done
fi

if [[ -e "${soloDir}/.selinuxDisableTODO" ]] ; then
  while ! [[ ${SelinuxQ,,} =~ ^(y(es)?|no?)$ ]] ; do
    f_question "disable SELinux? [Y/n]: " SelinuxQ $AUTO
    if [[ ${SelinuxQ,,} =~ ^(y(es)?)?$ ]] ; then
      sed -i -r "s/(SELINUX=).*/\1disabled/g" /etc/selinux/config
      setenforce 0
      rm "${soloDir}/.selinuxDisableTODO"
      break
    fi
  done
fi

if [[ -e "${soloDir}/.iptablesDisableTODO" ]] ; then
  while ! [[ ${IptablesQ,,} =~ ^(y(es)?|no?)$ ]] ; do
    f_question "disable IPtables/firewalld? [Y/n]: " IptablesQ $AUTO
    if [[ ${IptablesQ,,} =~ ^(y(es)?)?$ ]] ; then
      for s in iptables firewalld ; do
        systemctl disable $s
        systemctl stop $s
      done
      rm "${soloDir}/.iptablesDisableTODO"
      break
    fi
  done
fi

if [[ -e "${soloDir}/.hostRenameTODO" ]] ; then
  while ! [[ ${HostnameQ,,} =~ ^(y(es)?|no?)$ ]] ; do
    f_question "rename host? [Y/n]: " HostnameQ $AUTO
    if [[ ${HostnameQ,,} =~ ^(y(es)?)?$ ]] ; then
      f_question "  type the FQDN [server.domain.com]: " fqdn $AUTO
      if [[ -z $fqdn || $fqdn == yes ]] ; then
        fqdn="server.domain.com"
      else
        sed -i -r \
          -e "s/server.domain.com/"${fqdn}"/g" \
          ${soloDir}/roles/cumulocity-dev-singlenode.rb
      fi
      prettyname="Cumulocity Single Server Edition"
      hostname="${fqdn%%.*}"
      hostnamectl set-hostname --pretty "${prettyname}"
      hostnamectl set-hostname --static "${hostname}"
      hostnamectl set-hostname --transient "${fqdn}"
      sed -i -r "s/(127[.]0[.]0[.]1|::1)([ \t]+)(localhost)/\1\2${fqdn} ${hostname} \3/g" /etc/hosts
      printf "HOSTNAME=${hostname}\n" >> "/etc/sysconfig/network"
      [[ -e "/etc/cloud/cloud.cfg" ]] && printf "\npreserve_hostname: true\n" >> "/etc/cloud/cloud.cfg"
      eth0ip="$( ip -4 address show dev eth0 2>/dev/null | sed -n -r "s/[ ]*inet ([^/]+).*/\1/gp" )"
      if [[ ! -z $eth0ip ]] ; then
        printf "${eth0ip}\t${hostname} ${fqdn}\n" >> /etc/hosts
      fi
      rm "${soloDir}/.hostRenameTODO"
      break
    fi
  done
fi

while ! [[ ${runSoloQ,,} =~ ^(y(es)?|no?)$ ]] ; do
  f_question "run chef-solo and install the platform? [Y/n]: " runSoloQ $INST
  if [[ ${runSoloQ,,} =~ ^(y(es)?)?$ ]] ; then
    limit=5
    for ((x=1;x<=$limit;x++)) ; do
      f_color_pr cyn "chef-solo run attempt number $x..."
      "${soloDir}/chefrun.sh" && break
      [[ $x -ge $limit ]] && f_color_pr red "ERROR: could not run chef-solo until the end!"
    done
  fi
done

exit


__ARCHIVE_BELOW__'

( cd "${thisdir}"
  tar cz${VERBOSE+v}f - "chef-solo"
) >> "chef-solo-v${karafver}.sh"
chmod a+x "chef-solo-v${karafver}.sh"

