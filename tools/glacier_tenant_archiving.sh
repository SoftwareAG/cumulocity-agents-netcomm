#!/bin/bash

## INTERNAL CONFIGURATION ########################

#debug=true
dryrun=false
coreconfig="/etc/cumulocity/cumulocity-core.properties"
credentials="$( base64 -d <<< XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX )"
#url="https://management.iotpreprod.telstra.com"
url="http://localhost:8111"
vault="CumulocitySuspendedTenantsArchive"
sdays=56
rdays=100

##################################################

jqbin="$( dirname "$0")/jq"
debug=${debug:-false}

f_helpMsg(){
  echo "Usage: $0 --archive --rotate --susp-days=56 --del-days=100
  -c, --credentials             Set credentials in format tenant/user:password
  -u, --url                     Set url for rest calls
  -d, --susp-days               Set max days for suspension status [ default=${sdays} ]
  -w, --susp-weeks              Same as susp-days, but with weeks
  -D, --ret-days                Set max days for retention on glacier [ default=${rdays} ]
  -W, --ret-weeks               Same as --ret-days, but with weeks
  -v, --vault                   Configure vault name in glacier
  -P, --workdir                 Set current working directory [ default = ${workdir:-./archives} ]
  -l, --logfile                 Set logfile where to store archive ids and dates [ default = $( basename $0 .sh ).csv} ]
  -a, --archive                 Enable archive procedure
      --keep-tenants            Disable tenant deletion
  -r, --rotate                  Enable rotate procedure
  -t, --test                    Dry run, just test if operations are possible
      --coreconfig              Set path for cumulocity-core.properties [ default = ${coreconfig} ]
  -n, --notify                  Send an email if AMI or Backup creation fails (only if --test option is not used)
      --debug                   Enable debug verbosity
  -h, --help                    Shows this message
"
}

# no_args
f_color_pr(){
  case $1 in
    grn) COLOR='\e[1;32m' ;;
    ylw) COLOR='\e[1;33m' ;;
    red) COLOR='\e[1;31m' ;;
    cyn) COLOR='\e[1;36m' ;;
  esac
  shift
  printf "$COLOR""$@\n"'\e[m'
}

f_debug_pr(){
  $debug && f_color_pr "$@"
}

while getopts "hc:u:d:w:D:W:v:P:l:artn-:" opt ; do
  case "$opt" in
    -) case $OPTARG in
         credentials=*) credentials="${OPTARG#*=}" ;;
                 url=*) url="${OPTARG#*=}" ;;
           susp-days=*) sdays="${OPTARG#*=}" ;;
          susp-weeks=*) sdays="$(( ${OPTARG#*=} * 7 ))" ;;
            ret-days=*) rdays="${OPTARG#*=}" ;;
           ret-weeks=*) rdays="$(( ${OPTARG#*=} * 7 ))" ;;
               vault=*) vault="${OPTARG#*=}" ;;
             workdir=*) workdir="${OPTARG#*=}" ;;
             logfile=*) logfile="${OPTARG#*=}" ;;
               archive) archive=true ;;
          keep-tenants) keept=true ;;
                rotate) rotate=true ;;
                  test) dryrun=true ;;
          coreconfig=*) coreconfig="${OPTARG#*=}" ;;
                notify) notify=true ;;
                 debug) debug=true ;;
                  help) f_helpMsg && exit ;;
                     *) f_color_pr red "${OPTARG} is an invalid option!!" && f_helpMsg && exit 3;;
       esac ;;
    c) credentials="$OPTARG" ;;
    u) url="$OPTARG" ;;
    d) sdays="$OPTARG" ;;
    w) sdays="$(( $OPTARG * 7 ))" ;;
    D) rdays="$OPTARG" ;;
    W) rdays="$(( $OPTARG * 7 ))" ;;
    v) vault="$OPTARG" ;;
    P) workdir="$OPTARG" ;;
    l) logfile="$OPTARG" ;;
    a) archive=true ;;
    r) rotate=true ;;
    t) dryrun=true ;;
    n) notify=true ;;
    h) f_helpMsg && exit ;;
    *) f_color_pr red "${opt} is an invalid option!!" && f_helpMsg && exit 3;; 
  esac
done

if [[ -z $credentials || -z $url || -z $vault ]] ; then
  f_helpMsg && exit
fi

thisscript=$(readlink -f ${BASH_SOURCE[0]})

[[ -d "${workdir:=./archives}" ]] || mkdir "$workdir"
f_debug_pr cyn "Workdir set as ${workdir}"
logfile="${logfile:="$( dirname ${thisscript} )/$( basename ${thisscript} sh)csv"}"
f_debug_pr cyn "Logfile set as ${logfile}"

####################

# load settings:

configfile="$( dirname ${thisscript} )/$( basename ${thisscript} sh)conf"
[[ -f "$configfile" ]]  && . "$configfile"

####################

declare -A optDataMap
optDataMap=(
     [mongohost]='^[ \t]*mongodb.host = (.+)'
     [mongouser]='^[ \t]*mongodb.user = (.+)'
       [mongopw]='^[ \t]*mongodb.password = (.+)'
  [mongoadmindb]='^[ \t]*mongodb.admindb = (.+)'
)

declare -A defOptDataMap
defOptDataMap=(
     [mongohost]='localhost'
     [mongouser]='c8y-root'
  [mongoadmindb]='admin'
)

# arg1="mail subject" arg2="mail body"
f_notify(){
  if ( ${notify:-false} && ! ${dryrun:-false} ) ; then
    f_color_pr cyn "Sending info mail: \"$1\""
    mailx -s "$1" ${smtp_server:+-S "smtp=$smtp_server"} ${mail_from:+-S "from=$mail_from"} "$rcpt_to" <<< "$2" &>/dev/null
  fi  
}

# no args
f_guessConnectionData(){
  for D in mongohost mongouser mongopw mongoadmindb ; do 
    $debug && eval '[[ -z $'$D' ]] && f_color_pr ylw "Variable '$D' not set. Trying to guess from ${coreconfig}"'
    eval $D'=${'$D':-$( sudo sed -r -n "s@${optDataMap['$D']}@\1@gp" "${coreconfig}" )}'
    eval $D'=${'$D':-${defOptDataMap['$D']}}'
    $debug && eval 'f_color_pr grn "'$D' => $'$D'"'
  done
}

# no_args
f_fetchInfo(){
  f_color_pr cyn "-- $( TZ=UTC date )\n"
  f_color_pr cyn "Fetching information from current aws instance..."
  # instance-data or 169.254.169.254
  instanceid="$( wget --no-proxy -qO- http://169.254.169.254/latest/meta-data/instance-id )"
  regionid="$( wget --no-proxy -qO- http://169.254.169.254/latest/meta-data/placement/availability-zone | sed -r 's:([0-9][0-9]*)[a-z]*$:\1:' )"
  tagname="Name"
  instancename="$( aws ec2 describe-tags --filters "Name=resource-id,Values=$instanceid" "Name=key,Values=$tagname" --region $regionid --output=text | cut -f5 )"
  #me="$( aws iam get-user --output=text | sed -r 's/.+arn:aws:iam::([0-9]+):user.+/\1/g' )"
  me="$( aws sts get-caller-identity --query='Account' --output=text )"
  f_color_pr grn "  AwsUserID:    ${me}"
  f_color_pr grn "  InstanceID:   ${instanceid}"
  f_color_pr grn "  InstanceName: ${instancename}"
  f_color_pr grn "  RegionID:     ${regionid}"
}

currentuts="$( TZ=UTC date +%s )"
f_debug_pr cyn "Current UnixTimestamp: $currentuts"
currenttime="$( TZ=UTC date -d @${currentuts} +%Y%m%d_%H%M%S )"
currentprettytime="$( TZ=UTC date -d @${currentuts} +%Y-%m-%d\ %H:%M:%S )"
f_debug_pr cyn "Current Date and Time: $currenttime"

# arg1="ISO format date"
f_dateToEpoch(){
  if [[ "$1" =~ ^[0-9]+$ ]] ; then
    echo "$1"
  else
    date -d "$( sed -n -r 's/([0-9]{4}(-[0-9]{2}){2})T(([0-9]{2}:){2}[0-9]{2}[.][0-9]{3}).+/\1 \3/gp' <<< "$1" )" +%s 
  fi
}


# arg1="url" arg2="tenant/user:password"
f_listSuspendedTenants(){
  curl -k -X GET \
    --user "${2}" \
    "${1}/inventory/managedObjects?type=c8y_Tenant&pageSize=2000" 2>/dev/null | \
  ${jqbin} -r '
    .managedObjects[] |
    select( .status == "SUSPENDED") |
    .name + "," + (
      if (.statusChangeDate | length) != 29 then
        ( ( .statusChangeDate.millis / 1000 ) | tostring ) | sub( "[.][0-9]{3}" ; "" )
      else
        .statusChangeDate
      end
    )
  '
}

# no args
f_uploadArchive(){
  local retvalue
  f_color_pr grn "Tenant $TENANT is in suspended status since more than $sdays day$( [[ $sdays -ne 1 ]] && echo s ) and it will be archived"
  f_debug_pr cyn "  Querying app reference informations... (Output in Array format)"
  sudo mongo \
    --host ${mongohost} \
    -u ${mongouser} \
    -p "${mongopw}" \
    --authenticationDatabase ${mongoadmindb} \
    management \
    --eval 'db.applications.find({"ownerId":"'${TENANT}'"}).toArray()' \
    > "${workdir}/${TENANT}_${currenttime}.app_ref.array.json"
  f_debug_pr cyn "  Querying tenant info from management.tenants collections..."
  sudo mongo \
    --host ${mongohost} \
    -u ${mongouser} \
    -p "${mongopw}" \
    --authenticationDatabase ${mongoadmindb} \
    management \
    --eval 'db.tenants.find({"_id":"'${TENANT}'"}).pretty()' \
    > "${workdir}/${TENANT}_${currenttime}.tenant_info.json"
  f_debug_pr cyn "  Dumping Mongo database..."
  sudo mongodump \
    --host ${mongohost} \
    -u ${mongouser} \
    -p "${mongopw}" \
    --authenticationDatabase ${mongoadmindb} \
    --gzip -d ${TENANT} \
    --archive="${workdir}/${TENANT}_${currenttime}_mongodb.archive"
  f_debug_pr cyn "  Creating tarball..."
  tar cvf "${workdir}/${TENANT}_${currenttime}.tar" -C "${workdir}" "${TENANT}_${currenttime}_mongodb.archive" "${TENANT}_${currenttime}.app_ref.array.json" "${TENANT}_${currenttime}.tenant_info.json"
  if ${dryrun:-false} ; then
    f_color_pr cyn "dry run: upload would be performed with this command:
  => aws glacier upload-archive --region ${regionid} --vault-name "${vault}" --account-id - --body "${workdir}/${TENANT}_${currenttime}.tar" $extra_options "
  else
    archivejson="$(aws glacier upload-archive \
      --region ${regionid} \
      --vault-name "${vault}" \
      --account-id - \
      --body "${workdir}/${TENANT}_${currenttime}.tar" \
      $extra_options \
    )"
    retvalue=$?
    cat > "${workdir}/${TENANT}_${currenttime}.json" <<< "${archivejson}"
  fi
  f_debug_pr cyn "$FUNCNAME retvalue = ${retvalue:-0}"
  return ${retvalue:-0}
}

# arg1=archive-id
f_deleteArchive(){
  local retvalue
  if ${dryrun:-false} ; then
    f_color_pr cyn "dry run: delete would be performed with this command:
  => aws glacier delete-archive --region ${regionid} --vault-name "${vault}" --account-id - --archive-id="$1" $extra_options "
  else
    aws glacier delete-archive \
      --region ${regionid} \
      --vault-name "${vault}" \
      --account-id - \
      --archive-id="$1" \
      $extra_options 
    retvalue=$?
  fi
  f_debug_pr cyn "$FUNCNAME retvalue = ${retvalue:-0}"
  return ${retvalue:-0}
}

# arg1="archive json"
f_getArchiveId(){
  local retvalue
  if ${dryrun:-false} ; then
    archiveid="-- dry run --"
  else
    archiveid="$( ${jqbin} -r '.archiveId' <<< "${1}" )"
  fi
  retvalue=$?
  f_debug_pr cyn "$FUNCNAME retvalue = ${retvalue:-0}"
  return ${retvalue:-0}
}

# arg1="url" arg2="tenant/user:password" arg3="tenant"
f_deleteTenant(){
  ${dryrun:-false} || curl -k -X DELETE \
    --user "${2}" \
    "${1}/tenant/tenants/${3}" 2>/dev/null
}

f_guessConnectionData
f_fetchInfo

#return

f_archiveProcedure(){
  ${dryrun:-false} && flag="T"
  while read line ; do
    eval $( awk -F',' '{print "TENANT=\""$1"\"\nISODATE=\""$2"\"\n"}' <<< "$line" )
    UNIXTIMESTAMP="$( f_dateToEpoch "${ISODATE}" )"
    f_debug_pr cyn "$( printf "Tenant: %20s , ISODate: %s , UnixTimestamp: %s \n" $TENANT $ISODATE $UNIXTIMESTAMP )"
    if [[ $(( $currentuts - $UNIXTIMESTAMP )) -ge $(( ${sdays:=56} * 86400 )) ]] ; then
      if f_uploadArchive ; then
        f_color_pr grn "Archive ${TENANT}_${currenttime} created"
        if f_getArchiveId "${archivejson}" ; then
          f_color_pr grn "with archive ID ${archiveid}"
          if ! ${keept:-false} ; then
            f_color_pr cyn "Deleting tenant from system..."
            f_deleteTenant "${url}" "$credentials" "${TENANT}" && \
            deleted_tenants_list+="  ${TENANT}\n"
          fi
          f_color_pr cyn "writing to log file..."
          printf "%s , %30s , %s , %s , %s\n" "${flag:-A}" "${TENANT}" "${currentprettytime}" "${currentuts}" "${archiveid}" | tee -a "${logfile}"
        else
          f_color_pr red "Impossible to retrieve archive ID!"
        fi
      else
        f_color_pr red "Impossible to upload archive on glacier!"
      fi
    fi
  done < <( f_listSuspendedTenants "$url" "$credentials" )
}

# arg1=logfile
f_rotateProcedure(){
  while read line ; do
    eval $line
    if [[ $(( ${currentuts} - ${AUTS} )) -ge $(( ${rdays:=100} * 86400 )) ]] ; then
      if f_deleteArchive "$AID" ; then
        f_color_pr red "Archive ${AID} was older than $rdays day$( [[ $rdays -ne 1 ]] && echo s ) and has been deleted!"
        ${dryrun:-false} || sed -i -r "/${AID}/s/^A/D/" "${logfile}"
        deleted_archives_list+="  ${ARCHIVEDTENANT}\n"
      else
        f_color_pr red "Error deleting archive ${AID}"
      fi
    fi
  #done < <( awk -F' , '  '$1 == "A" {print "AUTS=" $4 " AID=\"" $5 "\""}' "${logfile}" )
  done < <( awk -F' , '  '$1 == "A" {gsub(/ /,"", $2) ; print "AUTS=" $4 " AID=\"" $5 "\" ARCHIVEDTENANT=\"" $2 "\""}' "${logfile}" )
}

${archive:-false} && f_archiveProcedure && ! test -z "${deleted_tenants_list}" && \
  f_notify "INFO: deleted tenants from platform" "$( printf "The following tenants have been removed from the platform and archived in glacier:\n${deleted_tenants_list}" )"
${rotate:-false}  && f_rotateProcedure  && ! test -z "${deleted_archives_list}" && \
  f_notify "INFO: deleted archives from glacier" "$( printf "The following archived tenants have been removed from glacier archives:\n${deleted_archives_list}" )"

f_color_pr cyn "-- Procedure complete --\n\n"

