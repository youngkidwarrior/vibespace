# /references

On-demand reference docs that **must not** live inside a skill directory's auto-load path.

## Layout

```
references/
├── reanalyze/
├── resgraph/
├── rescript-relay-best-practices/
└── rescript-relay-router/
```

Each subdirectory mirrors the skill name it serves. Filenames inside are unchanged from when they lived under `.claude/skills/<skill>/references/`.

## How to use

Load a file from here only when you have *already* engaged the relevant skill in a session and need that specific topic. Do not auto-load any of these files from a SKILL.md.

If a SKILL.md ever says "see `references/foo.md`", that mention is stale — it should point to `/Users/vic/Documents/vibespace/references/<skill>/foo.md` instead.

## Why this directory exists

Skills with a `references/` subdirectory list those files in their SKILL.md "Reference Map" or inline reference blocks, instructing the agent to load them. Multiplied across active skill triggers in a long session, this exhausted the context budget.

> Filled my context for 5 days in 2. Whoops, lesson learned.

The fix was moving the reference files out of the skill load path. A `MOVED.md` stub lives at each old `.claude/skills/<skill>/references/` location so a future agent doesn't go hunting after a stale path.

## The general rule

Any reference doc longer than a paragraph belongs here, not embedded in a skill's auto-load path. Same applies to **web fetches and external docs**: do not pull them into SKILL.md. Either keep them on-demand here, or summarize them in two sentences and link out — never both inline and full text.

## Related

- The `/todo` skill encodes the stub-with-TODO pattern for any future move/delete that leaves stale references.
