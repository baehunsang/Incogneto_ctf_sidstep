#!/bin/bash
set -euo pipefail

LOG=/var/log/wrapper/entrypoint.log
exec >>"$LOG" 2>&1

echo "[wrapper] Starting Docker daemon..."
# dockerd를 백그라운드로 띄우기
dockerd &


echo "[wrapper] Docker daemon running."
echo "[wrapper] Listening on TCP port 5959.."

# socat: TCP-LISTEN:1557,reuseaddr,fork EXEC:/usr/local/bin/handle_connection.sh,pty,stderr,setsid,sigint,sane
# 각 연결마다 handle_connection.sh가 새로운 프로세스로 실행되고 pty로 바인딩됩니다.
exec socat TCP-LISTEN:5959,reuseaddr,fork EXEC:/usr/local/bin/handle_connection.sh,pty,stderr,setsid,sigint,sane
