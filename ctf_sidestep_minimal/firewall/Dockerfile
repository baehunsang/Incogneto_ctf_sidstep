FROM ubuntu:22.04
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y iptables iputils-ping openssh-server sudo iproute2 procps --no-install-recommends net-tools && rm -rf /var/lib/apt/lists/*
RUN mkdir /var/run/sshd
COPY start-firewall.sh /usr/local/bin/start-firewall.sh
COPY enable-iptables.sh /usr/local/bin/enable-iptables.sh
RUN chmod +x /usr/local/bin/start-firewall.sh /usr/local/bin/enable-iptables.sh
# user for SSH from client into firewall
RUN useradd -m -s /bin/bash admin && echo "admin:admin" | chpasswd &&     mkdir -p /home/admin/.ssh && chown -R admin:admin /home/admin  && usermod -aG sudo admin
EXPOSE 22
ENTRYPOINT ["/usr/local/bin/start-firewall.sh"]
