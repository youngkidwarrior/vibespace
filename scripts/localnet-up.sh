#!/usr/bin/env bash
set -euo pipefail

if ! command -v direnv >/dev/null 2>&1; then
  echo "direnv is required for localnet startup. Enter the Nix shell with \`direnv allow\` or \`nix develop\`, then retry." >&2
  exit 1
fi

node scripts/localnet-gen-env.js --random --force
direnv exec . sh -lc 'tilt up --host 0.0.0.0 --port "$TILT_PORT"'
