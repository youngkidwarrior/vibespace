# Database Schemas

This directory contains pgschema desired-state SQL. pgschema is schema-level, so files here should define objects inside the managed `vibespace` schema without `vibespace.` qualifiers.

Database-level setup belongs in `db/bootstrap/`, including:

- `CREATE SCHEMA IF NOT EXISTS vibespace`
- `CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public`

The intended workflow is:

1. Keep the canonical Postgres schema definition here as SQL.
2. Run `yarn db:schema:bootstrap` against a live local Postgres database.
3. Run `yarn db:schema:plan`.
4. Review the generated plan before applying it.
5. Run `yarn db:schema:apply`.
6. Run `yarn pgtyped` after the schema is applied.

The scripts pass the target database as pgschema's external plan database because the desired state references `public.gen_random_uuid()` from `pgcrypto`. Keep `yarn db:schema:bootstrap` in the loop so the extension exists before planning.

Do not put generated `pgtyped-rescript` query modules here.
