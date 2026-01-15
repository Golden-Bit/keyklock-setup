#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

if [ ! -f ".env" ]; then
  echo "ERRORE: .env non trovato. Copia .env.example in .env e compila i valori."
  exit 1
fi

set -a
source .env
set +a

mkdir -p backups
OUT="backups/keycloak_$(date +%F).sql"

echo "[INFO] Dump DB -> $OUT"
docker exec -t kc-postgres pg_dump -U "${POSTGRES_USER}" "${POSTGRES_DB}" > "$OUT"

echo "[OK] Backup completato: $OUT"
ls -lh "$OUT"
