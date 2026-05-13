---
name: reanalyze
description: Use when running, wiring, auditing, or debugging ReScript Reanalyze in Vibespace, including dead-code analysis, exception analysis, termination analysis, all-analyses audits, monorepo CMT-directory checks, reanalyze-server, Tilt Reanalyze resources/buttons, warning budgets, suppressions, and source annotations.
---

# Reanalyze

Use this skill for ReScript static analysis work in Vibespace.

## First Pass

Before changing tooling or acting on findings, inspect the active repo shape:

- `package.json`: current `reanalyze*`, `rescript`, and `check` scripts.
- `Tiltfile`: the `reanalyze` resource, server process, and command buttons.
- Root and package `rescript.json`: monorepo package shape and package-local
  `reanalyze` config.
- Generated paths: Relay, router, ResGraph, and PgTyped output should be
  suppressed from reports, not hand-edited.

## Working Rules

- Build ReScript before analysis. Reanalyze reads compiled `.cmt` and `.cmti`
  artifacts, so stale builds produce stale reports.
- Prefer built-in Reanalyze CLI modes over custom monorepo discovery scripts.
  Root aggregate checks should use `*-cmt "$PWD"` with absolute suppress and
  exclude path prefixes.
- Use package-local `rescript-tools reanalyze -config` for focused package
  debugging, not as the aggregate monorepo coverage path.
- If Tilt is running a `reanalyze-server` on the default project socket,
  regular `rescript-tools reanalyze ...` calls delegate to it automatically.
- Suppress generated files when their code should still contribute to
  reachability analysis. Exclude paths only when artifacts should not
  participate in analysis at all.
- Do not use `-write` unless the user explicitly asks for source mutation and
  the output has been reviewed first.

## References (on-demand)

Detailed references are kept out of the skill load path at:
`/Users/vic/Documents/vibespace/references/reanalyze/`

Read a file from there only when you have already engaged this skill and need
that specific topic. Do not auto-load.

## Default Validation

For tooling changes, verify at least:

```sh
yarn reanalyze:json
yarn reanalyze:report
```

Run `yarn check` when the change affects the normal local verification path.
