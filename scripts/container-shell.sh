#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

if docker compose version >/dev/null 2>&1; then
  compose_cmd=(docker compose)
elif command -v docker-compose >/dev/null 2>&1; then
  compose_cmd=(docker-compose)
else
  echo "Docker Compose is not available."
  echo "Install Docker Desktop or docker-compose plugin."
  exit 1
fi

cd "$ROOT_DIR"
"${compose_cmd[@]}" run --rm latex bash
