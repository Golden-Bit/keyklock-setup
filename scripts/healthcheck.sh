#!/usr/bin/env bash
set -euo pipefail
echo "[INFO] Container status:"
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

echo
echo "[INFO] Local checks:"
curl -fsSI http://127.0.0.1:8080/ | head -n 1 || echo "[FAIL] Keycloak non risponde su 127.0.0.1:8080"
curl -fsSI http://127.0.0.1/ | head -n 1 || echo "[FAIL] Nginx non risponde su 127.0.0.1:80"

echo
echo "[INFO] Listening ports (host):"
sudo ss -lntp | egrep ':80|:443|:8080|:5432' || true
