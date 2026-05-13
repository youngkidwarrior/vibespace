# RescriptRelay Tooling

Use repo scripts first. Drop to raw CLIs only for targeted diagnostics,
maintenance, or refactors.

## Repo Commands

```sh
yarn resgraph
yarn relay
yarn relay:validate
yarn relay:watch
yarn rescript
```

- `yarn resgraph`: rebuilds the GraphQL schema output from the backend schema.
- `yarn relay`: generates Relay artifacts from `relay.config.json`.
- `yarn relay:validate`: checks whether Relay artifacts are current without
  writing them.
- `yarn relay:watch`: watches Relay documents. Use through local dev/Tilt flows
  when possible.
- `yarn rescript`: compiles ReScript after generated artifacts exist.

## Safe Audit Commands

These should not modify source files.

```sh
yarn exec rescript-relay-cli debug
yarn exec rescript-relay-cli format-all-graphql --ci
yarn exec rescript-relay-cli remove-unused-fields --ci --verbose
yarn exec rescript-relay-compiler relay.config.json --validate
yarn relay tools --help
```

Use compiler tools for impact analysis:

```sh
yarn relay tools find-references User.name
yarn relay tools fragment-dependents UserCard_user --transitive
yarn relay tools print-operation ProfileRouteQuery
yarn relay tools deprecated-usage
yarn relay tools unused-fragments
yarn relay tools fragment-usage
yarn relay tools schema-dce
yarn relay tools executable-definitions --min-selection-lines 50
```

Add `--json` when another tool or agent needs structured output.

For component-boundary audits, start with:

```sh
yarn relay tools executable-definitions --min-selection-lines 50
```

Review every large fragment before editing. If a fragment is roughly 50-60+
selection lines, check whether it is serving several UI components or states. If
so, split it into smaller component-owned fragments and pass fragment refs
through the UI tree instead of keeping one broad parent fragment.

If the local workspace only exposes the raw compiler binary, use the current
legacy aliases:

```sh
yarn workspace @vibespace/web exec rescript-relay-compiler tools find-schema-references User.name
yarn workspace @vibespace/web exec rescript-relay-compiler tools fragment-spread-usage
yarn workspace @vibespace/web exec rescript-relay-compiler tools unused-schema-members
yarn workspace @vibespace/web exec rescript-relay-compiler tools definition-audit --min-selection-lines 50
```

## Mutating Commands

These rewrite files. Use them only when changing the repo intentionally.

```sh
yarn relay
yarn exec rescript-relay-cli format-all-graphql
yarn exec rescript-relay-cli format-single-graphql /absolute/path/to/File.res
yarn exec rescript-relay-cli remove-unused-fields
yarn relay tools rename-fragment OldFragment_user NewFragment_user
```

For fragment renames, always inspect first:

```sh
yarn relay tools rename-fragment OldFragment_user NewFragment_user --dry-run
```

`rename-fragment` updates fragment definitions and spread sites, but it does not
rename source files. Rename files separately if the repo expects filename and
fragment-name alignment.

## Recommended Edit Loop

1. For schema changes: `yarn resgraph`.
2. For Relay document changes: `yarn relay`.
3. For validation: `yarn relay:validate`.
4. For type checking: `yarn rescript`.
5. For larger refactors: run compiler `tools` before editing and again after.
