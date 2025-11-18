#!/bin/bash
set -e

# The firewall has two interfaces: one on client_net (172.28.0.1)
# and one on server_net (172.29.0.1)
FW_CLIENT_IP=`cat /usr/local/bin/conf.txt`

echo "[firewall] enable ip forwarding"
/sbin/sysctl -w net.ipv4.ip_forward=1

# SSHD 시작
echo "[firewall] start sshd"
/usr/sbin/sshd -D &


while true; do
    echo "[firewall] Initialize, Reset firewall policy.."
    /usr/local/bin/enable-iptables.sh "$FW_CLIENT_IP"
    sleep 60
done
