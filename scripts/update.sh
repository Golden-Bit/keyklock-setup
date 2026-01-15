#!/usr/bin/env bash
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

echo "[INFO] Pre-update: stato stack"
docker compose ps

echo "[INFO] Pull nuove immagini (se presenti)"
docker compose pull

echo "[INFO] Apply update (up -d)"
docker compose up -d

echo "[INFO] Post-update: stato stack"
docker compose ps
