#!/usr/bin/env sh
USAGE="Description: ntcagent and smsagent release number versioner.

Usage:
$(basename $0) -h                    -- Show this help.
$(basename $0) ask                   -- Show ntcagent and smsagent current versions
$(basename $0) <ntcagent> <smsagent> -- Update <ntcagent> and <smsagent> version number.
                                      - for no update."

if [ "$1" = "" -o "$1" = "-h" ]; then
    echo "$USAGE"
elif [ "$1" = "ask" ]; then
    echo -n "ntcagent: "
    grep Version: debian/ntcagent/control | cut -c 10-
    echo -n "smsagent: "
    grep Version: debian/smsagent/control | cut -c 10-
else
    test $1 != '-' && sed -i "/Version:/c\Version: $1" debian/ntcagent/control
    test $2 != '-' && sed -i "/Version:/c\Version: $2" debian/smsagent/control
fi
exit 0
