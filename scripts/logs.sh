#!/usr/bin/env bash
set -euo pipefail
echo "[INFO] Keycloak logs (last 200):"
docker logs --tail=200 keycloak || true
echo
echo "[INFO] Postgres logs (last 200):"
docker logs --tail=200 kc-postgres || true
