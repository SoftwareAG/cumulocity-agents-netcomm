#!/bin/sh 
logger -p user.notice "cleaning up sms..."
find /usr/local/cdcs/sms/inbox -type f -mtime +1 | xargs rm
find /usr/local/cdcs/sms/outbox -type f -mtime +1 | xargs rm
