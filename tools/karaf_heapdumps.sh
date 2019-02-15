#!/bin/bash

#in MB
threshold_value=12000


while true
do

  timestamp=$(date +"%Y%m%d-%H%M%S")
  karaf_ram_usage=$(ps aux --sort -rss | grep karaf | awk '{printf "%.0f\n", $6 / 1024}' | head -1)
  echo $timestamp " karaf ram usage: " $karaf_ram_usage
  karaf_pid=$(ps aux --sort -rss | grep karaf | awk '{print $2}' | head -1)
  echo "karaf pid:" $karaf_pid

  if [ $karaf_ram_usage -gt $threshold_value ]
    then
      /bin/jmap -dump:file=/tmp/heapdump-$timestamp $karaf_pid
      gzip /tmp/heapdump-$timestamp
      /bin/jmap -histo:live $karaf_pid > /tmp/karaf-heap-$timestamp
      gzip /tmp/karaf-heap-$timestamp
      jstack -l $karaf_pid | gzip > /tmp/stack-dump-$timestamp.gz
    exit
  fi

  sleep 60

done
