FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
      socat \
      openssh-client \
      net-tools \
      iproute2 \
      procps \
      bash \
      sudo \
      iputils-ping \
      && rm -rf /var/lib/apt/lists/*



# ----------------------------------------
# 2) todo.txt 생성 (영문 문구 삽입)
# ----------------------------------------
RUN echo "Temporary rule added: any -> firewall:22 during firewall maintenance - ACL group, All id/pw is admin" \
    > /root/todo.txt 

COPY start-client.sh /usr/local/bin/start-client.sh
RUN chmod +x /usr/local/bin/start-client.sh
WORKDIR /root
# ----------------------------------------
# 5) socat 리스너 (엔트리포인트)
# ----------------------------------------
EXPOSE 5050
ENTRYPOINT ["/usr/local/bin/start-client.sh"]