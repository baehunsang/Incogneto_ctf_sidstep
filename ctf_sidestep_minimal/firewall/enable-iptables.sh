#!/bin/bash
# usage: enable-iptables.sh <FW_CLIENT_IP>
FW_CLIENT_IP="$1"
if [ -z "$FW_CLIENT_IP" ]; then
  echo "Usage: $0 <FW_CLIENT_IP>"
  exit 1
fi

set -e
echo "[firewall][iptables] flush"
/sbin/iptables -F
/sbin/iptables -t nat -F
/sbin/iptables -X

# eth0 : Untrust, eth1: Trust

# TP mode
/sbin/iptables -P FORWARD DROP
/sbin/iptables -t nat -A POSTROUTING -o eth1 -j MASQUERADE
/sbin/iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE

# INPUT policy
/sbin/iptables -P INPUT DROP
/sbin/iptables -P OUTPUT DROP
# Outbound (src: FW) permit
/sbin/iptables -A OUTPUT -o eth0 -j ACCEPT
/sbin/iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
/sbin/iptables -A INPUT -i lo -j ACCEPT
echo "[firewall][iptables] allowing SSH to firewall at $FW_CLIENT_IP:22"

# ACL01 Client ssh access permit 
/sbin/iptables -A INPUT -s "172.28.0.10" -p tcp -d "$FW_CLIENT_IP" --dport 22 -j ACCEPT


echo "[firewall][iptables] current FORWARD rules:"
/sbin/iptables -L FORWARD -n --line-numbers
