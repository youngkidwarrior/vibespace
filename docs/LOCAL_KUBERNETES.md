# Localnet

Vibespace uses a Canton-style localnet flow for backend development. A small gen-env step creates the local Kubernetes environment first, then Tilt runs the backend stack inside it.

The repo-standard command is:

```bash
direnv allow
yarn localnet:up
```

`yarn localnet:up` runs `scripts/localnet-gen-env.js --random --force`, then starts Tilt through `direnv exec .`. The generated environment is the contract between local tooling and Tilt.

Tilt starts backend compiler/codegen resources plus frontend codegen watchers. Expected local resources include:

- `schema-watch`: watches backend ReScript.
- `resgraph-lsp`: keeps the ResGraph schema output current.
- `relay-watch`: watches `%relay` operations and writes generated Relay artifacts under `apps/web/src/__generated__/relay`.
- `router-watch`: watches route JSON and writes generated router artifacts under `apps/web/src/routes/__generated__`.
- `rescript-watch`: watches app-shell ReScript after frontend codegen resources are running.
- `vite`: starts the Vite app and points it at the generated local GraphQL endpoint.
- `db-codegen`: applies local DB schema and runs the initial PgTyped query generation before backend watchers start.
- `pgtyped-watch`: watches SQL query files with `npx pgtyped-rescript -w -c pgtyped.config.json` after DB codegen is ready.
- `reanalyze`: manual analysis resource with buttons for dead-code, exception,
  report, reactive, benchmark, and Mermaid graph scripts.

Generated PgTyped, Relay, router, and ReScript files are host-written repo artifacts; commit them with the source changes that require them.
`relay-watch` uses RescriptRelay watch mode, which requires Watchman. The Nix shell includes Watchman for this path.

Generated files:

- `.env.local`: active localnet env loaded by direnv and Tilt
- `.localnet.env`: compatibility copy
- `.gen-env.lock`: generated cluster metadata
- `.k8s/kubeconfig`: isolated kubeconfig, so `~/.kube/config` is not required

Generated frontend env:

- `HTTP_PORT`: generated local GraphQL host port forwarded by Tilt to the backend container's internal `3000` port.
- `FRONTEND_PORT`: local Vite port used by the `vite` Tilt resource.
- `VIBESPACE_GRAPHQL_PUBLIC_URL`: generated browser-visible GraphQL URL used in backend logs.
- `VITE_GRAPHQL_ENDPOINT`: browser-visible GraphQL endpoint for Relay, always derived from the generated `HTTP_PORT` during `yarn localnet:up`.

The backend container still listens on `PORT=3000` inside Kubernetes. `yarn localnet:up` assigns a generated host `HTTP_PORT`, and Tilt forwards `127.0.0.1:$HTTP_PORT` to the container. If the backend log mentions container port `3000`, use the separate `Vibespace GraphQL localnet URL ...` line or the Tilt GraphQL link for the browser-accessible endpoint.

Useful commands:

```bash
yarn localnet:up
yarn localnet:down
yarn localnet:reset
yarn localnet:gen --status
direnv exec . kubectl get pods
direnv exec . tilt get uiresources --port "$TILT_PORT"
```

`yarn localnet:down` runs `tilt down` and deletes the generated k3d cluster plus localnet files. `yarn localnet:reset` recreates everything from scratch.

If `direnv`, `k3d`, `kubectl`, `tilt`, or `watchman` are missing, enter the Nix shell with `direnv allow` or `nix develop`.

Do not put durable local secrets in `.env.local`; gen-env owns that file. Put private overrides in ignored `.env.secrets.local` or simple `.envrc.private` exports, for example:

```dotenv
OPENAI_API_KEY=your_key_here
SEND_SUPABASE_URL=https://your-send-project.supabase.co
SEND_SUPABASE_ANON_KEY=your_send_anon_key
VITE_SEND_SUPABASE_URL=https://your-send-project.supabase.co
VITE_SEND_SUPABASE_ANON_KEY=your_send_anon_key
VIBESPACE_SESSION_SECRET=optional-stable-local-session-secret
VIBESPACE_DEV_ADMIN_TOKEN=optional-stable-dev-admin-token
```

```sh
export OPENAI_API_KEY=your_key_here
export SEND_SUPABASE_URL=https://your-send-project.supabase.co
export SEND_SUPABASE_ANON_KEY=your_send_anon_key
export VITE_SEND_SUPABASE_URL=https://your-send-project.supabase.co
export VITE_SEND_SUPABASE_ANON_KEY=your_send_anon_key
export VIBESPACE_SESSION_SECRET=optional-stable-local-session-secret
export VIBESPACE_DEV_ADMIN_TOKEN=optional-stable-dev-admin-token
```

Run `direnv allow` after changing either file, then restart localnet so Tilt can inject backend-only secrets and write browser-visible `VITE_*` values into generated `.env.local`. `localnet:gen` also maps `SEND_SUPABASE_URL` / `SEND_SUPABASE_ANON_KEY` into the matching `VITE_SEND_*` values when explicit Vite values are omitted. Do not use `VITE_OPENAI_API_KEY`; `VITE_*` values are browser-visible.
