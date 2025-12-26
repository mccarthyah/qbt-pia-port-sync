#!/bin/sh
set -eu

QBT_URL="${QBT_URL:-http://qbittorrent:8080}"
PORT_FILE="${PORT_FILE:-/run/pia-port.txt}"
FWD_FILE="${FWD_FILE:-/forwarded/forwarded_port}"  # container path

INTERVAL="${INTERVAL:-60}"
START_DELAY="${START_DELAY:-15}"

echo "[INFO] qBittorrent URL: $QBT_URL"
echo "[INFO] Forwarded port file: $FWD_FILE"

sleep "$START_DELAY"

echo "[INFO] Waiting for qBittorrent API..."
until curl -sf "$QBT_URL/api/v2/app/version" >/dev/null; do
    sleep 2
done
echo "[INFO] qBittorrent API ready"

last_port=""

while true; do
    if [ -f "$FWD_FILE" ]; then
        port="$(cat "$FWD_FILE" | tr -d '[:space:]')"
    else
        port=""
    fi

    if [ -n "$port" ] && [ "$port" != "$last_port" ]; then
        echo "[INFO] New forwarded port detected: $port"
        echo "$port" > "$PORT_FILE"

        curl -sf -X POST \
            -d "json={\"listen_port\": $port}" \
            "$QBT_URL/api/v2/app/setPreferences" \
            && echo "[INFO] qBittorrent port updated"

        last_port="$port"
    fi

    sleep "$INTERVAL"
done