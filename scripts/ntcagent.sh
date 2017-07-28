#!/bin/sh
#/etc/init.d/rc.d/ntcagent.sh

case "$1" in
    start) echo "Starting NTC-Agent..."
           rdb_set service.cumulocity.agent.status ""
           ENABLED=$(rdb_get service.cumulocity.enable)
           if [ $ENABLED = "1" ]
           then
                rdb_set service.cumulocity.agent.status "Starting..."
                VERSION=$(grep Version: /usr/lib/ipkg/info/smartrest-agent.control | cut -c 10-)
                rdb_set service.cumulocity.agent.version $VERSION
                LD_LIBRARY_PATH=/usr/local/lib /usr/local/bin/srwatchdogd /usr/local/bin/ntcagent 480&
           else
                echo "NTC-Agent is deactivated"
                rdb_set service.cumulocity.agent.status "Deactivated"
           fi
    ;;
    stop) echo "Shutting down NTC-Agent..."
           rdb_set service.cumulocity.agent.status "Stopped"
           pkill -f ntcagent
    ;;
esac
