#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

pg_host="${PGHOST:-127.0.0.1}"
pg_port="${PGPORT:-5432}"
pg_database="${PGDATABASE:-vibespace}"
pg_user="${PGUSER:-vibespace}"
pg_password="${PGPASSWORD:-${POSTGRES_PASSWORD:-vibespace}}"
pg_schema="${PGSCHEMA_SCHEMA:-vibespace}"
schema_file="${PGSCHEMA_FILE:-db/schemas/vibespace.sql}"
plan_dir="${PGSCHEMA_PLAN_DIR:-db/plans}"
plan_json="${PGSCHEMA_PLAN_JSON:-${plan_dir}/vibespace.plan.json}"
plan_human="${PGSCHEMA_PLAN_HUMAN:-${plan_dir}/vibespace.plan.txt}"
plan_sql="${PGSCHEMA_PLAN_SQL:-${plan_dir}/vibespace.plan.sql}"

pgschema_uses_docker=false
if command -v pgschema >/dev/null 2>&1; then
  pgschema_uses_docker=false
elif command -v docker >/dev/null 2>&1; then
  pgschema_uses_docker=true
else
  echo "pgschema is not installed and docker is unavailable for pgplex/pgschema:latest" >&2
  exit 1
fi

tool_path() {
  local path="$1"
  if [ "$pgschema_uses_docker" = true ]; then
    case "$path" in
      /workspace/*) printf '%s\n' "$path" ;;
      "$repo_root"/*) printf '/workspace/%s\n' "${path#"$repo_root"/}" ;;
      /*) printf '%s\n' "$path" ;;
      *) printf '/workspace/%s\n' "$path" ;;
    esac
  else
    printf '%s\n' "$path"
  fi
}

pgschema_host() {
  if [ "$pgschema_uses_docker" = false ]; then
    printf '%s\n' "$pg_host"
    return
  fi

  case "$pg_host" in
    127.0.0.1|localhost)
      if [ "$(uname -s)" = "Linux" ]; then
        printf '%s\n' "$pg_host"
      else
        printf '%s\n' "${PGSCHEMA_DOCKER_HOST:-host.docker.internal}"
      fi
      ;;
    *)
      printf '%s\n' "$pg_host"
      ;;
  esac
}

run_pgschema() {
  if [ "$pgschema_uses_docker" = false ]; then
    PGPASSWORD="$pg_password" PGSCHEMA_PLAN_PASSWORD="$pg_password" pgschema "$@"
    return
  fi

  local docker_args=(
    run
    --rm
    --user "$(id -u):$(id -g)"
    -v "${repo_root}:/workspace"
    -e "PGPASSWORD=${pg_password}"
    -e "PGSCHEMA_PLAN_PASSWORD=${pg_password}"
  )

  if [ -n "${PGSSLMODE:-}" ]; then
    docker_args+=(-e "PGSSLMODE=${PGSSLMODE}")
  fi

  if [ "$(uname -s)" = "Linux" ] && { [ "$pg_host" = "127.0.0.1" ] || [ "$pg_host" = "localhost" ]; }; then
    docker_args+=(--network host)
  fi

  docker "${docker_args[@]}" pgplex/pgschema:latest "$@"
}
