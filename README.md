# Vibespace

Vibespace is a local prototype for agent-written profile pages. The MVP focuses on a single fake profile whose source of truth is simple HTML and CSS markup.

The app shell lives in `apps/web` and is built with Vite, React, and ReScript. The profile itself is not React components; it is raw HTML/CSS rendered inside an iframe so the agent loop can iterate on markup directly.

The main route is canvas-first: enter edit mode, drag a visual area or click a profile section, then write the edit request in the anchored prompt bubble. The raw source editor lives at `/source` for development and debugging. Frontend routes are managed by `rescript-relay-router`, and the first viewer profile document is loaded through `rescript-relay` with a fixture fallback.

The reusable agentic core has started moving into `packages/generative-ui`. That workspace package is written in ReScript and emits genType TypeScript surfaces for prompt construction, web-context sanitization, trusted URL policy, and document-edit request wiring. The `apps/web` app still owns iframe rendering, selection screenshots, local prompt UI, and browser-only preview behavior.

The prototype now runs a basic validation pass before previewing or applying generated profile documents. Empty documents, scripts, inline event handlers, executable URLs, remote resource loads, embeds, forms, and CSS imports are blocked with a visible error.

Agent prompt references live in `docs/agent-context`. Runtime chat prompts are XML-organized so task, user intent, screenshots, selection context, source, rules, and response contract are clearly separated.

## Run

With Nix and direnv installed:

```bash
direnv allow
yarn install
yarn resgraph
yarn relay
yarn router
yarn rescript
yarn dev
```

Without direnv, run the frontend with your local Node/Corepack/Yarn setup:

```bash
yarn install
yarn resgraph
yarn relay
yarn router
yarn rescript
yarn dev
```

Open the local Vite URL printed by `yarn dev`.

## Backend Infra Preview

The backend scaffold is intentionally small while the frontend authoring loop remains the priority.

```bash
yarn localnet:up
```

`yarn localnet:up` generates `.env.local`, an isolated `.k8s/kubeconfig`, dynamic ports, and local registry metadata, then starts Tilt. See `docs/LOCAL_KUBERNETES.md` for the beginner-friendly localnet path.

`flake.nix` provides local tools such as Bun, k3d, kubectl, Helm, Tilt, and the Postgres client. pgschema is the chosen Postgres schema direction. Tilt starts Postgres, applies the pgschema desired state, runs `pgtyped`, regenerates the GraphQL schema, validates Relay, then starts the backend.

The first local schema loop is:

```bash
yarn db:schema:bootstrap
yarn db:schema:plan
yarn db:schema:apply
yarn pgtyped
```

`db/bootstrap/` owns database-level setup such as the `vibespace` schema and `pgcrypto`. `db/schemas/vibespace.sql` is the pgschema-managed desired state. The scripts use a native `pgschema` binary when available and otherwise fall back to `pgplex/pgschema:latest` through Docker.

## Optional OpenAI Key

`yarn localnet:up` owns `.env.local`. Put private local secrets in either ignored
file: `.env.secrets.local` for dotenv syntax, or `.envrc.private` when you
already keep simple local exports there:

```dotenv
OPENAI_API_KEY=your_key_here
```

```sh
export OPENAI_API_KEY=your_key_here
```

Run `direnv allow` after creating or changing either file, then restart localnet
so the backend pod receives the secret:

```bash
yarn localnet:up
```

Without an OpenAI key, the app still runs but assistant edits fail server-side with a configuration message. With a key, Relay calls the GraphQL `submitAgentEdit` mutation, and the GraphQL server calls the Responses API to produce and persist JSON profile patches.

Do not use `VITE_OPENAI_API_KEY`. `VITE_*` variables are browser-visible, so
OpenAI secrets must stay backend-only as `OPENAI_API_KEY`.

The default fast model is `gpt-5.4-nano`; the source-route reasoning mode defaults to `gpt-5.5`.

## MVP Boundaries

- One fake profile page.
- Plain HTML and CSS only.
- No JavaScript inside generated profile documents.
- Prompt history is local-only and stored in `localStorage`.
- Local MVP identity is invite-only with browser-local signed session tokens; real auth,
  feeds, rich friends UI, and Send Stores data are still deferred.
- Docs in `/docs` are the source of truth for research, assumptions, and future reintegration notes.
