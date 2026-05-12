#!/usr/bin/env bash
set -euo pipefail

if command -v direnv >/dev/null 2>&1; then
  direnv exec . sh -lc 'tilt down --port "${TILT_PORT:-10350}"' || true
elif command -v tilt >/dev/null 2>&1; then
  tilt down || true
fi

node scripts/localnet-gen-env.js --clean --yes
