#!/bin/bash
FW_CLIENT_IP=`cat /usr/local/bin/conf.txt`
CONTAINER_INTERNAL_PORT=`cat /usr/local/bin/port.txt`
set -e
echo "[client] socat listener on 0.0.0.0:5050 -> /bin/bash"
/usr/sbin/ip route del default
/usr/sbin/ip route add default via $FW_CLIENT_IP
exec socat TCP-LISTEN:$CONTAINER_INTERNAL_PORT,reuseaddr,fork EXEC:/bin/bash,pty,stderr,setsid,sigint,sane