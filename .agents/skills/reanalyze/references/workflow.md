# Vibespace Reanalyze Workflow

Reanalyze is a static-analysis tool for ReScript. It reads compiler artifacts
and reports issues the type checker does not report: dead values/types/fields,
redundant optional arguments, possible uncaught exceptions, and experimental
termination findings.

## Build First

Run ReScript before analysis:

```sh
yarn rescript
```

Source edits are invisible to Reanalyze until the corresponding `.cmt` and
`.cmti` files have been rebuilt.

## Root Aggregate Checks

For the Vibespace monorepo, prefer built-in CMT-directory analysis from the
repo root. Use absolute suppress/exclude prefixes because CMT-mode reports
absolute file paths.

Default gate:

```sh
rescript-tools reanalyze -dce-cmt "$PWD"
```

Broader audits:

```sh
rescript-tools reanalyze -all-cmt "$PWD"
rescript-tools reanalyze -exception-cmt "$PWD"
```

Suppress generated outputs such as:

- `apps/web/src/__generated__`
- `apps/web/src/routes/__generated__`
- `packages/schema/src/__generated__`
- `db/queries/__generated__`

Exclude dependency/build artifacts such as `node_modules`, root `lib`, and
package `lib/bs` directories.

## Package-Local Checks

Use package-local config when focusing on one package:

```sh
cd apps/web
rescript-tools reanalyze -config -json
```

Package `rescript.json` files should keep minimal local config:

```json
{
  "reanalyze": {
    "analysis": ["dce"],
    "suppress": ["src/__generated__"],
    "unsuppress": [],
    "transitive": false
  }
}
```

Do not rely on package-local `-config` as proof of aggregate monorepo coverage.

## Tilt Server Flow

The preferred local workflow is for Tilt to own `reanalyze-server` as a
long-running analysis resource. The main `reanalyze` resource trigger should
restart the server. Buttons should run normal `rescript-tools reanalyze ...`
commands; when the server is on the default socket, those commands delegate to
it automatically.

Important behavior:

- The default socket is `<projectRoot>/.rescript-reanalyze.sock`.
- Socket location is project-root based; calls may come from inside the repo.
- The server always runs with reactive analysis internally.
- Output, stderr, and exit code should match a direct CLI invocation.
- Rebuild ReScript before asking the server for fresh analysis after edits.

## Warning Budgets

Keep the default gate on dead-code analysis. Expose exception/all analyses as
explicit audits until the team decides they should affect the default budget.

`reanalyze:report` may format JSON and enforce a warning budget, but it should
not own monorepo file discovery when the built-in CMT flags are sufficient.
