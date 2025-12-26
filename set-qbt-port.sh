#!/bin/sh
set -eu

QBT_URL="${QBT_URL:-http://127.0.0.1:8080}"
FWD_FILE="${FWD_FILE:-/forwarded/forwarded_port}"
PORT_FILE="${PORT_FILE:-/run/pia-port.txt}"

INTERVAL=60
START_DELAY=15

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

        # Push the port to qBittorrent (torrenting port)
        curl -sf -X POST \
            -d "json={\"listen_port\": $port}" \
            "$QBT_URL/api/v2/app/setPreferences" \
            && echo "[INFO] qBittorrent torrenting port updated to $port"

        last_port="$port"
    fi

    sleep "$INTERVAL"
done