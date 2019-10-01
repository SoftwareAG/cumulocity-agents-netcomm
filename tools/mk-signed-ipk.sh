#!/bin/sh
USAGE="Description: add private key to IPK file. This script must be run after build.
Usage:
$(basename $0) -h                    -- Show this help.
$(basename $0) <input ipk file>      -- IPK file to be signed by private key"

PRIKEY=build/ipkkeys/cumulocity-private.pem
SIGN=$NTC_SDK_PATH/tools/sign.sh

if [ "$1" = "" -o "$1" = "-h" ]; then
    echo "$USAGE"
elif [ ! -e $(pwd)/$PRIKEY ]; then
    echo "private key is not found. Run 'make signature' first";
else
    SUFFIX="-signed.ipk"
    INPUT=$1
    OUTPUT=${INPUT%.*}$SUFFIX
    if sh $SIGN $(pwd)/$PRIKEY $(pwd)/$INPUT $(pwd)/$OUTPUT 2>/dev/null; then
        echo "$OUTPUT is successfully generated!";
    else
        echo "Signing failed. Check the usage.\n$USAGE";
    fi
fi
exit 0