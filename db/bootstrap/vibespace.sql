CREATE SCHEMA IF NOT EXISTS vibespace;

CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;

ALTER SCHEMA vibespace OWNER TO :"app_role";
GRANT USAGE ON SCHEMA vibespace TO :"app_role";
