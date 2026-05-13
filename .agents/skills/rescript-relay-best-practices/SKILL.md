---
name: rescript-relay-best-practices
description: Use when adding, changing, auditing, or debugging RescriptRelay in Vibespace, including Relay fragments, queries, mutations, compiler artifacts, schema usage impact, generated types, frontend GraphQL data flow, and Relay CLI tooling.
---

# RescriptRelay Best Practices

Use this skill for RescriptRelay work in Vibespace. Pair it with the
`rescript-relay-router` skill when route declarations, route renderers, or route
preloading are involved.

## First Pass

Before editing, inspect the active project shape:

- `relay.config.json`: source path, schema path, artifact path, and codegen
  command.
- `rescript.json`: `rescript-relay` dependency and PPX configuration.
- `packages/schema/src/__generated__/schema.graphql`: Relay-visible schema.
- `src/__generated__/relay`: generated Relay artifacts.
- The component, route, or package that owns the UI data dependency.

Read references only as needed:

- `references/tooling.md`: command guide and CLI safety rules.
- `references/rescript-relay-cli.md`: upstream CLI documentation.
- `references/patterns.md`: local best-practice notes and TODOs.

## Working Rules

- Keep generated Relay artifacts machine-owned. Do not hand-edit files in
  `src/__generated__/relay`.
- If the GraphQL schema changes, run ResGraph before Relay so Relay reads the
  latest schema output.
- Put data requirements near the UI that consumes them. Prefer focused fragments
  on components and route/query operations at loading boundaries.
- Use generated modules for typed hooks, loaders, variables, and fragment refs.
  Do not duplicate generated types by hand.
- Use Relay compiler analysis tools before risky schema, fragment, or operation
  changes.
- For broad Relay audits, run `yarn relay tools executable-definitions
  --min-selection-lines 50` and review large fragments first. Fragments around
  50-60+ selection lines often deserve a component/data-boundary split.
- Pair with the `reanalyze` skill for ReScript dead-code/exception audits,
  warning budgets, and generated Relay artifact suppressions.

## Store and List Updates

- Use stable GraphQL `id` values as React keys for Relay-backed arrays/lists.
- Use `@connection` and `ConnectionHandler.getConnectionID` for paginated
  collections or GraphQL collections whose membership changes via mutations.
- Prefer mutation payload fields, declarative connection directives such as
  `@appendEdge`, `@prependEdge`, and `@deleteEdge`, optimistic responses, or
  typed `@updatable` store APIs for Relay-backed updates.
- Do not force Relay store updates for non-Relay local state. For example,
  existing `localStorage` drafts should stay in local state unless they are
  first modeled as Relay client schema data.

## Default Flow

1. Inspect the existing fragment/query ownership.
2. Make the smallest `%relay(...)` source change that matches the UI need.
3. Run the relevant generator or validator from `references/tooling.md`.
4. Compile ReScript.
5. Review generated artifacts and source diffs together.
