# ReScript GraphQL Backend Tooling

**Status:** Draft decision  
**Last Updated:** 2026-05-12  
**Decision:** Use a ReScript-first GraphQL backend path for Vibespace.

## Decision

Vibespace should plan its first backend around:

- ReScript for backend domain code where practical.
- GraphQL with Relay conventions as the API contract.
- `rescript-relay` on the frontend.
- ResGraph plus GraphQL Yoga on the server.
- Postgres as the durable source of truth.
- `pgtyped-rescript` as the preferred ReScript/Postgres bridge if the backend spike proves the generated workflow is stable.
- pgschema as the Postgres schema tool, using desired-state SQL plus plan/review/apply before `pgtyped-rescript` generation.

The main reason is contract quality. Vibespace wants agentic programming to work against stable, typed product objects. Relay's object identity, fragment colocation, mutation payloads, and connection model fit users, profiles, versions, invites, friend activity, and prompt sessions better than ad hoc REST endpoints.

## Why Not TypeScript First

TypeScript with Hono or Yoga would be faster to scaffold and more familiar to most agents. It is still the fallback if ReScript backend setup becomes a blocker.

For Vibespace, the higher-upside bet is to keep the frontend and backend contract close to ReScript and Relay:

- One language family for UI and backend domain types.
- Stronger pattern matching and opaque domain types for identity, profile versions, handles, and revision state.
- Less JSON-shape drift between product code and agent-authored code.
- A smaller set of conventions future agents need to learn once the skill and examples exist.

## Relay Requirements

The backend schema should be Relay-compliant from the start:

- Every durable object that the frontend revisits should implement `Node`.
- Use stable global ids for `User`, `Profile`, `ProfileVersion`, `Invite`, `FriendConnection`, `ProfileEditSession`, and `ProfileUpdateEvent`.
- Paginated lists should use connections, especially profile versions, friend activity, and friends.
- Mutations should return payload objects with the changed node or edge, not only booleans.
- Mutations that publish profile changes should return the new `ProfileVersion` and the updated `Profile`.
- Avoid exposing raw provider traces or secrets through Relay nodes.

## Postgres Direction

Use Postgres as the authoritative backend database.

Vibespace has server-authoritative constraints that are a poor first fit for local-first-only storage:

- Single-use invite redemption.
- Stable handles.
- Friend-visible profile access.
- Admin disable/takedown controls.
- Current profile version pointers.
- Immutable profile version history.

Local-first tools such as PGlite and Electric remain interesting future layers for offline editing or local drafts, but they should not be the first source of truth.

Postgres supports schemas directly. A database contains one or more named schemas, and schemas contain tables plus other named objects. Use an explicit Vibespace-owned schema for application objects and be careful with `search_path`: Postgres documents that writable schemas in a search path can let users alter query behavior. Avoid granting untrusted users `CREATE` on schemas in the backend search path.

Gel is not part of the active stack or source tracking. Plain Postgres keeps the storage choice boring and portable.

## Schema Migration Direction

Use pgschema as the default schema-management tool for Vibespace.

The source of truth should be desired-state SQL under `db/schemas/`. The workflow is:

1. Dump or edit the desired schema SQL.
2. Run `pgschema plan` against a live Postgres database.
3. Review the human, SQL, or JSON plan.
4. Run `pgschema apply` with the reviewed plan.
5. Run `pgtyped-rescript` after the schema has been applied.

This fits Vibespace because the backend is Postgres-only and likely to use Postgres-native objects such as schemas, views, functions, triggers, policies, default privileges, and partial/expression indexes. pgschema's documented model is state-based and does not use a migration history table. On fingerprint mismatch, regenerate the plan from the current database state instead of forcing stale output.

Atlas remains historical scaffold and fallback context only. Do not add new Atlas-first schema work unless pgschema blocks implementation.

## Query Typing Direction

`pgtyped-rescript` is a strong candidate for database access because it lets us write plain SQL and generate ReScript types from a live Postgres schema.

Use it as the preferred spike path for:

- SQL files that generate ReScript query modules.
- Inline `%sql` in ReScript when it improves locality.
- Typed result records and query parameters.
- Postgres check constraints that generate ReScript polyvariant types for enum-like fields.
- JSON population helpers for bulk operations if they remain clean in generated ReScript.

`pgtyped-rescript` does not replace schema design. pgschema owns database shape; `pgtyped-rescript` consumes the applied database schema and generates typed query modules. Treat generated query modules as build artifacts that agents must not hand-edit.

Important runtime note: SQL result columns that feed ReScript records must be explicitly aliased to the expected camelCase field names with quoted aliases, for example `display_name AS "displayName"`. The generated ReScript types may be camelCase, but the Postgres row object still uses the actual SQL column labels at runtime. Do not rely on `camelCaseColumnNames` alone for resolver-facing rows.

ReScript 12 ships the standard library with the compiler. Do not add a direct `@rescript/core` dependency or `-open RescriptCore` to Vibespace ReScript packages. Use the built-in stdlib modules directly. Third-party packages may still bring their own transitive `@rescript/core` dependency, but Vibespace source should not rely on it.

Spike default:

- Try SQL-file mode first for shared repository queries and reviewability.
- Try inline `%sql` second for short resolver-local queries.
- Choose one default after proving watch/codegen behavior with this repo's ReScript version and project layout.

## Documentation And Changelog Sources

Docs can drift. Before copying setup snippets, generated-code assumptions, or API details into implementation, check both the docs and the changelog/release stream.

| Tool | Docs | Changelog / Releases |
| --- | --- | --- |
| ReScript | https://rescript-lang.org/docs/manual/latest/introduction | https://github.com/rescript-lang/rescript-compiler/releases |
| Relay | https://relay.dev/docs/ | https://relay.dev/versions/ and https://github.com/facebook/relay/releases |
| ReScriptRelay | https://rescript-relay-documentation.vercel.app/ | https://github.com/zth/rescript-relay/releases |
| ReScriptRelay Router | package README/source docs | https://unpkg.com/rescript-relay-router@latest/CHANGELOG.md |
| ResGraph | https://zth.github.io/resgraph/docs/getting-started | https://raw.githubusercontent.com/zth/resgraph/refs/heads/main/CHANGELOG.md |
| GraphQL Yoga | https://the-guild.dev/graphql/yoga-server/docs | https://the-guild.dev/graphql/yoga-server/changelogs/graphql-yoga |
| Postgres | https://www.postgresql.org/docs/ and https://www.postgresql.org/docs/current/ddl-schemas.html | https://www.postgresql.org/docs/release/ |
| pgschema | https://www.pgschema.com/llms.txt, https://www.pgschema.com/llms-full.txt, and local copies in `docs/reference/pgschema/` | https://github.com/pgplex/pgschema/releases |
| Atlas fallback/reference only | https://atlasgo.io/docs | https://github.com/ariga/atlas/releases |
| pgtyped-rescript | https://raw.githubusercontent.com/zth/pgtyped-rescript/refs/heads/rescript/RESCRIPT.md and https://pgtyped.dev/docs/ | https://github.com/zth/pgtyped-rescript/blob/rescript/CHANGELOG.md and https://github.com/adelsz/pgtyped/releases |
| PGlite reference only | https://pglite.dev/docs/api | https://github.com/electric-sql/pglite/releases |
| Electric reference only | https://electric-sql.com/product/sync | https://github.com/electric-sql/electric/releases |

## Known Friction

- ResGraph and ReScript backend examples are less common than TypeScript server examples.
- `pgtyped-rescript` is a ReScript-specific fork, not a broad industry-standard database layer.
- Relay requires a disciplined schema shape before the UI feels easy.
- pgschema is newer than Atlas; the first local wiring exists, but production review/apply policy still needs hardening after more schema changes.
- Database access patterns still need a small interop layer around `pg`.
- Generated artifacts need a documented command path so agents do not hand-edit generated files.
- Backend HTML/CSS validation should reuse the current validation policy, but the implementation may need server-safe wrappers around existing JS modules.

## Implemented Scaffold

The repo now has a first-pass backend scaffold. It is not the final backend, but it gives agents a concrete generation order and file layout:

- `packages/schema/rescript.json` is the reusable backend schema/domain ReScript package. This keeps the API contract close to the frontend without coupling the GraphQL server app to browser-only modules.
- `api/graphql/rescript.json` is the runnable GraphQL Yoga/Bun app package.
- ReScript 12 is uncurried by default; do not add legacy curried-call assumptions to backend examples or generated-code docs.
- ReScript 12's built-in stdlib provides helpers such as `Option.getOrThrow`; do not add compatibility shims for old `@rescript/core` names unless a generator regression proves one is required.
- `packages/schema/src/BackendSchema.res` defines the first Relay-shaped ResGraph contract for users, invites, friend connections, profiles, profile versions, edit sessions, selection snapshots, trusted capability references, conversation summaries, and activity events.
- `packages/schema/src/BackendNodeResolvers.res` owns Relay `Node.id`, `node(id:)`, and `nodes(ids:)`. Keep this separate from `BackendSchema.res`; importing generated `Interface_node` from `BackendSchema.res` creates a circular dependency.
- Domain records and future database rows should store internal ids only. The GraphQL boundary currently formats readable `Type:internalId` Relay ids for MVP debugging. TODO: switch this to `ResGraph.Utils.Base64` before production or external profile sharing.
- `api/graphql/src/BackendServer.res` starts GraphQL Yoga through Bun at `/graphql`.
- `packages/schema/src/__generated__/` is generated by ResGraph. Do not hand-edit it.
- `db/bootstrap/` owns database-level setup that pgschema does not manage, including `CREATE SCHEMA` and `CREATE EXTENSION`.
- `db/schemas/vibespace.sql` is the pgschema desired-state SQL source of truth for app tables, constraints, and indexes inside the `vibespace` schema.
- `db/queries/` contains hand-written SQL query files for `pgtyped-rescript`.
- `db/queries/__generated__/` is generated by `pgtyped-rescript`. Do not hand-edit it.
- `packages/schema/src/BackendDatabase.res` contains the small PG client/transaction wrapper used by DB-backed resolvers.
- `apps/web/relay.config.json` points Relay at `packages/schema/src/__generated__/schema.graphql`; `apps/web/relay.config.cjs` is a small compatibility shim for router tooling/docs that expect that filename.
- `scripts/relay-no-watchman.sh` runs one-shot RescriptRelay codegen without Watchman. Relay v20 invokes Watchman when it is available, and sandboxed agent runs can fail when Watchman tries to write state or LaunchAgent files outside the workspace. Long-running `yarn relay:watch` intentionally bypasses that wrapper because RescriptRelay watch mode requires Watchman.
- `apps/web/rescriptRelayRouter.config.cjs` keeps route declarations under `apps/web/src/routes` and generated router assets under `apps/web/src/routes/__generated__`.

The generated ResGraph interface helper expects `Option.getOrThrow`, which is available from the ReScript 12 built-in stdlib.

## Local Infra Scaffold

Vibespace now follows the same broad local-infra split as Cos:

- Target local tooling includes Bun, Node/Corepack/Yarn, Postgres client tools, Docker, k3d, kubectl, Helm, Tilt, `jq`, `rg`, and `curl`. The schema scripts use a native `pgschema` binary when available and otherwise fall back to the official `pgplex/pgschema:latest` Docker image.
- `Dockerfile` is a Cos-style multi-stage backend image using `oven/bun:1.3.5` as the base, with Node/Corepack copied in only because this repo uses Yarn 4 instead of Bun's lockfile.
- `scripts/localnet-gen-env.js` creates or reuses the local k3d cluster, writes isolated Kubernetes config to `.k8s/kubeconfig`, allocates local ports, records registry metadata, and writes `.env.local` plus `.gen-env.lock`.
- `Tiltfile` reads generated `.env.local`, runs Postgres in Kubernetes, port-forwards it locally, then uses a host-side `db-codegen` resource to apply pgschema and run initial PgTyped query generation before backend watchers start. Local backend ReScript, frontend ReScript, PgTyped, ResGraph LSP, Relay, router, and Vite resources own ongoing generated output and app serving during interactive development.
- `.dockerignore` keeps local caches, generated JS, build output, and dependency folders out of the Docker context.

pgschema should not be an npm dependency. Local scripts use a native install or the official Docker image. Tilt uses those local scripts from a host-side resource so app Docker builds do not download CLI binaries during `yarn install`.

TODO: Add a Helm chart only after the backend API, database schema, and deployment needs settle. For now Tilt uses direct Kubernetes YAML so the infra surface stays small.

TODO: Revisit the Cos Silo flow if multiple agents or local environments start fighting over ports, cluster contexts, registries, generated env state, or k3d lifecycle.

## Command Order

Target command order when changing backend schema or API contracts.

1. Edit desired-state SQL under `db/schemas/`.
2. Run `yarn db:schema:bootstrap` once per local database.
3. Run `yarn db:schema:plan` and review the generated plan in `db/plans/`.
4. Run `yarn db:schema:apply` with the reviewed plan.
5. `yarn pgtyped`
6. `yarn rescript:backend`
7. `yarn resgraph`
8. `yarn relay`
9. `yarn router`
10. `yarn backend:dev`

Why this order matters:

- `db/bootstrap/` prepares database-level prerequisites outside pgschema's scope.
- pgschema desired-state SQL defines the app schema.
- The schema scripts pass the live local database as pgschema's external plan database so extension-backed defaults such as `public.gen_random_uuid()` validate during plan generation.
- pgschema plans are review artifacts; regenerate them on fingerprint mismatch.
- `pgtyped-rescript` introspects a live Postgres schema and generates typed query modules from SQL files.
- ResGraph scans compiled ReScript type information and generates `ResGraphSchema` plus `schema.graphql`.
- Relay compiles frontend operations only after the GraphQL schema SDL exists.

For interactive development, do not run `resgraph watch` directly. Use `yarn rescript:backend:watch`, `yarn rescript:watch`, `npx pgtyped-rescript -w -c pgtyped.config.json`, `yarn resgraph:watch`, and `yarn workspace @vibespace/web vite --host 127.0.0.1 --port "$FRONTEND_PORT"` only when debugging outside Tilt. Prefer Tilt for the normal path. `yarn resgraph:watch` starts `resgraph lsp .` from the GraphQL workspace; the LSP watches the backend compiler log and regenerates committed files under `packages/schema/src/__generated__`.

Use `yarn localnet:up` as the normal backend startup command. It runs gen-env, then starts Tilt through `direnv exec .` so generated `KUBECONFIG`, ports, and registry values are available. Raw `tilt up` is valid only after `.env.local` exists. Outside Tilt, `yarn backend:check` compiles the backend GraphQL contract and validates Relay through `yarn backend:container:check`; run `yarn db:schema:plan`, `yarn db:schema:apply`, and `yarn pgtyped` separately only when debugging because they require a live local Postgres database.

`yarn backend:container:check` is the Docker-safe subset. It regenerates the backend GraphQL schema and validates Relay without requiring pgschema on the app image. Schema changes should be validated by the pgschema tooling path before backend startup.

Known Docker build warning: on local arm64 OrbStack, `docker build` currently prints an `OrbStack ERROR: Dynamic loader not found: /lib64/ld-linux-x86-64.so.2` message during `yarn backend:container:check`, then exits successfully and completes Relay validation. Treat this as a follow-up to investigate in the ResGraph/binary toolchain path if it becomes noisy or starts failing builds.

Local `yarn pgtyped` requires a running Postgres database with `db/bootstrap/vibespace.sql` and `db/schemas/vibespace.sql` applied.

## Backend Spike Acceptance Criteria

- Prove the first full pgschema desired-state SQL file applies cleanly to Postgres.
- Prove SQL-file mode and inline `%sql` mode enough to choose one default.
- Prove a generated query can feed a Relay-shaped resolver in ResGraph/Yoga.
- Prove `pgtyped-rescript` can generate useful ReScript types from the pgschema-applied database.
- Document generated files and commands so agents do not hand-edit generated query modules.
- Confirm the stack works with the repo's current ReScript version or document the required version change.

## Backend Skills

The repo now has a narrow ResGraph skill at:

`.agents/skills/resgraph/SKILL.md`

The local shared copy lives at:

`/Users/vic/Documents/Vix/packages/ai/skills/resgraph/SKILL.md`

The local Codex-discoverable copy lives at:

`/Users/vic/.codex/skills/resgraph/SKILL.md`

This skill currently focuses on ResGraph command selection, generated output, and `resgraph tools find-definition`. Expand it only as concrete schema patterns are proven in this repo.

Do not create the broader Vibespace backend Codex skill yet. We need more hands-on research and better source examples before encoding the full backend workflow as agent instructions.

For now, keep the broader backend stub at:

`docs/VIBESPACE_RESCRIPT_GRAPHQL_BACKEND_SKILL_STUB.md`

When the backend spike produces reliable patterns, promote that stub into a real local Codex skill with concise instructions and reference files. The eventual backend skill should cover backend schema, pgschema plan/review/apply, Relay operations, ResGraph/Yoga setup, Postgres schema work, and provider conversation persistence.

## Fallback

If ReScript GraphQL blocks progress after a focused spike, fall back to a TypeScript GraphQL Yoga backend while preserving the same Relay schema and frontend `rescript-relay` contract. The fallback changes implementation language, not the product API.
