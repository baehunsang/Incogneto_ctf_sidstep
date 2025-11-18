#!/bin/bash
set -euo pipefail

# read some environment or defaults
INSTANCE_BASE=/home/wrapper/instances
PROJECT_SRC=/home/wrapper/ctf_sidstep_minimal
PORT_MIN=40000
PORT_MAX=41000
SERVICE_NAME="client"   
CONTAINER_INTERNAL_PORT=5050

timestamp() { date +"%Y%m%dT%H%M%S" ; }

# unique instance id
ID="$(timestamp)-$$-$RANDOM"
INSTANCE_DIR="${INSTANCE_BASE}/${ID}"
mkdir -p "${INSTANCE_DIR}"

echo "[${ID}] New connection, creating instance..."

echo "[${ID}] Copying project to instance directory..."
cp -a "${PROJECT_SRC}/." "${INSTANCE_DIR}/"

echo "[${ID}] Finding Free port"
HOST_PORT=$(( RANDOM % 30001 + 10000 ))

echo "[${ID}] Selected host port: ${HOST_PORT}"

# create override
OVR="${INSTANCE_DIR}/docker-compose.override.yml"
cat > "${OVR}" <<EOF
version: "3.8"
services:
  ${SERVICE_NAME}:
    ports:
      - "${HOST_PORT}:${CONTAINER_INTERNAL_PORT}"
EOF

echo "[${ID}] Created override file:"
sed -n '1,200p' "${OVR}"

pushd "${INSTANCE_DIR}" >/dev/null
echo "[${ID}] Bringing up docker-compose..."
docker compose -f docker-compose.yml -f docker-compose.override.yml up -d --remove-orphans 

echo "[${ID}] Waiting for service to bind on 127.0.0.1:${HOST_PORT}..."
end=$((SECONDS+20))
while true; do
    if ss -ltn "( sport = :${HOST_PORT} )" >/dev/null 2>&1 ; then
        break
    fi
    if [ $SECONDS -ge $end ]; then
        echo "[${ID}] Timeout waiting for service to listen on ${HOST_PORT}"
        break
    fi
    sleep 0.5
done

echo "[${ID}] Proxying STDIO <-> 127.0.0.1:${HOST_PORT}..."
socat -,raw,echo=0 TCP:127.0.0.1:${HOST_PORT}


echo "[${ID}] Connection closed. Cleaning up..."

docker compose -f docker-compose.yml -f docker-compose.override.yml down -v --remove-orphans || true

popd >/dev/null

rm -rf "${INSTANCE_DIR}" || true

echo "[${ID}] Instance removed. Exiting."
exit 0
