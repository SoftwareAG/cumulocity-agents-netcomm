#!/bin/bash

datetag="$( date +%Y%m%d-%H%M%S )"
arcprefix="cumulocity-offline-setup"
tmpfolder="/tmp/c8y-oi-$datetag"
tmpfolder="./c8y-oi-$datetag"

thisscript="$( readlink -f "${BASH_SOURCE[0]}" )"
thisdir="$( dirname "$thisscript" )"
thisdate="$( date +'%F %H:%M:%S' )"

dryrun=false
verbose=false
nocheck=false
nocleanup=false
nocolors=false
regencfg=false
checkonly=false
skiptarball=false
dontlog=false
coloredlog=false

f_clean(){
  if $dontlog ; then
    cat
  elif $coloredlog ; then
    tee >( sed -r 's/^[# -=]+.* ([0-9]+[.][0-9]+%)/   download perc: \1/g' >> "${thisscript%.sh}.log" )
  else
    tee >( sed -r -e 's/(\x1b\[([0-9]+(;[0-9]+)?)?m|\x0d)//g' -e 's/^[# -=]+.* ([0-9]+[.][0-9]+%)/   download perc: \1/g' >> "${thisscript%.sh}.log" )
  fi
}

f_color_pr(){
  if ${nocolors:-false} ; then
    shift
    printf -- "%s\n" "$@" | f_clean
  else
    case $1 in
      wht) COLOR='\e[1m' ;;
      grn) COLOR='\e[1;32m' ;;
      ylw) COLOR='\e[1;33m' ;;
      red) COLOR='\e[1;31m' ;;
      cyn) COLOR='\e[1;36m' ;;
    esac
    shift
    printf "$COLOR""%s\n"'\e[m' "$@" | f_clean
  fi  
}

f_help_msg(){
  printf "USAGE: $0 -c file.conf [options...]
  -h --help        : show this help message
  -d --dryrun      : print commands without running anything (Default=false)
  -v --verbose     : enable verbosity (Default=false)
  -t --tmpfolder   : select the path for the creation of temporary folder (Default=/tmp/c8y-oi-<DATE-TIME>)
  -c --config      : select the configuration file to use
  -a --arcprefix   : set the prefix for the archive name (Default=$arcprefix)
  -r --regencfg    : generate a <configfile>.new configuration with recalculated md5 checksums
     --nocheck     : disable the md5 check on downloaded files
     --nocleanup   : disable the deletion of the temporary folder when archive is built
     --nocolors    : disable colored output
     --checkonly   : disable download of artifacts and only check md5 checksums. Requires --tmpfolder
     --skiptarball : disable tarball creation and tmp folder cleanup
     --dontlog     : disable logging
     --coloredlog  : enable colored log output

"
}

while getopts "hdvrt:c:a:-:" opt ; do
  case $opt in
    h) f_help_msg && exit ;;
    d) dryrun=true ;;
    v) verbose=true ;;
    t) tmpfolder="$OPTARG" ;;
    c) config="$OPTARG" ;;
    a) arcprefix="$OPTARG" ;;
    r) regencfg=true ;;
    -) case $OPTARG in
                help) f_help_msg && exit ;;
              dryrun) dryrun=true ;;
             verbose) verbose=true ;;
         tmpfolder=*) tmpfolder="${OPTARG#*=}" ;;
            config=*) config="${OPTARG#*=}" ;;
         arcprefix=*) arcprefix="${OPTARG#*=}" ;;
            regencfg) regencfg=true ;;
             nocheck) nocheck=true ;;
           nocleanup) nocleanup=true ;;
            nocolors) nocolors=true ;;
           checkonly) checkonly=true ;;
         skiptarball) skiptarball=true ;;
             dontlog) dontlog=true ;;
          coloredlog) coloredlog=true ;;
                   *) f_color_pr red "ERROR: option not recognized"
                      f_help_msg && exit 127 ;;
       esac ;;
    *) f_color_pr red "ERROR: option not recognized"
       f_help_msg && exit 127 ;;
  esac
done

f_exec(){
  ( $verbose || $dryrun ) && echo "$@"
  if ! $dryrun ; then
    eval "$@" 2>&1 | f_clean
    return ${retval:-${PIPESTATUS[-2]}}
  fi
}

if ${checkonly} && [[ ! -d "$tmpfolder" ]] ; then
  f_color_pr red "FATAL: you must specify an existing tmpfolder when using --checkonly option"
  exit 1
fi

if [[ -z $config ]] ; then
  f_color_pr red "FATAL: no configuration file selected!"
  f_help_msg
  exit 1
fi

if [[ ! -f $config ]] ; then
  f_color_pr red "FATAL: can't find config file '$config'"
  exit 1
fi

f_color_pr cyn "=== START: $thisdate ==="
f_color_pr cyn "the following folder will be used to store downloaded artifacts:"
f_color_pr wht "  $tmpfolder"

eval $( egrep '^version=' "$config" )
if [[ -z $version ]] ; then
  f_color_pr red "FATAL: your configuration file doesn't contain a 'version' parameter"
  exit 2
fi

archivename="${arcprefix}-${version}-${datetag}"

eval $( egrep '^tag=' "$config" )
[[ -z $tag ]] || archivename+=-$tag

if ${regencfg} ; then
  if [[ -e "${config}.new" ]] ; then
    f_color_pr ylw "WARNING: ${config}.new already exists and it will be overwritten"
    echo | f_clean
    dontlog=true f_color_pr wht "  Press CTRL+C to stop now or enter to continue.." 1>&2
    read -s
    echo
  fi
  echo "# SETTINGS:" > "${config}.new"
  [[ -z $tag ]] || echo "tag=$tag" >> "${config}.new"
  [[ -z $version ]] || echo "version=$version" >> "${config}.new"
  echo "##########" >> "${config}.new"
  echo >> "${config}.new"
fi

$dryrun || if [[ -d "$tmpfolder" ]] ; then
  f_color_pr ylw "WARNING: '$tmpfolder' directory is already existing"
  f_color_pr wht "  If you continue, $( basename $0 ) will try to resume the downloads,"
  f_color_pr wht "  but files that are already complete will trigger this output:"
  f_color_pr ylw "    curl: (22) The requested URL returned error: 416"
  f_color_pr wht "  or"
  f_color_pr ylw "    curl: (33) HTTP server doesn't seem to support byte ranges. Cannot resume."
  f_color_pr grn "  These can be safely ignored."
  echo | f_clean
  dontlog=true f_color_pr wht "  Press CTRL+C to stop now or enter to continue.." 1>&2
  read -s
  echo
else
  if ! mkdir "$tmpfolder" 2>/dev/null ; then
    f_color_pr red "FATAL: impossible to create $tmpfolder directory"
    exit 3
  fi
fi

for bin in curl md5sum ; do
  if ! command -v $bin &> /dev/null ; then
    f_color_pr red "FATAL: please, install '$bin'"
    exit 4
  fi
done

for c in $( sed -n -r 's/=== ([^ ]+) ===/\1/gp' "$config" ) ; do
  f_color_pr cyn "Fetching artifacts for category $( eval echo ${c} )"
  $regencfg && echo "=== $c ===" >> "${config}.new"
  categories[i++]="$c"
  curdir="${tmpfolder}/reposetup/$( eval echo "$c" )"
  f_exec mkdir -p "${curdir}"
  cForSed="${c/\//.}" ; cForSed="${cForSed/\$/.}"
  for a in $( sed -n -r "/=== ${cForSed} ===/,/==========/{/^(===|[ \t]*#)/d;p}" "$config" ) ; do
    md5tocheck="$( cut -d, -f1 <<< "$a" )"
    artifactlink="$( eval echo "$a" | cut -d, -f2 )"
    outputfile="$( basename "$artifactlink" )"
    outputpath="$curdir/$outputfile"
    f_color_pr grn "  $outputfile"
    if $checkonly ; then
      partcmd=
    else
      partcmd="curl -f -L -C - -# '$artifactlink' -o '$outputpath'"
    fi
    cmd="$( cat << EOF
$nocolors || printf '\\e[0;30m'
COLUMNS=80 $partcmd 2>&1
case \$? in
  0|22|33) local retval=true ;;
        *) local retval=false ;;
esac
if [[ ! -e "$outputpath" ]] ; then
  local retval=false
fi
if ! \${retval:-true} ; then
  f_color_pr red "  ERROR: something went wrong by fetching $artifactlink"
fi
$nocolors || printf '\e[m'
\${retval:-true}
EOF
)"
  ( $verbose || $dryrun ) && f_color_pr wht "$partcmd"
  if verbose=false coloredlog=false f_exec "$cmd" ; then
    ( $verbose || $dryrun ) && f_color_pr wht "md5sum $outputpath"
    if ! $dryrun && ( ! $nocheck || $regencfg ) ; then
      newmd5="$( md5sum "$outputpath" | cut -d' ' -f1 )"
      if ! $nocheck ; then
        if [[ "$newmd5" != "$md5tocheck" ]] ; then
          f_color_pr ylw "  WARNING: $outputfile doesn't match the md5 checksum in the config file:"
          f_color_pr ylw "    $md5tocheck ==> in config"
          f_color_pr ylw "    $newmd5 ==> new file"
          (( wrncount++ ))
        fi
      fi
    fi
  else
    (( errcount++ ))
  fi
  $regencfg && echo "${newmd5:-xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx},$( cut -d, -f2 <<< "$a" )" >> "${config}.new"
  unset newmd5
  done
$regencfg && echo "==========" >> "${config}.new"
$regencfg && echo >> "${config}.new"
done

if ls "${tmpfolder}/reposetup/initial/"omnirepo-chef-setup*.tgz &> /dev/null ; then
  f_color_pr cyn "Unpacking omnirepo-chef-solo setup"
  cmd="$( cat << EOF
tar xz$( $verbose && echo v )f "${tmpfolder}/reposetup/initial/"omnirepo-chef-setup*.tgz -C "${tmpfolder}/reposetup" #&& \
#rm "${tmpfolder}/reposetup/initial/"omnirepo-chef-setup*.tgz
EOF
)"
  if ! f_exec "$cmd" ; then
    f_color_pr red "  FATAL: omnirepo-chef-setup not found"
    exit 255
  fi
  includechefsh=true
else
  f_color_pr ylw "WARNING: no omnirepo-chef-setup tarball is present"
  f_color_pr wht "  Although, if you are building a delta package"
  f_color_pr wht "  you can safely ignore this message"
  (( wrncount++ ))
  includechefsh=false
fi

if [[ -d "${tmpfolder}/reposetup/initial" ]] ; then
  f_color_pr cyn "Creating setup script"
  setupscript='#!/bin/bash

thisscript="$( readlink -f "${BASH_SOURCE[0]}" )"
thisdir="$( dirname "$thisscript" )"
thisdate="$( date +"%F %H:%M:%S" )"

for v in dryrun verbose dontlog coloredlog nocolors ; do
  eval $v="\${$v:-false}"
done

'"$( typeset -f f_clean )"'

'"$( typeset -f f_color_pr )"'

'"$( typeset -f f_exec )"'

f_color_pr cyn "=== START: $thisdate ==="

f_color_pr cyn "Chef installation"
f_color_pr grn "You can safely ignore the following WARNING message"
read -p "press enter to continue"

cmd="$( cat << EOF
${thisdir}/../http-packages/Base/install.sh -l "file://${thisdir}/../yum-rpms/Base/'"$( sed -n -r '/=== yum-rpms.Base ===/,/==========/s/.+(chef-12.+[.]rpm)/\1/gp' "$config" )"'"
EOF
)"

if ! f_exec "$cmd" ; then
  f_color_pr red "ERROR: Chef installation failed"
  exit 1
fi

'
  $includechefsh && \
  setupscript+='f_color_pr cyn "Prerequisites installation via Chef-Solo"
read -p "press enter to continue"

cmd="$( cat << EOF
${thisdir}/../omnirepo-chef-setup/bootstrap.sh
EOF
)"

if ! f_exec "$cmd" ; then
  f_color_pr red "ERROR: Prerequisites installation failed"
  exit 2
fi

f_color_pr cyn "Nexus installation via Chef-Solo"
read -p "press enter to continue"

cmd="$( cat << EOF
${thisdir}/../omnirepo-chef-setup/chefrun.sh
EOF
)"

if ! f_exec "$cmd" ; then
  f_color_pr red "ERROR: Nexus installation failed"
  exit 3
fi

f_color_pr grn "--- Procedure completed successfully! ---"
'

  cmd="$( cat << EOF
cat > "${tmpfolder}/reposetup/initial/reposetup.sh" <<< "\$setupscript"
chmod a+x "${tmpfolder}/reposetup/initial/reposetup.sh"
chmod a+x "${tmpfolder}/reposetup/http-packages/Base/install.sh"
EOF
)"
  f_exec "$cmd"
fi

if ! $skiptarball ; then
  cmd="$( cat << EOF
(
  cd "${tmpfolder}"
  tar cz$( $verbose && echo v )f "${thisdir}/${archivename}".tgz --exclude="reposetup/initial/"omnirepo-chef-setup*.tgz *
)
EOF
)"
  if [[ $(( ${wrncount:-0} + ${errcount:-0} )) -ne 0 ]] ; then
    echo
    f_color_pr ylw "${wrncount:+$wrncount WARNING}$([[ $wrncount -gt 1 ]] && echo S)$( [[ ${wrncount:-0} -gt 0 && ${errcount:-0} -gt 0 ]] && echo " and " )${errcount:+$errcount ERROR}$([[ $errcount -gt 1 ]] && echo S) occurred"
    dontlog=true f_color_pr wht "Are you sure you want to continue with tarball creation?" 1>&2
    dontlog=true f_color_pr wht "If not, the temporary folder won't be cleaned and you will be able to retry later with the following" 1>&2
    f_color_pr wht "resume command:"
    f_color_pr wht "  $0 -c '$config' -t '$tmpfolder'"
    echo | f_clean
    if ! $dryrun ; then
      dontlog=true f_color_pr wht "  Press CTRL+C to stop now or enter to continue.." 1>&2
      read -s
    fi
  fi
  f_color_pr cyn "Creating archive ${archivename}.tgz"
  if ! f_exec "$cmd" ; then
    f_color_pr red "FATAL: Something went wrong while creating ${archivename}.tgz"
    exit 10
  fi

  cmd="$( cat << EOF
$nocleanup || rm -rf "${tmpfolder}"
EOF
)"
  if ! f_exec "$cmd" ; then
    f_color_pr red "ERROR: Impossible to delete ${tmpfolder}"
    exit 11
  fi
fi

f_color_pr grn "-- Procedure completed successfully! --"
echo | f_clean

