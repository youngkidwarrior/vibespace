---
name: rescript-relay-router
description: Use when adding, changing, or debugging Vibespace route definitions, route renderers, route query preloading, generated router assets, type-safe links, RelayRouter providers, or the router Vite plugin.
---

# RescriptRelay Router

Use this skill when the route tree, route preload data, or top-level router
provider changes.

## First Pass

Before editing, inspect:

- `rescriptRelayRouter.config.cjs`: routes folder and generated path.
- `src/routes/routes.json`: route declarations.
- `src/routes/*_route_renderer.res`: route renderers.
- `src/routes/__generated__`: generated router modules.
- `vite.config.js`: `rescriptRelayVitePlugin()` setup.

### References (on-demand)

Detailed references are kept out of the skill load path at:
`/Users/vic/Documents/vibespace/references/rescript-relay-router/`

Read a file from there only when you have already engaged this skill and need
that specific topic (route JSON / renderer / preload / link APIs, version
changelog, or prefetch-preload patterns). Do not auto-load.

## Vibespace Defaults

- Keep route JSON and renderers inside `src/routes`.
- Keep generated router assets in `src/routes/__generated__`.
- Use route `prepare` for Relay query preloading when a route needs data.
- Use route `prepareCode` with `%relay.deferredComponent(...).preload()` for
  route-owned components that should be code split and preloaded.
- Use `RelayRouter.Provider` at the app root and render
  `RelayRouter.RouteRenderer` inside React suspense/error boundaries.
- Prefer generated route links over raw paths once a route exists.
- For app-native buttons that call `router.push`, preload the generated route
  link on pointer/hover/focus intent with `router.preload`.

## Commands

Prefer repo scripts:

```sh
yarn router
yarn router:validate
yarn rescript
```

Direct CLI fallback:

```sh
yarn exec rescript-relay-router generate -scaffold-renderers
yarn exec rescript-relay-router dump-routes --include-name --include-route-renderer-path
```

## Editing Rules

- Do not hand-edit generated router files.
- After changing `routes.json`, regenerate route assets and commit them.
- Keep parent route renderers responsible for rendering child routes.
- If a route has a Relay query, return the query ref from `prepare` and read it
  with `Query.usePreloaded` in a component.
