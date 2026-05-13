/** Types generated for queries found in "db/queries/profile_versions.sql" */
open PgTyped


@gentype
type stringArray = array<string>

/** 'GetUserById' parameters type */
@gentype
type getUserByIdParams = {
  id: string,
}

/** 'GetUserById' return type */
@gentype
type getUserByIdResult = {
  activatedAt: option<string>,
  createdAt: option<string>,
  displayName: string,
  handle: string,
  id: string,
  invitedByUserId: option<string>,
  role: string,
  status: string,
  updatedAt: option<string>,
}

/** 'GetUserById' query type */
@gentype
type getUserByIdQuery = {
  params: getUserByIdParams,
  result: getUserByIdResult,
}

%%private(let getUserByIdIR: IR.t = %raw(`{"usedParamSet":{"id":true},"params":[{"name":"id","required":true,"transform":{"type":"scalar"},"locs":[{"a":321,"b":324}]}],"statement":"SELECT\n  u.id AS \"id\",\n  u.handle AS \"handle\",\n  u.display_name AS \"displayName\",\n  u.status AS \"status\",\n  u.role AS \"role\",\n  u.invited_by_user_id AS \"invitedByUserId\",\n  u.created_at::text AS \"createdAt\",\n  u.activated_at::text AS \"activatedAt\",\n  u.updated_at::text AS \"updatedAt\"\nFROM vibespace.users u\nWHERE u.id = :id!"}`))

/**
 Runnable query:
 ```sql
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
WHERE u.id = $1
 ```

 */
@gentype
module GetUserById: {
  /** Returns an array of all matched results. */
  @gentype
  let many: (PgTyped.Pg.Client.t, getUserByIdParams) => promise<array<getUserByIdResult>>
  /** Returns exactly 1 result. Returns `None` if more or less than exactly 1 result is returned. */
  @gentype
  let one: (PgTyped.Pg.Client.t, getUserByIdParams) => promise<option<getUserByIdResult>>
  
  /** Returns exactly 1 result. Raises `Exn.t` (with an optionally provided `errorMessage`) if more or less than exactly 1 result is returned. */
  @gentype
  let expectOne: (
    PgTyped.Pg.Client.t,
    getUserByIdParams,
    ~errorMessage: string=?
  ) => promise<getUserByIdResult>

  /** Executes the query, but ignores whatever is returned by it. */
  @gentype
  let execute: (PgTyped.Pg.Client.t, getUserByIdParams) => promise<unit>
} = {
  @module("pgtyped-rescript-runtime") @new external getUserById: IR.t => PreparedStatement.t<getUserByIdParams, getUserByIdResult> = "PreparedQuery";
  let query = getUserById(getUserByIdIR)
  let query = (params, ~client) => query->PreparedStatement.run(params, ~client)

  @gentype
  let many = (client, params) => query(params, ~client)

  @gentype
  let one = async (client, params) => switch await query(params, ~client) {
  | [item] => Some(item)
  | _ => None
  }

  @gentype
  let expectOne = async (client, params, ~errorMessage=?) => switch await query(params, ~client) {
  | [item] => item
  | _ => panic(errorMessage->Option.getOr("More or less than one item was returned"))
  }

  @gentype
  let execute = async (client, params) => {
    let _ = await query(params, ~client)
  }
}

@gentype
@deprecated("Use 'GetUserById.many' directly instead")
let getUserById = (params, ~client) => GetUserById.many(client, params)


/** 'GetUsersByIds' parameters type */
@gentype
type getUsersByIdsParams = {
  ids: stringArray,
}

/** 'GetUsersByIds' return type */
@gentype
type getUsersByIdsResult = {
  activatedAt: option<string>,
  createdAt: option<string>,
  displayName: string,
  handle: string,
  id: string,
  invitedByUserId: option<string>,
  role: string,
  status: string,
  updatedAt: option<string>,
}

/** 'GetUsersByIds' query type */
@gentype
type getUsersByIdsQuery = {
  params: getUsersByIdsParams,
  result: getUsersByIdsResult,
}

%%private(let getUsersByIdsIR: IR.t = %raw(`{"usedParamSet":{"ids":true},"params":[{"name":"ids","required":true,"transform":{"type":"scalar"},"locs":[{"a":325,"b":329}]}],"statement":"SELECT\n  u.id AS \"id\",\n  u.handle AS \"handle\",\n  u.display_name AS \"displayName\",\n  u.status AS \"status\",\n  u.role AS \"role\",\n  u.invited_by_user_id AS \"invitedByUserId\",\n  u.created_at::text AS \"createdAt\",\n  u.activated_at::text AS \"activatedAt\",\n  u.updated_at::text AS \"updatedAt\"\nFROM vibespace.users u\nWHERE u.id = ANY(:ids!)"}`))

/**
 Runnable query:
 ```sql
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
WHERE u.id = ANY($1)
 ```

 */
@gentype
module GetUsersByIds: {
  /** Returns an array of all matched results. */
  @gentype
  let many: (PgTyped.Pg.Client.t, getUsersByIdsParams) => promise<array<getUsersByIdsResult>>
  /** Returns exactly 1 result. Returns `None` if more or less than exactly 1 result is returned. */
  @gentype
  let one: (PgTyped.Pg.Client.t, getUsersByIdsParams) => promise<option<getUsersByIdsResult>>
  
  /** Returns exactly 1 result. Raises `Exn.t` (with an optionally provided `errorMessage`) if more or less than exactly 1 result is returned. */
  @gentype
  let expectOne: (
    PgTyped.Pg.Client.t,
    getUsersByIdsParams,
    ~errorMessage: string=?
  ) => promise<getUsersByIdsResult>

  /** Executes the query, but ignores whatever is returned by it. */
  @gentype
  let execute: (PgTyped.Pg.Client.t, getUsersByIdsParams) => promise<unit>
} = {
  @module("pgtyped-rescript-runtime") @new external getUsersByIds: IR.t => PreparedStatement.t<getUsersByIdsParams, getUsersByIdsResult> = "PreparedQuery";
  let query = getUsersByIds(getUsersByIdsIR)
  let query = (params, ~client) => query->PreparedStatement.run(params, ~client)

  @gentype
  let many = (client, params) => query(params, ~client)

  @gentype
  let one = async (client, params) => switch await query(params, ~client) {
  | [item] => Some(item)
  | _ => None
  }

  @gentype
  let expectOne = async (client, params, ~errorMessage=?) => switch await query(params, ~client) {
  | [item] => item
  | _ => panic(errorMessage->Option.getOr("More or less than one item was returned"))
  }

  @gentype
  let execute = async (client, params) => {
    let _ = await query(params, ~client)
  }
}

@gentype
@deprecated("Use 'GetUsersByIds.many' directly instead")
let getUsersByIds = (params, ~client) => GetUsersByIds.many(client, params)


/** 'GetUserByHandle' parameters type */
@gentype
type getUserByHandleParams = {
  handle: string,
}

/** 'GetUserByHandle' return type */
@gentype
type getUserByHandleResult = {
  activatedAt: option<string>,
  createdAt: option<string>,
  displayName: string,
  handle: string,
  id: string,
  invitedByUserId: option<string>,
  role: string,
  status: string,
  updatedAt: option<string>,
}

/** 'GetUserByHandle' query type */
@gentype
type getUserByHandleQuery = {
  params: getUserByHandleParams,
  result: getUserByHandleResult,
}

%%private(let getUserByHandleIR: IR.t = %raw(`{"usedParamSet":{"handle":true},"params":[{"name":"handle","required":true,"transform":{"type":"scalar"},"locs":[{"a":325,"b":332}]}],"statement":"SELECT\n  u.id AS \"id\",\n  u.handle AS \"handle\",\n  u.display_name AS \"displayName\",\n  u.status AS \"status\",\n  u.role AS \"role\",\n  u.invited_by_user_id AS \"invitedByUserId\",\n  u.created_at::text AS \"createdAt\",\n  u.activated_at::text AS \"activatedAt\",\n  u.updated_at::text AS \"updatedAt\"\nFROM vibespace.users u\nWHERE u.handle = :handle!"}`))

/**
 Runnable query:
 ```sql
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
WHERE u.handle = $1
 ```

 */
@gentype
module GetUserByHandle: {
  /** Returns an array of all matched results. */
  @gentype
  let many: (PgTyped.Pg.Client.t, getUserByHandleParams) => promise<array<getUserByHandleResult>>
  /** Returns exactly 1 result. Returns `None` if more or less than exactly 1 result is returned. */
  @gentype
  let one: (PgTyped.Pg.Client.t, getUserByHandleParams) => promise<option<getUserByHandleResult>>
  
  /** Returns exactly 1 result. Raises `Exn.t` (with an optionally provided `errorMessage`) if more or less than exactly 1 result is returned. */
  @gentype
  let expectOne: (
    PgTyped.Pg.Client.t,
    getUserByHandleParams,
    ~errorMessage: string=?
  ) => promise<getUserByHandleResult>

  /** Executes the query, but ignores whatever is returned by it. */
  @gentype
  let execute: (PgTyped.Pg.Client.t, getUserByHandleParams) => promise<unit>
} = {
  @module("pgtyped-rescript-runtime") @new external getUserByHandle: IR.t => PreparedStatement.t<getUserByHandleParams, getUserByHandleResult> = "PreparedQuery";
  let query = getUserByHandle(getUserByHandleIR)
  let query = (params, ~client) => query->PreparedStatement.run(params, ~client)

  @gentype
  let many = (client, params) => query(params, ~client)

  @gentype
  let one = async (client, params) => switch await query(params, ~client) {
  | [item] => Some(item)
  | _ => None
  }

  @gentype
  let expectOne = async (client, params, ~errorMessage=?) => switch await query(params, ~client) {
  | [item] => item
  | _ => panic(errorMessage->Option.getOr("More or less than one item was returned"))
  }

  @gentype
  let execute = async (client, params) => {
    let _ = await query(params, ~client)
  }
}

@gentype
@deprecated("Use 'GetUserByHandle.many' directly instead")
let getUserByHandle = (params, ~client) => GetUserByHandle.many(client, params)


/** 'UpsertSeedUser' parameters type */
@gentype
type upsertSeedUserParams = {
  displayName: string,
  handle: string,
  role: string,
}

/** 'UpsertSeedUser' return type */
@gentype
type upsertSeedUserResult = {
  activatedAt: option<string>,
  createdAt: option<string>,
  displayName: string,
  handle: string,
  id: string,
  invitedByUserId: option<string>,
  role: string,
  status: string,
  updatedAt: option<string>,
}

/** 'UpsertSeedUser' query type */
@gentype
type upsertSeedUserQuery = {
  params: upsertSeedUserParams,
  result: upsertSeedUserResult,
}

%%private(let upsertSeedUserIR: IR.t = %raw(`{"usedParamSet":{"handle":true,"displayName":true,"role":true},"params":[{"name":"handle","required":true,"transform":{"type":"scalar"},"locs":[{"a":102,"b":109}]},{"name":"displayName","required":true,"transform":{"type":"scalar"},"locs":[{"a":114,"b":126}]},{"name":"role","required":true,"transform":{"type":"scalar"},"locs":[{"a":131,"b":136}]}],"statement":"INSERT INTO vibespace.users (\n  handle,\n  display_name,\n  role,\n  status,\n  activated_at\n)\nVALUES (\n  :handle!,\n  :displayName!,\n  :role!,\n  'enabled',\n  now()\n)\nON CONFLICT (handle) DO UPDATE SET\n  display_name = EXCLUDED.display_name,\n  role = EXCLUDED.role,\n  status = 'enabled',\n  activated_at = COALESCE(vibespace.users.activated_at, now()),\n  updated_at = now()\nRETURNING\n  id AS \"id\",\n  handle AS \"handle\",\n  display_name AS \"displayName\",\n  status AS \"status\",\n  role AS \"role\",\n  invited_by_user_id AS \"invitedByUserId\",\n  created_at::text AS \"createdAt\",\n  activated_at::text AS \"activatedAt\",\n  updated_at::text AS \"updatedAt\""}`))

/**
 Runnable query:
 ```sql
INSERT INTO vibespace.users (
  handle,
  display_name,
  role,
  status,
  activated_at
)
VALUES (
  $1,
  $2,
  $3,
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
  updated_at::text AS "updatedAt"
 ```

 */
@gentype
module UpsertSeedUser: {
  /** Returns an array of all matched results. */
  @gentype
  let many: (PgTyped.Pg.Client.t, upsertSeedUserParams) => promise<array<upsertSeedUserResult>>
  /** Returns exactly 1 result. Returns `None` if more or less than exactly 1 result is returned. */
  @gentype
  let one: (PgTyped.Pg.Client.t, upsertSeedUserParams) => promise<option<upsertSeedUserResult>>
  
  /** Returns exactly 1 result. Raises `Exn.t` (with an optionally provided `errorMessage`) if more or less than exactly 1 result is returned. */
  @gentype
  let expectOne: (
    PgTyped.Pg.Client.t,
    upsertSeedUserParams,
    ~errorMessage: string=?
  ) => promise<upsertSeedUserResult>

  /** Executes the query, but ignores whatever is returned by it. */
  @gentype
  let execute: (PgTyped.Pg.Client.t, upsertSeedUserParams) => promise<unit>
} = {
  @module("pgtyped-rescript-runtime") @new external upsertSeedUser: IR.t => PreparedStatement.t<upsertSeedUserParams, upsertSeedUserResult> = "PreparedQuery";
  let query = upsertSeedUser(upsertSeedUserIR)
  let query = (params, ~client) => query->PreparedStatement.run(params, ~client)

  @gentype
  let many = (client, params) => query(params, ~client)

  @gentype
  let one = async (client, params) => switch await query(params, ~client) {
  | [item] => Some(item)
  | _ => None
  }

  @gentype
  let expectOne = async (client, params, ~errorMessage=?) => switch await query(params, ~client) {
  | [item] => item
  | _ => panic(errorMessage->Option.getOr("More or less than one item was returned"))
  }

  @gentype
  let execute = async (client, params) => {
    let _ = await query(params, ~client)
  }
}

@gentype
@deprecated("Use 'UpsertSeedUser.many' directly instead")
let upsertSeedUser = (params, ~client) => UpsertSeedUser.many(client, params)


/** 'EnsureInviteForUser' parameters type */
@gentype
type ensureInviteForUserParams = {
  codeHash: string,
  inviterUserId: string,
}

/** 'EnsureInviteForUser' return type */
@gentype
type ensureInviteForUserResult = {
  codeHash: string,
  createdAt: option<string>,
  expiresAt: option<string>,
  id: string,
  inviteeUserId: option<string>,
  inviterUserId: string,
  redeemedAt: option<string>,
  status: string,
}

/** 'EnsureInviteForUser' query type */
@gentype
type ensureInviteForUserQuery = {
  params: ensureInviteForUserParams,
  result: ensureInviteForUserResult,
}

%%private(let ensureInviteForUserIR: IR.t = %raw(`{"usedParamSet":{"codeHash":true,"inviterUserId":true},"params":[{"name":"codeHash","required":true,"transform":{"type":"scalar"},"locs":[{"a":86,"b":95}]},{"name":"inviterUserId","required":true,"transform":{"type":"scalar"},"locs":[{"a":100,"b":114}]}],"statement":"INSERT INTO vibespace.invites (\n  code_hash,\n  inviter_user_id,\n  status\n)\nVALUES (\n  :codeHash!,\n  :inviterUserId!,\n  'available'\n)\nON CONFLICT (code_hash) DO UPDATE SET\n  inviter_user_id = EXCLUDED.inviter_user_id\nRETURNING\n  id AS \"id\",\n  code_hash AS \"codeHash\",\n  inviter_user_id AS \"inviterUserId\",\n  invitee_user_id AS \"inviteeUserId\",\n  status AS \"status\",\n  created_at::text AS \"createdAt\",\n  redeemed_at::text AS \"redeemedAt\",\n  expires_at::text AS \"expiresAt\""}`))

/**
 Runnable query:
 ```sql
INSERT INTO vibespace.invites (
  code_hash,
  inviter_user_id,
  status
)
VALUES (
  $1,
  $2,
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
  expires_at::text AS "expiresAt"
 ```

 */
@gentype
module EnsureInviteForUser: {
  /** Returns an array of all matched results. */
  @gentype
  let many: (PgTyped.Pg.Client.t, ensureInviteForUserParams) => promise<array<ensureInviteForUserResult>>
  /** Returns exactly 1 result. Returns `None` if more or less than exactly 1 result is returned. */
  @gentype
  let one: (PgTyped.Pg.Client.t, ensureInviteForUserParams) => promise<option<ensureInviteForUserResult>>
  
  /** Returns exactly 1 result. Raises `Exn.t` (with an optionally provided `errorMessage`) if more or less than exactly 1 result is returned. */
  @gentype
  let expectOne: (
    PgTyped.Pg.Client.t,
    ensureInviteForUserParams,
    ~errorMessage: string=?
  ) => promise<ensureInviteForUserResult>

  /** Executes the query, but ignores whatever is returned by it. */
  @gentype
  let execute: (PgTyped.Pg.Client.t, ensureInviteForUserParams) => promise<unit>
} = {
  @module("pgtyped-rescript-runtime") @new external ensureInviteForUser: IR.t => PreparedStatement.t<ensureInviteForUserParams, ensureInviteForUserResult> = "PreparedQuery";
  let query = ensureInviteForUser(ensureInviteForUserIR)
  let query = (params, ~client) => query->PreparedStatement.run(params, ~client)

  @gentype
  let many = (client, params) => query(params, ~client)

  @gentype
  let one = async (client, params) => switch await query(params, ~client) {
  | [item] => Some(item)
  | _ => None
  }

  @gentype
  let expectOne = async (client, params, ~errorMessage=?) => switch await query(params, ~client) {
  | [item] => item
  | _ => panic(errorMessage->Option.getOr("More or less than one item was returned"))
  }

  @gentype
  let execute = async (client, params) => {
    let _ = await query(params, ~client)
  }
}

@gentype
@deprecated("Use 'EnsureInviteForUser.many' directly instead")
let ensureInviteForUser = (params, ~client) => EnsureInviteForUser.many(client, params)


/** 'GetAvailableInviteForUser' parameters type */
@gentype
type getAvailableInviteForUserParams = {
  userId: string,
}

/** 'GetAvailableInviteForUser' return type */
@gentype
type getAvailableInviteForUserResult = {
  codeHash: string,
  createdAt: option<string>,
  expiresAt: option<string>,
  id: string,
  inviteeUserId: option<string>,
  inviterUserId: string,
  redeemedAt: option<string>,
  status: string,
}

/** 'GetAvailableInviteForUser' query type */
@gentype
type getAvailableInviteForUserQuery = {
  params: getAvailableInviteForUserParams,
  result: getAvailableInviteForUserResult,
}

%%private(let getAvailableInviteForUserIR: IR.t = %raw(`{"usedParamSet":{"userId":true},"params":[{"name":"userId","required":true,"transform":{"type":"scalar"},"locs":[{"a":319,"b":326},{"a":429,"b":436}]}],"statement":"SELECT\n  i.id AS \"id\",\n  i.code_hash AS \"codeHash\",\n  i.inviter_user_id AS \"inviterUserId\",\n  i.invitee_user_id AS \"inviteeUserId\",\n  i.status AS \"status\",\n  i.created_at::text AS \"createdAt\",\n  i.redeemed_at::text AS \"redeemedAt\",\n  i.expires_at::text AS \"expiresAt\"\nFROM vibespace.invites i\nWHERE i.inviter_user_id = :userId!\n  AND i.status = 'available'\n  AND EXISTS (\n    SELECT 1\n    FROM vibespace.users u\n    WHERE u.id = :userId!\n      AND u.status = 'enabled'\n  )\nORDER BY i.created_at ASC\nLIMIT 1"}`))

/**
 Runnable query:
 ```sql
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
WHERE i.inviter_user_id = $1
  AND i.status = 'available'
  AND EXISTS (
    SELECT 1
    FROM vibespace.users u
    WHERE u.id = $1
      AND u.status = 'enabled'
  )
ORDER BY i.created_at ASC
LIMIT 1
 ```

 */
@gentype
module GetAvailableInviteForUser: {
  /** Returns an array of all matched results. */
  @gentype
  let many: (PgTyped.Pg.Client.t, getAvailableInviteForUserParams) => promise<array<getAvailableInviteForUserResult>>
  /** Returns exactly 1 result. Returns `None` if more or less than exactly 1 result is returned. */
  @gentype
  let one: (PgTyped.Pg.Client.t, getAvailableInviteForUserParams) => promise<option<getAvailableInviteForUserResult>>
  
  /** Returns exactly 1 result. Raises `Exn.t` (with an optionally provided `errorMessage`) if more or less than exactly 1 result is returned. */
  @gentype
  let expectOne: (
    PgTyped.Pg.Client.t,
    getAvailableInviteForUserParams,
    ~errorMessage: string=?
  ) => promise<getAvailableInviteForUserResult>

  /** Executes the query, but ignores whatever is returned by it. */
  @gentype
  let execute: (PgTyped.Pg.Client.t, getAvailableInviteForUserParams) => promise<unit>
} = {
  @module("pgtyped-rescript-runtime") @new external getAvailableInviteForUser: IR.t => PreparedStatement.t<getAvailableInviteForUserParams, getAvailableInviteForUserResult> = "PreparedQuery";
  let query = getAvailableInviteForUser(getAvailableInviteForUserIR)
  let query = (params, ~client) => query->PreparedStatement.run(params, ~client)

  @gentype
  let many = (client, params) => query(params, ~client)

  @gentype
  let one = async (client, params) => switch await query(params, ~client) {
  | [item] => Some(item)
  | _ => None
  }

  @gentype
  let expectOne = async (client, params, ~errorMessage=?) => switch await query(params, ~client) {
  | [item] => item
  | _ => panic(errorMessage->Option.getOr("More or less than one item was returned"))
  }

  @gentype
  let execute = async (client, params) => {
    let _ = await query(params, ~client)
  }
}

@gentype
@deprecated("Use 'GetAvailableInviteForUser.many' directly instead")
let getAvailableInviteForUser = (params, ~client) => GetAvailableInviteForUser.many(client, params)


/** 'GetUsedInviteForUser' parameters type */
@gentype
type getUsedInviteForUserParams = {
  userId: string,
}

/** 'GetUsedInviteForUser' return type */
@gentype
type getUsedInviteForUserResult = {
  codeHash: string,
  createdAt: option<string>,
  expiresAt: option<string>,
  id: string,
  inviteeUserId: option<string>,
  inviterUserId: string,
  redeemedAt: option<string>,
  status: string,
}

/** 'GetUsedInviteForUser' query type */
@gentype
type getUsedInviteForUserQuery = {
  params: getUsedInviteForUserParams,
  result: getUsedInviteForUserResult,
}

%%private(let getUsedInviteForUserIR: IR.t = %raw(`{"usedParamSet":{"userId":true},"params":[{"name":"userId","required":true,"transform":{"type":"scalar"},"locs":[{"a":319,"b":326}]}],"statement":"SELECT\n  i.id AS \"id\",\n  i.code_hash AS \"codeHash\",\n  i.inviter_user_id AS \"inviterUserId\",\n  i.invitee_user_id AS \"inviteeUserId\",\n  i.status AS \"status\",\n  i.created_at::text AS \"createdAt\",\n  i.redeemed_at::text AS \"redeemedAt\",\n  i.expires_at::text AS \"expiresAt\"\nFROM vibespace.invites i\nWHERE i.invitee_user_id = :userId!\n  AND i.status = 'redeemed'\nORDER BY i.redeemed_at DESC NULLS LAST, i.created_at DESC\nLIMIT 1"}`))

/**
 Runnable query:
 ```sql
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
WHERE i.invitee_user_id = $1
  AND i.status = 'redeemed'
ORDER BY i.redeemed_at DESC NULLS LAST, i.created_at DESC
LIMIT 1
 ```

 */
@gentype
module GetUsedInviteForUser: {
  /** Returns an array of all matched results. */
  @gentype
  let many: (PgTyped.Pg.Client.t, getUsedInviteForUserParams) => promise<array<getUsedInviteForUserResult>>
  /** Returns exactly 1 result. Returns `None` if more or less than exactly 1 result is returned. */
  @gentype
  let one: (PgTyped.Pg.Client.t, getUsedInviteForUserParams) => promise<option<getUsedInviteForUserResult>>
  
  /** Returns exactly 1 result. Raises `Exn.t` (with an optionally provided `errorMessage`) if more or less than exactly 1 result is returned. */
  @gentype
  let expectOne: (
    PgTyped.Pg.Client.t,
    getUsedInviteForUserParams,
    ~errorMessage: string=?
  ) => promise<getUsedInviteForUserResult>

  /** Executes the query, but ignores whatever is returned by it. */
  @gentype
  let execute: (PgTyped.Pg.Client.t, getUsedInviteForUserParams) => promise<unit>
} = {
  @module("pgtyped-rescript-runtime") @new external getUsedInviteForUser: IR.t => PreparedStatement.t<getUsedInviteForUserParams, getUsedInviteForUserResult> = "PreparedQuery";
  let query = getUsedInviteForUser(getUsedInviteForUserIR)
  let query = (params, ~client) => query->PreparedStatement.run(params, ~client)

  @gentype
  let many = (client, params) => query(params, ~client)

  @gentype
  let one = async (client, params) => switch await query(params, ~client) {
  | [item] => Some(item)
  | _ => None
  }

  @gentype
  let expectOne = async (client, params, ~errorMessage=?) => switch await query(params, ~client) {
  | [item] => item
  | _ => panic(errorMessage->Option.getOr("More or less than one item was returned"))
  }

  @gentype
  let execute = async (client, params) => {
    let _ = await query(params, ~client)
  }
}

@gentype
@deprecated("Use 'GetUsedInviteForUser.many' directly instead")
let getUsedInviteForUser = (params, ~client) => GetUsedInviteForUser.many(client, params)


/** 'ReactivateUsedInviteForUser' parameters type */
@gentype
type reactivateUsedInviteForUserParams = {
  userId: string,
}

/** 'ReactivateUsedInviteForUser' return type */
@gentype
type reactivateUsedInviteForUserResult = {
  inviteCodeHash: string,
  inviteCreatedAt: option<string>,
  inviteExpiresAt: option<string>,
  inviteId: string,
  inviteInviteeUserId: option<string>,
  inviteInviterUserId: string,
  inviteRedeemedAt: option<string>,
  inviteStatus: string,
  userActivatedAt: option<string>,
  userCreatedAt: option<string>,
  userDisplayName: string,
  userHandle: string,
  userId: string,
  userInvitedByUserId: option<string>,
  userRole: string,
  userStatus: string,
  userUpdatedAt: option<string>,
}

/** 'ReactivateUsedInviteForUser' query type */
@gentype
type reactivateUsedInviteForUserQuery = {
  params: reactivateUsedInviteForUserParams,
  result: reactivateUsedInviteForUserResult,
}

%%private(let reactivateUsedInviteForUserIR: IR.t = %raw(`{"usedParamSet":{"userId":true},"params":[{"name":"userId","required":true,"transform":{"type":"scalar"},"locs":[{"a":169,"b":176},{"a":288,"b":295},{"a":607,"b":614}]}],"statement":"WITH reactivated_invite AS (\n  UPDATE vibespace.invites i\n  SET\n    invitee_user_id = NULL,\n    status = 'available',\n    redeemed_at = NULL\n  WHERE i.invitee_user_id = :userId!\n    AND i.status = 'redeemed'\n    AND EXISTS (\n      SELECT 1\n      FROM vibespace.users u\n      WHERE u.id = :userId!\n        AND u.status = 'enabled'\n    )\n  RETURNING\n    i.id,\n    i.code_hash,\n    i.inviter_user_id,\n    i.invitee_user_id,\n    i.status,\n    i.created_at,\n    i.redeemed_at,\n    i.expires_at\n),\ndisabled_user AS (\n  UPDATE vibespace.users u\n  SET\n    status = 'disabled',\n    updated_at = now()\n  WHERE u.id = :userId!\n    AND EXISTS (SELECT 1 FROM reactivated_invite)\n  RETURNING\n    u.id,\n    u.handle,\n    u.display_name,\n    u.status,\n    u.role,\n    u.invited_by_user_id,\n    u.created_at,\n    u.activated_at,\n    u.updated_at\n)\nSELECT\n  disabled_user.id AS \"userId\",\n  disabled_user.handle AS \"userHandle\",\n  disabled_user.display_name AS \"userDisplayName\",\n  disabled_user.status AS \"userStatus\",\n  disabled_user.role AS \"userRole\",\n  disabled_user.invited_by_user_id AS \"userInvitedByUserId\",\n  disabled_user.created_at::text AS \"userCreatedAt\",\n  disabled_user.activated_at::text AS \"userActivatedAt\",\n  disabled_user.updated_at::text AS \"userUpdatedAt\",\n  reactivated_invite.id AS \"inviteId\",\n  reactivated_invite.code_hash AS \"inviteCodeHash\",\n  reactivated_invite.inviter_user_id AS \"inviteInviterUserId\",\n  reactivated_invite.invitee_user_id AS \"inviteInviteeUserId\",\n  reactivated_invite.status AS \"inviteStatus\",\n  reactivated_invite.created_at::text AS \"inviteCreatedAt\",\n  reactivated_invite.redeemed_at::text AS \"inviteRedeemedAt\",\n  reactivated_invite.expires_at::text AS \"inviteExpiresAt\"\nFROM reactivated_invite\nJOIN disabled_user ON true\nLIMIT 1"}`))

/**
 Runnable query:
 ```sql
WITH reactivated_invite AS (
  UPDATE vibespace.invites i
  SET
    invitee_user_id = NULL,
    status = 'available',
    redeemed_at = NULL
  WHERE i.invitee_user_id = $1
    AND i.status = 'redeemed'
    AND EXISTS (
      SELECT 1
      FROM vibespace.users u
      WHERE u.id = $1
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
  WHERE u.id = $1
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
LIMIT 1
 ```

 */
@gentype
module ReactivateUsedInviteForUser: {
  /** Returns an array of all matched results. */
  @gentype
  let many: (PgTyped.Pg.Client.t, reactivateUsedInviteForUserParams) => promise<array<reactivateUsedInviteForUserResult>>
  /** Returns exactly 1 result. Returns `None` if more or less than exactly 1 result is returned. */
  @gentype
  let one: (PgTyped.Pg.Client.t, reactivateUsedInviteForUserParams) => promise<option<reactivateUsedInviteForUserResult>>
  
  /** Returns exactly 1 result. Raises `Exn.t` (with an optionally provided `errorMessage`) if more or less than exactly 1 result is returned. */
  @gentype
  let expectOne: (
    PgTyped.Pg.Client.t,
    reactivateUsedInviteForUserParams,
    ~errorMessage: string=?
  ) => promise<reactivateUsedInviteForUserResult>

  /** Executes the query, but ignores whatever is returned by it. */
  @gentype
  let execute: (PgTyped.Pg.Client.t, reactivateUsedInviteForUserParams) => promise<unit>
} = {
  @module("pgtyped-rescript-runtime") @new external reactivateUsedInviteForUser: IR.t => PreparedStatement.t<reactivateUsedInviteForUserParams, reactivateUsedInviteForUserResult> = "PreparedQuery";
  let query = reactivateUsedInviteForUser(reactivateUsedInviteForUserIR)
  let query = (params, ~client) => query->PreparedStatement.run(params, ~client)

  @gentype
  let many = (client, params) => query(params, ~client)

  @gentype
  let one = async (client, params) => switch await query(params, ~client) {
  | [item] => Some(item)
  | _ => None
  }

  @gentype
  let expectOne = async (client, params, ~errorMessage=?) => switch await query(params, ~client) {
  | [item] => item
  | _ => panic(errorMessage->Option.getOr("More or less than one item was returned"))
  }

  @gentype
  let execute = async (client, params) => {
    let _ = await query(params, ~client)
  }
}

@gentype
@deprecated("Use 'ReactivateUsedInviteForUser.many' directly instead")
let reactivateUsedInviteForUser = (params, ~client) => ReactivateUsedInviteForUser.many(client, params)


/** 'GetInviteByCode' parameters type */
@gentype
type getInviteByCodeParams = {
  codeHash: string,
}

/** 'GetInviteByCode' return type */
@gentype
type getInviteByCodeResult = {
  codeHash: string,
  createdAt: option<string>,
  expiresAt: option<string>,
  id: string,
  inviteeUserId: option<string>,
  inviterUserId: string,
  redeemedAt: option<string>,
  status: string,
}

/** 'GetInviteByCode' query type */
@gentype
type getInviteByCodeQuery = {
  params: getInviteByCodeParams,
  result: getInviteByCodeResult,
}

%%private(let getInviteByCodeIR: IR.t = %raw(`{"usedParamSet":{"codeHash":true},"params":[{"name":"codeHash","required":true,"transform":{"type":"scalar"},"locs":[{"a":313,"b":322}]}],"statement":"SELECT\n  i.id AS \"id\",\n  i.code_hash AS \"codeHash\",\n  i.inviter_user_id AS \"inviterUserId\",\n  i.invitee_user_id AS \"inviteeUserId\",\n  i.status AS \"status\",\n  i.created_at::text AS \"createdAt\",\n  i.redeemed_at::text AS \"redeemedAt\",\n  i.expires_at::text AS \"expiresAt\"\nFROM vibespace.invites i\nWHERE i.code_hash = :codeHash!\nLIMIT 1"}`))

/**
 Runnable query:
 ```sql
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
WHERE i.code_hash = $1
LIMIT 1
 ```

 */
@gentype
module GetInviteByCode: {
  /** Returns an array of all matched results. */
  @gentype
  let many: (PgTyped.Pg.Client.t, getInviteByCodeParams) => promise<array<getInviteByCodeResult>>
  /** Returns exactly 1 result. Returns `None` if more or less than exactly 1 result is returned. */
  @gentype
  let one: (PgTyped.Pg.Client.t, getInviteByCodeParams) => promise<option<getInviteByCodeResult>>
  
  /** Returns exactly 1 result. Raises `Exn.t` (with an optionally provided `errorMessage`) if more or less than exactly 1 result is returned. */
  @gentype
  let expectOne: (
    PgTyped.Pg.Client.t,
    getInviteByCodeParams,
    ~errorMessage: string=?
  ) => promise<getInviteByCodeResult>

  /** Executes the query, but ignores whatever is returned by it. */
  @gentype
  let execute: (PgTyped.Pg.Client.t, getInviteByCodeParams) => promise<unit>
} = {
  @module("pgtyped-rescript-runtime") @new external getInviteByCode: IR.t => PreparedStatement.t<getInviteByCodeParams, getInviteByCodeResult> = "PreparedQuery";
  let query = getInviteByCode(getInviteByCodeIR)
  let query = (params, ~client) => query->PreparedStatement.run(params, ~client)

  @gentype
  let many = (client, params) => query(params, ~client)

  @gentype
  let one = async (client, params) => switch await query(params, ~client) {
  | [item] => Some(item)
  | _ => None
  }

  @gentype
  let expectOne = async (client, params, ~errorMessage=?) => switch await query(params, ~client) {
  | [item] => item
  | _ => panic(errorMessage->Option.getOr("More or less than one item was returned"))
  }

  @gentype
  let execute = async (client, params) => {
    let _ = await query(params, ~client)
  }
}

@gentype
@deprecated("Use 'GetInviteByCode.many' directly instead")
let getInviteByCode = (params, ~client) => GetInviteByCode.many(client, params)


/** 'GetAvailableInviteByCodeForUpdate' parameters type */
@gentype
type getAvailableInviteByCodeForUpdateParams = {
  codeHash: string,
}

/** 'GetAvailableInviteByCodeForUpdate' return type */
@gentype
type getAvailableInviteByCodeForUpdateResult = {
  codeHash: string,
  createdAt: option<string>,
  expiresAt: option<string>,
  id: string,
  inviteeUserId: option<string>,
  inviterUserId: string,
  redeemedAt: option<string>,
  status: string,
}

/** 'GetAvailableInviteByCodeForUpdate' query type */
@gentype
type getAvailableInviteByCodeForUpdateQuery = {
  params: getAvailableInviteByCodeForUpdateParams,
  result: getAvailableInviteByCodeForUpdateResult,
}

%%private(let getAvailableInviteByCodeForUpdateIR: IR.t = %raw(`{"usedParamSet":{"codeHash":true},"params":[{"name":"codeHash","required":true,"transform":{"type":"scalar"},"locs":[{"a":313,"b":322}]}],"statement":"SELECT\n  i.id AS \"id\",\n  i.code_hash AS \"codeHash\",\n  i.inviter_user_id AS \"inviterUserId\",\n  i.invitee_user_id AS \"inviteeUserId\",\n  i.status AS \"status\",\n  i.created_at::text AS \"createdAt\",\n  i.redeemed_at::text AS \"redeemedAt\",\n  i.expires_at::text AS \"expiresAt\"\nFROM vibespace.invites i\nWHERE i.code_hash = :codeHash!\n  AND i.status = 'available'\n  AND i.invitee_user_id IS NULL\n  AND (i.expires_at IS NULL OR i.expires_at > now())\nFOR UPDATE"}`))

/**
 Runnable query:
 ```sql
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
WHERE i.code_hash = $1
  AND i.status = 'available'
  AND i.invitee_user_id IS NULL
  AND (i.expires_at IS NULL OR i.expires_at > now())
FOR UPDATE
 ```

 */
@gentype
module GetAvailableInviteByCodeForUpdate: {
  /** Returns an array of all matched results. */
  @gentype
  let many: (PgTyped.Pg.Client.t, getAvailableInviteByCodeForUpdateParams) => promise<array<getAvailableInviteByCodeForUpdateResult>>
  /** Returns exactly 1 result. Returns `None` if more or less than exactly 1 result is returned. */
  @gentype
  let one: (PgTyped.Pg.Client.t, getAvailableInviteByCodeForUpdateParams) => promise<option<getAvailableInviteByCodeForUpdateResult>>
  
  /** Returns exactly 1 result. Raises `Exn.t` (with an optionally provided `errorMessage`) if more or less than exactly 1 result is returned. */
  @gentype
  let expectOne: (
    PgTyped.Pg.Client.t,
    getAvailableInviteByCodeForUpdateParams,
    ~errorMessage: string=?
  ) => promise<getAvailableInviteByCodeForUpdateResult>

  /** Executes the query, but ignores whatever is returned by it. */
  @gentype
  let execute: (PgTyped.Pg.Client.t, getAvailableInviteByCodeForUpdateParams) => promise<unit>
} = {
  @module("pgtyped-rescript-runtime") @new external getAvailableInviteByCodeForUpdate: IR.t => PreparedStatement.t<getAvailableInviteByCodeForUpdateParams, getAvailableInviteByCodeForUpdateResult> = "PreparedQuery";
  let query = getAvailableInviteByCodeForUpdate(getAvailableInviteByCodeForUpdateIR)
  let query = (params, ~client) => query->PreparedStatement.run(params, ~client)

  @gentype
  let many = (client, params) => query(params, ~client)

  @gentype
  let one = async (client, params) => switch await query(params, ~client) {
  | [item] => Some(item)
  | _ => None
  }

  @gentype
  let expectOne = async (client, params, ~errorMessage=?) => switch await query(params, ~client) {
  | [item] => item
  | _ => panic(errorMessage->Option.getOr("More or less than one item was returned"))
  }

  @gentype
  let execute = async (client, params) => {
    let _ = await query(params, ~client)
  }
}

@gentype
@deprecated("Use 'GetAvailableInviteByCodeForUpdate.many' directly instead")
let getAvailableInviteByCodeForUpdate = (params, ~client) => GetAvailableInviteByCodeForUpdate.many(client, params)


/** 'LockNumericHandleAllocator' parameters type */
@gentype
type lockNumericHandleAllocatorParams = unit

/** 'LockNumericHandleAllocator' return type */
@gentype
type lockNumericHandleAllocatorResult = {
  locked: option<unit>,
}

/** 'LockNumericHandleAllocator' query type */
@gentype
type lockNumericHandleAllocatorQuery = {
  params: lockNumericHandleAllocatorParams,
  result: lockNumericHandleAllocatorResult,
}

%%private(let lockNumericHandleAllocatorIR: IR.t = %raw(`{"usedParamSet":{},"params":[],"statement":"SELECT pg_advisory_xact_lock(946721381) AS \"locked\""}`))

/**
 Runnable query:
 ```sql
SELECT pg_advisory_xact_lock(946721381) AS "locked"
 ```

 */
@gentype
module LockNumericHandleAllocator: {
  /** Returns an array of all matched results. */
  @gentype
  let many: (PgTyped.Pg.Client.t, lockNumericHandleAllocatorParams) => promise<array<lockNumericHandleAllocatorResult>>
  /** Returns exactly 1 result. Returns `None` if more or less than exactly 1 result is returned. */
  @gentype
  let one: (PgTyped.Pg.Client.t, lockNumericHandleAllocatorParams) => promise<option<lockNumericHandleAllocatorResult>>
  
  /** Returns exactly 1 result. Raises `Exn.t` (with an optionally provided `errorMessage`) if more or less than exactly 1 result is returned. */
  @gentype
  let expectOne: (
    PgTyped.Pg.Client.t,
    lockNumericHandleAllocatorParams,
    ~errorMessage: string=?
  ) => promise<lockNumericHandleAllocatorResult>

  /** Executes the query, but ignores whatever is returned by it. */
  @gentype
  let execute: (PgTyped.Pg.Client.t, lockNumericHandleAllocatorParams) => promise<unit>
} = {
  @module("pgtyped-rescript-runtime") @new external lockNumericHandleAllocator: IR.t => PreparedStatement.t<lockNumericHandleAllocatorParams, lockNumericHandleAllocatorResult> = "PreparedQuery";
  let query = lockNumericHandleAllocator(lockNumericHandleAllocatorIR)
  let query = (params, ~client) => query->PreparedStatement.run(params, ~client)

  @gentype
  let many = (client, params) => query(params, ~client)

  @gentype
  let one = async (client, params) => switch await query(params, ~client) {
  | [item] => Some(item)
  | _ => None
  }

  @gentype
  let expectOne = async (client, params, ~errorMessage=?) => switch await query(params, ~client) {
  | [item] => item
  | _ => panic(errorMessage->Option.getOr("More or less than one item was returned"))
  }

  @gentype
  let execute = async (client, params) => {
    let _ = await query(params, ~client)
  }
}

@gentype
@deprecated("Use 'LockNumericHandleAllocator.many' directly instead")
let lockNumericHandleAllocator = (params, ~client) => LockNumericHandleAllocator.many(client, params)


/** 'InsertInviteeUserWithNumericHandle' parameters type */
@gentype
type insertInviteeUserWithNumericHandleParams = {
  displayName: string,
  invitedByUserId: string,
}

/** 'InsertInviteeUserWithNumericHandle' return type */
@gentype
type insertInviteeUserWithNumericHandleResult = {
  activatedAt: option<string>,
  createdAt: option<string>,
  displayName: string,
  handle: string,
  id: string,
  invitedByUserId: option<string>,
  role: string,
  status: string,
  updatedAt: option<string>,
}

/** 'InsertInviteeUserWithNumericHandle' query type */
@gentype
type insertInviteeUserWithNumericHandleQuery = {
  params: insertInviteeUserWithNumericHandleParams,
  result: insertInviteeUserWithNumericHandleResult,
}

%%private(let insertInviteeUserWithNumericHandleIR: IR.t = %raw(`{"usedParamSet":{"displayName":true,"invitedByUserId":true},"params":[{"name":"displayName","required":true,"transform":{"type":"scalar"},"locs":[{"a":523,"b":535}]},{"name":"invitedByUserId","required":true,"transform":{"type":"scalar"},"locs":[{"a":563,"b":579}]}],"statement":"WITH next_handle AS (\n  SELECT candidate.handle\n  FROM generate_series(0, 1000000) AS sequence_number(value)\n  CROSS JOIN LATERAL (SELECT sequence_number.value::text AS handle) candidate\n  WHERE NOT EXISTS (\n    SELECT 1\n    FROM vibespace.users existing_user\n    WHERE existing_user.handle = candidate.handle\n  )\n  ORDER BY sequence_number.value ASC\n  LIMIT 1\n)\nINSERT INTO vibespace.users (\n  handle,\n  display_name,\n  status,\n  role,\n  invited_by_user_id,\n  activated_at\n)\nVALUES (\n  (SELECT handle FROM next_handle),\n  :displayName!,\n  'enabled',\n  'user',\n  :invitedByUserId!,\n  now()\n)\nRETURNING\n  id AS \"id\",\n  handle AS \"handle\",\n  display_name AS \"displayName\",\n  status AS \"status\",\n  role AS \"role\",\n  invited_by_user_id AS \"invitedByUserId\",\n  created_at::text AS \"createdAt\",\n  activated_at::text AS \"activatedAt\",\n  updated_at::text AS \"updatedAt\""}`))

/**
 Runnable query:
 ```sql
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
  $1,
  'enabled',
  'user',
  $2,
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
  updated_at::text AS "updatedAt"
 ```

 */
@gentype
module InsertInviteeUserWithNumericHandle: {
  /** Returns an array of all matched results. */
  @gentype
  let many: (PgTyped.Pg.Client.t, insertInviteeUserWithNumericHandleParams) => promise<array<insertInviteeUserWithNumericHandleResult>>
  /** Returns exactly 1 result. Returns `None` if more or less than exactly 1 result is returned. */
  @gentype
  let one: (PgTyped.Pg.Client.t, insertInviteeUserWithNumericHandleParams) => promise<option<insertInviteeUserWithNumericHandleResult>>
  
  /** Returns exactly 1 result. Raises `Exn.t` (with an optionally provided `errorMessage`) if more or less than exactly 1 result is returned. */
  @gentype
  let expectOne: (
    PgTyped.Pg.Client.t,
    insertInviteeUserWithNumericHandleParams,
    ~errorMessage: string=?
  ) => promise<insertInviteeUserWithNumericHandleResult>

  /** Executes the query, but ignores whatever is returned by it. */
  @gentype
  let execute: (PgTyped.Pg.Client.t, insertInviteeUserWithNumericHandleParams) => promise<unit>
} = {
  @module("pgtyped-rescript-runtime") @new external insertInviteeUserWithNumericHandle: IR.t => PreparedStatement.t<insertInviteeUserWithNumericHandleParams, insertInviteeUserWithNumericHandleResult> = "PreparedQuery";
  let query = insertInviteeUserWithNumericHandle(insertInviteeUserWithNumericHandleIR)
  let query = (params, ~client) => query->PreparedStatement.run(params, ~client)

  @gentype
  let many = (client, params) => query(params, ~client)

  @gentype
  let one = async (client, params) => switch await query(params, ~client) {
  | [item] => Some(item)
  | _ => None
  }

  @gentype
  let expectOne = async (client, params, ~errorMessage=?) => switch await query(params, ~client) {
  | [item] => item
  | _ => panic(errorMessage->Option.getOr("More or less than one item was returned"))
  }

  @gentype
  let execute = async (client, params) => {
    let _ = await query(params, ~client)
  }
}

@gentype
@deprecated("Use 'InsertInviteeUserWithNumericHandle.many' directly instead")
let insertInviteeUserWithNumericHandle = (params, ~client) => InsertInviteeUserWithNumericHandle.many(client, params)


/** 'RedeemInviteById' parameters type */
@gentype
type redeemInviteByIdParams = {
  id: string,
  inviteeUserId: string,
}

/** 'RedeemInviteById' return type */
@gentype
type redeemInviteByIdResult = {
  codeHash: string,
  createdAt: option<string>,
  expiresAt: option<string>,
  id: string,
  inviteeUserId: option<string>,
  inviterUserId: string,
  redeemedAt: option<string>,
  status: string,
}

/** 'RedeemInviteById' query type */
@gentype
type redeemInviteByIdQuery = {
  params: redeemInviteByIdParams,
  result: redeemInviteByIdResult,
}

%%private(let redeemInviteByIdIR: IR.t = %raw(`{"usedParamSet":{"inviteeUserId":true,"id":true},"params":[{"name":"inviteeUserId","required":true,"transform":{"type":"scalar"},"locs":[{"a":49,"b":63}]},{"name":"id","required":true,"transform":{"type":"scalar"},"locs":[{"a":122,"b":125}]}],"statement":"UPDATE vibespace.invites\nSET\n  invitee_user_id = :inviteeUserId!,\n  status = 'redeemed',\n  redeemed_at = now()\nWHERE id = :id!\n  AND status = 'available'\n  AND invitee_user_id IS NULL\nRETURNING\n  id AS \"id\",\n  code_hash AS \"codeHash\",\n  inviter_user_id AS \"inviterUserId\",\n  invitee_user_id AS \"inviteeUserId\",\n  status AS \"status\",\n  created_at::text AS \"createdAt\",\n  redeemed_at::text AS \"redeemedAt\",\n  expires_at::text AS \"expiresAt\""}`))

/**
 Runnable query:
 ```sql
UPDATE vibespace.invites
SET
  invitee_user_id = $1,
  status = 'redeemed',
  redeemed_at = now()
WHERE id = $2
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
  expires_at::text AS "expiresAt"
 ```

 */
@gentype
module RedeemInviteById: {
  /** Returns an array of all matched results. */
  @gentype
  let many: (PgTyped.Pg.Client.t, redeemInviteByIdParams) => promise<array<redeemInviteByIdResult>>
  /** Returns exactly 1 result. Returns `None` if more or less than exactly 1 result is returned. */
  @gentype
  let one: (PgTyped.Pg.Client.t, redeemInviteByIdParams) => promise<option<redeemInviteByIdResult>>
  
  /** Returns exactly 1 result. Raises `Exn.t` (with an optionally provided `errorMessage`) if more or less than exactly 1 result is returned. */
  @gentype
  let expectOne: (
    PgTyped.Pg.Client.t,
    redeemInviteByIdParams,
    ~errorMessage: string=?
  ) => promise<redeemInviteByIdResult>

  /** Executes the query, but ignores whatever is returned by it. */
  @gentype
  let execute: (PgTyped.Pg.Client.t, redeemInviteByIdParams) => promise<unit>
} = {
  @module("pgtyped-rescript-runtime") @new external redeemInviteById: IR.t => PreparedStatement.t<redeemInviteByIdParams, redeemInviteByIdResult> = "PreparedQuery";
  let query = redeemInviteById(redeemInviteByIdIR)
  let query = (params, ~client) => query->PreparedStatement.run(params, ~client)

  @gentype
  let many = (client, params) => query(params, ~client)

  @gentype
  let one = async (client, params) => switch await query(params, ~client) {
  | [item] => Some(item)
  | _ => None
  }

  @gentype
  let expectOne = async (client, params, ~errorMessage=?) => switch await query(params, ~client) {
  | [item] => item
  | _ => panic(errorMessage->Option.getOr("More or less than one item was returned"))
  }

  @gentype
  let execute = async (client, params) => {
    let _ = await query(params, ~client)
  }
}

@gentype
@deprecated("Use 'RedeemInviteById.many' directly instead")
let redeemInviteById = (params, ~client) => RedeemInviteById.many(client, params)


/** 'EnsureInviteFriendConnection' parameters type */
@gentype
type ensureInviteFriendConnectionParams = {
  userAId: string,
  userBId: string,
}

/** 'EnsureInviteFriendConnection' return type */
@gentype
type ensureInviteFriendConnectionResult = {
  createdAt: option<string>,
  id: string,
  source: string,
  status: string,
  updatedAt: option<string>,
  userAId: string,
  userBId: string,
}

/** 'EnsureInviteFriendConnection' query type */
@gentype
type ensureInviteFriendConnectionQuery = {
  params: ensureInviteFriendConnectionParams,
  result: ensureInviteFriendConnectionResult,
}

%%private(let ensureInviteFriendConnectionIR: IR.t = %raw(`{"usedParamSet":{"userAId":true,"userBId":true},"params":[{"name":"userAId","required":true,"transform":{"type":"scalar"},"locs":[{"a":101,"b":109}]},{"name":"userBId","required":true,"transform":{"type":"scalar"},"locs":[{"a":114,"b":122}]}],"statement":"INSERT INTO vibespace.friend_connections (\n  user_a_id,\n  user_b_id,\n  status,\n  source\n)\nVALUES (\n  :userAId!,\n  :userBId!,\n  'accepted',\n  'invite'\n)\nON CONFLICT (user_a_id, user_b_id) DO UPDATE SET\n  status = 'accepted',\n  updated_at = now()\nRETURNING\n  id AS \"id\",\n  user_a_id AS \"userAId\",\n  user_b_id AS \"userBId\",\n  status AS \"status\",\n  source AS \"source\",\n  created_at::text AS \"createdAt\",\n  updated_at::text AS \"updatedAt\""}`))

/**
 Runnable query:
 ```sql
INSERT INTO vibespace.friend_connections (
  user_a_id,
  user_b_id,
  status,
  source
)
VALUES (
  $1,
  $2,
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
  updated_at::text AS "updatedAt"
 ```

 */
@gentype
module EnsureInviteFriendConnection: {
  /** Returns an array of all matched results. */
  @gentype
  let many: (PgTyped.Pg.Client.t, ensureInviteFriendConnectionParams) => promise<array<ensureInviteFriendConnectionResult>>
  /** Returns exactly 1 result. Returns `None` if more or less than exactly 1 result is returned. */
  @gentype
  let one: (PgTyped.Pg.Client.t, ensureInviteFriendConnectionParams) => promise<option<ensureInviteFriendConnectionResult>>
  
  /** Returns exactly 1 result. Raises `Exn.t` (with an optionally provided `errorMessage`) if more or less than exactly 1 result is returned. */
  @gentype
  let expectOne: (
    PgTyped.Pg.Client.t,
    ensureInviteFriendConnectionParams,
    ~errorMessage: string=?
  ) => promise<ensureInviteFriendConnectionResult>

  /** Executes the query, but ignores whatever is returned by it. */
  @gentype
  let execute: (PgTyped.Pg.Client.t, ensureInviteFriendConnectionParams) => promise<unit>
} = {
  @module("pgtyped-rescript-runtime") @new external ensureInviteFriendConnection: IR.t => PreparedStatement.t<ensureInviteFriendConnectionParams, ensureInviteFriendConnectionResult> = "PreparedQuery";
  let query = ensureInviteFriendConnection(ensureInviteFriendConnectionIR)
  let query = (params, ~client) => query->PreparedStatement.run(params, ~client)

  @gentype
  let many = (client, params) => query(params, ~client)

  @gentype
  let one = async (client, params) => switch await query(params, ~client) {
  | [item] => Some(item)
  | _ => None
  }

  @gentype
  let expectOne = async (client, params, ~errorMessage=?) => switch await query(params, ~client) {
  | [item] => item
  | _ => panic(errorMessage->Option.getOr("More or less than one item was returned"))
  }

  @gentype
  let execute = async (client, params) => {
    let _ = await query(params, ~client)
  }
}

@gentype
@deprecated("Use 'EnsureInviteFriendConnection.many' directly instead")
let ensureInviteFriendConnection = (params, ~client) => EnsureInviteFriendConnection.many(client, params)


/** 'GetProfileById' parameters type */
@gentype
type getProfileByIdParams = {
  id: string,
}

/** 'GetProfileById' return type */
@gentype
type getProfileByIdResult = {
  createdAt: option<string>,
  currentVersionId: option<string>,
  disabledAt: option<string>,
  disabledReason: option<string>,
  id: string,
  ownerUserId: string,
  publishedAt: option<string>,
  sendtag: option<string>,
  slug: string,
  title: string,
  updatedAt: option<string>,
  visibility: string,
}

/** 'GetProfileById' query type */
@gentype
type getProfileByIdQuery = {
  params: getProfileByIdParams,
  result: getProfileByIdResult,
}

%%private(let getProfileByIdIR: IR.t = %raw(`{"usedParamSet":{"id":true},"params":[{"name":"id","required":true,"transform":{"type":"scalar"},"locs":[{"a":438,"b":441}]}],"statement":"SELECT\n  p.id AS \"id\",\n  p.owner_user_id AS \"ownerUserId\",\n  p.slug AS \"slug\",\n  p.title AS \"title\",\n  p.sendtag AS \"sendtag\",\n  p.visibility AS \"visibility\",\n  p.current_version_id AS \"currentVersionId\",\n  p.created_at::text AS \"createdAt\",\n  p.updated_at::text AS \"updatedAt\",\n  p.published_at::text AS \"publishedAt\",\n  p.disabled_at::text AS \"disabledAt\",\n  p.disabled_reason AS \"disabledReason\"\nFROM vibespace.profiles p\nWHERE p.id = :id!"}`))

/**
 Runnable query:
 ```sql
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
WHERE p.id = $1
 ```

 */
@gentype
module GetProfileById: {
  /** Returns an array of all matched results. */
  @gentype
  let many: (PgTyped.Pg.Client.t, getProfileByIdParams) => promise<array<getProfileByIdResult>>
  /** Returns exactly 1 result. Returns `None` if more or less than exactly 1 result is returned. */
  @gentype
  let one: (PgTyped.Pg.Client.t, getProfileByIdParams) => promise<option<getProfileByIdResult>>
  
  /** Returns exactly 1 result. Raises `Exn.t` (with an optionally provided `errorMessage`) if more or less than exactly 1 result is returned. */
  @gentype
  let expectOne: (
    PgTyped.Pg.Client.t,
    getProfileByIdParams,
    ~errorMessage: string=?
  ) => promise<getProfileByIdResult>

  /** Executes the query, but ignores whatever is returned by it. */
  @gentype
  let execute: (PgTyped.Pg.Client.t, getProfileByIdParams) => promise<unit>
} = {
  @module("pgtyped-rescript-runtime") @new external getProfileById: IR.t => PreparedStatement.t<getProfileByIdParams, getProfileByIdResult> = "PreparedQuery";
  let query = getProfileById(getProfileByIdIR)
  let query = (params, ~client) => query->PreparedStatement.run(params, ~client)

  @gentype
  let many = (client, params) => query(params, ~client)

  @gentype
  let one = async (client, params) => switch await query(params, ~client) {
  | [item] => Some(item)
  | _ => None
  }

  @gentype
  let expectOne = async (client, params, ~errorMessage=?) => switch await query(params, ~client) {
  | [item] => item
  | _ => panic(errorMessage->Option.getOr("More or less than one item was returned"))
  }

  @gentype
  let execute = async (client, params) => {
    let _ = await query(params, ~client)
  }
}

@gentype
@deprecated("Use 'GetProfileById.many' directly instead")
let getProfileById = (params, ~client) => GetProfileById.many(client, params)


/** 'GetProfilesByIds' parameters type */
@gentype
type getProfilesByIdsParams = {
  ids: stringArray,
}

/** 'GetProfilesByIds' return type */
@gentype
type getProfilesByIdsResult = {
  createdAt: option<string>,
  currentVersionId: option<string>,
  disabledAt: option<string>,
  disabledReason: option<string>,
  id: string,
  ownerUserId: string,
  publishedAt: option<string>,
  sendtag: option<string>,
  slug: string,
  title: string,
  updatedAt: option<string>,
  visibility: string,
}

/** 'GetProfilesByIds' query type */
@gentype
type getProfilesByIdsQuery = {
  params: getProfilesByIdsParams,
  result: getProfilesByIdsResult,
}

%%private(let getProfilesByIdsIR: IR.t = %raw(`{"usedParamSet":{"ids":true},"params":[{"name":"ids","required":true,"transform":{"type":"scalar"},"locs":[{"a":442,"b":446}]}],"statement":"SELECT\n  p.id AS \"id\",\n  p.owner_user_id AS \"ownerUserId\",\n  p.slug AS \"slug\",\n  p.title AS \"title\",\n  p.sendtag AS \"sendtag\",\n  p.visibility AS \"visibility\",\n  p.current_version_id AS \"currentVersionId\",\n  p.created_at::text AS \"createdAt\",\n  p.updated_at::text AS \"updatedAt\",\n  p.published_at::text AS \"publishedAt\",\n  p.disabled_at::text AS \"disabledAt\",\n  p.disabled_reason AS \"disabledReason\"\nFROM vibespace.profiles p\nWHERE p.id = ANY(:ids!)"}`))

/**
 Runnable query:
 ```sql
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
WHERE p.id = ANY($1)
 ```

 */
@gentype
module GetProfilesByIds: {
  /** Returns an array of all matched results. */
  @gentype
  let many: (PgTyped.Pg.Client.t, getProfilesByIdsParams) => promise<array<getProfilesByIdsResult>>
  /** Returns exactly 1 result. Returns `None` if more or less than exactly 1 result is returned. */
  @gentype
  let one: (PgTyped.Pg.Client.t, getProfilesByIdsParams) => promise<option<getProfilesByIdsResult>>
  
  /** Returns exactly 1 result. Raises `Exn.t` (with an optionally provided `errorMessage`) if more or less than exactly 1 result is returned. */
  @gentype
  let expectOne: (
    PgTyped.Pg.Client.t,
    getProfilesByIdsParams,
    ~errorMessage: string=?
  ) => promise<getProfilesByIdsResult>

  /** Executes the query, but ignores whatever is returned by it. */
  @gentype
  let execute: (PgTyped.Pg.Client.t, getProfilesByIdsParams) => promise<unit>
} = {
  @module("pgtyped-rescript-runtime") @new external getProfilesByIds: IR.t => PreparedStatement.t<getProfilesByIdsParams, getProfilesByIdsResult> = "PreparedQuery";
  let query = getProfilesByIds(getProfilesByIdsIR)
  let query = (params, ~client) => query->PreparedStatement.run(params, ~client)

  @gentype
  let many = (client, params) => query(params, ~client)

  @gentype
  let one = async (client, params) => switch await query(params, ~client) {
  | [item] => Some(item)
  | _ => None
  }

  @gentype
  let expectOne = async (client, params, ~errorMessage=?) => switch await query(params, ~client) {
  | [item] => item
  | _ => panic(errorMessage->Option.getOr("More or less than one item was returned"))
  }

  @gentype
  let execute = async (client, params) => {
    let _ = await query(params, ~client)
  }
}

@gentype
@deprecated("Use 'GetProfilesByIds.many' directly instead")
let getProfilesByIds = (params, ~client) => GetProfilesByIds.many(client, params)


/** 'GetProfileByOwnerId' parameters type */
@gentype
type getProfileByOwnerIdParams = {
  ownerUserId: string,
}

/** 'GetProfileByOwnerId' return type */
@gentype
type getProfileByOwnerIdResult = {
  createdAt: option<string>,
  currentVersionId: option<string>,
  disabledAt: option<string>,
  disabledReason: option<string>,
  id: string,
  ownerUserId: string,
  publishedAt: option<string>,
  sendtag: option<string>,
  slug: string,
  title: string,
  updatedAt: option<string>,
  visibility: string,
}

/** 'GetProfileByOwnerId' query type */
@gentype
type getProfileByOwnerIdQuery = {
  params: getProfileByOwnerIdParams,
  result: getProfileByOwnerIdResult,
}

%%private(let getProfileByOwnerIdIR: IR.t = %raw(`{"usedParamSet":{"ownerUserId":true},"params":[{"name":"ownerUserId","required":true,"transform":{"type":"scalar"},"locs":[{"a":449,"b":461}]}],"statement":"SELECT\n  p.id AS \"id\",\n  p.owner_user_id AS \"ownerUserId\",\n  p.slug AS \"slug\",\n  p.title AS \"title\",\n  p.sendtag AS \"sendtag\",\n  p.visibility AS \"visibility\",\n  p.current_version_id AS \"currentVersionId\",\n  p.created_at::text AS \"createdAt\",\n  p.updated_at::text AS \"updatedAt\",\n  p.published_at::text AS \"publishedAt\",\n  p.disabled_at::text AS \"disabledAt\",\n  p.disabled_reason AS \"disabledReason\"\nFROM vibespace.profiles p\nWHERE p.owner_user_id = :ownerUserId!"}`))

/**
 Runnable query:
 ```sql
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
WHERE p.owner_user_id = $1
 ```

 */
@gentype
module GetProfileByOwnerId: {
  /** Returns an array of all matched results. */
  @gentype
  let many: (PgTyped.Pg.Client.t, getProfileByOwnerIdParams) => promise<array<getProfileByOwnerIdResult>>
  /** Returns exactly 1 result. Returns `None` if more or less than exactly 1 result is returned. */
  @gentype
  let one: (PgTyped.Pg.Client.t, getProfileByOwnerIdParams) => promise<option<getProfileByOwnerIdResult>>
  
  /** Returns exactly 1 result. Raises `Exn.t` (with an optionally provided `errorMessage`) if more or less than exactly 1 result is returned. */
  @gentype
  let expectOne: (
    PgTyped.Pg.Client.t,
    getProfileByOwnerIdParams,
    ~errorMessage: string=?
  ) => promise<getProfileByOwnerIdResult>

  /** Executes the query, but ignores whatever is returned by it. */
  @gentype
  let execute: (PgTyped.Pg.Client.t, getProfileByOwnerIdParams) => promise<unit>
} = {
  @module("pgtyped-rescript-runtime") @new external getProfileByOwnerId: IR.t => PreparedStatement.t<getProfileByOwnerIdParams, getProfileByOwnerIdResult> = "PreparedQuery";
  let query = getProfileByOwnerId(getProfileByOwnerIdIR)
  let query = (params, ~client) => query->PreparedStatement.run(params, ~client)

  @gentype
  let many = (client, params) => query(params, ~client)

  @gentype
  let one = async (client, params) => switch await query(params, ~client) {
  | [item] => Some(item)
  | _ => None
  }

  @gentype
  let expectOne = async (client, params, ~errorMessage=?) => switch await query(params, ~client) {
  | [item] => item
  | _ => panic(errorMessage->Option.getOr("More or less than one item was returned"))
  }

  @gentype
  let execute = async (client, params) => {
    let _ = await query(params, ~client)
  }
}

@gentype
@deprecated("Use 'GetProfileByOwnerId.many' directly instead")
let getProfileByOwnerId = (params, ~client) => GetProfileByOwnerId.many(client, params)


/** 'GetProfilesByOwnerIds' parameters type */
@gentype
type getProfilesByOwnerIdsParams = {
  ownerUserIds: stringArray,
}

/** 'GetProfilesByOwnerIds' return type */
@gentype
type getProfilesByOwnerIdsResult = {
  createdAt: option<string>,
  currentVersionId: option<string>,
  disabledAt: option<string>,
  disabledReason: option<string>,
  id: string,
  ownerUserId: string,
  publishedAt: option<string>,
  sendtag: option<string>,
  slug: string,
  title: string,
  updatedAt: option<string>,
  visibility: string,
}

/** 'GetProfilesByOwnerIds' query type */
@gentype
type getProfilesByOwnerIdsQuery = {
  params: getProfilesByOwnerIdsParams,
  result: getProfilesByOwnerIdsResult,
}

%%private(let getProfilesByOwnerIdsIR: IR.t = %raw(`{"usedParamSet":{"ownerUserIds":true},"params":[{"name":"ownerUserIds","required":true,"transform":{"type":"scalar"},"locs":[{"a":453,"b":466}]}],"statement":"SELECT\n  p.id AS \"id\",\n  p.owner_user_id AS \"ownerUserId\",\n  p.slug AS \"slug\",\n  p.title AS \"title\",\n  p.sendtag AS \"sendtag\",\n  p.visibility AS \"visibility\",\n  p.current_version_id AS \"currentVersionId\",\n  p.created_at::text AS \"createdAt\",\n  p.updated_at::text AS \"updatedAt\",\n  p.published_at::text AS \"publishedAt\",\n  p.disabled_at::text AS \"disabledAt\",\n  p.disabled_reason AS \"disabledReason\"\nFROM vibespace.profiles p\nWHERE p.owner_user_id = ANY(:ownerUserIds!)"}`))

/**
 Runnable query:
 ```sql
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
WHERE p.owner_user_id = ANY($1)
 ```

 */
@gentype
module GetProfilesByOwnerIds: {
  /** Returns an array of all matched results. */
  @gentype
  let many: (PgTyped.Pg.Client.t, getProfilesByOwnerIdsParams) => promise<array<getProfilesByOwnerIdsResult>>
  /** Returns exactly 1 result. Returns `None` if more or less than exactly 1 result is returned. */
  @gentype
  let one: (PgTyped.Pg.Client.t, getProfilesByOwnerIdsParams) => promise<option<getProfilesByOwnerIdsResult>>
  
  /** Returns exactly 1 result. Raises `Exn.t` (with an optionally provided `errorMessage`) if more or less than exactly 1 result is returned. */
  @gentype
  let expectOne: (
    PgTyped.Pg.Client.t,
    getProfilesByOwnerIdsParams,
    ~errorMessage: string=?
  ) => promise<getProfilesByOwnerIdsResult>

  /** Executes the query, but ignores whatever is returned by it. */
  @gentype
  let execute: (PgTyped.Pg.Client.t, getProfilesByOwnerIdsParams) => promise<unit>
} = {
  @module("pgtyped-rescript-runtime") @new external getProfilesByOwnerIds: IR.t => PreparedStatement.t<getProfilesByOwnerIdsParams, getProfilesByOwnerIdsResult> = "PreparedQuery";
  let query = getProfilesByOwnerIds(getProfilesByOwnerIdsIR)
  let query = (params, ~client) => query->PreparedStatement.run(params, ~client)

  @gentype
  let many = (client, params) => query(params, ~client)

  @gentype
  let one = async (client, params) => switch await query(params, ~client) {
  | [item] => Some(item)
  | _ => None
  }

  @gentype
  let expectOne = async (client, params, ~errorMessage=?) => switch await query(params, ~client) {
  | [item] => item
  | _ => panic(errorMessage->Option.getOr("More or less than one item was returned"))
  }

  @gentype
  let execute = async (client, params) => {
    let _ = await query(params, ~client)
  }
}

@gentype
@deprecated("Use 'GetProfilesByOwnerIds.many' directly instead")
let getProfilesByOwnerIds = (params, ~client) => GetProfilesByOwnerIds.many(client, params)


/** 'GetProfileBySlug' parameters type */
@gentype
type getProfileBySlugParams = {
  slug: string,
}

/** 'GetProfileBySlug' return type */
@gentype
type getProfileBySlugResult = {
  createdAt: option<string>,
  currentVersionId: option<string>,
  disabledAt: option<string>,
  disabledReason: option<string>,
  id: string,
  ownerUserId: string,
  publishedAt: option<string>,
  sendtag: option<string>,
  slug: string,
  title: string,
  updatedAt: option<string>,
  visibility: string,
}

/** 'GetProfileBySlug' query type */
@gentype
type getProfileBySlugQuery = {
  params: getProfileBySlugParams,
  result: getProfileBySlugResult,
}

%%private(let getProfileBySlugIR: IR.t = %raw(`{"usedParamSet":{"slug":true},"params":[{"name":"slug","required":true,"transform":{"type":"scalar"},"locs":[{"a":440,"b":445}]}],"statement":"SELECT\n  p.id AS \"id\",\n  p.owner_user_id AS \"ownerUserId\",\n  p.slug AS \"slug\",\n  p.title AS \"title\",\n  p.sendtag AS \"sendtag\",\n  p.visibility AS \"visibility\",\n  p.current_version_id AS \"currentVersionId\",\n  p.created_at::text AS \"createdAt\",\n  p.updated_at::text AS \"updatedAt\",\n  p.published_at::text AS \"publishedAt\",\n  p.disabled_at::text AS \"disabledAt\",\n  p.disabled_reason AS \"disabledReason\"\nFROM vibespace.profiles p\nWHERE p.slug = :slug!"}`))

/**
 Runnable query:
 ```sql
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
WHERE p.slug = $1
 ```

 */
@gentype
module GetProfileBySlug: {
  /** Returns an array of all matched results. */
  @gentype
  let many: (PgTyped.Pg.Client.t, getProfileBySlugParams) => promise<array<getProfileBySlugResult>>
  /** Returns exactly 1 result. Returns `None` if more or less than exactly 1 result is returned. */
  @gentype
  let one: (PgTyped.Pg.Client.t, getProfileBySlugParams) => promise<option<getProfileBySlugResult>>
  
  /** Returns exactly 1 result. Raises `Exn.t` (with an optionally provided `errorMessage`) if more or less than exactly 1 result is returned. */
  @gentype
  let expectOne: (
    PgTyped.Pg.Client.t,
    getProfileBySlugParams,
    ~errorMessage: string=?
  ) => promise<getProfileBySlugResult>

  /** Executes the query, but ignores whatever is returned by it. */
  @gentype
  let execute: (PgTyped.Pg.Client.t, getProfileBySlugParams) => promise<unit>
} = {
  @module("pgtyped-rescript-runtime") @new external getProfileBySlug: IR.t => PreparedStatement.t<getProfileBySlugParams, getProfileBySlugResult> = "PreparedQuery";
  let query = getProfileBySlug(getProfileBySlugIR)
  let query = (params, ~client) => query->PreparedStatement.run(params, ~client)

  @gentype
  let many = (client, params) => query(params, ~client)

  @gentype
  let one = async (client, params) => switch await query(params, ~client) {
  | [item] => Some(item)
  | _ => None
  }

  @gentype
  let expectOne = async (client, params, ~errorMessage=?) => switch await query(params, ~client) {
  | [item] => item
  | _ => panic(errorMessage->Option.getOr("More or less than one item was returned"))
  }

  @gentype
  let execute = async (client, params) => {
    let _ = await query(params, ~client)
  }
}

@gentype
@deprecated("Use 'GetProfileBySlug.many' directly instead")
let getProfileBySlug = (params, ~client) => GetProfileBySlug.many(client, params)


/** 'GetRandomPublicProfile' parameters type */
@gentype
type getRandomPublicProfileParams = unit

/** 'GetRandomPublicProfile' return type */
@gentype
type getRandomPublicProfileResult = {
  createdAt: option<string>,
  currentVersionId: option<string>,
  disabledAt: option<string>,
  disabledReason: option<string>,
  id: string,
  ownerUserId: string,
  publishedAt: option<string>,
  sendtag: option<string>,
  slug: string,
  title: string,
  updatedAt: option<string>,
  visibility: string,
}

/** 'GetRandomPublicProfile' query type */
@gentype
type getRandomPublicProfileQuery = {
  params: getRandomPublicProfileParams,
  result: getRandomPublicProfileResult,
}

%%private(let getRandomPublicProfileIR: IR.t = %raw(`{"usedParamSet":{},"params":[],"statement":"SELECT\n  p.id AS \"id\",\n  p.owner_user_id AS \"ownerUserId\",\n  p.slug AS \"slug\",\n  p.title AS \"title\",\n  p.sendtag AS \"sendtag\",\n  p.visibility AS \"visibility\",\n  p.current_version_id AS \"currentVersionId\",\n  p.created_at::text AS \"createdAt\",\n  p.updated_at::text AS \"updatedAt\",\n  p.published_at::text AS \"publishedAt\",\n  p.disabled_at::text AS \"disabledAt\",\n  p.disabled_reason AS \"disabledReason\"\nFROM vibespace.profiles p\nJOIN vibespace.users u ON u.id = p.owner_user_id\nJOIN vibespace.profile_versions pv\n  ON pv.id = p.current_version_id\n  AND pv.profile_id = p.id\nWHERE u.status = 'enabled'\n  AND p.visibility = 'friends'\n  AND p.disabled_at IS NULL\n  AND pv.source <> 'import'\n  AND pv.validation_status = 'valid'\nORDER BY random()\nLIMIT 1"}`))

/**
 Runnable query:
 ```sql
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
JOIN vibespace.users u ON u.id = p.owner_user_id
JOIN vibespace.profile_versions pv
  ON pv.id = p.current_version_id
  AND pv.profile_id = p.id
WHERE u.status = 'enabled'
  AND p.visibility = 'friends'
  AND p.disabled_at IS NULL
  AND pv.source <> 'import'
  AND pv.validation_status = 'valid'
ORDER BY random()
LIMIT 1
 ```

 */
@gentype
module GetRandomPublicProfile: {
  /** Returns an array of all matched results. */
  @gentype
  let many: (PgTyped.Pg.Client.t, getRandomPublicProfileParams) => promise<array<getRandomPublicProfileResult>>
  /** Returns exactly 1 result. Returns `None` if more or less than exactly 1 result is returned. */
  @gentype
  let one: (PgTyped.Pg.Client.t, getRandomPublicProfileParams) => promise<option<getRandomPublicProfileResult>>
  
  /** Returns exactly 1 result. Raises `Exn.t` (with an optionally provided `errorMessage`) if more or less than exactly 1 result is returned. */
  @gentype
  let expectOne: (
    PgTyped.Pg.Client.t,
    getRandomPublicProfileParams,
    ~errorMessage: string=?
  ) => promise<getRandomPublicProfileResult>

  /** Executes the query, but ignores whatever is returned by it. */
  @gentype
  let execute: (PgTyped.Pg.Client.t, getRandomPublicProfileParams) => promise<unit>
} = {
  @module("pgtyped-rescript-runtime") @new external getRandomPublicProfile: IR.t => PreparedStatement.t<getRandomPublicProfileParams, getRandomPublicProfileResult> = "PreparedQuery";
  let query = getRandomPublicProfile(getRandomPublicProfileIR)
  let query = (params, ~client) => query->PreparedStatement.run(params, ~client)

  @gentype
  let many = (client, params) => query(params, ~client)

  @gentype
  let one = async (client, params) => switch await query(params, ~client) {
  | [item] => Some(item)
  | _ => None
  }

  @gentype
  let expectOne = async (client, params, ~errorMessage=?) => switch await query(params, ~client) {
  | [item] => item
  | _ => panic(errorMessage->Option.getOr("More or less than one item was returned"))
  }

  @gentype
  let execute = async (client, params) => {
    let _ = await query(params, ~client)
  }
}

@gentype
@deprecated("Use 'GetRandomPublicProfile.many' directly instead")
let getRandomPublicProfile = (params, ~client) => GetRandomPublicProfile.many(client, params)


/** 'EnsureProfileForUser' parameters type */
@gentype
type ensureProfileForUserParams = {
  ownerUserId: string,
  slug: string,
  title: string,
}

/** 'EnsureProfileForUser' return type */
@gentype
type ensureProfileForUserResult = {
  createdAt: option<string>,
  currentVersionId: option<string>,
  disabledAt: option<string>,
  disabledReason: option<string>,
  id: string,
  ownerUserId: string,
  publishedAt: option<string>,
  sendtag: option<string>,
  slug: string,
  title: string,
  updatedAt: option<string>,
  visibility: string,
}

/** 'EnsureProfileForUser' query type */
@gentype
type ensureProfileForUserQuery = {
  params: ensureProfileForUserParams,
  result: ensureProfileForUserResult,
}

%%private(let ensureProfileForUserIR: IR.t = %raw(`{"usedParamSet":{"ownerUserId":true,"slug":true,"title":true},"params":[{"name":"ownerUserId","required":true,"transform":{"type":"scalar"},"locs":[{"a":109,"b":121}]},{"name":"slug","required":true,"transform":{"type":"scalar"},"locs":[{"a":126,"b":131}]},{"name":"title","required":true,"transform":{"type":"scalar"},"locs":[{"a":136,"b":142}]}],"statement":"INSERT INTO vibespace.profiles (\n  owner_user_id,\n  slug,\n  title,\n  visibility,\n  published_at\n)\nVALUES (\n  :ownerUserId!,\n  :slug!,\n  :title!,\n  'friends',\n  now()\n)\nON CONFLICT (owner_user_id) DO UPDATE SET\n  slug = EXCLUDED.slug,\n  title = EXCLUDED.title,\n  visibility = 'friends',\n  updated_at = now()\nRETURNING\n  id AS \"id\",\n  owner_user_id AS \"ownerUserId\",\n  slug AS \"slug\",\n  title AS \"title\",\n  sendtag AS \"sendtag\",\n  visibility AS \"visibility\",\n  current_version_id AS \"currentVersionId\",\n  created_at::text AS \"createdAt\",\n  updated_at::text AS \"updatedAt\",\n  published_at::text AS \"publishedAt\",\n  disabled_at::text AS \"disabledAt\",\n  disabled_reason AS \"disabledReason\""}`))

/**
 Runnable query:
 ```sql
INSERT INTO vibespace.profiles (
  owner_user_id,
  slug,
  title,
  visibility,
  published_at
)
VALUES (
  $1,
  $2,
  $3,
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
  disabled_reason AS "disabledReason"
 ```

 */
@gentype
module EnsureProfileForUser: {
  /** Returns an array of all matched results. */
  @gentype
  let many: (PgTyped.Pg.Client.t, ensureProfileForUserParams) => promise<array<ensureProfileForUserResult>>
  /** Returns exactly 1 result. Returns `None` if more or less than exactly 1 result is returned. */
  @gentype
  let one: (PgTyped.Pg.Client.t, ensureProfileForUserParams) => promise<option<ensureProfileForUserResult>>
  
  /** Returns exactly 1 result. Raises `Exn.t` (with an optionally provided `errorMessage`) if more or less than exactly 1 result is returned. */
  @gentype
  let expectOne: (
    PgTyped.Pg.Client.t,
    ensureProfileForUserParams,
    ~errorMessage: string=?
  ) => promise<ensureProfileForUserResult>

  /** Executes the query, but ignores whatever is returned by it. */
  @gentype
  let execute: (PgTyped.Pg.Client.t, ensureProfileForUserParams) => promise<unit>
} = {
  @module("pgtyped-rescript-runtime") @new external ensureProfileForUser: IR.t => PreparedStatement.t<ensureProfileForUserParams, ensureProfileForUserResult> = "PreparedQuery";
  let query = ensureProfileForUser(ensureProfileForUserIR)
  let query = (params, ~client) => query->PreparedStatement.run(params, ~client)

  @gentype
  let many = (client, params) => query(params, ~client)

  @gentype
  let one = async (client, params) => switch await query(params, ~client) {
  | [item] => Some(item)
  | _ => None
  }

  @gentype
  let expectOne = async (client, params, ~errorMessage=?) => switch await query(params, ~client) {
  | [item] => item
  | _ => panic(errorMessage->Option.getOr("More or less than one item was returned"))
  }

  @gentype
  let execute = async (client, params) => {
    let _ = await query(params, ~client)
  }
}

@gentype
@deprecated("Use 'EnsureProfileForUser.many' directly instead")
let ensureProfileForUser = (params, ~client) => EnsureProfileForUser.many(client, params)


/** 'GetProfileVersionById' parameters type */
@gentype
type getProfileVersionByIdParams = {
  id: string,
}

/** 'GetProfileVersionById' return type */
@gentype
type getProfileVersionByIdResult = {
  createdAt: option<string>,
  createdByUserId: string,
  css: string,
  html: string,
  id: string,
  parentVersionId: option<string>,
  profileId: string,
  promptSessionId: option<string>,
  revisionNumber: int,
  source: string,
  summary: string,
  validationErrorsJson: option<string>,
  validationStatus: string,
}

/** 'GetProfileVersionById' query type */
@gentype
type getProfileVersionByIdQuery = {
  params: getProfileVersionByIdParams,
  result: getProfileVersionByIdResult,
}

%%private(let getProfileVersionByIdIR: IR.t = %raw(`{"usedParamSet":{"id":true},"params":[{"name":"id","required":true,"transform":{"type":"scalar"},"locs":[{"a":514,"b":517}]}],"statement":"SELECT\n  pv.id AS \"id\",\n  pv.profile_id AS \"profileId\",\n  pv.revision_number AS \"revisionNumber\",\n  pv.parent_version_id AS \"parentVersionId\",\n  pv.html AS \"html\",\n  pv.css AS \"css\",\n  pv.source AS \"source\",\n  pv.prompt_session_id AS \"promptSessionId\",\n  pv.summary AS \"summary\",\n  pv.validation_status AS \"validationStatus\",\n  pv.validation_errors::text AS \"validationErrorsJson\",\n  pv.created_by_user_id AS \"createdByUserId\",\n  pv.created_at::text AS \"createdAt\"\nFROM vibespace.profile_versions pv\nWHERE pv.id = :id!"}`))

/**
 Runnable query:
 ```sql
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
WHERE pv.id = $1
 ```

 */
@gentype
module GetProfileVersionById: {
  /** Returns an array of all matched results. */
  @gentype
  let many: (PgTyped.Pg.Client.t, getProfileVersionByIdParams) => promise<array<getProfileVersionByIdResult>>
  /** Returns exactly 1 result. Returns `None` if more or less than exactly 1 result is returned. */
  @gentype
  let one: (PgTyped.Pg.Client.t, getProfileVersionByIdParams) => promise<option<getProfileVersionByIdResult>>
  
  /** Returns exactly 1 result. Raises `Exn.t` (with an optionally provided `errorMessage`) if more or less than exactly 1 result is returned. */
  @gentype
  let expectOne: (
    PgTyped.Pg.Client.t,
    getProfileVersionByIdParams,
    ~errorMessage: string=?
  ) => promise<getProfileVersionByIdResult>

  /** Executes the query, but ignores whatever is returned by it. */
  @gentype
  let execute: (PgTyped.Pg.Client.t, getProfileVersionByIdParams) => promise<unit>
} = {
  @module("pgtyped-rescript-runtime") @new external getProfileVersionById: IR.t => PreparedStatement.t<getProfileVersionByIdParams, getProfileVersionByIdResult> = "PreparedQuery";
  let query = getProfileVersionById(getProfileVersionByIdIR)
  let query = (params, ~client) => query->PreparedStatement.run(params, ~client)

  @gentype
  let many = (client, params) => query(params, ~client)

  @gentype
  let one = async (client, params) => switch await query(params, ~client) {
  | [item] => Some(item)
  | _ => None
  }

  @gentype
  let expectOne = async (client, params, ~errorMessage=?) => switch await query(params, ~client) {
  | [item] => item
  | _ => panic(errorMessage->Option.getOr("More or less than one item was returned"))
  }

  @gentype
  let execute = async (client, params) => {
    let _ = await query(params, ~client)
  }
}

@gentype
@deprecated("Use 'GetProfileVersionById.many' directly instead")
let getProfileVersionById = (params, ~client) => GetProfileVersionById.many(client, params)


/** 'GetProfileVersionsByIds' parameters type */
@gentype
type getProfileVersionsByIdsParams = {
  ids: stringArray,
}

/** 'GetProfileVersionsByIds' return type */
@gentype
type getProfileVersionsByIdsResult = {
  createdAt: option<string>,
  createdByUserId: string,
  css: string,
  html: string,
  id: string,
  parentVersionId: option<string>,
  profileId: string,
  promptSessionId: option<string>,
  revisionNumber: int,
  source: string,
  summary: string,
  validationErrorsJson: option<string>,
  validationStatus: string,
}

/** 'GetProfileVersionsByIds' query type */
@gentype
type getProfileVersionsByIdsQuery = {
  params: getProfileVersionsByIdsParams,
  result: getProfileVersionsByIdsResult,
}

%%private(let getProfileVersionsByIdsIR: IR.t = %raw(`{"usedParamSet":{"ids":true},"params":[{"name":"ids","required":true,"transform":{"type":"scalar"},"locs":[{"a":518,"b":522}]}],"statement":"SELECT\n  pv.id AS \"id\",\n  pv.profile_id AS \"profileId\",\n  pv.revision_number AS \"revisionNumber\",\n  pv.parent_version_id AS \"parentVersionId\",\n  pv.html AS \"html\",\n  pv.css AS \"css\",\n  pv.source AS \"source\",\n  pv.prompt_session_id AS \"promptSessionId\",\n  pv.summary AS \"summary\",\n  pv.validation_status AS \"validationStatus\",\n  pv.validation_errors::text AS \"validationErrorsJson\",\n  pv.created_by_user_id AS \"createdByUserId\",\n  pv.created_at::text AS \"createdAt\"\nFROM vibespace.profile_versions pv\nWHERE pv.id = ANY(:ids!)"}`))

/**
 Runnable query:
 ```sql
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
WHERE pv.id = ANY($1)
 ```

 */
@gentype
module GetProfileVersionsByIds: {
  /** Returns an array of all matched results. */
  @gentype
  let many: (PgTyped.Pg.Client.t, getProfileVersionsByIdsParams) => promise<array<getProfileVersionsByIdsResult>>
  /** Returns exactly 1 result. Returns `None` if more or less than exactly 1 result is returned. */
  @gentype
  let one: (PgTyped.Pg.Client.t, getProfileVersionsByIdsParams) => promise<option<getProfileVersionsByIdsResult>>
  
  /** Returns exactly 1 result. Raises `Exn.t` (with an optionally provided `errorMessage`) if more or less than exactly 1 result is returned. */
  @gentype
  let expectOne: (
    PgTyped.Pg.Client.t,
    getProfileVersionsByIdsParams,
    ~errorMessage: string=?
  ) => promise<getProfileVersionsByIdsResult>

  /** Executes the query, but ignores whatever is returned by it. */
  @gentype
  let execute: (PgTyped.Pg.Client.t, getProfileVersionsByIdsParams) => promise<unit>
} = {
  @module("pgtyped-rescript-runtime") @new external getProfileVersionsByIds: IR.t => PreparedStatement.t<getProfileVersionsByIdsParams, getProfileVersionsByIdsResult> = "PreparedQuery";
  let query = getProfileVersionsByIds(getProfileVersionsByIdsIR)
  let query = (params, ~client) => query->PreparedStatement.run(params, ~client)

  @gentype
  let many = (client, params) => query(params, ~client)

  @gentype
  let one = async (client, params) => switch await query(params, ~client) {
  | [item] => Some(item)
  | _ => None
  }

  @gentype
  let expectOne = async (client, params, ~errorMessage=?) => switch await query(params, ~client) {
  | [item] => item
  | _ => panic(errorMessage->Option.getOr("More or less than one item was returned"))
  }

  @gentype
  let execute = async (client, params) => {
    let _ = await query(params, ~client)
  }
}

@gentype
@deprecated("Use 'GetProfileVersionsByIds.many' directly instead")
let getProfileVersionsByIds = (params, ~client) => GetProfileVersionsByIds.many(client, params)


/** 'GetCurrentProfileVersionForProfile' parameters type */
@gentype
type getCurrentProfileVersionForProfileParams = {
  profileId: string,
}

/** 'GetCurrentProfileVersionForProfile' return type */
@gentype
type getCurrentProfileVersionForProfileResult = {
  createdAt: option<string>,
  createdByUserId: string,
  css: string,
  html: string,
  id: string,
  parentVersionId: option<string>,
  profileId: string,
  promptSessionId: option<string>,
  revisionNumber: int,
  source: string,
  summary: string,
  validationErrorsJson: option<string>,
  validationStatus: string,
}

/** 'GetCurrentProfileVersionForProfile' query type */
@gentype
type getCurrentProfileVersionForProfileQuery = {
  params: getCurrentProfileVersionForProfileParams,
  result: getCurrentProfileVersionForProfileResult,
}

%%private(let getCurrentProfileVersionForProfileIR: IR.t = %raw(`{"usedParamSet":{"profileId":true},"params":[{"name":"profileId","required":true,"transform":{"type":"scalar"},"locs":[{"a":571,"b":581}]}],"statement":"SELECT\n  pv.id AS \"id\",\n  pv.profile_id AS \"profileId\",\n  pv.revision_number AS \"revisionNumber\",\n  pv.parent_version_id AS \"parentVersionId\",\n  pv.html AS \"html\",\n  pv.css AS \"css\",\n  pv.source AS \"source\",\n  pv.prompt_session_id AS \"promptSessionId\",\n  pv.summary AS \"summary\",\n  pv.validation_status AS \"validationStatus\",\n  pv.validation_errors::text AS \"validationErrorsJson\",\n  pv.created_by_user_id AS \"createdByUserId\",\n  pv.created_at::text AS \"createdAt\"\nFROM vibespace.profiles p\nJOIN vibespace.profile_versions pv ON pv.id = p.current_version_id\nWHERE p.id = :profileId!"}`))

/**
 Runnable query:
 ```sql
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
WHERE p.id = $1
 ```

 */
@gentype
module GetCurrentProfileVersionForProfile: {
  /** Returns an array of all matched results. */
  @gentype
  let many: (PgTyped.Pg.Client.t, getCurrentProfileVersionForProfileParams) => promise<array<getCurrentProfileVersionForProfileResult>>
  /** Returns exactly 1 result. Returns `None` if more or less than exactly 1 result is returned. */
  @gentype
  let one: (PgTyped.Pg.Client.t, getCurrentProfileVersionForProfileParams) => promise<option<getCurrentProfileVersionForProfileResult>>
  
  /** Returns exactly 1 result. Raises `Exn.t` (with an optionally provided `errorMessage`) if more or less than exactly 1 result is returned. */
  @gentype
  let expectOne: (
    PgTyped.Pg.Client.t,
    getCurrentProfileVersionForProfileParams,
    ~errorMessage: string=?
  ) => promise<getCurrentProfileVersionForProfileResult>

  /** Executes the query, but ignores whatever is returned by it. */
  @gentype
  let execute: (PgTyped.Pg.Client.t, getCurrentProfileVersionForProfileParams) => promise<unit>
} = {
  @module("pgtyped-rescript-runtime") @new external getCurrentProfileVersionForProfile: IR.t => PreparedStatement.t<getCurrentProfileVersionForProfileParams, getCurrentProfileVersionForProfileResult> = "PreparedQuery";
  let query = getCurrentProfileVersionForProfile(getCurrentProfileVersionForProfileIR)
  let query = (params, ~client) => query->PreparedStatement.run(params, ~client)

  @gentype
  let many = (client, params) => query(params, ~client)

  @gentype
  let one = async (client, params) => switch await query(params, ~client) {
  | [item] => Some(item)
  | _ => None
  }

  @gentype
  let expectOne = async (client, params, ~errorMessage=?) => switch await query(params, ~client) {
  | [item] => item
  | _ => panic(errorMessage->Option.getOr("More or less than one item was returned"))
  }

  @gentype
  let execute = async (client, params) => {
    let _ = await query(params, ~client)
  }
}

@gentype
@deprecated("Use 'GetCurrentProfileVersionForProfile.many' directly instead")
let getCurrentProfileVersionForProfile = (params, ~client) => GetCurrentProfileVersionForProfile.many(client, params)


/** 'GetCurrentProfileVersionsByProfileIds' parameters type */
@gentype
type getCurrentProfileVersionsByProfileIdsParams = {
  profileIds: stringArray,
}

/** 'GetCurrentProfileVersionsByProfileIds' return type */
@gentype
type getCurrentProfileVersionsByProfileIdsResult = {
  createdAt: option<string>,
  createdByUserId: string,
  css: string,
  html: string,
  id: string,
  parentVersionId: option<string>,
  profileId: string,
  promptSessionId: option<string>,
  revisionNumber: int,
  source: string,
  summary: string,
  validationErrorsJson: option<string>,
  validationStatus: string,
}

/** 'GetCurrentProfileVersionsByProfileIds' query type */
@gentype
type getCurrentProfileVersionsByProfileIdsQuery = {
  params: getCurrentProfileVersionsByProfileIdsParams,
  result: getCurrentProfileVersionsByProfileIdsResult,
}

%%private(let getCurrentProfileVersionsByProfileIdsIR: IR.t = %raw(`{"usedParamSet":{"profileIds":true},"params":[{"name":"profileIds","required":true,"transform":{"type":"scalar"},"locs":[{"a":575,"b":586}]}],"statement":"SELECT\n  pv.id AS \"id\",\n  pv.profile_id AS \"profileId\",\n  pv.revision_number AS \"revisionNumber\",\n  pv.parent_version_id AS \"parentVersionId\",\n  pv.html AS \"html\",\n  pv.css AS \"css\",\n  pv.source AS \"source\",\n  pv.prompt_session_id AS \"promptSessionId\",\n  pv.summary AS \"summary\",\n  pv.validation_status AS \"validationStatus\",\n  pv.validation_errors::text AS \"validationErrorsJson\",\n  pv.created_by_user_id AS \"createdByUserId\",\n  pv.created_at::text AS \"createdAt\"\nFROM vibespace.profiles p\nJOIN vibespace.profile_versions pv ON pv.id = p.current_version_id\nWHERE p.id = ANY(:profileIds!)"}`))

/**
 Runnable query:
 ```sql
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
WHERE p.id = ANY($1)
 ```

 */
@gentype
module GetCurrentProfileVersionsByProfileIds: {
  /** Returns an array of all matched results. */
  @gentype
  let many: (PgTyped.Pg.Client.t, getCurrentProfileVersionsByProfileIdsParams) => promise<array<getCurrentProfileVersionsByProfileIdsResult>>
  /** Returns exactly 1 result. Returns `None` if more or less than exactly 1 result is returned. */
  @gentype
  let one: (PgTyped.Pg.Client.t, getCurrentProfileVersionsByProfileIdsParams) => promise<option<getCurrentProfileVersionsByProfileIdsResult>>
  
  /** Returns exactly 1 result. Raises `Exn.t` (with an optionally provided `errorMessage`) if more or less than exactly 1 result is returned. */
  @gentype
  let expectOne: (
    PgTyped.Pg.Client.t,
    getCurrentProfileVersionsByProfileIdsParams,
    ~errorMessage: string=?
  ) => promise<getCurrentProfileVersionsByProfileIdsResult>

  /** Executes the query, but ignores whatever is returned by it. */
  @gentype
  let execute: (PgTyped.Pg.Client.t, getCurrentProfileVersionsByProfileIdsParams) => promise<unit>
} = {
  @module("pgtyped-rescript-runtime") @new external getCurrentProfileVersionsByProfileIds: IR.t => PreparedStatement.t<getCurrentProfileVersionsByProfileIdsParams, getCurrentProfileVersionsByProfileIdsResult> = "PreparedQuery";
  let query = getCurrentProfileVersionsByProfileIds(getCurrentProfileVersionsByProfileIdsIR)
  let query = (params, ~client) => query->PreparedStatement.run(params, ~client)

  @gentype
  let many = (client, params) => query(params, ~client)

  @gentype
  let one = async (client, params) => switch await query(params, ~client) {
  | [item] => Some(item)
  | _ => None
  }

  @gentype
  let expectOne = async (client, params, ~errorMessage=?) => switch await query(params, ~client) {
  | [item] => item
  | _ => panic(errorMessage->Option.getOr("More or less than one item was returned"))
  }

  @gentype
  let execute = async (client, params) => {
    let _ = await query(params, ~client)
  }
}

@gentype
@deprecated("Use 'GetCurrentProfileVersionsByProfileIds.many' directly instead")
let getCurrentProfileVersionsByProfileIds = (params, ~client) => GetCurrentProfileVersionsByProfileIds.many(client, params)


/** 'ListProfileVersionsForProfile' parameters type */
@gentype
type listProfileVersionsForProfileParams = {
  profileId: string,
}

/** 'ListProfileVersionsForProfile' return type */
@gentype
type listProfileVersionsForProfileResult = {
  createdAt: option<string>,
  createdByUserId: string,
  css: string,
  html: string,
  id: string,
  parentVersionId: option<string>,
  profileId: string,
  promptSessionId: option<string>,
  revisionNumber: int,
  source: string,
  summary: string,
  validationErrorsJson: option<string>,
  validationStatus: string,
}

/** 'ListProfileVersionsForProfile' query type */
@gentype
type listProfileVersionsForProfileQuery = {
  params: listProfileVersionsForProfileParams,
  result: listProfileVersionsForProfileResult,
}

%%private(let listProfileVersionsForProfileIR: IR.t = %raw(`{"usedParamSet":{"profileId":true},"params":[{"name":"profileId","required":true,"transform":{"type":"scalar"},"locs":[{"a":522,"b":532}]}],"statement":"SELECT\n  pv.id AS \"id\",\n  pv.profile_id AS \"profileId\",\n  pv.revision_number AS \"revisionNumber\",\n  pv.parent_version_id AS \"parentVersionId\",\n  pv.html AS \"html\",\n  pv.css AS \"css\",\n  pv.source AS \"source\",\n  pv.prompt_session_id AS \"promptSessionId\",\n  pv.summary AS \"summary\",\n  pv.validation_status AS \"validationStatus\",\n  pv.validation_errors::text AS \"validationErrorsJson\",\n  pv.created_by_user_id AS \"createdByUserId\",\n  pv.created_at::text AS \"createdAt\"\nFROM vibespace.profile_versions pv\nWHERE pv.profile_id = :profileId!\nORDER BY pv.revision_number DESC\nLIMIT 100"}`))

/**
 Runnable query:
 ```sql
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
WHERE pv.profile_id = $1
ORDER BY pv.revision_number DESC
LIMIT 100
 ```

 */
@gentype
module ListProfileVersionsForProfile: {
  /** Returns an array of all matched results. */
  @gentype
  let many: (PgTyped.Pg.Client.t, listProfileVersionsForProfileParams) => promise<array<listProfileVersionsForProfileResult>>
  /** Returns exactly 1 result. Returns `None` if more or less than exactly 1 result is returned. */
  @gentype
  let one: (PgTyped.Pg.Client.t, listProfileVersionsForProfileParams) => promise<option<listProfileVersionsForProfileResult>>
  
  /** Returns exactly 1 result. Raises `Exn.t` (with an optionally provided `errorMessage`) if more or less than exactly 1 result is returned. */
  @gentype
  let expectOne: (
    PgTyped.Pg.Client.t,
    listProfileVersionsForProfileParams,
    ~errorMessage: string=?
  ) => promise<listProfileVersionsForProfileResult>

  /** Executes the query, but ignores whatever is returned by it. */
  @gentype
  let execute: (PgTyped.Pg.Client.t, listProfileVersionsForProfileParams) => promise<unit>
} = {
  @module("pgtyped-rescript-runtime") @new external listProfileVersionsForProfile: IR.t => PreparedStatement.t<listProfileVersionsForProfileParams, listProfileVersionsForProfileResult> = "PreparedQuery";
  let query = listProfileVersionsForProfile(listProfileVersionsForProfileIR)
  let query = (params, ~client) => query->PreparedStatement.run(params, ~client)

  @gentype
  let many = (client, params) => query(params, ~client)

  @gentype
  let one = async (client, params) => switch await query(params, ~client) {
  | [item] => Some(item)
  | _ => None
  }

  @gentype
  let expectOne = async (client, params, ~errorMessage=?) => switch await query(params, ~client) {
  | [item] => item
  | _ => panic(errorMessage->Option.getOr("More or less than one item was returned"))
  }

  @gentype
  let execute = async (client, params) => {
    let _ = await query(params, ~client)
  }
}

@gentype
@deprecated("Use 'ListProfileVersionsForProfile.many' directly instead")
let listProfileVersionsForProfile = (params, ~client) => ListProfileVersionsForProfile.many(client, params)


/** 'EnsureInitialProfileVersion' parameters type */
@gentype
type ensureInitialProfileVersionParams = {
  createdByUserId: string,
  css: string,
  html: string,
  profileId: string,
}

/** 'EnsureInitialProfileVersion' return type */
@gentype
type ensureInitialProfileVersionResult = {
  createdAt: option<string>,
  createdByUserId: option<string>,
  css: option<string>,
  html: option<string>,
  id: option<string>,
  parentVersionId: option<string>,
  profileId: option<string>,
  promptSessionId: option<string>,
  revisionNumber: option<int>,
  source: option<string>,
  summary: option<string>,
  validationErrorsJson: option<string>,
  validationStatus: option<string>,
}

/** 'EnsureInitialProfileVersion' query type */
@gentype
type ensureInitialProfileVersionQuery = {
  params: ensureInitialProfileVersionParams,
  result: ensureInitialProfileVersionResult,
}

%%private(let ensureInitialProfileVersionIR: IR.t = %raw(`{"usedParamSet":{"profileId":true,"html":true,"css":true,"createdByUserId":true},"params":[{"name":"profileId","required":true,"transform":{"type":"scalar"},"locs":[{"a":102,"b":112},{"a":416,"b":426}]},{"name":"html","required":true,"transform":{"type":"scalar"},"locs":[{"a":450,"b":455},{"a":729,"b":734}]},{"name":"css","required":true,"transform":{"type":"scalar"},"locs":[{"a":462,"b":466},{"a":747,"b":751}]},{"name":"createdByUserId","required":true,"transform":{"type":"scalar"},"locs":[{"a":554,"b":570}]}],"statement":"WITH existing_version AS (\n  SELECT pv.*\n  FROM vibespace.profile_versions pv\n  WHERE pv.profile_id = :profileId!\n  ORDER BY pv.revision_number ASC\n  LIMIT 1\n),\ninserted_version AS (\n  INSERT INTO vibespace.profile_versions (\n    profile_id,\n    revision_number,\n    parent_version_id,\n    html,\n    css,\n    source,\n    summary,\n    validation_status,\n    validation_errors,\n    created_by_user_id\n  )\n  SELECT\n    :profileId!,\n    1,\n    NULL,\n    :html!,\n    :css!,\n    'import',\n    'Initial seed profile version.',\n    'valid',\n    '[]'::jsonb,\n    :createdByUserId!\n  WHERE NOT EXISTS (SELECT 1 FROM existing_version)\n  RETURNING *\n),\nrefreshed_existing_version AS (\n  UPDATE vibespace.profile_versions pv\n  SET\n    html = :html!,\n    css = :css!,\n    summary = 'Initial seed profile version.',\n    validation_status = 'valid',\n    validation_errors = '[]'::jsonb\n  FROM existing_version\n  WHERE pv.id = existing_version.id\n    AND existing_version.source = 'import'\n    AND existing_version.summary = 'Initial seed profile version.'\n    AND (\n      existing_version.html LIKE '%Vibespace fixture profile%'\n      OR existing_version.css LIKE '%#101114%'\n    )\n  RETURNING pv.*\n),\nselected_version AS (\n  SELECT * FROM inserted_version\n  UNION ALL\n  SELECT * FROM refreshed_existing_version\n  UNION ALL\n  SELECT * FROM existing_version\n  WHERE NOT EXISTS (SELECT 1 FROM refreshed_existing_version)\n  LIMIT 1\n),\nupdated_profile AS (\n  UPDATE vibespace.profiles p\n  SET\n    current_version_id = selected_version.id,\n    published_at = COALESCE(p.published_at, now()),\n    updated_at = now()\n  FROM selected_version\n  WHERE p.id = selected_version.profile_id\n  RETURNING p.id\n)\nSELECT\n  selected_version.id AS \"id\",\n  selected_version.profile_id AS \"profileId\",\n  selected_version.revision_number AS \"revisionNumber\",\n  selected_version.parent_version_id AS \"parentVersionId\",\n  selected_version.html AS \"html\",\n  selected_version.css AS \"css\",\n  selected_version.source AS \"source\",\n  selected_version.prompt_session_id AS \"promptSessionId\",\n  selected_version.summary AS \"summary\",\n  selected_version.validation_status AS \"validationStatus\",\n  selected_version.validation_errors::text AS \"validationErrorsJson\",\n  selected_version.created_by_user_id AS \"createdByUserId\",\n  selected_version.created_at::text AS \"createdAt\"\nFROM selected_version"}`))

/**
 Runnable query:
 ```sql
WITH existing_version AS (
  SELECT pv.*
  FROM vibespace.profile_versions pv
  WHERE pv.profile_id = $1
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
    $1,
    1,
    NULL,
    $2,
    $3,
    'import',
    'Initial seed profile version.',
    'valid',
    '[]'::jsonb,
    $4
  WHERE NOT EXISTS (SELECT 1 FROM existing_version)
  RETURNING *
),
refreshed_existing_version AS (
  UPDATE vibespace.profile_versions pv
  SET
    html = $2,
    css = $3,
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
FROM selected_version
 ```

 */
@gentype
module EnsureInitialProfileVersion: {
  /** Returns an array of all matched results. */
  @gentype
  let many: (PgTyped.Pg.Client.t, ensureInitialProfileVersionParams) => promise<array<ensureInitialProfileVersionResult>>
  /** Returns exactly 1 result. Returns `None` if more or less than exactly 1 result is returned. */
  @gentype
  let one: (PgTyped.Pg.Client.t, ensureInitialProfileVersionParams) => promise<option<ensureInitialProfileVersionResult>>
  
  /** Returns exactly 1 result. Raises `Exn.t` (with an optionally provided `errorMessage`) if more or less than exactly 1 result is returned. */
  @gentype
  let expectOne: (
    PgTyped.Pg.Client.t,
    ensureInitialProfileVersionParams,
    ~errorMessage: string=?
  ) => promise<ensureInitialProfileVersionResult>

  /** Executes the query, but ignores whatever is returned by it. */
  @gentype
  let execute: (PgTyped.Pg.Client.t, ensureInitialProfileVersionParams) => promise<unit>
} = {
  @module("pgtyped-rescript-runtime") @new external ensureInitialProfileVersion: IR.t => PreparedStatement.t<ensureInitialProfileVersionParams, ensureInitialProfileVersionResult> = "PreparedQuery";
  let query = ensureInitialProfileVersion(ensureInitialProfileVersionIR)
  let query = (params, ~client) => query->PreparedStatement.run(params, ~client)

  @gentype
  let many = (client, params) => query(params, ~client)

  @gentype
  let one = async (client, params) => switch await query(params, ~client) {
  | [item] => Some(item)
  | _ => None
  }

  @gentype
  let expectOne = async (client, params, ~errorMessage=?) => switch await query(params, ~client) {
  | [item] => item
  | _ => panic(errorMessage->Option.getOr("More or less than one item was returned"))
  }

  @gentype
  let execute = async (client, params) => {
    let _ = await query(params, ~client)
  }
}

@gentype
@deprecated("Use 'EnsureInitialProfileVersion.many' directly instead")
let ensureInitialProfileVersion = (params, ~client) => EnsureInitialProfileVersion.many(client, params)


/** 'InsertManualProfileVersion' parameters type */
@gentype
type insertManualProfileVersionParams = {
  createdByUserId: string,
  css: string,
  html: string,
  profileId: string,
  summary: string,
}

/** 'InsertManualProfileVersion' return type */
@gentype
type insertManualProfileVersionResult = {
  createdAt: option<string>,
  createdByUserId: string,
  css: string,
  html: string,
  id: string,
  parentVersionId: option<string>,
  profileId: string,
  promptSessionId: option<string>,
  revisionNumber: int,
  source: string,
  summary: string,
  validationErrorsJson: option<string>,
  validationStatus: string,
}

/** 'InsertManualProfileVersion' query type */
@gentype
type insertManualProfileVersionQuery = {
  params: insertManualProfileVersionParams,
  result: insertManualProfileVersionResult,
}

%%private(let insertManualProfileVersionIR: IR.t = %raw(`{"usedParamSet":{"profileId":true,"html":true,"css":true,"summary":true,"createdByUserId":true},"params":[{"name":"profileId","required":true,"transform":{"type":"scalar"},"locs":[{"a":314,"b":324}]},{"name":"html","required":true,"transform":{"type":"scalar"},"locs":[{"a":703,"b":708}]},{"name":"css","required":true,"transform":{"type":"scalar"},"locs":[{"a":715,"b":719}]},{"name":"summary","required":true,"transform":{"type":"scalar"},"locs":[{"a":740,"b":748}]},{"name":"createdByUserId","required":true,"transform":{"type":"scalar"},"locs":[{"a":785,"b":801}]}],"statement":"WITH target_profile AS (\n  SELECT\n    p.id,\n    p.owner_user_id,\n    p.current_version_id,\n    COALESCE(MAX(existing_versions.revision_number), 0) + 1 AS next_revision_number\n  FROM vibespace.profiles p\n  LEFT JOIN vibespace.profile_versions existing_versions ON existing_versions.profile_id = p.id\n  WHERE p.id = :profileId!\n  GROUP BY p.id\n),\ninserted_version AS (\n  INSERT INTO vibespace.profile_versions (\n    profile_id,\n    revision_number,\n    parent_version_id,\n    html,\n    css,\n    source,\n    summary,\n    validation_status,\n    validation_errors,\n    created_by_user_id\n  )\n  SELECT\n    target_profile.id,\n    target_profile.next_revision_number,\n    target_profile.current_version_id,\n    :html!,\n    :css!,\n    'manual',\n    :summary!,\n    'valid',\n    '[]'::jsonb,\n    :createdByUserId!\n  FROM target_profile\n  RETURNING *\n),\nupdated_profile AS (\n  UPDATE vibespace.profiles p\n  SET\n    current_version_id = inserted_version.id,\n    published_at = now(),\n    updated_at = now()\n  FROM inserted_version\n  WHERE p.id = inserted_version.profile_id\n  RETURNING p.id\n)\nSELECT\n  inserted_version.id AS \"id\",\n  inserted_version.profile_id AS \"profileId\",\n  inserted_version.revision_number AS \"revisionNumber\",\n  inserted_version.parent_version_id AS \"parentVersionId\",\n  inserted_version.html AS \"html\",\n  inserted_version.css AS \"css\",\n  inserted_version.source AS \"source\",\n  inserted_version.prompt_session_id AS \"promptSessionId\",\n  inserted_version.summary AS \"summary\",\n  inserted_version.validation_status AS \"validationStatus\",\n  inserted_version.validation_errors::text AS \"validationErrorsJson\",\n  inserted_version.created_by_user_id AS \"createdByUserId\",\n  inserted_version.created_at::text AS \"createdAt\"\nFROM inserted_version"}`))

/**
 Runnable query:
 ```sql
WITH target_profile AS (
  SELECT
    p.id,
    p.owner_user_id,
    p.current_version_id,
    COALESCE(MAX(existing_versions.revision_number), 0) + 1 AS next_revision_number
  FROM vibespace.profiles p
  LEFT JOIN vibespace.profile_versions existing_versions ON existing_versions.profile_id = p.id
  WHERE p.id = $1
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
    $2,
    $3,
    'manual',
    $4,
    'valid',
    '[]'::jsonb,
    $5
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
FROM inserted_version
 ```

 */
@gentype
module InsertManualProfileVersion: {
  /** Returns an array of all matched results. */
  @gentype
  let many: (PgTyped.Pg.Client.t, insertManualProfileVersionParams) => promise<array<insertManualProfileVersionResult>>
  /** Returns exactly 1 result. Returns `None` if more or less than exactly 1 result is returned. */
  @gentype
  let one: (PgTyped.Pg.Client.t, insertManualProfileVersionParams) => promise<option<insertManualProfileVersionResult>>
  
  /** Returns exactly 1 result. Raises `Exn.t` (with an optionally provided `errorMessage`) if more or less than exactly 1 result is returned. */
  @gentype
  let expectOne: (
    PgTyped.Pg.Client.t,
    insertManualProfileVersionParams,
    ~errorMessage: string=?
  ) => promise<insertManualProfileVersionResult>

  /** Executes the query, but ignores whatever is returned by it. */
  @gentype
  let execute: (PgTyped.Pg.Client.t, insertManualProfileVersionParams) => promise<unit>
} = {
  @module("pgtyped-rescript-runtime") @new external insertManualProfileVersion: IR.t => PreparedStatement.t<insertManualProfileVersionParams, insertManualProfileVersionResult> = "PreparedQuery";
  let query = insertManualProfileVersion(insertManualProfileVersionIR)
  let query = (params, ~client) => query->PreparedStatement.run(params, ~client)

  @gentype
  let many = (client, params) => query(params, ~client)

  @gentype
  let one = async (client, params) => switch await query(params, ~client) {
  | [item] => Some(item)
  | _ => None
  }

  @gentype
  let expectOne = async (client, params, ~errorMessage=?) => switch await query(params, ~client) {
  | [item] => item
  | _ => panic(errorMessage->Option.getOr("More or less than one item was returned"))
  }

  @gentype
  let execute = async (client, params) => {
    let _ = await query(params, ~client)
  }
}

@gentype
@deprecated("Use 'InsertManualProfileVersion.many' directly instead")
let insertManualProfileVersion = (params, ~client) => InsertManualProfileVersion.many(client, params)


/** 'RestoreProfileVersion' parameters type */
@gentype
type restoreProfileVersionParams = {
  createdByUserId: string,
  profileId: string,
  summary: string,
  versionId: string,
}

/** 'RestoreProfileVersion' return type */
@gentype
type restoreProfileVersionResult = {
  createdAt: option<string>,
  createdByUserId: string,
  css: string,
  html: string,
  id: string,
  parentVersionId: option<string>,
  profileId: string,
  promptSessionId: option<string>,
  revisionNumber: int,
  source: string,
  summary: string,
  validationErrorsJson: option<string>,
  validationStatus: string,
}

/** 'RestoreProfileVersion' query type */
@gentype
type restoreProfileVersionQuery = {
  params: restoreProfileVersionParams,
  result: restoreProfileVersionResult,
}

%%private(let restoreProfileVersionIR: IR.t = %raw(`{"usedParamSet":{"versionId":true,"profileId":true,"summary":true,"createdByUserId":true},"params":[{"name":"versionId","required":true,"transform":{"type":"scalar"},"locs":[{"a":205,"b":215}]},{"name":"profileId","required":true,"transform":{"type":"scalar"},"locs":[{"a":241,"b":251},{"a":557,"b":567}]},{"name":"summary","required":true,"transform":{"type":"scalar"},"locs":[{"a":1002,"b":1010}]},{"name":"createdByUserId","required":true,"transform":{"type":"scalar"},"locs":[{"a":1093,"b":1109}]}],"statement":"WITH source_version AS (\n  SELECT\n    sv.*,\n    p.current_version_id AS previous_current_version_id\n  FROM vibespace.profile_versions sv\n  JOIN vibespace.profiles p ON p.id = sv.profile_id\n  WHERE sv.id = :versionId!\n    AND sv.profile_id = :profileId!\n    AND sv.validation_status = 'valid'\n),\ntarget_profile AS (\n  SELECT\n    p.id,\n    COALESCE(MAX(existing_versions.revision_number), 0) + 1 AS next_revision_number\n  FROM vibespace.profiles p\n  LEFT JOIN vibespace.profile_versions existing_versions ON existing_versions.profile_id = p.id\n  WHERE p.id = :profileId!\n  GROUP BY p.id\n),\ninserted_version AS (\n  INSERT INTO vibespace.profile_versions (\n    profile_id,\n    revision_number,\n    parent_version_id,\n    html,\n    css,\n    source,\n    summary,\n    validation_status,\n    validation_errors,\n    created_by_user_id\n  )\n  SELECT\n    source_version.profile_id,\n    target_profile.next_revision_number,\n    source_version.id,\n    source_version.html,\n    source_version.css,\n    'restore',\n    :summary!,\n    source_version.validation_status,\n    source_version.validation_errors,\n    :createdByUserId!\n  FROM source_version\n  JOIN target_profile ON target_profile.id = source_version.profile_id\n  RETURNING *\n),\nupdated_profile AS (\n  UPDATE vibespace.profiles p\n  SET\n    current_version_id = inserted_version.id,\n    published_at = now(),\n    updated_at = now()\n  FROM inserted_version\n  WHERE p.id = inserted_version.profile_id\n  RETURNING p.id\n)\nSELECT\n  inserted_version.id AS \"id\",\n  inserted_version.profile_id AS \"profileId\",\n  inserted_version.revision_number AS \"revisionNumber\",\n  inserted_version.parent_version_id AS \"parentVersionId\",\n  inserted_version.html AS \"html\",\n  inserted_version.css AS \"css\",\n  inserted_version.source AS \"source\",\n  inserted_version.prompt_session_id AS \"promptSessionId\",\n  inserted_version.summary AS \"summary\",\n  inserted_version.validation_status AS \"validationStatus\",\n  inserted_version.validation_errors::text AS \"validationErrorsJson\",\n  inserted_version.created_by_user_id AS \"createdByUserId\",\n  inserted_version.created_at::text AS \"createdAt\"\nFROM inserted_version"}`))

/**
 Runnable query:
 ```sql
WITH source_version AS (
  SELECT
    sv.*,
    p.current_version_id AS previous_current_version_id
  FROM vibespace.profile_versions sv
  JOIN vibespace.profiles p ON p.id = sv.profile_id
  WHERE sv.id = $1
    AND sv.profile_id = $2
    AND sv.validation_status = 'valid'
),
target_profile AS (
  SELECT
    p.id,
    COALESCE(MAX(existing_versions.revision_number), 0) + 1 AS next_revision_number
  FROM vibespace.profiles p
  LEFT JOIN vibespace.profile_versions existing_versions ON existing_versions.profile_id = p.id
  WHERE p.id = $2
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
    $3,
    source_version.validation_status,
    source_version.validation_errors,
    $4
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
FROM inserted_version
 ```

 */
@gentype
module RestoreProfileVersion: {
  /** Returns an array of all matched results. */
  @gentype
  let many: (PgTyped.Pg.Client.t, restoreProfileVersionParams) => promise<array<restoreProfileVersionResult>>
  /** Returns exactly 1 result. Returns `None` if more or less than exactly 1 result is returned. */
  @gentype
  let one: (PgTyped.Pg.Client.t, restoreProfileVersionParams) => promise<option<restoreProfileVersionResult>>
  
  /** Returns exactly 1 result. Raises `Exn.t` (with an optionally provided `errorMessage`) if more or less than exactly 1 result is returned. */
  @gentype
  let expectOne: (
    PgTyped.Pg.Client.t,
    restoreProfileVersionParams,
    ~errorMessage: string=?
  ) => promise<restoreProfileVersionResult>

  /** Executes the query, but ignores whatever is returned by it. */
  @gentype
  let execute: (PgTyped.Pg.Client.t, restoreProfileVersionParams) => promise<unit>
} = {
  @module("pgtyped-rescript-runtime") @new external restoreProfileVersion: IR.t => PreparedStatement.t<restoreProfileVersionParams, restoreProfileVersionResult> = "PreparedQuery";
  let query = restoreProfileVersion(restoreProfileVersionIR)
  let query = (params, ~client) => query->PreparedStatement.run(params, ~client)

  @gentype
  let many = (client, params) => query(params, ~client)

  @gentype
  let one = async (client, params) => switch await query(params, ~client) {
  | [item] => Some(item)
  | _ => None
  }

  @gentype
  let expectOne = async (client, params, ~errorMessage=?) => switch await query(params, ~client) {
  | [item] => item
  | _ => panic(errorMessage->Option.getOr("More or less than one item was returned"))
  }

  @gentype
  let execute = async (client, params) => {
    let _ = await query(params, ~client)
  }
}

@gentype
@deprecated("Use 'RestoreProfileVersion.many' directly instead")
let restoreProfileVersion = (params, ~client) => RestoreProfileVersion.many(client, params)


/** 'InsertProfileUpdateEvent' parameters type */
@gentype
type insertProfileUpdateEventParams = {
  actorUserId: string,
  kind: string,
  profileId: string,
  profileVersionId: string,
  summary: string,
  title: string,
}

/** 'InsertProfileUpdateEvent' return type */
@gentype
type insertProfileUpdateEventResult = {
  actorUserId: string,
  createdAt: option<string>,
  id: string,
  kind: string,
  profileId: string,
  profileVersionId: string,
  summary: string,
  title: string,
  visibility: string,
}

/** 'InsertProfileUpdateEvent' query type */
@gentype
type insertProfileUpdateEventQuery = {
  params: insertProfileUpdateEventParams,
  result: insertProfileUpdateEventResult,
}

%%private(let insertProfileUpdateEventIR: IR.t = %raw(`{"usedParamSet":{"actorUserId":true,"profileId":true,"profileVersionId":true,"kind":true,"title":true,"summary":true},"params":[{"name":"actorUserId","required":true,"transform":{"type":"scalar"},"locs":[{"a":153,"b":165}]},{"name":"profileId","required":true,"transform":{"type":"scalar"},"locs":[{"a":170,"b":180}]},{"name":"profileVersionId","required":true,"transform":{"type":"scalar"},"locs":[{"a":185,"b":202}]},{"name":"kind","required":true,"transform":{"type":"scalar"},"locs":[{"a":207,"b":212}]},{"name":"title","required":true,"transform":{"type":"scalar"},"locs":[{"a":217,"b":223}]},{"name":"summary","required":true,"transform":{"type":"scalar"},"locs":[{"a":228,"b":236}]}],"statement":"INSERT INTO vibespace.profile_update_events (\n  actor_user_id,\n  profile_id,\n  profile_version_id,\n  kind,\n  title,\n  summary,\n  visibility\n)\nVALUES (\n  :actorUserId!,\n  :profileId!,\n  :profileVersionId!,\n  :kind!,\n  :title!,\n  :summary!,\n  'friends'\n)\nRETURNING\n  id AS \"id\",\n  actor_user_id AS \"actorUserId\",\n  profile_id AS \"profileId\",\n  profile_version_id AS \"profileVersionId\",\n  kind AS \"kind\",\n  title AS \"title\",\n  summary AS \"summary\",\n  visibility AS \"visibility\",\n  created_at::text AS \"createdAt\""}`))

/**
 Runnable query:
 ```sql
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
  $1,
  $2,
  $3,
  $4,
  $5,
  $6,
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
  created_at::text AS "createdAt"
 ```

 */
@gentype
module InsertProfileUpdateEvent: {
  /** Returns an array of all matched results. */
  @gentype
  let many: (PgTyped.Pg.Client.t, insertProfileUpdateEventParams) => promise<array<insertProfileUpdateEventResult>>
  /** Returns exactly 1 result. Returns `None` if more or less than exactly 1 result is returned. */
  @gentype
  let one: (PgTyped.Pg.Client.t, insertProfileUpdateEventParams) => promise<option<insertProfileUpdateEventResult>>
  
  /** Returns exactly 1 result. Raises `Exn.t` (with an optionally provided `errorMessage`) if more or less than exactly 1 result is returned. */
  @gentype
  let expectOne: (
    PgTyped.Pg.Client.t,
    insertProfileUpdateEventParams,
    ~errorMessage: string=?
  ) => promise<insertProfileUpdateEventResult>

  /** Executes the query, but ignores whatever is returned by it. */
  @gentype
  let execute: (PgTyped.Pg.Client.t, insertProfileUpdateEventParams) => promise<unit>
} = {
  @module("pgtyped-rescript-runtime") @new external insertProfileUpdateEvent: IR.t => PreparedStatement.t<insertProfileUpdateEventParams, insertProfileUpdateEventResult> = "PreparedQuery";
  let query = insertProfileUpdateEvent(insertProfileUpdateEventIR)
  let query = (params, ~client) => query->PreparedStatement.run(params, ~client)

  @gentype
  let many = (client, params) => query(params, ~client)

  @gentype
  let one = async (client, params) => switch await query(params, ~client) {
  | [item] => Some(item)
  | _ => None
  }

  @gentype
  let expectOne = async (client, params, ~errorMessage=?) => switch await query(params, ~client) {
  | [item] => item
  | _ => panic(errorMessage->Option.getOr("More or less than one item was returned"))
  }

  @gentype
  let execute = async (client, params) => {
    let _ = await query(params, ~client)
  }
}

@gentype
@deprecated("Use 'InsertProfileUpdateEvent.many' directly instead")
let insertProfileUpdateEvent = (params, ~client) => InsertProfileUpdateEvent.many(client, params)


/** 'GetProfileEditSessionById' parameters type */
@gentype
type getProfileEditSessionByIdParams = {
  id: string,
}

/** 'GetProfileEditSessionById' return type */
@gentype
type getProfileEditSessionByIdResult = {
  createdAt: option<string>,
  error: option<string>,
  failedCss: option<string>,
  failedHtml: option<string>,
  failedValidationMessage: option<string>,
  id: string,
  profileId: string,
  progressPhase: string,
  prompt: string,
  providerConversationId: option<string>,
  resultVersionId: option<string>,
  selectionSnapshotId: option<string>,
  status: string,
  summary: string,
  updatedAt: option<string>,
  userId: string,
  warningsJson: option<string>,
}

/** 'GetProfileEditSessionById' query type */
@gentype
type getProfileEditSessionByIdQuery = {
  params: getProfileEditSessionByIdParams,
  result: getProfileEditSessionByIdResult,
}

%%private(let getProfileEditSessionByIdIR: IR.t = %raw(`{"usedParamSet":{"id":true},"params":[{"name":"id","required":true,"transform":{"type":"scalar"},"locs":[{"a":693,"b":696}]}],"statement":"SELECT\n  pes.id AS \"id\",\n  pes.profile_id AS \"profileId\",\n  pes.user_id AS \"userId\",\n  pes.provider_conversation_id AS \"providerConversationId\",\n  pes.status AS \"status\",\n  pes.progress_phase AS \"progressPhase\",\n  pes.prompt AS \"prompt\",\n  pes.selection_snapshot_id AS \"selectionSnapshotId\",\n  pes.result_version_id AS \"resultVersionId\",\n  pes.summary AS \"summary\",\n  pes.warnings::text AS \"warningsJson\",\n  pes.error AS \"error\",\n  pes.failed_html AS \"failedHtml\",\n  pes.failed_css AS \"failedCss\",\n  pes.failed_validation_message AS \"failedValidationMessage\",\n  pes.created_at::text AS \"createdAt\",\n  pes.updated_at::text AS \"updatedAt\"\nFROM vibespace.profile_edit_sessions pes\nWHERE pes.id = :id!"}`))

/**
 Runnable query:
 ```sql
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
  pes.failed_html AS "failedHtml",
  pes.failed_css AS "failedCss",
  pes.failed_validation_message AS "failedValidationMessage",
  pes.created_at::text AS "createdAt",
  pes.updated_at::text AS "updatedAt"
FROM vibespace.profile_edit_sessions pes
WHERE pes.id = $1
 ```

 */
@gentype
module GetProfileEditSessionById: {
  /** Returns an array of all matched results. */
  @gentype
  let many: (PgTyped.Pg.Client.t, getProfileEditSessionByIdParams) => promise<array<getProfileEditSessionByIdResult>>
  /** Returns exactly 1 result. Returns `None` if more or less than exactly 1 result is returned. */
  @gentype
  let one: (PgTyped.Pg.Client.t, getProfileEditSessionByIdParams) => promise<option<getProfileEditSessionByIdResult>>
  
  /** Returns exactly 1 result. Raises `Exn.t` (with an optionally provided `errorMessage`) if more or less than exactly 1 result is returned. */
  @gentype
  let expectOne: (
    PgTyped.Pg.Client.t,
    getProfileEditSessionByIdParams,
    ~errorMessage: string=?
  ) => promise<getProfileEditSessionByIdResult>

  /** Executes the query, but ignores whatever is returned by it. */
  @gentype
  let execute: (PgTyped.Pg.Client.t, getProfileEditSessionByIdParams) => promise<unit>
} = {
  @module("pgtyped-rescript-runtime") @new external getProfileEditSessionById: IR.t => PreparedStatement.t<getProfileEditSessionByIdParams, getProfileEditSessionByIdResult> = "PreparedQuery";
  let query = getProfileEditSessionById(getProfileEditSessionByIdIR)
  let query = (params, ~client) => query->PreparedStatement.run(params, ~client)

  @gentype
  let many = (client, params) => query(params, ~client)

  @gentype
  let one = async (client, params) => switch await query(params, ~client) {
  | [item] => Some(item)
  | _ => None
  }

  @gentype
  let expectOne = async (client, params, ~errorMessage=?) => switch await query(params, ~client) {
  | [item] => item
  | _ => panic(errorMessage->Option.getOr("More or less than one item was returned"))
  }

  @gentype
  let execute = async (client, params) => {
    let _ = await query(params, ~client)
  }
}

@gentype
@deprecated("Use 'GetProfileEditSessionById.many' directly instead")
let getProfileEditSessionById = (params, ~client) => GetProfileEditSessionById.many(client, params)


/** 'ListProfileEditSessionsForProfile' parameters type */
@gentype
type listProfileEditSessionsForProfileParams = {
  profileId: string,
}

/** 'ListProfileEditSessionsForProfile' return type */
@gentype
type listProfileEditSessionsForProfileResult = {
  createdAt: option<string>,
  error: option<string>,
  failedCss: option<string>,
  failedHtml: option<string>,
  failedValidationMessage: option<string>,
  id: string,
  profileId: string,
  progressPhase: string,
  prompt: string,
  providerConversationId: option<string>,
  resultVersionId: option<string>,
  selectionSnapshotId: option<string>,
  status: string,
  summary: string,
  updatedAt: option<string>,
  userId: string,
  warningsJson: option<string>,
}

/** 'ListProfileEditSessionsForProfile' query type */
@gentype
type listProfileEditSessionsForProfileQuery = {
  params: listProfileEditSessionsForProfileParams,
  result: listProfileEditSessionsForProfileResult,
}

%%private(let listProfileEditSessionsForProfileIR: IR.t = %raw(`{"usedParamSet":{"profileId":true},"params":[{"name":"profileId","required":true,"transform":{"type":"scalar"},"locs":[{"a":701,"b":711}]}],"statement":"SELECT\n  pes.id AS \"id\",\n  pes.profile_id AS \"profileId\",\n  pes.user_id AS \"userId\",\n  pes.provider_conversation_id AS \"providerConversationId\",\n  pes.status AS \"status\",\n  pes.progress_phase AS \"progressPhase\",\n  pes.prompt AS \"prompt\",\n  pes.selection_snapshot_id AS \"selectionSnapshotId\",\n  pes.result_version_id AS \"resultVersionId\",\n  pes.summary AS \"summary\",\n  pes.warnings::text AS \"warningsJson\",\n  pes.error AS \"error\",\n  pes.failed_html AS \"failedHtml\",\n  pes.failed_css AS \"failedCss\",\n  pes.failed_validation_message AS \"failedValidationMessage\",\n  pes.created_at::text AS \"createdAt\",\n  pes.updated_at::text AS \"updatedAt\"\nFROM vibespace.profile_edit_sessions pes\nWHERE pes.profile_id = :profileId!\nORDER BY pes.created_at DESC\nLIMIT 100"}`))

/**
 Runnable query:
 ```sql
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
  pes.failed_html AS "failedHtml",
  pes.failed_css AS "failedCss",
  pes.failed_validation_message AS "failedValidationMessage",
  pes.created_at::text AS "createdAt",
  pes.updated_at::text AS "updatedAt"
FROM vibespace.profile_edit_sessions pes
WHERE pes.profile_id = $1
ORDER BY pes.created_at DESC
LIMIT 100
 ```

 */
@gentype
module ListProfileEditSessionsForProfile: {
  /** Returns an array of all matched results. */
  @gentype
  let many: (PgTyped.Pg.Client.t, listProfileEditSessionsForProfileParams) => promise<array<listProfileEditSessionsForProfileResult>>
  /** Returns exactly 1 result. Returns `None` if more or less than exactly 1 result is returned. */
  @gentype
  let one: (PgTyped.Pg.Client.t, listProfileEditSessionsForProfileParams) => promise<option<listProfileEditSessionsForProfileResult>>
  
  /** Returns exactly 1 result. Raises `Exn.t` (with an optionally provided `errorMessage`) if more or less than exactly 1 result is returned. */
  @gentype
  let expectOne: (
    PgTyped.Pg.Client.t,
    listProfileEditSessionsForProfileParams,
    ~errorMessage: string=?
  ) => promise<listProfileEditSessionsForProfileResult>

  /** Executes the query, but ignores whatever is returned by it. */
  @gentype
  let execute: (PgTyped.Pg.Client.t, listProfileEditSessionsForProfileParams) => promise<unit>
} = {
  @module("pgtyped-rescript-runtime") @new external listProfileEditSessionsForProfile: IR.t => PreparedStatement.t<listProfileEditSessionsForProfileParams, listProfileEditSessionsForProfileResult> = "PreparedQuery";
  let query = listProfileEditSessionsForProfile(listProfileEditSessionsForProfileIR)
  let query = (params, ~client) => query->PreparedStatement.run(params, ~client)

  @gentype
  let many = (client, params) => query(params, ~client)

  @gentype
  let one = async (client, params) => switch await query(params, ~client) {
  | [item] => Some(item)
  | _ => None
  }

  @gentype
  let expectOne = async (client, params, ~errorMessage=?) => switch await query(params, ~client) {
  | [item] => item
  | _ => panic(errorMessage->Option.getOr("More or less than one item was returned"))
  }

  @gentype
  let execute = async (client, params) => {
    let _ = await query(params, ~client)
  }
}

@gentype
@deprecated("Use 'ListProfileEditSessionsForProfile.many' directly instead")
let listProfileEditSessionsForProfile = (params, ~client) => ListProfileEditSessionsForProfile.many(client, params)


/** 'CancelProfileEditSession' parameters type */
@gentype
type cancelProfileEditSessionParams = {
  id: string,
}

/** 'CancelProfileEditSession' return type */
@gentype
type cancelProfileEditSessionResult = {
  createdAt: option<string>,
  error: option<string>,
  failedCss: option<string>,
  failedHtml: option<string>,
  failedValidationMessage: option<string>,
  id: string,
  profileId: string,
  progressPhase: string,
  prompt: string,
  providerConversationId: option<string>,
  resultVersionId: option<string>,
  selectionSnapshotId: option<string>,
  status: string,
  summary: string,
  updatedAt: option<string>,
  userId: string,
  warningsJson: option<string>,
}

/** 'CancelProfileEditSession' query type */
@gentype
type cancelProfileEditSessionQuery = {
  params: cancelProfileEditSessionParams,
  result: cancelProfileEditSessionResult,
}

%%private(let cancelProfileEditSessionIR: IR.t = %raw(`{"usedParamSet":{"id":true},"params":[{"name":"id","required":true,"transform":{"type":"scalar"},"locs":[{"a":169,"b":172}]}],"statement":"UPDATE vibespace.profile_edit_sessions pes\nSET\n  status = 'canceled',\n  progress_phase = 'preparing',\n  error = 'Canceled by user.',\n  updated_at = now()\nWHERE pes.id = :id!\nRETURNING\n  pes.id AS \"id\",\n  pes.profile_id AS \"profileId\",\n  pes.user_id AS \"userId\",\n  pes.provider_conversation_id AS \"providerConversationId\",\n  pes.status AS \"status\",\n  pes.progress_phase AS \"progressPhase\",\n  pes.prompt AS \"prompt\",\n  pes.selection_snapshot_id AS \"selectionSnapshotId\",\n  pes.result_version_id AS \"resultVersionId\",\n  pes.summary AS \"summary\",\n  pes.warnings::text AS \"warningsJson\",\n  pes.error AS \"error\",\n  pes.failed_html AS \"failedHtml\",\n  pes.failed_css AS \"failedCss\",\n  pes.failed_validation_message AS \"failedValidationMessage\",\n  pes.created_at::text AS \"createdAt\",\n  pes.updated_at::text AS \"updatedAt\""}`))

/**
 Runnable query:
 ```sql
UPDATE vibespace.profile_edit_sessions pes
SET
  status = 'canceled',
  progress_phase = 'preparing',
  error = 'Canceled by user.',
  updated_at = now()
WHERE pes.id = $1
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
  pes.failed_html AS "failedHtml",
  pes.failed_css AS "failedCss",
  pes.failed_validation_message AS "failedValidationMessage",
  pes.created_at::text AS "createdAt",
  pes.updated_at::text AS "updatedAt"
 ```

 */
@gentype
module CancelProfileEditSession: {
  /** Returns an array of all matched results. */
  @gentype
  let many: (PgTyped.Pg.Client.t, cancelProfileEditSessionParams) => promise<array<cancelProfileEditSessionResult>>
  /** Returns exactly 1 result. Returns `None` if more or less than exactly 1 result is returned. */
  @gentype
  let one: (PgTyped.Pg.Client.t, cancelProfileEditSessionParams) => promise<option<cancelProfileEditSessionResult>>
  
  /** Returns exactly 1 result. Raises `Exn.t` (with an optionally provided `errorMessage`) if more or less than exactly 1 result is returned. */
  @gentype
  let expectOne: (
    PgTyped.Pg.Client.t,
    cancelProfileEditSessionParams,
    ~errorMessage: string=?
  ) => promise<cancelProfileEditSessionResult>

  /** Executes the query, but ignores whatever is returned by it. */
  @gentype
  let execute: (PgTyped.Pg.Client.t, cancelProfileEditSessionParams) => promise<unit>
} = {
  @module("pgtyped-rescript-runtime") @new external cancelProfileEditSession: IR.t => PreparedStatement.t<cancelProfileEditSessionParams, cancelProfileEditSessionResult> = "PreparedQuery";
  let query = cancelProfileEditSession(cancelProfileEditSessionIR)
  let query = (params, ~client) => query->PreparedStatement.run(params, ~client)

  @gentype
  let many = (client, params) => query(params, ~client)

  @gentype
  let one = async (client, params) => switch await query(params, ~client) {
  | [item] => Some(item)
  | _ => None
  }

  @gentype
  let expectOne = async (client, params, ~errorMessage=?) => switch await query(params, ~client) {
  | [item] => item
  | _ => panic(errorMessage->Option.getOr("More or less than one item was returned"))
  }

  @gentype
  let execute = async (client, params) => {
    let _ = await query(params, ~client)
  }
}

@gentype
@deprecated("Use 'CancelProfileEditSession.many' directly instead")
let cancelProfileEditSession = (params, ~client) => CancelProfileEditSession.many(client, params)


/** 'GetSelectionSnapshotById' parameters type */
@gentype
type getSelectionSnapshotByIdParams = {
  id: string,
}

/** 'GetSelectionSnapshotById' return type */
@gentype
type getSelectionSnapshotByIdResult = {
  agentContext: string,
  boundsJson: string,
  createdAt: option<string>,
  description: string,
  id: string,
  kind: string,
  label: string,
  nearestElementJson: option<string>,
  profileId: string,
  requestId: string,
  selectedElementsJson: option<string>,
  viewportJson: string,
}

/** 'GetSelectionSnapshotById' query type */
@gentype
type getSelectionSnapshotByIdQuery = {
  params: getSelectionSnapshotByIdParams,
  result: getSelectionSnapshotByIdResult,
}

%%private(let getSelectionSnapshotByIdIR: IR.t = %raw(`{"usedParamSet":{"id":true},"params":[{"name":"id","required":true,"transform":{"type":"scalar"},"locs":[{"a":474,"b":477}]}],"statement":"SELECT\n  ss.id AS \"id\",\n  ss.profile_id AS \"profileId\",\n  ss.request_id AS \"requestId\",\n  ss.kind AS \"kind\",\n  ss.label AS \"label\",\n  ss.description AS \"description\",\n  ss.agent_context AS \"agentContext\",\n  ss.bounds_json AS \"boundsJson\",\n  ss.viewport_json AS \"viewportJson\",\n  ss.nearest_element::text AS \"nearestElementJson\",\n  ss.selected_elements::text AS \"selectedElementsJson\",\n  ss.created_at::text AS \"createdAt\"\nFROM vibespace.selection_snapshots ss\nWHERE ss.id = :id!"}`))

/**
 Runnable query:
 ```sql
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
WHERE ss.id = $1
 ```

 */
@gentype
module GetSelectionSnapshotById: {
  /** Returns an array of all matched results. */
  @gentype
  let many: (PgTyped.Pg.Client.t, getSelectionSnapshotByIdParams) => promise<array<getSelectionSnapshotByIdResult>>
  /** Returns exactly 1 result. Returns `None` if more or less than exactly 1 result is returned. */
  @gentype
  let one: (PgTyped.Pg.Client.t, getSelectionSnapshotByIdParams) => promise<option<getSelectionSnapshotByIdResult>>
  
  /** Returns exactly 1 result. Raises `Exn.t` (with an optionally provided `errorMessage`) if more or less than exactly 1 result is returned. */
  @gentype
  let expectOne: (
    PgTyped.Pg.Client.t,
    getSelectionSnapshotByIdParams,
    ~errorMessage: string=?
  ) => promise<getSelectionSnapshotByIdResult>

  /** Executes the query, but ignores whatever is returned by it. */
  @gentype
  let execute: (PgTyped.Pg.Client.t, getSelectionSnapshotByIdParams) => promise<unit>
} = {
  @module("pgtyped-rescript-runtime") @new external getSelectionSnapshotById: IR.t => PreparedStatement.t<getSelectionSnapshotByIdParams, getSelectionSnapshotByIdResult> = "PreparedQuery";
  let query = getSelectionSnapshotById(getSelectionSnapshotByIdIR)
  let query = (params, ~client) => query->PreparedStatement.run(params, ~client)

  @gentype
  let many = (client, params) => query(params, ~client)

  @gentype
  let one = async (client, params) => switch await query(params, ~client) {
  | [item] => Some(item)
  | _ => None
  }

  @gentype
  let expectOne = async (client, params, ~errorMessage=?) => switch await query(params, ~client) {
  | [item] => item
  | _ => panic(errorMessage->Option.getOr("More or less than one item was returned"))
  }

  @gentype
  let execute = async (client, params) => {
    let _ = await query(params, ~client)
  }
}

@gentype
@deprecated("Use 'GetSelectionSnapshotById.many' directly instead")
let getSelectionSnapshotById = (params, ~client) => GetSelectionSnapshotById.many(client, params)


/** 'ListTrustedCapabilitiesForVersion' parameters type */
@gentype
type listTrustedCapabilitiesForVersionParams = {
  profileVersionId: string,
}

/** 'ListTrustedCapabilitiesForVersion' return type */
@gentype
type listTrustedCapabilitiesForVersionResult = {
  canonicalUrl: string,
  createdAt: option<string>,
  id: string,
  kind: string,
  metadataJson: string,
  origin: string,
  profileVersionId: string,
  source: string,
  validationStatus: string,
}

/** 'ListTrustedCapabilitiesForVersion' query type */
@gentype
type listTrustedCapabilitiesForVersionQuery = {
  params: listTrustedCapabilitiesForVersionParams,
  result: listTrustedCapabilitiesForVersionResult,
}

%%private(let listTrustedCapabilitiesForVersionIR: IR.t = %raw(`{"usedParamSet":{"profileVersionId":true},"params":[{"name":"profileVersionId","required":true,"transform":{"type":"scalar"},"locs":[{"a":390,"b":407}]}],"statement":"SELECT\n  tcr.id AS \"id\",\n  tcr.profile_version_id AS \"profileVersionId\",\n  tcr.kind AS \"kind\",\n  tcr.origin AS \"origin\",\n  tcr.source AS \"source\",\n  tcr.canonical_url AS \"canonicalUrl\",\n  tcr.metadata_json AS \"metadataJson\",\n  tcr.validation_status AS \"validationStatus\",\n  tcr.created_at::text AS \"createdAt\"\nFROM vibespace.trusted_capability_references tcr\nWHERE tcr.profile_version_id = :profileVersionId!\nORDER BY tcr.created_at ASC"}`))

/**
 Runnable query:
 ```sql
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
WHERE tcr.profile_version_id = $1
ORDER BY tcr.created_at ASC
 ```

 */
@gentype
module ListTrustedCapabilitiesForVersion: {
  /** Returns an array of all matched results. */
  @gentype
  let many: (PgTyped.Pg.Client.t, listTrustedCapabilitiesForVersionParams) => promise<array<listTrustedCapabilitiesForVersionResult>>
  /** Returns exactly 1 result. Returns `None` if more or less than exactly 1 result is returned. */
  @gentype
  let one: (PgTyped.Pg.Client.t, listTrustedCapabilitiesForVersionParams) => promise<option<listTrustedCapabilitiesForVersionResult>>
  
  /** Returns exactly 1 result. Raises `Exn.t` (with an optionally provided `errorMessage`) if more or less than exactly 1 result is returned. */
  @gentype
  let expectOne: (
    PgTyped.Pg.Client.t,
    listTrustedCapabilitiesForVersionParams,
    ~errorMessage: string=?
  ) => promise<listTrustedCapabilitiesForVersionResult>

  /** Executes the query, but ignores whatever is returned by it. */
  @gentype
  let execute: (PgTyped.Pg.Client.t, listTrustedCapabilitiesForVersionParams) => promise<unit>
} = {
  @module("pgtyped-rescript-runtime") @new external listTrustedCapabilitiesForVersion: IR.t => PreparedStatement.t<listTrustedCapabilitiesForVersionParams, listTrustedCapabilitiesForVersionResult> = "PreparedQuery";
  let query = listTrustedCapabilitiesForVersion(listTrustedCapabilitiesForVersionIR)
  let query = (params, ~client) => query->PreparedStatement.run(params, ~client)

  @gentype
  let many = (client, params) => query(params, ~client)

  @gentype
  let one = async (client, params) => switch await query(params, ~client) {
  | [item] => Some(item)
  | _ => None
  }

  @gentype
  let expectOne = async (client, params, ~errorMessage=?) => switch await query(params, ~client) {
  | [item] => item
  | _ => panic(errorMessage->Option.getOr("More or less than one item was returned"))
  }

  @gentype
  let execute = async (client, params) => {
    let _ = await query(params, ~client)
  }
}

@gentype
@deprecated("Use 'ListTrustedCapabilitiesForVersion.many' directly instead")
let listTrustedCapabilitiesForVersion = (params, ~client) => ListTrustedCapabilitiesForVersion.many(client, params)


/** 'GetTrustedCapabilityById' parameters type */
@gentype
type getTrustedCapabilityByIdParams = {
  id: string,
}

/** 'GetTrustedCapabilityById' return type */
@gentype
type getTrustedCapabilityByIdResult = {
  canonicalUrl: string,
  createdAt: option<string>,
  id: string,
  kind: string,
  metadataJson: string,
  origin: string,
  profileVersionId: string,
  source: string,
  validationStatus: string,
}

/** 'GetTrustedCapabilityById' query type */
@gentype
type getTrustedCapabilityByIdQuery = {
  params: getTrustedCapabilityByIdParams,
  result: getTrustedCapabilityByIdResult,
}

%%private(let getTrustedCapabilityByIdIR: IR.t = %raw(`{"usedParamSet":{"id":true},"params":[{"name":"id","required":true,"transform":{"type":"scalar"},"locs":[{"a":374,"b":377}]}],"statement":"SELECT\n  tcr.id AS \"id\",\n  tcr.profile_version_id AS \"profileVersionId\",\n  tcr.kind AS \"kind\",\n  tcr.origin AS \"origin\",\n  tcr.source AS \"source\",\n  tcr.canonical_url AS \"canonicalUrl\",\n  tcr.metadata_json AS \"metadataJson\",\n  tcr.validation_status AS \"validationStatus\",\n  tcr.created_at::text AS \"createdAt\"\nFROM vibespace.trusted_capability_references tcr\nWHERE tcr.id = :id!"}`))

/**
 Runnable query:
 ```sql
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
WHERE tcr.id = $1
 ```

 */
@gentype
module GetTrustedCapabilityById: {
  /** Returns an array of all matched results. */
  @gentype
  let many: (PgTyped.Pg.Client.t, getTrustedCapabilityByIdParams) => promise<array<getTrustedCapabilityByIdResult>>
  /** Returns exactly 1 result. Returns `None` if more or less than exactly 1 result is returned. */
  @gentype
  let one: (PgTyped.Pg.Client.t, getTrustedCapabilityByIdParams) => promise<option<getTrustedCapabilityByIdResult>>
  
  /** Returns exactly 1 result. Raises `Exn.t` (with an optionally provided `errorMessage`) if more or less than exactly 1 result is returned. */
  @gentype
  let expectOne: (
    PgTyped.Pg.Client.t,
    getTrustedCapabilityByIdParams,
    ~errorMessage: string=?
  ) => promise<getTrustedCapabilityByIdResult>

  /** Executes the query, but ignores whatever is returned by it. */
  @gentype
  let execute: (PgTyped.Pg.Client.t, getTrustedCapabilityByIdParams) => promise<unit>
} = {
  @module("pgtyped-rescript-runtime") @new external getTrustedCapabilityById: IR.t => PreparedStatement.t<getTrustedCapabilityByIdParams, getTrustedCapabilityByIdResult> = "PreparedQuery";
  let query = getTrustedCapabilityById(getTrustedCapabilityByIdIR)
  let query = (params, ~client) => query->PreparedStatement.run(params, ~client)

  @gentype
  let many = (client, params) => query(params, ~client)

  @gentype
  let one = async (client, params) => switch await query(params, ~client) {
  | [item] => Some(item)
  | _ => None
  }

  @gentype
  let expectOne = async (client, params, ~errorMessage=?) => switch await query(params, ~client) {
  | [item] => item
  | _ => panic(errorMessage->Option.getOr("More or less than one item was returned"))
  }

  @gentype
  let execute = async (client, params) => {
    let _ = await query(params, ~client)
  }
}

@gentype
@deprecated("Use 'GetTrustedCapabilityById.many' directly instead")
let getTrustedCapabilityById = (params, ~client) => GetTrustedCapabilityById.many(client, params)


/** 'GetAgentConversationSummaryForSession' parameters type */
@gentype
type getAgentConversationSummaryForSessionParams = {
  editSessionId: string,
}

/** 'GetAgentConversationSummaryForSession' return type */
@gentype
type getAgentConversationSummaryForSessionResult = {
  createdAt: option<string>,
  editSessionId: string,
  error: option<string>,
  id: string,
  model: option<string>,
  prompt: string,
  provider: string,
  providerConversationId: option<string>,
  resultVersionId: option<string>,
  selectionLabel: option<string>,
  selectionSnapshotId: option<string>,
  summary: string,
  warningsJson: option<string>,
}

/** 'GetAgentConversationSummaryForSession' query type */
@gentype
type getAgentConversationSummaryForSessionQuery = {
  params: getAgentConversationSummaryForSessionParams,
  result: getAgentConversationSummaryForSessionResult,
}

%%private(let getAgentConversationSummaryForSessionIR: IR.t = %raw(`{"usedParamSet":{"editSessionId":true},"params":[{"name":"editSessionId","required":true,"transform":{"type":"scalar"},"locs":[{"a":556,"b":570}]}],"statement":"SELECT\n  acs.id AS \"id\",\n  acs.edit_session_id AS \"editSessionId\",\n  acs.provider AS \"provider\",\n  acs.provider_conversation_id AS \"providerConversationId\",\n  acs.model AS \"model\",\n  acs.prompt AS \"prompt\",\n  acs.selection_label AS \"selectionLabel\",\n  acs.selection_snapshot_id AS \"selectionSnapshotId\",\n  acs.result_version_id AS \"resultVersionId\",\n  acs.summary AS \"summary\",\n  acs.warnings::text AS \"warningsJson\",\n  acs.error AS \"error\",\n  acs.created_at::text AS \"createdAt\"\nFROM vibespace.agent_conversation_summaries acs\nWHERE acs.edit_session_id = :editSessionId!\nORDER BY acs.created_at DESC\nLIMIT 1"}`))

/**
 Runnable query:
 ```sql
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
WHERE acs.edit_session_id = $1
ORDER BY acs.created_at DESC
LIMIT 1
 ```

 */
@gentype
module GetAgentConversationSummaryForSession: {
  /** Returns an array of all matched results. */
  @gentype
  let many: (PgTyped.Pg.Client.t, getAgentConversationSummaryForSessionParams) => promise<array<getAgentConversationSummaryForSessionResult>>
  /** Returns exactly 1 result. Returns `None` if more or less than exactly 1 result is returned. */
  @gentype
  let one: (PgTyped.Pg.Client.t, getAgentConversationSummaryForSessionParams) => promise<option<getAgentConversationSummaryForSessionResult>>
  
  /** Returns exactly 1 result. Raises `Exn.t` (with an optionally provided `errorMessage`) if more or less than exactly 1 result is returned. */
  @gentype
  let expectOne: (
    PgTyped.Pg.Client.t,
    getAgentConversationSummaryForSessionParams,
    ~errorMessage: string=?
  ) => promise<getAgentConversationSummaryForSessionResult>

  /** Executes the query, but ignores whatever is returned by it. */
  @gentype
  let execute: (PgTyped.Pg.Client.t, getAgentConversationSummaryForSessionParams) => promise<unit>
} = {
  @module("pgtyped-rescript-runtime") @new external getAgentConversationSummaryForSession: IR.t => PreparedStatement.t<getAgentConversationSummaryForSessionParams, getAgentConversationSummaryForSessionResult> = "PreparedQuery";
  let query = getAgentConversationSummaryForSession(getAgentConversationSummaryForSessionIR)
  let query = (params, ~client) => query->PreparedStatement.run(params, ~client)

  @gentype
  let many = (client, params) => query(params, ~client)

  @gentype
  let one = async (client, params) => switch await query(params, ~client) {
  | [item] => Some(item)
  | _ => None
  }

  @gentype
  let expectOne = async (client, params, ~errorMessage=?) => switch await query(params, ~client) {
  | [item] => item
  | _ => panic(errorMessage->Option.getOr("More or less than one item was returned"))
  }

  @gentype
  let execute = async (client, params) => {
    let _ = await query(params, ~client)
  }
}

@gentype
@deprecated("Use 'GetAgentConversationSummaryForSession.many' directly instead")
let getAgentConversationSummaryForSession = (params, ~client) => GetAgentConversationSummaryForSession.many(client, params)


/** 'GetAgentConversationSummaryById' parameters type */
@gentype
type getAgentConversationSummaryByIdParams = {
  id: string,
}

/** 'GetAgentConversationSummaryById' return type */
@gentype
type getAgentConversationSummaryByIdResult = {
  createdAt: option<string>,
  editSessionId: string,
  error: option<string>,
  id: string,
  model: option<string>,
  prompt: string,
  provider: string,
  providerConversationId: option<string>,
  resultVersionId: option<string>,
  selectionLabel: option<string>,
  selectionSnapshotId: option<string>,
  summary: string,
  warningsJson: option<string>,
}

/** 'GetAgentConversationSummaryById' query type */
@gentype
type getAgentConversationSummaryByIdQuery = {
  params: getAgentConversationSummaryByIdParams,
  result: getAgentConversationSummaryByIdResult,
}

%%private(let getAgentConversationSummaryByIdIR: IR.t = %raw(`{"usedParamSet":{"id":true},"params":[{"name":"id","required":true,"transform":{"type":"scalar"},"locs":[{"a":543,"b":546}]}],"statement":"SELECT\n  acs.id AS \"id\",\n  acs.edit_session_id AS \"editSessionId\",\n  acs.provider AS \"provider\",\n  acs.provider_conversation_id AS \"providerConversationId\",\n  acs.model AS \"model\",\n  acs.prompt AS \"prompt\",\n  acs.selection_label AS \"selectionLabel\",\n  acs.selection_snapshot_id AS \"selectionSnapshotId\",\n  acs.result_version_id AS \"resultVersionId\",\n  acs.summary AS \"summary\",\n  acs.warnings::text AS \"warningsJson\",\n  acs.error AS \"error\",\n  acs.created_at::text AS \"createdAt\"\nFROM vibespace.agent_conversation_summaries acs\nWHERE acs.id = :id!"}`))

/**
 Runnable query:
 ```sql
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
WHERE acs.id = $1
 ```

 */
@gentype
module GetAgentConversationSummaryById: {
  /** Returns an array of all matched results. */
  @gentype
  let many: (PgTyped.Pg.Client.t, getAgentConversationSummaryByIdParams) => promise<array<getAgentConversationSummaryByIdResult>>
  /** Returns exactly 1 result. Returns `None` if more or less than exactly 1 result is returned. */
  @gentype
  let one: (PgTyped.Pg.Client.t, getAgentConversationSummaryByIdParams) => promise<option<getAgentConversationSummaryByIdResult>>
  
  /** Returns exactly 1 result. Raises `Exn.t` (with an optionally provided `errorMessage`) if more or less than exactly 1 result is returned. */
  @gentype
  let expectOne: (
    PgTyped.Pg.Client.t,
    getAgentConversationSummaryByIdParams,
    ~errorMessage: string=?
  ) => promise<getAgentConversationSummaryByIdResult>

  /** Executes the query, but ignores whatever is returned by it. */
  @gentype
  let execute: (PgTyped.Pg.Client.t, getAgentConversationSummaryByIdParams) => promise<unit>
} = {
  @module("pgtyped-rescript-runtime") @new external getAgentConversationSummaryById: IR.t => PreparedStatement.t<getAgentConversationSummaryByIdParams, getAgentConversationSummaryByIdResult> = "PreparedQuery";
  let query = getAgentConversationSummaryById(getAgentConversationSummaryByIdIR)
  let query = (params, ~client) => query->PreparedStatement.run(params, ~client)

  @gentype
  let many = (client, params) => query(params, ~client)

  @gentype
  let one = async (client, params) => switch await query(params, ~client) {
  | [item] => Some(item)
  | _ => None
  }

  @gentype
  let expectOne = async (client, params, ~errorMessage=?) => switch await query(params, ~client) {
  | [item] => item
  | _ => panic(errorMessage->Option.getOr("More or less than one item was returned"))
  }

  @gentype
  let execute = async (client, params) => {
    let _ = await query(params, ~client)
  }
}

@gentype
@deprecated("Use 'GetAgentConversationSummaryById.many' directly instead")
let getAgentConversationSummaryById = (params, ~client) => GetAgentConversationSummaryById.many(client, params)


/** 'ListFriendActivityForUser' parameters type */
@gentype
type listFriendActivityForUserParams = {
  userId: string,
}

/** 'ListFriendActivityForUser' return type */
@gentype
type listFriendActivityForUserResult = {
  actorUserId: string,
  createdAt: option<string>,
  id: string,
  kind: string,
  profileId: string,
  profileVersionId: string,
  summary: string,
  title: string,
  visibility: string,
}

/** 'ListFriendActivityForUser' query type */
@gentype
type listFriendActivityForUserQuery = {
  params: listFriendActivityForUserParams,
  result: listFriendActivityForUserResult,
}

%%private(let listFriendActivityForUserIR: IR.t = %raw(`{"usedParamSet":{"userId":true},"params":[{"name":"userId","required":true,"transform":{"type":"scalar"},"locs":[{"a":478,"b":485},{"a":636,"b":643},{"a":710,"b":717}]}],"statement":"SELECT\n  pue.id AS \"id\",\n  pue.actor_user_id AS \"actorUserId\",\n  pue.profile_id AS \"profileId\",\n  pue.profile_version_id AS \"profileVersionId\",\n  pue.kind AS \"kind\",\n  pue.title AS \"title\",\n  pue.summary AS \"summary\",\n  pue.visibility AS \"visibility\",\n  pue.created_at::text AS \"createdAt\"\nFROM vibespace.profile_update_events pue\nJOIN vibespace.profiles p ON p.id = pue.profile_id\nWHERE pue.visibility = 'friends'\n  AND p.visibility <> 'disabled'\n  AND (\n    p.owner_user_id = :userId!\n    OR EXISTS (\n      SELECT 1\n      FROM vibespace.friend_connections fc\n      WHERE fc.status = 'accepted'\n        AND (\n          (fc.user_a_id = :userId! AND fc.user_b_id = p.owner_user_id)\n          OR (fc.user_b_id = :userId! AND fc.user_a_id = p.owner_user_id)\n        )\n    )\n  )\nORDER BY pue.created_at DESC\nLIMIT 100"}`))

/**
 Runnable query:
 ```sql
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
    p.owner_user_id = $1
    OR EXISTS (
      SELECT 1
      FROM vibespace.friend_connections fc
      WHERE fc.status = 'accepted'
        AND (
          (fc.user_a_id = $1 AND fc.user_b_id = p.owner_user_id)
          OR (fc.user_b_id = $1 AND fc.user_a_id = p.owner_user_id)
        )
    )
  )
ORDER BY pue.created_at DESC
LIMIT 100
 ```

 */
@gentype
module ListFriendActivityForUser: {
  /** Returns an array of all matched results. */
  @gentype
  let many: (PgTyped.Pg.Client.t, listFriendActivityForUserParams) => promise<array<listFriendActivityForUserResult>>
  /** Returns exactly 1 result. Returns `None` if more or less than exactly 1 result is returned. */
  @gentype
  let one: (PgTyped.Pg.Client.t, listFriendActivityForUserParams) => promise<option<listFriendActivityForUserResult>>
  
  /** Returns exactly 1 result. Raises `Exn.t` (with an optionally provided `errorMessage`) if more or less than exactly 1 result is returned. */
  @gentype
  let expectOne: (
    PgTyped.Pg.Client.t,
    listFriendActivityForUserParams,
    ~errorMessage: string=?
  ) => promise<listFriendActivityForUserResult>

  /** Executes the query, but ignores whatever is returned by it. */
  @gentype
  let execute: (PgTyped.Pg.Client.t, listFriendActivityForUserParams) => promise<unit>
} = {
  @module("pgtyped-rescript-runtime") @new external listFriendActivityForUser: IR.t => PreparedStatement.t<listFriendActivityForUserParams, listFriendActivityForUserResult> = "PreparedQuery";
  let query = listFriendActivityForUser(listFriendActivityForUserIR)
  let query = (params, ~client) => query->PreparedStatement.run(params, ~client)

  @gentype
  let many = (client, params) => query(params, ~client)

  @gentype
  let one = async (client, params) => switch await query(params, ~client) {
  | [item] => Some(item)
  | _ => None
  }

  @gentype
  let expectOne = async (client, params, ~errorMessage=?) => switch await query(params, ~client) {
  | [item] => item
  | _ => panic(errorMessage->Option.getOr("More or less than one item was returned"))
  }

  @gentype
  let execute = async (client, params) => {
    let _ = await query(params, ~client)
  }
}

@gentype
@deprecated("Use 'ListFriendActivityForUser.many' directly instead")
let listFriendActivityForUser = (params, ~client) => ListFriendActivityForUser.many(client, params)


/** 'ListInviteChainFriendsForUser' parameters type */
@gentype
type listInviteChainFriendsForUserParams = {
  ownerUserId: string,
}

/** 'ListInviteChainFriendsForUser' return type */
@gentype
type listInviteChainFriendsForUserResult = {
  createdAt: option<string>,
  displayName: string,
  handle: string,
  profileId: string,
  profileSlug: string,
  profileTitle: string,
  userId: string,
}

/** 'ListInviteChainFriendsForUser' query type */
@gentype
type listInviteChainFriendsForUserQuery = {
  params: listInviteChainFriendsForUserParams,
  result: listInviteChainFriendsForUserResult,
}

%%private(let listInviteChainFriendsForUserIR: IR.t = %raw(`{"usedParamSet":{"ownerUserId":true},"params":[{"name":"ownerUserId","required":true,"transform":{"type":"scalar"},"locs":[{"a":51,"b":63},{"a":937,"b":949}]}],"statement":"WITH RECURSIVE invite_chain(user_id) AS (\n  SELECT :ownerUserId!::uuid\n\n  UNION\n\n  SELECT next_link.user_id\n  FROM invite_chain chain\n  JOIN LATERAL (\n    SELECT child.id AS user_id\n    FROM vibespace.users child\n    WHERE child.invited_by_user_id = chain.user_id\n\n    UNION\n\n    SELECT parent.invited_by_user_id AS user_id\n    FROM vibespace.users parent\n    WHERE parent.id = chain.user_id\n      AND parent.invited_by_user_id IS NOT NULL\n  ) next_link ON true\n)\nSELECT\n  u.id AS \"userId\",\n  u.handle AS \"handle\",\n  u.display_name AS \"displayName\",\n  u.created_at::text AS \"createdAt\",\n  p.id AS \"profileId\",\n  p.slug AS \"profileSlug\",\n  p.title AS \"profileTitle\"\nFROM invite_chain chain\nJOIN vibespace.users u ON u.id = chain.user_id\nJOIN vibespace.profiles p ON p.owner_user_id = u.id\nJOIN vibespace.profile_versions current_version\n  ON current_version.id = p.current_version_id\n  AND current_version.profile_id = p.id\nWHERE u.id <> :ownerUserId!::uuid\n  AND u.status = 'enabled'\n  AND p.visibility = 'friends'\n  AND current_version.source <> 'import'\n  AND current_version.validation_status = 'valid'\nORDER BY u.created_at DESC, u.id DESC"}`))

/**
 Runnable query:
 ```sql
WITH RECURSIVE invite_chain(user_id) AS (
  SELECT $1::uuid

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
WHERE u.id <> $1::uuid
  AND u.status = 'enabled'
  AND p.visibility = 'friends'
  AND current_version.source <> 'import'
  AND current_version.validation_status = 'valid'
ORDER BY u.created_at DESC, u.id DESC
 ```

 */
@gentype
module ListInviteChainFriendsForUser: {
  /** Returns an array of all matched results. */
  @gentype
  let many: (PgTyped.Pg.Client.t, listInviteChainFriendsForUserParams) => promise<array<listInviteChainFriendsForUserResult>>
  /** Returns exactly 1 result. Returns `None` if more or less than exactly 1 result is returned. */
  @gentype
  let one: (PgTyped.Pg.Client.t, listInviteChainFriendsForUserParams) => promise<option<listInviteChainFriendsForUserResult>>
  
  /** Returns exactly 1 result. Raises `Exn.t` (with an optionally provided `errorMessage`) if more or less than exactly 1 result is returned. */
  @gentype
  let expectOne: (
    PgTyped.Pg.Client.t,
    listInviteChainFriendsForUserParams,
    ~errorMessage: string=?
  ) => promise<listInviteChainFriendsForUserResult>

  /** Executes the query, but ignores whatever is returned by it. */
  @gentype
  let execute: (PgTyped.Pg.Client.t, listInviteChainFriendsForUserParams) => promise<unit>
} = {
  @module("pgtyped-rescript-runtime") @new external listInviteChainFriendsForUser: IR.t => PreparedStatement.t<listInviteChainFriendsForUserParams, listInviteChainFriendsForUserResult> = "PreparedQuery";
  let query = listInviteChainFriendsForUser(listInviteChainFriendsForUserIR)
  let query = (params, ~client) => query->PreparedStatement.run(params, ~client)

  @gentype
  let many = (client, params) => query(params, ~client)

  @gentype
  let one = async (client, params) => switch await query(params, ~client) {
  | [item] => Some(item)
  | _ => None
  }

  @gentype
  let expectOne = async (client, params, ~errorMessage=?) => switch await query(params, ~client) {
  | [item] => item
  | _ => panic(errorMessage->Option.getOr("More or less than one item was returned"))
  }

  @gentype
  let execute = async (client, params) => {
    let _ = await query(params, ~client)
  }
}

@gentype
@deprecated("Use 'ListInviteChainFriendsForUser.many' directly instead")
let listInviteChainFriendsForUser = (params, ~client) => ListInviteChainFriendsForUser.many(client, params)


/** 'GetProfileUpdateEventById' parameters type */
@gentype
type getProfileUpdateEventByIdParams = {
  id: string,
}

/** 'GetProfileUpdateEventById' return type */
@gentype
type getProfileUpdateEventByIdResult = {
  actorUserId: string,
  createdAt: option<string>,
  id: string,
  kind: string,
  profileId: string,
  profileVersionId: string,
  summary: string,
  title: string,
  visibility: string,
}

/** 'GetProfileUpdateEventById' query type */
@gentype
type getProfileUpdateEventByIdQuery = {
  params: getProfileUpdateEventByIdParams,
  result: getProfileUpdateEventByIdResult,
}

%%private(let getProfileUpdateEventByIdIR: IR.t = %raw(`{"usedParamSet":{"id":true},"params":[{"name":"id","required":true,"transform":{"type":"scalar"},"locs":[{"a":346,"b":349}]}],"statement":"SELECT\n  pue.id AS \"id\",\n  pue.actor_user_id AS \"actorUserId\",\n  pue.profile_id AS \"profileId\",\n  pue.profile_version_id AS \"profileVersionId\",\n  pue.kind AS \"kind\",\n  pue.title AS \"title\",\n  pue.summary AS \"summary\",\n  pue.visibility AS \"visibility\",\n  pue.created_at::text AS \"createdAt\"\nFROM vibespace.profile_update_events pue\nWHERE pue.id = :id!"}`))

/**
 Runnable query:
 ```sql
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
WHERE pue.id = $1
 ```

 */
@gentype
module GetProfileUpdateEventById: {
  /** Returns an array of all matched results. */
  @gentype
  let many: (PgTyped.Pg.Client.t, getProfileUpdateEventByIdParams) => promise<array<getProfileUpdateEventByIdResult>>
  /** Returns exactly 1 result. Returns `None` if more or less than exactly 1 result is returned. */
  @gentype
  let one: (PgTyped.Pg.Client.t, getProfileUpdateEventByIdParams) => promise<option<getProfileUpdateEventByIdResult>>
  
  /** Returns exactly 1 result. Raises `Exn.t` (with an optionally provided `errorMessage`) if more or less than exactly 1 result is returned. */
  @gentype
  let expectOne: (
    PgTyped.Pg.Client.t,
    getProfileUpdateEventByIdParams,
    ~errorMessage: string=?
  ) => promise<getProfileUpdateEventByIdResult>

  /** Executes the query, but ignores whatever is returned by it. */
  @gentype
  let execute: (PgTyped.Pg.Client.t, getProfileUpdateEventByIdParams) => promise<unit>
} = {
  @module("pgtyped-rescript-runtime") @new external getProfileUpdateEventById: IR.t => PreparedStatement.t<getProfileUpdateEventByIdParams, getProfileUpdateEventByIdResult> = "PreparedQuery";
  let query = getProfileUpdateEventById(getProfileUpdateEventByIdIR)
  let query = (params, ~client) => query->PreparedStatement.run(params, ~client)

  @gentype
  let many = (client, params) => query(params, ~client)

  @gentype
  let one = async (client, params) => switch await query(params, ~client) {
  | [item] => Some(item)
  | _ => None
  }

  @gentype
  let expectOne = async (client, params, ~errorMessage=?) => switch await query(params, ~client) {
  | [item] => item
  | _ => panic(errorMessage->Option.getOr("More or less than one item was returned"))
  }

  @gentype
  let execute = async (client, params) => {
    let _ = await query(params, ~client)
  }
}

@gentype
@deprecated("Use 'GetProfileUpdateEventById.many' directly instead")
let getProfileUpdateEventById = (params, ~client) => GetProfileUpdateEventById.many(client, params)


