#!/bin/sh
set -eu

QBT_URL="${QBT_URL:-http://qbittorrent:8080}"
PIA_LOG="${PIA_LOG:-/logs/gluetun.log}"
PORT_FILE="${PORT_FILE:-/run/pia-port.txt}"

INTERVAL="${INTERVAL:-60}"
START_DELAY="${START_DELAY:-15}"

echo "[INFO] qBittorrent URL: $QBT_URL"
echo "[INFO] PIA log file: $PIA_LOG"

sleep "$START_DELAY"

echo "[INFO] Waiting for qBittorrent API..."
until curl -sf "$QBT_URL/api/v2/app/version" >/dev/null; do
    sleep 2
done
echo "[INFO] qBittorrent API ready"

last_port=""

while true; do
    port="$(
        grep "Forwarded port" "$PIA_LOG" 2>/dev/null \
        | tail -n1 \
        | sed -r 's/\x1B\[[0-9;]*[mK]//g' \
        | tr -d '\r' \
        | tr -cd '0-9'
    )"

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
