# Reanalyze Review Policy

Review findings against Vibespace's type-safety goals. Do not apply reports
mechanically.

## Triage Buckets

- `true dead`: remove private code and stale `.resi` exports when no callers
  exist.
- `interop false positive`: mark values imported by raw JavaScript with
  `@live` or suppress a narrow boundary path.
- `generated`: suppress generated ReScript artifacts; do not hand-edit them.
- `library surface`: suppress reusable UI primitives where unused variants,
  props, and constructors are intentional component-library capacity.

## Good Cleanup Candidates

- Dead variants in app-domain state.
- Record fields that survived a refactor.
- Unused helper functions in ReScript modules.
- `.resi` exports that no caller uses.
- Components replaced by newer UI primitives.
- Prompt-state branches made obsolete by the newer draft model.

## High-Risk Findings

Manually inspect before changing:

- Values exported for JS or JSX interop.
- Functions called from raw JS files.
- React entrypoint functions used by generated JavaScript imports.
- Browser bridge callbacks and iframe wiring.
- ReScript-shadcn or generated UI binding modules.
- OpenAI/Codex request and response wire shapes.
- LocalStorage decode/encode helpers.
- Data attributes and capability IDs referenced by generated HTML/CSS.

## Default Policy

- Remove obviously dead private code.
- Shrink `.resi` surfaces before deleting implementation helpers.
- Mark true interop entrypoints with `@live` and a short nearby comment.
- Avoid `@dead` unless code is intentionally retained for near-term work.
- Convert exception-heavy flows to `result` rather than spreading `@throws`.
