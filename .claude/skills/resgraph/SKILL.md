---
name: resgraph
description: Use when creating, changing, inspecting, or debugging ResGraph schemas in ReScript, including GraphQL object types, fields, resolvers, queries, mutations, inputs, dataloaders, generated schema output, and ResGraph CLI tools such as build, lsp, and tools find-definition.
---

# ResGraph

Use this skill when working on a ReScript GraphQL schema powered by ResGraph.
Pair it with ReScript best practices when editing `.res`, `.resi`, or
`rescript.json`.

Pair it with the `reanalyze` skill when auditing schema package dead code,
exception boundaries, or generated ResGraph artifact suppressions.

## Start Here

Before editing schema code, inspect the repo's actual ResGraph shape:

- `package.json`: scripts for ReScript, ResGraph build/watch/LSP, Relay, and checks.
- The package-local `resgraph.json`: source directory and generated output folder.
- Generated output: schema SDL, generated ReScript modules, and README warnings.
- Existing schema modules: look for `@gql.type`, `@gql.field`, `@gql.enum`,
  `@gql.interface`, `@gql.union`, and imports of generated modules.

In Vibespace, the active setup is:

- GraphQL app workspace: `api/graphql`
- Schema source: `packages/schema/src`
- Generated ResGraph output: `packages/schema/src/__generated__`
- ResGraph config: `api/graphql/resgraph.json`

Do not hand-edit generated files. Change source `.res` files, run ReScript, run
ResGraph, then inspect generated output.

## References (on-demand)

Detailed references are kept out of the skill load path at:
`/Users/vic/Documents/vibespace/references/resgraph/`

Read a file from there only when you have already engaged this skill and need
that specific topic. Do not auto-load.

## Default Validation

When adding or changing GraphQL surface, prefer the repo validation chain:

```sh
yarn rescript:backend
yarn resgraph
yarn relay:validate
```

Use `yarn backend:container:check` when available because it combines the
backend GraphQL contract, Relay validation, and router validation path.

## TODO Reference Areas

Add focused reference files as these patterns become proven in working code:

- Object Types
- Enums
- Interfaces
- Custom Scalars
- Input Objects
- Input Unions
- Query
- Mutations
- Subscriptions
- The Node Interface
- Dataloaders
