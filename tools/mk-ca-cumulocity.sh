#!/bin/sh
PREFIX=build/staging/ca-cumulocity
CACERT=/usr/local/ssl/certs/ca-cumulocity.pem

CAFILE=misc/certs/cacert.pem
CAVERFILE=misc/certs/cacert.version
MYPWD=$(pwd)

declare -i counter=0

mkdir -p "$PREFIX/usr/local/ssl/certs/"
cp "$CAFILE" "$PREFIX$CACERT"
for entry in "misc/certs/cacert.d"/*; do
    if [ -f "$entry" ]; then
        ((counter++))
        cat "$entry" >> "$PREFIX$CACERT"
    fi
done

IPK_VERSION=$(cat "$CAVERFILE")".$counter"

mkdir -p "$PREFIX/CONTROL"
cat > "$PREFIX/CONTROL/control" <<EOF
Package: ca-cumulocity
Priority: optional
Section: Misc
Version: $IPK_VERSION
Architecture: arm
Maintainer: support@cumulocity.com
Depends:
Description: Mozilla CA cert bundle with Cumulocity addtions.
EOF

usage() {
    cat <<Help_Msg
Usage:

    $(basename $0) -h               Show this help message.
    $(basename $0) pkg              Make the Mozilla certificate bundle as a .ipk.
    $(basename $0) update           Update the certificate bundle from https://curl.haxx.se.
    $(basename $0) verify <server>  Check if <server>'s certificate can be verified with the current certificat bundle.
Help_Msg
    exit 0
}

if [ -z "$1" -o "$1" = "-h" ]; then
    usage
elif [ "$1" = "pkg" ]; then
    $NTC_SDK_PATH/tools/mkipk.sh "$MYPWD/$PREFIX" "$MYPWD/build"
elif [ "$1" = "verify" ]; then
    curl --cacert "$PREFIX$CACERT" -X GET https://demos.cumulocity.com &> /dev/null
    if [ $? -eq 0 ]; then
        echo "Verify OK!"
    else
        echo "Verify Error!"
    fi
elif [ "$1" = "update" ]; then
    curl -o misc/certs/cacert.pem https://curl.haxx.se/ca/cacert.pem &> /dev/null
    vertime=$(grep "Certificate data from Mozilla as of: " misc/certs/cacert.pem | sed 's/[^:]*://')
    TMPVERSION=$(date -d "$vertime" +"%Y%m%d")
    echo "$TMPVERSION" > "$CAVERFILE"
    echo "Updated to version $TMPVERSION"
fi
