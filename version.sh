#!/usr/bin/env sh
USAGE="Description: cumulocity-ntc-agent release number versioner.

Usage:
$(basename $0) -h                            -- Show this help.
$(basename $0) ask                           -- Show cumulocity-ntc-agent current version.
$(basename $0) update <cumulocity-ntc-agent> -- Update <cumulocity-ntc-agent> version number.
                                         -- for no update."

if [ "$1" = "" -o "$1" = "-h" ]; then
    echo "$USAGE"
elif [ "$1" = "ask" ]; then
    echo -n "cumulocity-ntc-agent: "
    grep Version: debian/c8yntcagent/control | cut -c 10-
elif [ "$1" = "update" ]; then
    test $2 != '-' && sed -i "/Version:/c\Version: $2" debian/c8yntcagent/control
fi
exit 0
