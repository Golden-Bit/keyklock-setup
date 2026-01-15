#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

if [ $# -ne 1 ]; then
  echo "Uso: $0 <path_dump.sql>"
  exit 1
fi

DUMP="$1"
if [ ! -f "$DUMP" ]; then
  echo "ERRORE: dump non trovato: $DUMP"
  exit 1
fi

if [ ! -f ".env" ]; then
  echo "ERRORE: .env non trovato. Copia .env.example in .env e compila i valori."
  exit 1
fi

set -a
source .env
set +a

echo "[WARN] Restore in corso. Consigliato eseguire su ambiente di test prima."
echo "[INFO] Stop Keycloak per evitare scritture..."
docker compose stop keycloak

echo "[INFO] Restore DB da $DUMP ..."
cat "$DUMP" | docker exec -i kc-postgres psql -U "${POSTGRES_USER}" -d "${POSTGRES_DB}"

echo "[INFO] Start Keycloak..."
docker compose start keycloak

echo "[OK] Restore completato."
