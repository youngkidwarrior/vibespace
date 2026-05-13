# Reanalyze CLI Reference

Use `yarn exec rescript-tools reanalyze --help` as the final authority for the
installed CLI version.

## Analysis Selection

```sh
rescript-tools reanalyze -dce
rescript-tools reanalyze -exception
rescript-tools reanalyze -termination
rescript-tools reanalyze -all
```

- `-dce`: dead-code analysis and redundant optional argument checks.
- `-exception`: possible uncaught exception analysis.
- `-termination`: experimental recursive progress analysis.
- `-all`: all available analyses.

Use `-all` for broad audits, not as the first budget gate.

## Config Mode

```sh
rescript-tools reanalyze -config
```

Reads `reanalyze` config from the active `rescript.json`. CLI analysis flags
are additive, so `-config -exception` runs configured analyses plus exception
analysis.

## CMT Directory Mode

```sh
rescript-tools reanalyze -dce-cmt path/to/root
rescript-tools reanalyze -exception-cmt path/to/root
rescript-tools reanalyze -termination-cmt path/to/root
rescript-tools reanalyze -all-cmt path/to/root
```

These scan `.cmt` and `.cmti` files recursively. In Vibespace root aggregate
analysis, pass `"$PWD"` from the repo root and use absolute suppress/exclude
prefixes.

## Filtering

```sh
rescript-tools reanalyze -dce -suppress src/generated
rescript-tools reanalyze -dce -unsuppress src/generated/Keep.res
rescript-tools reanalyze -dce -exclude-paths node_modules,lib
```

- `-suppress`: hide reports for matching path prefixes while still using the
  files for analysis.
- `-unsuppress`: report a path inside suppressed paths.
- `-exclude-paths`: remove matching path prefixes from analysis entirely.

Prefer suppression for generated ReScript artifacts and exclusion for
dependency/build output.

## Output And Diagnostics

```sh
rescript-tools reanalyze -dce -json
rescript-tools reanalyze -dce -debug
rescript-tools reanalyze -config -timing
rescript-tools reanalyze -config -reactive -runs 3
rescript-tools reanalyze -config -reactive -mermaid
```

- `-json`: machine-readable report output.
- `-debug`: debug details.
- `-timing`: internal timing.
- `-runs n`: repeated runs for reactive benchmark checks.
- `-mermaid`: reactive pipeline diagram output.

## Server Delegation

Start the server:

```sh
rescript-tools reanalyze-server
```

Then normal `rescript-tools reanalyze ...` calls delegate to it when it is
running on the default project socket. The server forces reactive mode
internally.

## Source Mutation

```sh
rescript-tools reanalyze -dce -write
```

Avoid this by default. It mutates source files by adding annotations and should
only be used in a dedicated cleanup branch after reviewing reports.
