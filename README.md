# Vibespace

Vibespace is a local prototype for agent-written profile pages. The MVP focuses on a single fake profile whose source of truth is simple HTML and CSS markup.

The app shell is Vite, React, and ReScript. The profile itself is not React components; it is raw HTML/CSS rendered inside an isolated iframe so the agent loop can iterate on markup directly.

## Run

```bash
yarn install
yarn rescript
yarn dev
```

Open the local Vite URL printed by `yarn dev`.

## Optional Agent Key

Create `.env.local`:

```bash
VITE_TAMBO_API_KEY=your_key_here
```

Without a Tambo key, the app still runs in local mode and exposes a deterministic safe-edit button so the profile document loop can be tested. With a key, the agent panel sends the current HTML, CSS, and selected-element context to Tambo and renders `ProfileDocumentPatch` responses that can be applied to the profile source.

## MVP Boundaries

- One fake profile page.
- Plain HTML and CSS only.
- No JavaScript inside generated profile documents.
- No friends, users, auth, feeds, persistence, or Send Stores data yet.
- Docs in `/docs` are the source of truth for research, assumptions, and future reintegration notes.
