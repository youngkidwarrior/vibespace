# ResGraph Tooling

Use this reference for command selection, generated output inspection, and
schema-aware CLI navigation.

## Command Selection

Prefer repo scripts when present:

```sh
yarn rescript:backend
yarn resgraph
yarn backend:container:check
yarn relay:validate
```

For interactive Vibespace backend work, use the watcher pair or Tilt resources:

```sh
yarn rescript:backend:watch
yarn resgraph:watch
```

`yarn resgraph:watch` intentionally starts `resgraph lsp .` from the GraphQL
workspace. Do not reintroduce direct `resgraph watch` unless the team changes
that policy.

Use package-local execution for ResGraph CLI tools so the command reads the
right `resgraph.json` and generated state:

```sh
yarn workspace @vibespace/graphql exec resgraph tools find-definition User.displayName
yarn workspace @vibespace/graphql exec resgraph tools find-definition User.displayName --json
```

Generic projects may use the documented `npx` shape instead:

```sh
npx resgraph tools find-definition Query.currentTime
npx resgraph tools find-definition User
npx resgraph tools find-definition User.name --json
```

## Find Definitions

Use `resgraph tools find-definition` before guessing where a GraphQL type or
field is defined.

The command expects either:

- `TypeName`
- `TypeName.fieldName`

Run `resgraph build`, `resgraph watch`, or the repo's `yarn resgraph` first.
The tool reads generated ResGraph state.

Plain-text output gives the GraphQL path, definition kind, file, and range:

```txt
path: Query.node
kind: resolver
file: /path/to/packages/schema/src/BackendNodeResolvers.res
range: 86:5-86:9
```

Use `--json` for scripts, review bots, or exact line/column reporting:

```json
{
  "path": "User.displayName",
  "kind": "exposedField",
  "file": "/path/to/packages/schema/src/BackendSchema.res",
  "range": {
    "start": {"line": 102, "column": 14},
    "end": {"line": 102, "column": 25}
  }
}
```

Known definition kinds include `resolver`, `exposedField`, `objectType`,
`interface`, `enum`, `union`, `inputObject`, `inputUnion`, and `scalar`.

## Reading Output

Use ResGraph output as the source of truth for GraphQL contract shape:

- `schema.graphql` shows the public GraphQL API Relay sees.
- Generated ReScript files show helper modules, interface implementors, and
  resolver wiring that hand-written code may need to import.
- `find-definition` tells you which hand-written source owns a GraphQL path.

Do not hand-edit generated files. Change source `.res` files, run ReScript, run
ResGraph, then inspect generated output.
