#!/bin/bash

SOLO=false

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

while getopts "Svik:m:c:a:" opt ; do
  case $opt in
    S) SOLO=true ;;
    v) VERBOSE=true ;;
    i) interactive=true ;;
    k) karafver="${OPTARG}" ;;
    m) mainver="${OPTARG}" ;;
    c) cepver="${OPTARG}" ;;
    a) ssaver="${OPTARG}" ;;
  esac
done

if [[ -z $karafver || -z $cepver ]] ; then
  f_color_pr red "ERROR: specify release version for both karaf and cep!" && exit 1
fi

mainver="${mainver:=$karafver}"

f_color_pr cyn "Main version:"
f_color_pr wht "  ${mainver}"

if [[ -z $ssaver ]] ; then
  ssaver="$( sed -r 's/^(([0-9]+[.]){2})[0-9]+-1/\11-1/g' <<< "${karafver}" )"
fi

thisscript="$( readlink -f ${BASH_SOURCE[0]} )"
   thisdir="$( dirname "${thisscript}" )"
  c8yCBdir="$( readlink -e "${thisdir}/../../cumulocity-cookbooks" )"
  comCBdir="$HOME/.berkshelf/cookbooks"
    solDir="${thisdir}/chef-solo"
  solCBdir="${thisdir}/chef-solo/cookbooks"
    relDir="${thisdir}/cumulocity-chef"
  relCBdir="${relDir}/cookbooks"
template_archive="${thisdir}/chef-solo-12-template.tgz"

declare -A c8yCB
c8yCB=(
                 ["cumulocity"]=0.6.0
        ["cumulocity-ssagents"]=0.4.0
         ["cumulocity-rsyslog"]=1.0.0
   ["cumulocity-backup-script"]=latest
["cumulocity-monitoring-agent"]=latest
        ["cumulocity-filebeat"]=latest
      ["cumulocity-opsmanager"]=latest
    ["cumulocity-chaos-monkey"]=latest
      ["cumulocity-kubernetes"]=latest
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
            ["packagecloud"]=1.0.1
                ["yum-epel"]=3.3.0
                    ["cron"]=6.2.1
               ["logrotate"]=2.2.0
                 ["windows"]=6.0.0
                ["iptables"]=4.5.0
                     ["apt"]=7.1.1
                ["homebrew"]=4.3.0
         ["compat_resource"]=12.19.1
                    ["ohai"]=5.1.0
              ["filesystem"]=1.0.0
                     ["lvm"]=4.5.3
                ["filebeat"]=2.1.0
            ["elastic_repo"]=1.1.1
  ["yum-plugin-versionlock"]=0.2.1
                  ["docker"]=latest
                 ["haproxy"]=5.0.4
                     ["cpu"]=2.0.0
         ["build-essential"]=8.2.1
                   ["poise"]=2.8.2
           ["poise-service"]=1.5.2
               ["seven_zip"]=3.0.0
                   ["mingw"]=2.1.0
)

declare -a mnRoles
mnRoles=(
  cumulocity-base
  cumulocity-cep-server
  cumulocity-common-cores
  cumulocity-common-dbs-standalone-mongo
  cumulocity-core-master
  cumulocity-core
  cumulocity-external-lb
  cumulocity-internal-lb
  cumulocity-kubernetes
  cumulocity-mn-active-core
  cumulocity-mongo-configsvr
  cumulocity-mongo-standalone
  cumulocity-mongo
  cumulocity-ontop-lb
  cumulocity-sql-db
  cumulocity-ssagents
)

declare -a snRoles
snRoles=(
  cumulocity-base
  cumulocity-dev-singlenode
  cumulocity-common-cores
  cumulocity-kubernetes
  cumulocity-mn-active-core
)

declare -a mnTools
mnTools=(
  kube_cleanup.sh
  kube_mms_manual_provisioning.sh
  kube_registrypwgen.sh
  kube_tokengen.sh
  postgresToMongo_helper.sh
)

f_findLastVersion(){
  local list="${1}"
  i=0
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

f_cb_copy(){
  wrkCBdir="${1}"

  f_color_pr cyn "Copying community cookbooks..."
  for cb in "${!comCB[@]}" ; do
    f_color_pr wht "-- ${cb}-${comCB[$cb]}"
    if [[ ${comCB[$cb]} == "latest" ]] ; then
      verList="$( ls -d -w1 "${comCBdir}/${cb}"-* 2>/dev/null | sed -r "s|${comCBdir}/${cb}-||g" )" && \
      version="$( f_findLastVersion "${verList}" )"
    else
      version="${comCB[$cb]}"
    fi
    cp -ar${VERBOSE+v} "${comCBdir}/${cb}-${version:-*}" "${wrkCBdir}/${cb}"
  done
  echo

  f_color_pr cyn "Copying Cumulocity cookbooks..."
  for cb in "${!c8yCB[@]}" ; do
    f_color_pr wht "-- ${cb}"
    version="${c8yCB[$cb]}"
    cp -ar${VERBOSE+v} "${c8yCBdir}/${cb}" "${wrkCBdir}"
  done
  echo
}

if ${SOLO} ; then
  f_color_pr cyn "Creating directory structure..."
  for d in \
    config \
    environments \
    data_bags/certs \
    data_bags/users_cumulocity \
    roles \
    cookbooks \

  do
    mkdir -p "${solDir}/${d}" 2> /dev/null
  done
  echo

  f_cb_copy "${solCBdir}"

  f_color_pr cyn "Copying role file..."
  for r in "${snRoles[@]}" ; do
    f_color_pr wht "-- $r"
    cp -a${VERBOSE+v} "${thisdir}/../roles/${r}.rb" "${solDir}/roles" || \
    f_color_pr red "ERROR: role $r not found!"
  done
  echo

  f_color_pr cyn "Copying misc files..."
  f_color_pr wht "-- data_bags/certs/certificate.json"
  cp -a${VERBOSE+v} "${thisdir}/../data_bags/certs/cumulocity.json" "${solDir}/data_bags/certs"
  f_color_pr wht "-- cumulocity-single-node.json"
  cp -a${VERBOSE+v} "${thisdir}/../environments/cumulocity-single-node.json" "${solDir}/environments"
  f_color_pr wht "-- chef-solo/config/chef_config"
  cp -a${VERBOSE+v} "${thisdir}/../chef-solo/config/chef_config" "${solDir}/config"
  f_color_pr wht "-- chef-solo/chefrun.sh"
  cp -a${VERBOSE+v} "${thisdir}/../chef-solo/chefrun.sh" "${solDir}/chefrun.sh"

##########

  export prefixName="cumulocity-chef-solo"
  cat > "${prefixName}-v${mainver}.sh" <<< '#!/bin/bash

EXTRACTONLY=false
AUTO=false
INST=false
INSTALLONLY=false

while getopts "veiyYo:" opt ; do
  case $opt in
    v) VERBOSE=true ;;
    e) EXTRACTONLY=true ;;
    i) INSTALLONLY=true;;
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

if $INSTALLONLY && $EXTRACTONLY; then
  f_color_pr red "Invalid combination of options: -e and -i"
fi

if ! $INSTALLONLY; then
  f_color_pr wht "extract chef-solo folder in ${outputFolder:=/var}..."
  sed -n "/^__ARCHIVE_BELOW__$/{s///;:a;n;p;ba;}" "$0" | tar xz${VERBOSE+v}f - -C "${outputFolder}"
  f_color_pr wht "Done!"
fi

${EXTRACTONLY} && exit

[[ ! -d /var/config ]] && mkdir /var/config
ln -sf "${outputFolder}/chef-solo/config/chef_config" "/var/config/chef_config.rb"

soloDir="${outputFolder}/chef-solo"

sed -i -r \
  -e "s/___KARAFVERSION___/"'${karafver}'"/g" \
  ${soloDir}/environments/cumulocity-single-node.json

if [[ ! -e "${soloDir}/.systemUpdateDONE" ]] ; then
  while ! [[ ${UpdateQ,,} =~ ^(y(es)?|no?)$ ]] ; do
    f_question "run a system update? [Y/n]: " UpdateQ $AUTO
    if [[ ${UpdateQ,,} =~ ^(y(es)?)?$ ]] ; then
      sudo yum ${yes} update --exclude="mongodb* cumulocity-* postgresql* nginx *-agent-server* epel-release sms-gateway-server python2-boto vaisala-server nodejs* remote-access-server* openresty* kube*" --disablerepo=cumulocity* && \
      touch "${soloDir}/.systemUpdateDONE"
      break
    fi
  done
fi

if [[ ! -e "${soloDir}/.rpmInstallDONE" ]] ; then
  while ! [[ ${rpmQ,,} =~ ^(y(es)?|no?)$ ]] ; do
    f_question "install the necessary additional components? [Y/n]: " rpmQ $AUTO
    if [[ ${rpmQ,,} =~ ^(y(es)?)?$ ]] ; then
      sudo yum ${yes} install java-1.{7,8}.0-openjdk gcc{,-c++} patch readline{,-devel} zlib{,-devel} libyaml-devel libffi-devel openssl-devel make git bzip2 autoconf automake libtool bison libxml2-devel libxslt{,-devel} ruby{,gems,-libs,-devel} make wget mlocate telnet wireshark vim lsof strace psmisc && \
      touch "${soloDir}/.rpmInstallDONE"
      break
    fi
  done
fi

if [[ ! -e "${soloDir}/.chefInstallDONE" ]] ; then
  while ! [[ ${ChefQ,,} =~ ^(y(es)?|no?)$ ]] ; do
    f_question "install chef engine? [Y/n]: " ChefQ $AUTO
    if [[ ${ChefQ,,} =~ ^(y(es)?)?$ ]] ; then
      installScript="$( wget -qO - https://omnitruck-direct.chef.io/chef/install.sh )"
      bash -s -- -v 12 <<< "${installScript}"
      touch "${soloDir}/.chefInstallDONE"
      break
    fi
  done
fi

if [[ ! -e "${soloDir}/.selinuxDisableDONE" ]] ; then
  while ! [[ ${SelinuxQ,,} =~ ^(y(es)?|no?)$ ]] ; do
    f_question "disable SELinux? [Y/n]: " SelinuxQ $AUTO
    if [[ ${SelinuxQ,,} =~ ^(y(es)?)?$ ]] ; then
      sed -i -r "s/(SELINUX=).*/\1disabled/g" /etc/selinux/config
      setenforce 0
      touch "${soloDir}/.selinuxDisableDONE"
      break
    fi
  done
fi

if [[ ! -e "${soloDir}/.iptablesDisableDONE" ]] ; then
  while ! [[ ${IptablesQ,,} =~ ^(y(es)?|no?)$ ]] ; do
    f_question "disable IPtables/firewalld? [Y/n]: " IptablesQ $AUTO
    if [[ ${IptablesQ,,} =~ ^(y(es)?)?$ ]] ; then
      for s in iptables firewalld ; do
        systemctl disable $s
        systemctl stop $s
      done
      touch "${soloDir}/.iptablesDisableDONE"
      break
    fi
  done
fi

if [[ ! -e "${soloDir}/.timeZoneSetDONE" ]] ; then
  while ! [[ ${TimezoneQ,,} =~ ^(y(es)?|no?)$ ]] ; do
    f_question "set Timezone? [Y/n]: " TimezoneQ $AUTO
    if [[ ${TimezoneQ,,} =~ ^(y(es)?)?$ ]] ; then
      f_question "  type the timezone [Europe/Berlin]: " timezone $AUTO
      if [[ -z $timezone || $timezone == yes ]] ; then
        timedatectl set-timezone "Europe/Berlin"
      else
        timedatectl set-timezone "$timezone"
      fi
      touch "${soloDir}/.timeZoneSetDONE"
      break
    fi
  done
fi

if [[ ! -e "${soloDir}/.hostRenameDONE" ]] ; then
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
      touch "${soloDir}/.hostRenameDONE"
      break
    fi
  done
fi

while ! [[ ${runSoloQ,,} =~ ^(y(es)?|no?)$ ]] ; do
  f_question "run chef-zero and install the platform? [Y/n]: " runSoloQ $INST
  if [[ ${runSoloQ,,} =~ ^(y(es)?)?$ ]] ; then
    cd ${soloDir}
    "./chefrun.sh" && break
    f_color_pr red "ERROR: could not run chef-zero!"
  fi
done

exit


__ARCHIVE_BELOW__'

  ( cd "${thisdir}"
    tar cz${VERBOSE+v}f - "chef-solo"
  ) | tee "${prefixName}-v${mainver}.tgz" >> "${prefixName}-v${mainver}.sh"
  chmod a+x "${prefixName}-v${mainver}.sh"

  echo
  f_color_pr cyn "Eliminating temporary folder and archive..."
  rm -rf${VERBOSE+v} "${solDir}"
  rm -rf${VERBOSE+v} "${prefixName}-v${mainver}.tgz"
else
  f_color_pr cyn "Creating directory structure..."
  for d in \
    environments \
    data_bags/users_cumulocity \
    data_bags/certs \
    roles \
    cookbooks \
    tools \
    .chef/access_certs \
    .chef/trusted_certs \
    .chef/secrets \
    .chef/keys \

  do
    mkdir -p "${relDir}/${d}" 2> /dev/null
  done
  echo

  f_cb_copy "${relCBdir}"

  f_color_pr cyn "Copying role files..."
  for r in "${mnRoles[@]}" ; do
    f_color_pr wht "-- $r"
    cp -a${VERBOSE+v} "${thisdir}/../roles/${r}.rb" "${relDir}/roles" || \
    f_color_pr red "ERROR: role $r not found!"
  done
  echo

  f_color_pr cyn "Copying tool scripts..."
  for s in "${mnTools[@]}" ; do
    f_color_pr wht "-- $s"
    cp -a${VERBOSE+v} "${thisdir}/../tools/${s}" "${relDir}/tools" || \
    f_color_pr red "ERROR: script $s not found!"
  done
  echo

  f_color_pr cyn "Copying misc files..."
  f_color_pr wht "-- data_bags/certs/certificate.json"
  cp -a${VERBOSE+v} "${thisdir}/../data_bags/certs/certificate.json" "${relDir}/data_bags/certs"
  f_color_pr wht "-- environments/environment_template.rb"
  cp -a${VERBOSE+v} "${thisdir}/../environments/environment_template.rb" "${relDir}/environments"
  echo

  f_color_pr cyn "Creating user template..."
  cat > "${relDir}/data_bags/users_cumulocity/user_template.json" << EOF
{
  "id": "<username>",
  "comment": "<User Name>",
  "ssh_keys": [
    "<ssh key>"
  ],
  "groups": ["wheel"],
  "shell": "\/bin\/bash"
}
EOF
  echo

  f_color_pr cyn "Creating knife skel config..."
  cat > "${relDir}/.chef/knife.rb.template" << EOF
current_dir = File.dirname(__FILE__)

log_level                :info
log_location             STDOUT
node_name                "cli"
client_key               "#{current_dir}/access_certs/___ORGNAME___-cli.pem"
validation_client_name   "___ORGNAME___-validator"
validation_key           "#{current_dir}/access_certs/___ORGNAME___-validator.pem"
chef_server_url          "https://___CHEFNAME___/organizations/___ORGNAME___"
syntax_check_cache_path  "#{ENV['HOME']}/.chef/syntaxcache"
cookbook_path            ["#{current_dir}/../cookbooks"]

EOF
  echo

  f_color_pr cyn "Creating vault json templates..."
  cat > "${relDir}/.chef/secrets/environment_name.core.json" << EOF
{
#  "contextService.rdbmsPassword":"<postgres_password>",
  "mongodb.initPassword":"<mongodb_initPassword>",
  "mongodb.password":"<mongodb_password>"
}
EOF
  cat > "${relDir}/.chef/secrets/environment_name.docker.json" << EOF
{
    "extPort":"30002",
    "useMongoDriver":false,
    "dockercreds":"<dockercreds>",
    "dockersecrt":"<dockersecret>"
}
EOF
  echo

  f_color_pr cyn "Creating tarball..."
  export prefixName="cumulocity-chef-release-pack"
  ( cd "${thisdir}"
    tar cz${VERBOSE+v}f "${prefixName}-v${mainver}.tgz" "cumulocity-chef"
  )
  echo
  f_color_pr cyn "Eliminating temporary folder..."
  rm -rf${VERBOSE+v} "${relDir}"
fi
