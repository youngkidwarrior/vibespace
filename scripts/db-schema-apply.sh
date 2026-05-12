#!/usr/bin/env bash
set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/db-schema-env.sh"

cd "$repo_root"

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

case "${PGSCHEMA_APPLY_MODE:-plan}" in
  file)
    run_pgschema apply \
      "${connection_args[@]}" \
      "${plan_db_args[@]}" \
      --file "$(tool_path "$schema_file")" \
      --auto-approve
    ;;
  plan)
    if [ ! -f "$plan_json" ]; then
      echo "Missing pgschema plan: $plan_json" >&2
      echo "Run yarn db:schema:plan and review the generated plan before applying." >&2
      exit 1
    fi

    run_pgschema apply \
      "${connection_args[@]}" \
      --plan "$(tool_path "$plan_json")" \
      --auto-approve
    ;;
  *)
    echo "Unsupported PGSCHEMA_APPLY_MODE=${PGSCHEMA_APPLY_MODE}. Use plan or file." >&2
    exit 1
    ;;
esac
