# Reanalyze Feature Leaderboard

This ranks Reanalyze features for Vibespace by practical utility and by
implementation complexity. "Implementation" means wiring the feature into the
repo's scripts, docs, config, or review workflow, not fixing every warning it
can report.

## Utility Ranking

| Rank | Feature | Value | Why | Add Effort | LOC |
|---:|---|---:|---|---:|---:|
| 1 | DCE / dead-code analysis | Very high | Finds stale types, unused exports, dead UI surface, and bad boundaries. | Done | Done |
| 2 | `@live`, `suppress`, `unsuppress` policy | Very high | Keeps DCE useful around JS interop and generated/UI boundary code. | 1-2 hrs | 20-60 |
| 3 | JSON output + CI/report parser | High | Makes warnings trackable and reviewable over time. | Done | Done |
| 4 | Exception analysis | High | Makes unsafe parser/interop boundaries explicit. | Trial done | Scripts/docs done |
| 5 | Transitive DCE audits | Medium-high | Finds deeper dead chains after obvious cleanup. | 15-30 min | 2-10 |
| 6 | Reactive mode | Medium | Speeds repeated local analysis once reports become frequent. | Done as opt-in scripts | Done |
| 7 | `reanalyze-server` | Medium | Best speed story, but adds process/socket lifecycle complexity. | 2-4 hrs | 20-80 |
| 8 | Timing / benchmark / runs | Medium-low | Useful DX diagnostics, not direct type safety. | Done as opt-in script | Done |
| 9 | `-externals` | Medium-low | Can expose unused externals around JS bindings. | 30-60 min | 5-20 |
| 10 | CMT directory analysis | Low | Mostly useful for unusual artifact workflows. | 30-60 min | 5-20 |
| 11 | Mermaid pipeline output | Low | Useful for Reanalyze internals, not normal app work. | Done as opt-in script | Done |
| 12 | `-test-shuffle` / `-churn` | Low | Upstream correctness/debugging tools, not normal app quality gates. | 30-60 min | 5-20 |
| 13 | Termination analysis | Low for now | Useful only if recursive transforms become important. | 2-4 hrs to trial | 20-80 |
| 14 | `-write` source mutation | Avoid by default | Mutates source with `@dead`; risky before cleanup policy is mature. | Avoid | 0 |

## Complexity Ranking

| Rank | Feature | Complexity | Time | LOC |
|---:|---|---:|---:|---:|
| 1 | One-off scripts for flags | Very low | 10-20 min | 2-10 |
| 2 | Transitive override scripts | Very low | 15-30 min | 2-10 |
| 3 | `-externals` script/docs | Low | 30-60 min | 5-20 |
| 4 | CMT scripts/docs | Low | 30-60 min | 5-20 |
| 5 | Suppression/live policy docs | Low-medium | 1-2 hrs | 20-60 |
| 6 | Baseline JSON artifact/report script | Medium | Done | Done |
| 7 | CI warning budget/gate | Medium | 3-5 hrs | 80-220 |
| 8 | Exception analysis trial | Medium | 3-6 hrs | 30-100 plus fixes |
| 9 | `reanalyze-server` workflow | Medium | 2-4 hrs | 20-80 |
| 10 | Exception cleanup across repo | High | 1-3 days | Depends on findings |
| 11 | DCE cleanup across repo | High | 1-2 days | Net negative LOC likely |
| 12 | Termination analysis adoption | High | 1-2 days if recursive code exists | 40-150 |
| 13 | Automated Reanalyze dashboard | High | 1-3 days | 200-500 |

## Recommended Next Move

Run a transitive DCE audit:

- Keep normal DCE reporting non-transitive for routine checks.
- Add or use an opt-in transitive script for deeper cleanup.
- Compare transitive findings against suppressed interop/UI boundaries before
  deciding whether anything should be removed.

Exception analysis is available as an opt-in audit and currently reports no
issues, so transitive DCE is the next highest-weighted unfinished feature.
