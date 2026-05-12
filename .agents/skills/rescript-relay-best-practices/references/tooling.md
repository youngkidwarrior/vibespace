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
yarn exec rescript-relay-compiler tools --help
```

Use compiler tools for impact analysis:

```sh
yarn exec rescript-relay-compiler tools find-schema-references User.name --with-snippet
yarn exec rescript-relay-compiler tools fragment-dependents UserCard_user --transitive
yarn exec rescript-relay-compiler tools print-operation ProfileRouteQuery
yarn exec rescript-relay-compiler tools definition-audit --min-selection-lines 40
yarn exec rescript-relay-compiler tools deprecated-usage
yarn exec rescript-relay-compiler tools unused-fragments
yarn exec rescript-relay-compiler tools fragment-spread-usage
yarn exec rescript-relay-compiler tools unused-schema-members
```

Add `--json` when another tool or agent needs structured output.

## Mutating Commands

These rewrite files. Use them only when changing the repo intentionally.

```sh
yarn relay
yarn exec rescript-relay-cli format-all-graphql
yarn exec rescript-relay-cli format-single-graphql /absolute/path/to/File.res
yarn exec rescript-relay-cli remove-unused-fields
yarn exec rescript-relay-compiler tools rename-fragment OldFragment_user NewFragment_user
```

For fragment renames, always inspect first:

```sh
yarn exec rescript-relay-compiler tools rename-fragment OldFragment_user NewFragment_user --dry-run
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

