# qbt-pia-port-sync

Minimal container that watches a PIA / Gluetun log for a forwarded port
and pushes it into qBittorrent via the WebUI API.

## Example docker-compose

```yaml
services:
  qbt-port-sync:
    image: ghcr.io/mccarthyah/qbt-pia-port-sync:latest
    restart: unless-stopped
    environment:
      QBT_URL: http://qbittorrent:8080
      PIA_LOG: /logs/gluetun.log
    volumes:
      - /dockerdata/gluetun:/logs:ro
```
