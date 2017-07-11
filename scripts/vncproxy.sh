#!/bin/sh
#/etc/rc.d/init.d/vncproxy.sh

case "$1" in
    start) echo "Starting vncproxy..."
           /usr/local/bin/srwatchdogd /usr/local/bin/vncproxy 0&
    ;;
    stop) echo "Stopping vncproxy..."
          pkill -f vncproxy
    ;;
esac
