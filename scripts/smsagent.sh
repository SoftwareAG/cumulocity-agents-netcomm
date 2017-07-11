#!/bin/sh
#/etc/rc.d/init.d/smsagent.sh

case "$1" in
    start) echo "Starting smsagent..."
           /usr/local/bin/srwatchdogd /usr/local/bin/smsagent 240&
    ;;
    stop) echo "Shutting down smsagent..."
           pkill -f smsagent
    ;;
esac
