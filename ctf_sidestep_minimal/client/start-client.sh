#!/bin/bash
set -e
echo "[client] socat listener on 0.0.0.0:5050 -> /bin/bash"
/usr/sbin/ip route del default
/usr/sbin/ip route add default via 172.28.0.2
exec socat TCP-LISTEN:5050,reuseaddr,fork EXEC:/bin/bash,pty,stderr,setsid,sigint,sane