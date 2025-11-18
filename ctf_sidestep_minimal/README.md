Minimal CTF environment (client - firewall - server)
---------------------------------------------------

Overview:
- Only three containers are used: client, firewall, server.
- Host listens on 127.0.0.1:1337 -> connects to a shell inside the client container.
- The firewall forwards between client_net and server_net but initially blocks FORWARD with a DROP rule.
- The server contains the flag at /flag.txt. Remove the firewall blocking rule to reach it.

How to run:
1. Build and start:
   $ docker compose up --build -d

2. Connect to client:
   $ nc 127.0.0.1 1337

3. Follow the PLAYBOOK.md steps to get the flag.

Security notes:
- This environment is for CTF use only. Do not run on untrusted networks.
- The firewall container requires NET_ADMIN capability to manage iptables.

