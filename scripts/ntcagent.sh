#!/bin/sh
#/etc/rc.d/init.d/smsagent.sh

case "$1" in
    start) echo "Starting ntcagent..."
           VERSION=$(grep Version: /usr/lib/ipkg/info/smartrest-agent.control | cut -c 10-)
           rdb_set service.cumulocity.agent.version $VERSION
           LD_LIBRARY_PATH=/usr/local/lib /usr/local/bin/srwatchdogd /usr/local/bin/ntcagent 480&
    ;;
    stop) echo "Shutting down ntcagent..."
           pkill -f ntcagent
    ;;
esac
