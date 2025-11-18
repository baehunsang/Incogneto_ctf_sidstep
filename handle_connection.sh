#!/bin/bash
set -euo pipefail

# get connection no
FILE="/home/wrapper/connection_no.txt"
PORT_FILE="/home/wrapper/ctf_sidestep_minimal/port.txt"
if [ ! -f "$FILE" ]; then
    echo "0" > "$FILE"
fi
if [ ! -f "$PORT_FILE" ]; then
    echo "5050" > "$PORT_FILE"
fi

CURRENT_CON_NO="$(cat "$FILE")"

NEXT_NO="$(expr \( "$CURRENT_CON_NO" + 1 \) % 256)"

echo "$NEXT_NO" > "$FILE"

CLIENT_SUB="172.28.${CURRENT_CON_NO}.0/24"
SERVER_SUB="172.29.${CURRENT_CON_NO}.0/24"
CLIENT_IP="172.28.${CURRENT_CON_NO}.10"
SERVER_IP="172.29.${CURRENT_CON_NO}.10"
FW_IP_U="172.28.${CURRENT_CON_NO}.2"
FW_IP_T="172.29.${CURRENT_CON_NO}.2"
echo "$FW_IP_U" > "/home/wrapper/ctf_sidestep_minimal/client/conf.txt"
echo "$FW_IP_T" > "/home/wrapper/ctf_sidestep_minimal/server/conf.txt"
echo "$FW_IP_U" > "/home/wrapper/ctf_sidestep_minimal/firewall/conf.txt"

# read some environment or defaults
INSTANCE_BASE=/home/wrapper/instances
PROJECT_SRC=/home/wrapper/ctf_sidestep_minimal
PORT_MIN=40000
PORT_MAX=41000

CONTAINER_INTERNAL_PORT=`cat $PORT_FILE`
echo "$CONTAINER_INTERNAL_PORT" > "/home/wrapper/ctf_sidestep_minimal/client/port.txt"
NEXT_NO="$(expr \( "$CONTAINER_INTERNAL_PORT" + 1 \))"
echo "$NEXT_NO" > "$PORT_FILE"


timestamp() { date +"%Y%m%dT%H%M%S" ; }

# unique instance id
ID="$(timestamp)-$$-$RANDOM"
INSTANCE_DIR="${INSTANCE_BASE}/${ID}"
mkdir -p "${INSTANCE_DIR}"

echo "[${ID}] New connection, creating instance..."

echo "[${ID}] Copying project to instance directory..."
cp -a "${PROJECT_SRC}/." "${INSTANCE_DIR}/"

echo "[${ID}] Finding Free port"
HOST_PORT=$CONTAINER_INTERNAL_PORT

echo "[${ID}] Selected host port: ${HOST_PORT}"

# create override
OVR="${INSTANCE_DIR}/docker-compose.override.yml"
cat > "${OVR}" <<EOF
services:
  client:
    ports:
      - "${HOST_PORT}:${CONTAINER_INTERNAL_PORT}"
    networks:
      client_net:
        ipv4_address: ${CLIENT_IP}
  fw:
    networks:
      client_net:
        ipv4_address: ${FW_IP_U}
      server_net:
        ipv4_address: ${FW_IP_T}
  server:
    networks:
      server_net:
        ipv4_address: ${SERVER_IP}
networks:
  client_net:
    ipam:
      config:
        - subnet: ${CLIENT_SUB}
  server_net:
    ipam:
      config:
        - subnet: ${SERVER_SUB}

EOF

echo "[${ID}] Created override file:"
sed -n '1,200p' "${OVR}"

pushd "${INSTANCE_DIR}" >/dev/null
echo "[${ID}] Bringing up docker-compose..."
docker compose -f docker-compose.yml -f docker-compose.override.yml up  -d --remove-orphans > /dev/null


echo "[${ID}] Proxying STDIO <-> 127.0.0.1:${HOST_PORT}..."

socat -,raw,echo=0 TCP:127.0.0.1:${HOST_PORT}


echo "[${ID}] Connection closed. Cleaning up..."

docker compose -f docker-compose.yml -f docker-compose.override.yml down -v --remove-orphans || true

popd >/dev/null

rm -rf "${INSTANCE_DIR}" || true

echo "[${ID}] Instance removed. Exiting."
exit 0
