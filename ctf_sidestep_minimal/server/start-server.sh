#!/bin/bash
set -e
FW_CLIENT_IP=`cat /usr/local/bin/conf.txt`
/usr/sbin/ip route del default
/usr/sbin/ip route add default via $FW_CLIENT_IP
echo "[server] starting sshd"
/usr/sbin/sshd -D
