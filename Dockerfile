# Dockerfile
FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

# 기본 툴 + docker + docker compose plugin + socat + netcat
RUN apt-get update && \
    apt-get install -y \
        apt-transport-https \
        ca-certificates \
        curl \
        gnupg-agent \
        software-properties-common \
        lsb-release \
        git \
        iproute2 \
        iputils-ping \
        net-tools \
        socat \
        vim && \
    # Docker CE 설치
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add - && \
    add-apt-repository \
       "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
       $(lsb_release -cs) \
       stable" && \
    apt-get update && \
    apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose && \
    rm -rf /var/lib/apt/lists/*

# 작업 디렉터리
WORKDIR /home/wrapper

# 인스턴스 작업 폴더
RUN mkdir -p /home/wrapper/instances && chown -R root:root /home/wrapper

# 사용자 코드(프로젝트 디렉터리) 전체를 이미지에 복사
# 빌드 컨텍스트에 ./ctf_sidstep_minimal 이 존재해야 함
COPY ctf_sidestep_minimal /home/wrapper/ctf_sidstep_minimal

# 핸들러/엔트리포인트 스크립트
COPY handle_connection.sh /usr/local/bin/handle_connection.sh
RUN chmod +x /usr/local/bin/handle_connection.sh

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# 로그 폴더
RUN mkdir -p /var/log/wrapper && chown -R root:root /var/log/wrapper

EXPOSE 1557
VOLUME /var/lib/docker

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
