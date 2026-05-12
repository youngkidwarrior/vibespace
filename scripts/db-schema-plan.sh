#!/usr/bin/env bash
set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/db-schema-env.sh"

cd "$repo_root"
mkdir -p "$plan_dir"

connection_args=(
  --host "$(pgschema_host)"
  --port "$pg_port"
  --db "$pg_database"
  --schema "$pg_schema"
  --user "$pg_user"
)

plan_db_args=(
  --plan-host "$(pgschema_host)"
  --plan-port "$pg_port"
  --plan-db "$pg_database"
  --plan-user "$pg_user"
)

run_pgschema plan \
  "${connection_args[@]}" \
  "${plan_db_args[@]}" \
  --file "$(tool_path "$schema_file")" \
  --output-human "$(tool_path "$plan_human")" \
  --output-json "$(tool_path "$plan_json")" \
  --output-sql "$(tool_path "$plan_sql")" \
  --no-color

echo "Wrote pgschema plan artifacts:"
echo "  $plan_human"
echo "  $plan_json"
echo "  $plan_sql"
