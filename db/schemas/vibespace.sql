CREATE TABLE users (
  id uuid PRIMARY KEY DEFAULT public.gen_random_uuid(),
  handle text NOT NULL UNIQUE,
  display_name text NOT NULL,
  status text NOT NULL DEFAULT 'enabled' CHECK (status IN ('enabled', 'disabled')),
  role text NOT NULL DEFAULT 'user' CHECK (role IN ('user', 'admin')),
  invited_by_user_id uuid REFERENCES users(id),
  created_at timestamptz NOT NULL DEFAULT now(),
  activated_at timestamptz,
  updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE invites (
  id uuid PRIMARY KEY DEFAULT public.gen_random_uuid(),
  code_hash text NOT NULL UNIQUE,
  inviter_user_id uuid NOT NULL REFERENCES users(id),
  invitee_user_id uuid REFERENCES users(id),
  status text NOT NULL DEFAULT 'available' CHECK (status IN ('available', 'redeemed', 'revoked', 'expired')),
  created_at timestamptz NOT NULL DEFAULT now(),
  redeemed_at timestamptz,
  expires_at timestamptz
);

CREATE TABLE friend_connections (
  id uuid PRIMARY KEY DEFAULT public.gen_random_uuid(),
  user_a_id uuid NOT NULL REFERENCES users(id),
  user_b_id uuid NOT NULL REFERENCES users(id),
  status text NOT NULL DEFAULT 'accepted' CHECK (status IN ('accepted', 'blocked')),
  source text NOT NULL DEFAULT 'invite' CHECK (source IN ('invite', 'manual')),
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  CHECK (user_a_id <> user_b_id),
  UNIQUE (user_a_id, user_b_id)
);

CREATE TABLE profiles (
  id uuid PRIMARY KEY DEFAULT public.gen_random_uuid(),
  owner_user_id uuid NOT NULL UNIQUE REFERENCES users(id),
  slug text NOT NULL UNIQUE,
  title text NOT NULL,
  sendtag text,
  visibility text NOT NULL DEFAULT 'friends' CHECK (visibility IN ('friends', 'disabled')),
  current_version_id uuid,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  published_at timestamptz,
  disabled_at timestamptz,
  disabled_reason text
);

CREATE TABLE selection_snapshots (
  id uuid PRIMARY KEY DEFAULT public.gen_random_uuid(),
  profile_id uuid NOT NULL REFERENCES profiles(id),
  user_id uuid NOT NULL REFERENCES users(id),
  request_id text NOT NULL,
  kind text NOT NULL DEFAULT 'none' CHECK (kind IN ('none', 'element', 'area')),
  label text NOT NULL,
  description text NOT NULL DEFAULT '',
  agent_context text NOT NULL DEFAULT '',
  bounds_json text NOT NULL DEFAULT '{}',
  viewport_json text NOT NULL DEFAULT '{}',
  nearest_element jsonb,
  selected_elements jsonb NOT NULL DEFAULT '[]'::jsonb,
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE profile_edit_sessions (
  id uuid PRIMARY KEY DEFAULT public.gen_random_uuid(),
  profile_id uuid NOT NULL REFERENCES profiles(id),
  user_id uuid NOT NULL REFERENCES users(id),
  provider text NOT NULL DEFAULT 'openai',
  provider_conversation_id text,
  status text NOT NULL DEFAULT 'draft' CHECK (status IN ('draft', 'running', 'applied', 'failed', 'canceled')),
  progress_phase text NOT NULL DEFAULT 'preparing' CHECK (
    progress_phase IN (
      'preparing',
      'planning',
      'checking_web_context',
      'extracting_assets',
      'generating',
      'validating',
      'repairing',
      'applying'
    )
  ),
  prompt text NOT NULL,
  selection_snapshot_id uuid REFERENCES selection_snapshots(id),
  result_version_id uuid,
  summary text NOT NULL DEFAULT '',
  warnings jsonb NOT NULL DEFAULT '[]'::jsonb,
  error text,
  failed_html text,
  failed_css text,
  failed_validation_message text,
  failed_validation_span jsonb,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE profile_versions (
  id uuid PRIMARY KEY DEFAULT public.gen_random_uuid(),
  profile_id uuid NOT NULL REFERENCES profiles(id),
  revision_number integer NOT NULL,
  parent_version_id uuid REFERENCES profile_versions(id),
  html text NOT NULL CHECK (btrim(html) <> ''),
  css text NOT NULL CHECK (btrim(css) <> ''),
  source text NOT NULL CHECK (source IN ('manual', 'agent', 'restore', 'import')),
  prompt_session_id uuid REFERENCES profile_edit_sessions(id),
  summary text NOT NULL DEFAULT '',
  validation_status text NOT NULL CHECK (validation_status IN ('valid', 'invalid')),
  validation_errors jsonb NOT NULL DEFAULT '[]'::jsonb CHECK (jsonb_typeof(validation_errors) = 'array'),
  created_by_user_id uuid NOT NULL REFERENCES users(id),
  created_at timestamptz NOT NULL DEFAULT now(),
  CHECK (validation_status <> 'valid' OR validation_errors = '[]'::jsonb),
  UNIQUE (profile_id, revision_number)
);

ALTER TABLE profiles
  ADD CONSTRAINT profiles_current_version_fk
  FOREIGN KEY (current_version_id)
  REFERENCES profile_versions(id);

ALTER TABLE profile_edit_sessions
  ADD CONSTRAINT profile_edit_sessions_result_version_fk
  FOREIGN KEY (result_version_id)
  REFERENCES profile_versions(id);

CREATE FUNCTION enforce_valid_profile_current_version()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
  IF NEW.current_version_id IS NULL THEN
    RETURN NEW;
  END IF;

  IF NOT EXISTS (
    SELECT 1
    FROM vibespace.profile_versions pv
    WHERE pv.id = NEW.current_version_id
      AND pv.profile_id = NEW.id
      AND pv.validation_status = 'valid'
  ) THEN
    RAISE EXCEPTION 'profiles.current_version_id must reference a valid version for the same profile';
  END IF;

  RETURN NEW;
END;
$$;

CREATE TRIGGER profiles_current_version_valid_trigger
BEFORE INSERT OR UPDATE OF current_version_id ON profiles
FOR EACH ROW
EXECUTE FUNCTION enforce_valid_profile_current_version();

CREATE TABLE trusted_capability_references (
  id uuid PRIMARY KEY DEFAULT public.gen_random_uuid(),
  profile_version_id uuid NOT NULL REFERENCES profile_versions(id),
  kind text NOT NULL CHECK (kind IN ('trusted_image', 'trusted_frame')),
  origin text NOT NULL,
  source text NOT NULL,
  canonical_url text NOT NULL,
  metadata_json text NOT NULL DEFAULT '{}',
  validation_status text NOT NULL DEFAULT 'valid' CHECK (validation_status IN ('valid', 'invalid')),
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE agent_conversation_summaries (
  id uuid PRIMARY KEY DEFAULT public.gen_random_uuid(),
  edit_session_id uuid NOT NULL REFERENCES profile_edit_sessions(id),
  provider text NOT NULL DEFAULT 'openai',
  provider_conversation_id text,
  model text,
  prompt text NOT NULL,
  selection_label text,
  selection_snapshot_id uuid REFERENCES selection_snapshots(id),
  result_version_id uuid REFERENCES profile_versions(id),
  summary text NOT NULL DEFAULT '',
  warnings jsonb NOT NULL DEFAULT '[]'::jsonb,
  error text,
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE profile_update_events (
  id uuid PRIMARY KEY DEFAULT public.gen_random_uuid(),
  actor_user_id uuid NOT NULL REFERENCES users(id),
  profile_id uuid NOT NULL REFERENCES profiles(id),
  profile_version_id uuid NOT NULL REFERENCES profile_versions(id),
  kind text NOT NULL DEFAULT 'profile_published' CHECK (kind IN ('profile_published', 'profile_restored')),
  title text NOT NULL,
  summary text NOT NULL DEFAULT '',
  visibility text NOT NULL DEFAULT 'friends' CHECK (visibility IN ('friends')),
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX profile_versions_profile_created_idx ON profile_versions(profile_id, created_at DESC);
CREATE INDEX profile_edit_sessions_profile_created_idx ON profile_edit_sessions(profile_id, created_at DESC);
CREATE INDEX selection_snapshots_profile_created_idx ON selection_snapshots(profile_id, created_at DESC);
CREATE INDEX trusted_capabilities_version_created_idx ON trusted_capability_references(profile_version_id, created_at DESC);
CREATE INDEX profile_update_events_actor_created_idx ON profile_update_events(actor_user_id, created_at DESC);
CREATE INDEX profile_update_events_profile_created_idx ON profile_update_events(profile_id, created_at DESC);
