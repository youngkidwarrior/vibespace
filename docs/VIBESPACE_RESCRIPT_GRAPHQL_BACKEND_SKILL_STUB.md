# Vibespace ReScript GraphQL Backend Skill Stub

**Status:** Stub only. Do not treat this as a complete Codex skill yet.

## Intended Skill Trigger

Use the eventual skill when working on Vibespace backend schema, ReScript GraphQL server code, Relay contracts, Postgres data modeling, invite/profile/version APIs, or provider conversation persistence.

## Minimum Future Workflow

1. Read `docs/BACKEND_SPEC.md`.
2. Read `docs/RESCRIPT_GRAPHQL_BACKEND_TOOLING.md`.
3. Check the docs and changelog links before copying setup or API patterns.
4. Preserve the Relay contract: `Node`, stable global ids, connections, and mutation payloads that return changed records.
5. Preserve profile source truth: validated full HTML/CSS snapshots in Postgres.
6. Keep agent sessions lightweight: provider conversation id, prompt, summary, status, version link, warnings, and errors.
7. Use `yarn db:schema:bootstrap`, `yarn db:schema:plan`, and `yarn db:schema:apply` before running `pgtyped-rescript`.

## Research Needed Before Promotion

- Current ResGraph setup patterns and generated code workflow.
- Current GraphQL Yoga integration pattern for ReScript-compiled server code.
- `pgtyped-rescript` setup with current ReScript.
- SQL-file mode versus inline `%sql` mode.
- Generated-file naming, watch mode, and agent guardrails.
- pgschema plan/review/apply workflow beside `pgtyped-rescript`, including the `db/bootstrap/` versus `db/schemas/` split.
- Relay schema examples that work cleanly with `rescript-relay`.
- Server-side reuse of Vibespace HTML/CSS validation.
- Local dev workflow for running frontend, backend, Postgres, schema generation, and Relay compilation.

## Local pgschema References

- `docs/reference/pgschema/README.md`
- `docs/reference/pgschema/intro-blog.md`
- `docs/reference/pgschema/llms.txt`
- `docs/reference/pgschema/llms-full.txt`
