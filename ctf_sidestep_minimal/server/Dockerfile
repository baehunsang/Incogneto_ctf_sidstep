FROM ubuntu:22.04
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y openssh-server iproute2 sudo --no-install-recommends && rm -rf /var/lib/apt/lists/*
RUN mkdir /var/run/sshd
COPY start-server.sh /usr/local/bin/start-server.sh
COPY flag.txt /flag.txt
RUN chmod +x /usr/local/bin/start-server.sh
RUN useradd -m -s /bin/bash admin && echo "admin:admin" | chpasswd
EXPOSE 22
ENTRYPOINT ["/usr/local/bin/start-server.sh"]
