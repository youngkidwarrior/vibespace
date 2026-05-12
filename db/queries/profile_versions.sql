/* @name getUserById */
SELECT
  u.id AS "id",
  u.handle AS "handle",
  u.display_name AS "displayName",
  u.status AS "status",
  u.role AS "role",
  u.invited_by_user_id AS "invitedByUserId",
  u.created_at::text AS "createdAt",
  u.activated_at::text AS "activatedAt",
  u.updated_at::text AS "updatedAt"
FROM vibespace.users u
WHERE u.id = :id!;

/* @name getUsersByIds */
SELECT
  u.id AS "id",
  u.handle AS "handle",
  u.display_name AS "displayName",
  u.status AS "status",
  u.role AS "role",
  u.invited_by_user_id AS "invitedByUserId",
  u.created_at::text AS "createdAt",
  u.activated_at::text AS "activatedAt",
  u.updated_at::text AS "updatedAt"
FROM vibespace.users u
WHERE u.id = ANY(:ids!);

/* @name getUserByHandle */
SELECT
  u.id AS "id",
  u.handle AS "handle",
  u.display_name AS "displayName",
  u.status AS "status",
  u.role AS "role",
  u.invited_by_user_id AS "invitedByUserId",
  u.created_at::text AS "createdAt",
  u.activated_at::text AS "activatedAt",
  u.updated_at::text AS "updatedAt"
FROM vibespace.users u
WHERE u.handle = :handle!;

/* @name upsertSeedUser */
INSERT INTO vibespace.users (
  handle,
  display_name,
  role,
  status,
  activated_at
)
VALUES (
  :handle!,
  :displayName!,
  :role!,
  'enabled',
  now()
)
ON CONFLICT (handle) DO UPDATE SET
  display_name = EXCLUDED.display_name,
  role = EXCLUDED.role,
  status = 'enabled',
  activated_at = COALESCE(vibespace.users.activated_at, now()),
  updated_at = now()
RETURNING
  id AS "id",
  handle AS "handle",
  display_name AS "displayName",
  status AS "status",
  role AS "role",
  invited_by_user_id AS "invitedByUserId",
  created_at::text AS "createdAt",
  activated_at::text AS "activatedAt",
  updated_at::text AS "updatedAt";

/* @name ensureInviteForUser */
INSERT INTO vibespace.invites (
  code_hash,
  inviter_user_id,
  status
)
VALUES (
  :codeHash!,
  :inviterUserId!,
  'available'
)
ON CONFLICT (code_hash) DO UPDATE SET
  inviter_user_id = EXCLUDED.inviter_user_id
RETURNING
  id AS "id",
  code_hash AS "codeHash",
  inviter_user_id AS "inviterUserId",
  invitee_user_id AS "inviteeUserId",
  status AS "status",
  created_at::text AS "createdAt",
  redeemed_at::text AS "redeemedAt",
  expires_at::text AS "expiresAt";

/* @name getAvailableInviteForUser */
SELECT
  i.id AS "id",
  i.code_hash AS "codeHash",
  i.inviter_user_id AS "inviterUserId",
  i.invitee_user_id AS "inviteeUserId",
  i.status AS "status",
  i.created_at::text AS "createdAt",
  i.redeemed_at::text AS "redeemedAt",
  i.expires_at::text AS "expiresAt"
FROM vibespace.invites i
WHERE i.inviter_user_id = :userId!
  AND i.status = 'available'
  AND EXISTS (
    SELECT 1
    FROM vibespace.users u
    WHERE u.id = :userId!
      AND u.status = 'enabled'
  )
ORDER BY i.created_at ASC
LIMIT 1;

/* @name getUsedInviteForUser */
SELECT
  i.id AS "id",
  i.code_hash AS "codeHash",
  i.inviter_user_id AS "inviterUserId",
  i.invitee_user_id AS "inviteeUserId",
  i.status AS "status",
  i.created_at::text AS "createdAt",
  i.redeemed_at::text AS "redeemedAt",
  i.expires_at::text AS "expiresAt"
FROM vibespace.invites i
WHERE i.invitee_user_id = :userId!
  AND i.status = 'redeemed'
ORDER BY i.redeemed_at DESC NULLS LAST, i.created_at DESC
LIMIT 1;

/* @name reactivateUsedInviteForUser */
WITH reactivated_invite AS (
  UPDATE vibespace.invites i
  SET
    invitee_user_id = NULL,
    status = 'available',
    redeemed_at = NULL
  WHERE i.invitee_user_id = :userId!
    AND i.status = 'redeemed'
    AND EXISTS (
      SELECT 1
      FROM vibespace.users u
      WHERE u.id = :userId!
        AND u.status = 'enabled'
    )
  RETURNING
    i.id,
    i.code_hash,
    i.inviter_user_id,
    i.invitee_user_id,
    i.status,
    i.created_at,
    i.redeemed_at,
    i.expires_at
),
disabled_user AS (
  UPDATE vibespace.users u
  SET
    status = 'disabled',
    updated_at = now()
  WHERE u.id = :userId!
    AND EXISTS (SELECT 1 FROM reactivated_invite)
  RETURNING
    u.id,
    u.handle,
    u.display_name,
    u.status,
    u.role,
    u.invited_by_user_id,
    u.created_at,
    u.activated_at,
    u.updated_at
)
SELECT
  disabled_user.id AS "userId",
  disabled_user.handle AS "userHandle",
  disabled_user.display_name AS "userDisplayName",
  disabled_user.status AS "userStatus",
  disabled_user.role AS "userRole",
  disabled_user.invited_by_user_id AS "userInvitedByUserId",
  disabled_user.created_at::text AS "userCreatedAt",
  disabled_user.activated_at::text AS "userActivatedAt",
  disabled_user.updated_at::text AS "userUpdatedAt",
  reactivated_invite.id AS "inviteId",
  reactivated_invite.code_hash AS "inviteCodeHash",
  reactivated_invite.inviter_user_id AS "inviteInviterUserId",
  reactivated_invite.invitee_user_id AS "inviteInviteeUserId",
  reactivated_invite.status AS "inviteStatus",
  reactivated_invite.created_at::text AS "inviteCreatedAt",
  reactivated_invite.redeemed_at::text AS "inviteRedeemedAt",
  reactivated_invite.expires_at::text AS "inviteExpiresAt"
FROM reactivated_invite
JOIN disabled_user ON true
LIMIT 1;

/* @name getInviteByCode */
SELECT
  i.id AS "id",
  i.code_hash AS "codeHash",
  i.inviter_user_id AS "inviterUserId",
  i.invitee_user_id AS "inviteeUserId",
  i.status AS "status",
  i.created_at::text AS "createdAt",
  i.redeemed_at::text AS "redeemedAt",
  i.expires_at::text AS "expiresAt"
FROM vibespace.invites i
WHERE i.code_hash = :codeHash!
LIMIT 1;

/* @name getAvailableInviteByCodeForUpdate */
SELECT
  i.id AS "id",
  i.code_hash AS "codeHash",
  i.inviter_user_id AS "inviterUserId",
  i.invitee_user_id AS "inviteeUserId",
  i.status AS "status",
  i.created_at::text AS "createdAt",
  i.redeemed_at::text AS "redeemedAt",
  i.expires_at::text AS "expiresAt"
FROM vibespace.invites i
WHERE i.code_hash = :codeHash!
  AND i.status = 'available'
  AND i.invitee_user_id IS NULL
  AND (i.expires_at IS NULL OR i.expires_at > now())
FOR UPDATE;

/* @name lockNumericHandleAllocator */
SELECT pg_advisory_xact_lock(946721381) AS "locked";

/* @name insertInviteeUserWithNumericHandle */
WITH next_handle AS (
  SELECT candidate.handle
  FROM generate_series(0, 1000000) AS sequence_number(value)
  CROSS JOIN LATERAL (SELECT sequence_number.value::text AS handle) candidate
  WHERE NOT EXISTS (
    SELECT 1
    FROM vibespace.users existing_user
    WHERE existing_user.handle = candidate.handle
  )
  ORDER BY sequence_number.value ASC
  LIMIT 1
)
INSERT INTO vibespace.users (
  handle,
  display_name,
  status,
  role,
  invited_by_user_id,
  activated_at
)
VALUES (
  (SELECT handle FROM next_handle),
  :displayName!,
  'enabled',
  'user',
  :invitedByUserId!,
  now()
)
RETURNING
  id AS "id",
  handle AS "handle",
  display_name AS "displayName",
  status AS "status",
  role AS "role",
  invited_by_user_id AS "invitedByUserId",
  created_at::text AS "createdAt",
  activated_at::text AS "activatedAt",
  updated_at::text AS "updatedAt";

/* @name redeemInviteById */
UPDATE vibespace.invites
SET
  invitee_user_id = :inviteeUserId!,
  status = 'redeemed',
  redeemed_at = now()
WHERE id = :id!
  AND status = 'available'
  AND invitee_user_id IS NULL
RETURNING
  id AS "id",
  code_hash AS "codeHash",
  inviter_user_id AS "inviterUserId",
  invitee_user_id AS "inviteeUserId",
  status AS "status",
  created_at::text AS "createdAt",
  redeemed_at::text AS "redeemedAt",
  expires_at::text AS "expiresAt";

/* @name ensureInviteFriendConnection */
INSERT INTO vibespace.friend_connections (
  user_a_id,
  user_b_id,
  status,
  source
)
VALUES (
  :userAId!,
  :userBId!,
  'accepted',
  'invite'
)
ON CONFLICT (user_a_id, user_b_id) DO UPDATE SET
  status = 'accepted',
  updated_at = now()
RETURNING
  id AS "id",
  user_a_id AS "userAId",
  user_b_id AS "userBId",
  status AS "status",
  source AS "source",
  created_at::text AS "createdAt",
  updated_at::text AS "updatedAt";

/* @name getProfileById */
SELECT
  p.id AS "id",
  p.owner_user_id AS "ownerUserId",
  p.slug AS "slug",
  p.title AS "title",
  p.sendtag AS "sendtag",
  p.visibility AS "visibility",
  p.current_version_id AS "currentVersionId",
  p.created_at::text AS "createdAt",
  p.updated_at::text AS "updatedAt",
  p.published_at::text AS "publishedAt",
  p.disabled_at::text AS "disabledAt",
  p.disabled_reason AS "disabledReason"
FROM vibespace.profiles p
WHERE p.id = :id!;

/* @name getProfilesByIds */
SELECT
  p.id AS "id",
  p.owner_user_id AS "ownerUserId",
  p.slug AS "slug",
  p.title AS "title",
  p.sendtag AS "sendtag",
  p.visibility AS "visibility",
  p.current_version_id AS "currentVersionId",
  p.created_at::text AS "createdAt",
  p.updated_at::text AS "updatedAt",
  p.published_at::text AS "publishedAt",
  p.disabled_at::text AS "disabledAt",
  p.disabled_reason AS "disabledReason"
FROM vibespace.profiles p
WHERE p.id = ANY(:ids!);

/* @name getProfileByOwnerId */
SELECT
  p.id AS "id",
  p.owner_user_id AS "ownerUserId",
  p.slug AS "slug",
  p.title AS "title",
  p.sendtag AS "sendtag",
  p.visibility AS "visibility",
  p.current_version_id AS "currentVersionId",
  p.created_at::text AS "createdAt",
  p.updated_at::text AS "updatedAt",
  p.published_at::text AS "publishedAt",
  p.disabled_at::text AS "disabledAt",
  p.disabled_reason AS "disabledReason"
FROM vibespace.profiles p
WHERE p.owner_user_id = :ownerUserId!;

/* @name getProfilesByOwnerIds */
SELECT
  p.id AS "id",
  p.owner_user_id AS "ownerUserId",
  p.slug AS "slug",
  p.title AS "title",
  p.sendtag AS "sendtag",
  p.visibility AS "visibility",
  p.current_version_id AS "currentVersionId",
  p.created_at::text AS "createdAt",
  p.updated_at::text AS "updatedAt",
  p.published_at::text AS "publishedAt",
  p.disabled_at::text AS "disabledAt",
  p.disabled_reason AS "disabledReason"
FROM vibespace.profiles p
WHERE p.owner_user_id = ANY(:ownerUserIds!);

/* @name getProfileBySlug */
SELECT
  p.id AS "id",
  p.owner_user_id AS "ownerUserId",
  p.slug AS "slug",
  p.title AS "title",
  p.sendtag AS "sendtag",
  p.visibility AS "visibility",
  p.current_version_id AS "currentVersionId",
  p.created_at::text AS "createdAt",
  p.updated_at::text AS "updatedAt",
  p.published_at::text AS "publishedAt",
  p.disabled_at::text AS "disabledAt",
  p.disabled_reason AS "disabledReason"
FROM vibespace.profiles p
WHERE p.slug = :slug!;

/* @name ensureProfileForUser */
INSERT INTO vibespace.profiles (
  owner_user_id,
  slug,
  title,
  visibility,
  published_at
)
VALUES (
  :ownerUserId!,
  :slug!,
  :title!,
  'friends',
  now()
)
ON CONFLICT (owner_user_id) DO UPDATE SET
  slug = EXCLUDED.slug,
  title = EXCLUDED.title,
  visibility = 'friends',
  updated_at = now()
RETURNING
  id AS "id",
  owner_user_id AS "ownerUserId",
  slug AS "slug",
  title AS "title",
  sendtag AS "sendtag",
  visibility AS "visibility",
  current_version_id AS "currentVersionId",
  created_at::text AS "createdAt",
  updated_at::text AS "updatedAt",
  published_at::text AS "publishedAt",
  disabled_at::text AS "disabledAt",
  disabled_reason AS "disabledReason";

/* @name getProfileVersionById */
SELECT
  pv.id AS "id",
  pv.profile_id AS "profileId",
  pv.revision_number AS "revisionNumber",
  pv.parent_version_id AS "parentVersionId",
  pv.html AS "html",
  pv.css AS "css",
  pv.source AS "source",
  pv.prompt_session_id AS "promptSessionId",
  pv.summary AS "summary",
  pv.validation_status AS "validationStatus",
  pv.validation_errors::text AS "validationErrorsJson",
  pv.created_by_user_id AS "createdByUserId",
  pv.created_at::text AS "createdAt"
FROM vibespace.profile_versions pv
WHERE pv.id = :id!;

/* @name getProfileVersionsByIds */
SELECT
  pv.id AS "id",
  pv.profile_id AS "profileId",
  pv.revision_number AS "revisionNumber",
  pv.parent_version_id AS "parentVersionId",
  pv.html AS "html",
  pv.css AS "css",
  pv.source AS "source",
  pv.prompt_session_id AS "promptSessionId",
  pv.summary AS "summary",
  pv.validation_status AS "validationStatus",
  pv.validation_errors::text AS "validationErrorsJson",
  pv.created_by_user_id AS "createdByUserId",
  pv.created_at::text AS "createdAt"
FROM vibespace.profile_versions pv
WHERE pv.id = ANY(:ids!);

/* @name getCurrentProfileVersionForProfile */
SELECT
  pv.id AS "id",
  pv.profile_id AS "profileId",
  pv.revision_number AS "revisionNumber",
  pv.parent_version_id AS "parentVersionId",
  pv.html AS "html",
  pv.css AS "css",
  pv.source AS "source",
  pv.prompt_session_id AS "promptSessionId",
  pv.summary AS "summary",
  pv.validation_status AS "validationStatus",
  pv.validation_errors::text AS "validationErrorsJson",
  pv.created_by_user_id AS "createdByUserId",
  pv.created_at::text AS "createdAt"
FROM vibespace.profiles p
JOIN vibespace.profile_versions pv ON pv.id = p.current_version_id
WHERE p.id = :profileId!;

/* @name getCurrentProfileVersionsByProfileIds */
SELECT
  pv.id AS "id",
  pv.profile_id AS "profileId",
  pv.revision_number AS "revisionNumber",
  pv.parent_version_id AS "parentVersionId",
  pv.html AS "html",
  pv.css AS "css",
  pv.source AS "source",
  pv.prompt_session_id AS "promptSessionId",
  pv.summary AS "summary",
  pv.validation_status AS "validationStatus",
  pv.validation_errors::text AS "validationErrorsJson",
  pv.created_by_user_id AS "createdByUserId",
  pv.created_at::text AS "createdAt"
FROM vibespace.profiles p
JOIN vibespace.profile_versions pv ON pv.id = p.current_version_id
WHERE p.id = ANY(:profileIds!);

/* @name listProfileVersionsForProfile */
SELECT
  pv.id AS "id",
  pv.profile_id AS "profileId",
  pv.revision_number AS "revisionNumber",
  pv.parent_version_id AS "parentVersionId",
  pv.html AS "html",
  pv.css AS "css",
  pv.source AS "source",
  pv.prompt_session_id AS "promptSessionId",
  pv.summary AS "summary",
  pv.validation_status AS "validationStatus",
  pv.validation_errors::text AS "validationErrorsJson",
  pv.created_by_user_id AS "createdByUserId",
  pv.created_at::text AS "createdAt"
FROM vibespace.profile_versions pv
WHERE pv.profile_id = :profileId!
ORDER BY pv.revision_number DESC
LIMIT 100;

/* @name ensureInitialProfileVersion */
WITH existing_version AS (
  SELECT pv.*
  FROM vibespace.profile_versions pv
  WHERE pv.profile_id = :profileId!
  ORDER BY pv.revision_number ASC
  LIMIT 1
),
inserted_version AS (
  INSERT INTO vibespace.profile_versions (
    profile_id,
    revision_number,
    parent_version_id,
    html,
    css,
    source,
    summary,
    validation_status,
    validation_errors,
    created_by_user_id
  )
  SELECT
    :profileId!,
    1,
    NULL,
    :html!,
    :css!,
    'import',
    'Initial seed profile version.',
    'valid',
    '[]'::jsonb,
    :createdByUserId!
  WHERE NOT EXISTS (SELECT 1 FROM existing_version)
  RETURNING *
),
refreshed_existing_version AS (
  UPDATE vibespace.profile_versions pv
  SET
    html = :html!,
    css = :css!,
    summary = 'Initial seed profile version.',
    validation_status = 'valid',
    validation_errors = '[]'::jsonb
  FROM existing_version
  WHERE pv.id = existing_version.id
    AND existing_version.source = 'import'
    AND existing_version.summary = 'Initial seed profile version.'
    AND (
      existing_version.html LIKE '%Vibespace fixture profile%'
      OR existing_version.css LIKE '%#101114%'
    )
  RETURNING pv.*
),
selected_version AS (
  SELECT * FROM inserted_version
  UNION ALL
  SELECT * FROM refreshed_existing_version
  UNION ALL
  SELECT * FROM existing_version
  WHERE NOT EXISTS (SELECT 1 FROM refreshed_existing_version)
  LIMIT 1
),
updated_profile AS (
  UPDATE vibespace.profiles p
  SET
    current_version_id = selected_version.id,
    published_at = COALESCE(p.published_at, now()),
    updated_at = now()
  FROM selected_version
  WHERE p.id = selected_version.profile_id
  RETURNING p.id
)
SELECT
  selected_version.id AS "id",
  selected_version.profile_id AS "profileId",
  selected_version.revision_number AS "revisionNumber",
  selected_version.parent_version_id AS "parentVersionId",
  selected_version.html AS "html",
  selected_version.css AS "css",
  selected_version.source AS "source",
  selected_version.prompt_session_id AS "promptSessionId",
  selected_version.summary AS "summary",
  selected_version.validation_status AS "validationStatus",
  selected_version.validation_errors::text AS "validationErrorsJson",
  selected_version.created_by_user_id AS "createdByUserId",
  selected_version.created_at::text AS "createdAt"
FROM selected_version;

/* @name insertManualProfileVersion */
WITH target_profile AS (
  SELECT
    p.id,
    p.owner_user_id,
    p.current_version_id,
    COALESCE(MAX(existing_versions.revision_number), 0) + 1 AS next_revision_number
  FROM vibespace.profiles p
  LEFT JOIN vibespace.profile_versions existing_versions ON existing_versions.profile_id = p.id
  WHERE p.id = :profileId!
  GROUP BY p.id
),
inserted_version AS (
  INSERT INTO vibespace.profile_versions (
    profile_id,
    revision_number,
    parent_version_id,
    html,
    css,
    source,
    summary,
    validation_status,
    validation_errors,
    created_by_user_id
  )
  SELECT
    target_profile.id,
    target_profile.next_revision_number,
    target_profile.current_version_id,
    :html!,
    :css!,
    'manual',
    :summary!,
    'valid',
    '[]'::jsonb,
    :createdByUserId!
  FROM target_profile
  RETURNING *
),
updated_profile AS (
  UPDATE vibespace.profiles p
  SET
    current_version_id = inserted_version.id,
    published_at = now(),
    updated_at = now()
  FROM inserted_version
  WHERE p.id = inserted_version.profile_id
  RETURNING p.id
)
SELECT
  inserted_version.id AS "id",
  inserted_version.profile_id AS "profileId",
  inserted_version.revision_number AS "revisionNumber",
  inserted_version.parent_version_id AS "parentVersionId",
  inserted_version.html AS "html",
  inserted_version.css AS "css",
  inserted_version.source AS "source",
  inserted_version.prompt_session_id AS "promptSessionId",
  inserted_version.summary AS "summary",
  inserted_version.validation_status AS "validationStatus",
  inserted_version.validation_errors::text AS "validationErrorsJson",
  inserted_version.created_by_user_id AS "createdByUserId",
  inserted_version.created_at::text AS "createdAt"
FROM inserted_version;

/* @name restoreProfileVersion */
WITH source_version AS (
  SELECT
    sv.*,
    p.current_version_id AS previous_current_version_id
  FROM vibespace.profile_versions sv
  JOIN vibespace.profiles p ON p.id = sv.profile_id
  WHERE sv.id = :versionId!
    AND sv.profile_id = :profileId!
    AND sv.validation_status = 'valid'
),
target_profile AS (
  SELECT
    p.id,
    COALESCE(MAX(existing_versions.revision_number), 0) + 1 AS next_revision_number
  FROM vibespace.profiles p
  LEFT JOIN vibespace.profile_versions existing_versions ON existing_versions.profile_id = p.id
  WHERE p.id = :profileId!
  GROUP BY p.id
),
inserted_version AS (
  INSERT INTO vibespace.profile_versions (
    profile_id,
    revision_number,
    parent_version_id,
    html,
    css,
    source,
    summary,
    validation_status,
    validation_errors,
    created_by_user_id
  )
  SELECT
    source_version.profile_id,
    target_profile.next_revision_number,
    source_version.id,
    source_version.html,
    source_version.css,
    'restore',
    :summary!,
    source_version.validation_status,
    source_version.validation_errors,
    :createdByUserId!
  FROM source_version
  JOIN target_profile ON target_profile.id = source_version.profile_id
  RETURNING *
),
updated_profile AS (
  UPDATE vibespace.profiles p
  SET
    current_version_id = inserted_version.id,
    published_at = now(),
    updated_at = now()
  FROM inserted_version
  WHERE p.id = inserted_version.profile_id
  RETURNING p.id
)
SELECT
  inserted_version.id AS "id",
  inserted_version.profile_id AS "profileId",
  inserted_version.revision_number AS "revisionNumber",
  inserted_version.parent_version_id AS "parentVersionId",
  inserted_version.html AS "html",
  inserted_version.css AS "css",
  inserted_version.source AS "source",
  inserted_version.prompt_session_id AS "promptSessionId",
  inserted_version.summary AS "summary",
  inserted_version.validation_status AS "validationStatus",
  inserted_version.validation_errors::text AS "validationErrorsJson",
  inserted_version.created_by_user_id AS "createdByUserId",
  inserted_version.created_at::text AS "createdAt"
FROM inserted_version;

/* @name insertProfileUpdateEvent */
INSERT INTO vibespace.profile_update_events (
  actor_user_id,
  profile_id,
  profile_version_id,
  kind,
  title,
  summary,
  visibility
)
VALUES (
  :actorUserId!,
  :profileId!,
  :profileVersionId!,
  :kind!,
  :title!,
  :summary!,
  'friends'
)
RETURNING
  id AS "id",
  actor_user_id AS "actorUserId",
  profile_id AS "profileId",
  profile_version_id AS "profileVersionId",
  kind AS "kind",
  title AS "title",
  summary AS "summary",
  visibility AS "visibility",
  created_at::text AS "createdAt";

/* @name getProfileEditSessionById */
SELECT
  pes.id AS "id",
  pes.profile_id AS "profileId",
  pes.user_id AS "userId",
  pes.provider_conversation_id AS "providerConversationId",
  pes.status AS "status",
  pes.progress_phase AS "progressPhase",
  pes.prompt AS "prompt",
  pes.selection_snapshot_id AS "selectionSnapshotId",
  pes.result_version_id AS "resultVersionId",
  pes.summary AS "summary",
  pes.warnings::text AS "warningsJson",
  pes.error AS "error",
  pes.created_at::text AS "createdAt",
  pes.updated_at::text AS "updatedAt"
FROM vibespace.profile_edit_sessions pes
WHERE pes.id = :id!;

/* @name listProfileEditSessionsForProfile */
SELECT
  pes.id AS "id",
  pes.profile_id AS "profileId",
  pes.user_id AS "userId",
  pes.provider_conversation_id AS "providerConversationId",
  pes.status AS "status",
  pes.progress_phase AS "progressPhase",
  pes.prompt AS "prompt",
  pes.selection_snapshot_id AS "selectionSnapshotId",
  pes.result_version_id AS "resultVersionId",
  pes.summary AS "summary",
  pes.warnings::text AS "warningsJson",
  pes.error AS "error",
  pes.created_at::text AS "createdAt",
  pes.updated_at::text AS "updatedAt"
FROM vibespace.profile_edit_sessions pes
WHERE pes.profile_id = :profileId!
ORDER BY pes.created_at DESC
LIMIT 100;

/* @name cancelProfileEditSession */
UPDATE vibespace.profile_edit_sessions pes
SET
  status = 'canceled',
  progress_phase = 'preparing',
  error = 'Canceled by user.',
  updated_at = now()
WHERE pes.id = :id!
RETURNING
  pes.id AS "id",
  pes.profile_id AS "profileId",
  pes.user_id AS "userId",
  pes.provider_conversation_id AS "providerConversationId",
  pes.status AS "status",
  pes.progress_phase AS "progressPhase",
  pes.prompt AS "prompt",
  pes.selection_snapshot_id AS "selectionSnapshotId",
  pes.result_version_id AS "resultVersionId",
  pes.summary AS "summary",
  pes.warnings::text AS "warningsJson",
  pes.error AS "error",
  pes.created_at::text AS "createdAt",
  pes.updated_at::text AS "updatedAt";

/* @name getSelectionSnapshotById */
SELECT
  ss.id AS "id",
  ss.profile_id AS "profileId",
  ss.request_id AS "requestId",
  ss.kind AS "kind",
  ss.label AS "label",
  ss.description AS "description",
  ss.agent_context AS "agentContext",
  ss.bounds_json AS "boundsJson",
  ss.viewport_json AS "viewportJson",
  ss.nearest_element::text AS "nearestElementJson",
  ss.selected_elements::text AS "selectedElementsJson",
  ss.created_at::text AS "createdAt"
FROM vibespace.selection_snapshots ss
WHERE ss.id = :id!;

/* @name listTrustedCapabilitiesForVersion */
SELECT
  tcr.id AS "id",
  tcr.profile_version_id AS "profileVersionId",
  tcr.kind AS "kind",
  tcr.origin AS "origin",
  tcr.source AS "source",
  tcr.canonical_url AS "canonicalUrl",
  tcr.metadata_json AS "metadataJson",
  tcr.validation_status AS "validationStatus",
  tcr.created_at::text AS "createdAt"
FROM vibespace.trusted_capability_references tcr
WHERE tcr.profile_version_id = :profileVersionId!
ORDER BY tcr.created_at ASC;

/* @name getTrustedCapabilityById */
SELECT
  tcr.id AS "id",
  tcr.profile_version_id AS "profileVersionId",
  tcr.kind AS "kind",
  tcr.origin AS "origin",
  tcr.source AS "source",
  tcr.canonical_url AS "canonicalUrl",
  tcr.metadata_json AS "metadataJson",
  tcr.validation_status AS "validationStatus",
  tcr.created_at::text AS "createdAt"
FROM vibespace.trusted_capability_references tcr
WHERE tcr.id = :id!;

/* @name getAgentConversationSummaryForSession */
SELECT
  acs.id AS "id",
  acs.edit_session_id AS "editSessionId",
  acs.provider AS "provider",
  acs.provider_conversation_id AS "providerConversationId",
  acs.model AS "model",
  acs.prompt AS "prompt",
  acs.selection_label AS "selectionLabel",
  acs.selection_snapshot_id AS "selectionSnapshotId",
  acs.result_version_id AS "resultVersionId",
  acs.summary AS "summary",
  acs.warnings::text AS "warningsJson",
  acs.error AS "error",
  acs.created_at::text AS "createdAt"
FROM vibespace.agent_conversation_summaries acs
WHERE acs.edit_session_id = :editSessionId!
ORDER BY acs.created_at DESC
LIMIT 1;

/* @name getAgentConversationSummaryById */
SELECT
  acs.id AS "id",
  acs.edit_session_id AS "editSessionId",
  acs.provider AS "provider",
  acs.provider_conversation_id AS "providerConversationId",
  acs.model AS "model",
  acs.prompt AS "prompt",
  acs.selection_label AS "selectionLabel",
  acs.selection_snapshot_id AS "selectionSnapshotId",
  acs.result_version_id AS "resultVersionId",
  acs.summary AS "summary",
  acs.warnings::text AS "warningsJson",
  acs.error AS "error",
  acs.created_at::text AS "createdAt"
FROM vibespace.agent_conversation_summaries acs
WHERE acs.id = :id!;

/* @name listFriendActivityForUser */
SELECT
  pue.id AS "id",
  pue.actor_user_id AS "actorUserId",
  pue.profile_id AS "profileId",
  pue.profile_version_id AS "profileVersionId",
  pue.kind AS "kind",
  pue.title AS "title",
  pue.summary AS "summary",
  pue.visibility AS "visibility",
  pue.created_at::text AS "createdAt"
FROM vibespace.profile_update_events pue
JOIN vibespace.profiles p ON p.id = pue.profile_id
WHERE pue.visibility = 'friends'
  AND p.visibility <> 'disabled'
  AND (
    p.owner_user_id = :userId!
    OR EXISTS (
      SELECT 1
      FROM vibespace.friend_connections fc
      WHERE fc.status = 'accepted'
        AND (
          (fc.user_a_id = :userId! AND fc.user_b_id = p.owner_user_id)
          OR (fc.user_b_id = :userId! AND fc.user_a_id = p.owner_user_id)
        )
    )
  )
ORDER BY pue.created_at DESC
LIMIT 100;

/* @name listInviteChainFriendsForUser */
WITH RECURSIVE invite_chain(user_id) AS (
  SELECT :ownerUserId!::uuid

  UNION

  SELECT next_link.user_id
  FROM invite_chain chain
  JOIN LATERAL (
    SELECT child.id AS user_id
    FROM vibespace.users child
    WHERE child.invited_by_user_id = chain.user_id

    UNION

    SELECT parent.invited_by_user_id AS user_id
    FROM vibespace.users parent
    WHERE parent.id = chain.user_id
      AND parent.invited_by_user_id IS NOT NULL
  ) next_link ON true
)
SELECT
  u.id AS "userId",
  u.handle AS "handle",
  u.display_name AS "displayName",
  u.created_at::text AS "createdAt",
  p.id AS "profileId",
  p.slug AS "profileSlug",
  p.title AS "profileTitle"
FROM invite_chain chain
JOIN vibespace.users u ON u.id = chain.user_id
JOIN vibespace.profiles p ON p.owner_user_id = u.id
JOIN vibespace.profile_versions current_version
  ON current_version.id = p.current_version_id
  AND current_version.profile_id = p.id
WHERE u.id <> :ownerUserId!::uuid
  AND u.status = 'enabled'
  AND p.visibility = 'friends'
  AND current_version.source <> 'import'
  AND current_version.validation_status = 'valid'
ORDER BY u.created_at DESC, u.id DESC;

/* @name getProfileUpdateEventById */
SELECT
  pue.id AS "id",
  pue.actor_user_id AS "actorUserId",
  pue.profile_id AS "profileId",
  pue.profile_version_id AS "profileVersionId",
  pue.kind AS "kind",
  pue.title AS "title",
  pue.summary AS "summary",
  pue.visibility AS "visibility",
  pue.created_at::text AS "createdAt"
FROM vibespace.profile_update_events pue
WHERE pue.id = :id!;
