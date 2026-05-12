# Database Bootstrap

These SQL files prepare database-level prerequisites before pgschema manages the `vibespace` schema.

Keep `CREATE SCHEMA`, extension installation, ownership, and grants here. Keep tables, indexes, constraints, and other application schema objects in `db/schemas/`.

`scripts/db-schema-bootstrap.sh` passes `app_role` to these files from `PGUSER`, defaulting to `vibespace`.
