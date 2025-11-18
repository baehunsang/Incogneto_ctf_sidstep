#!/bin/bash
set -e
/usr/sbin/ip route del default
/usr/sbin/ip route add default via 172.29.0.2
echo "[server] starting sshd"
/usr/sbin/sshd -D
