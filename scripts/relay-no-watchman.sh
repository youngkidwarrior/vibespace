#!/bin/sh
set -eu

PROJECT_ROOT="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
NODE_DIR="$(dirname "$(command -v node)")"

# Relay v20 eagerly invokes Watchman when it is available. In sandboxed agent
# runs Watchman may try to write LaunchAgent/state files outside the workspace,
# so keep one-shot codegen on Node + project binaries only.
export PATH="$PROJECT_ROOT/node_modules/.bin:$NODE_DIR:/usr/bin:/bin:/usr/sbin:/sbin"

exec rescript-relay-compiler "$@"
