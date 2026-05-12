# Reanalyze User Guide

The detailed Vibespace Reanalyze workflow has moved into the repo-local
Codex skill at `.agents/skills/reanalyze`.

Use that skill for agent work involving:

- ReScript dead-code analysis.
- Exception or termination analysis.
- Monorepo CMT-directory checks.
- Tilt `reanalyze` resources and `reanalyze-server`.
- Warning budgets, suppressions, and source annotations.

Related docs:

- `docs/REANALYZE_FEATURE_LEADERBOARD.md`
- `.agents/skills/reanalyze/references/workflow.md`
- `.agents/skills/reanalyze/references/cli.md`
- `.agents/skills/reanalyze/references/annotations.md`
- `.agents/skills/reanalyze/references/review-policy.md`

The short rule: build ReScript before analysis, prefer built-in
`rescript-tools reanalyze` flags over custom discovery scripts, suppress
generated artifacts instead of editing them, and do not use `-write` unless
source mutation was explicitly requested.
