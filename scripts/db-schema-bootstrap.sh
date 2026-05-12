#!/usr/bin/env bash
set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/db-schema-env.sh"

if ! command -v psql >/dev/null 2>&1; then
  echo "psql is required for database bootstrap. Enter the Nix shell or install PostgreSQL client tools." >&2
  exit 1
fi

cd "$repo_root"

PGPASSWORD="$pg_password" psql \
  -h "$pg_host" \
  -p "$pg_port" \
  -U "$pg_user" \
  -d "$pg_database" \
  -v ON_ERROR_STOP=1 \
  -v "app_role=$pg_user" \
  -f db/bootstrap/vibespace.sql
