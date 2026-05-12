type decodedNodeId = {
  typename: Interface_node.ImplementedBy.t,
  internalId: ResGraph.id,
}

@val @scope("Promise") external promiseAll: array<promise<'a>> => promise<array<'a>> = "all"

// TODO: Switch readable "Type:internalId" values to ResGraph.Utils.Base64 before production.
let encodeGlobalId = (
  ~typename: Interface_node.ImplementedBy.t,
  ~internalId: ResGraph.id,
): ResGraph.id =>
  `${typename->Interface_node.ImplementedBy.toString}:${internalId->ResGraph.idToString}`
  ->ResGraph.id

let decodeGlobalId = (nodeId: ResGraph.id): option<decodedNodeId> =>
  switch nodeId->ResGraph.idToString->String.split(":") {
  | [typename, internalId] =>
    switch typename->Interface_node.ImplementedBy.decode {
    | Some(typename) => Some({typename, internalId: internalId->ResGraph.id})
    | None => None
    }
  | _ => None
  }

/** Relay global id for every type implementing Node. */
@gql.field
let id = (
  node: BackendSchema.node,
  ~typename: Interface_node.ImplementedBy.t,
): ResGraph.id => encodeGlobalId(~typename, ~internalId=node.id)

/** Current signed-in user id as a Relay global id. */
@gql.field
let currentUserId = (_: BackendSchema.query, ~ctx: ResGraphContext.context): ResGraph.id =>
  encodeGlobalId(
    ~typename=Interface_node.ImplementedBy.User,
    ~internalId=ctx->BackendSchema.currentUserIdFromContext->BackendSchema.internalIdFromMaybeGlobal,
  )

let nodeByDecodedId = async (
  ctx: ResGraphContext.context,
  decoded: decodedNodeId,
): option<Interface_node.Resolver.t> =>
  switch decoded.typename {
  | AgentConversationSummary =>
    switch await BackendSchema.loadConversationSummaryById(ctx, decoded.internalId) {
    | Some(summary) => Some(Interface_node.Resolver.AgentConversationSummary(summary))
    | None =>
      decoded.internalId
      ->BackendSchema.conversationSummaryById
      ->Option.map(summary => Interface_node.Resolver.AgentConversationSummary(summary))
    }
  | FriendConnection =>
    decoded.internalId
    ->BackendSchema.friendConnectionById
    ->Option.map(connection => Interface_node.Resolver.FriendConnection(connection))
  | Invite =>
    decoded.internalId
    ->BackendSchema.inviteById
    ->Option.map(invite => Interface_node.Resolver.Invite(invite))
  | Profile =>
    switch await BackendSchema.loadProfileById(ctx, decoded.internalId) {
    | Some(profile) => Some(Interface_node.Resolver.Profile(profile))
    | None =>
      decoded.internalId
      ->BackendSchema.profileById
      ->Option.map(profile => Interface_node.Resolver.Profile(profile))
    }
  | ProfileEditSession =>
    switch await BackendSchema.loadProfileEditSessionById(ctx, decoded.internalId) {
    | Some(session) => Some(Interface_node.Resolver.ProfileEditSession(session))
    | None =>
      decoded.internalId
      ->BackendSchema.profileEditSessionByRawId
      ->Option.map(session => Interface_node.Resolver.ProfileEditSession(session))
    }
  | ProfileUpdateEvent =>
    switch await BackendSchema.loadProfileUpdateEventById(ctx, decoded.internalId) {
    | Some(event) => Some(Interface_node.Resolver.ProfileUpdateEvent(event))
    | None =>
      decoded.internalId
      ->BackendSchema.profileUpdateEventById
      ->Option.map(event => Interface_node.Resolver.ProfileUpdateEvent(event))
    }
  | ProfileVersion =>
    switch await BackendSchema.loadProfileVersionById(ctx, decoded.internalId) {
    | Some(version) => Some(Interface_node.Resolver.ProfileVersion(version))
    | None =>
      decoded.internalId
      ->BackendSchema.profileVersionByRawId
      ->Option.map(version => Interface_node.Resolver.ProfileVersion(version))
    }
  | SelectionSnapshot =>
    switch await BackendSchema.loadSelectionSnapshotById(ctx, decoded.internalId) {
    | Some(snapshot) => Some(Interface_node.Resolver.SelectionSnapshot(snapshot))
    | None =>
      decoded.internalId
      ->BackendSchema.selectionSnapshotById
      ->Option.map(snapshot => Interface_node.Resolver.SelectionSnapshot(snapshot))
    }
  | TrustedCapabilityReference =>
    switch await BackendSchema.loadTrustedCapabilityById(ctx, decoded.internalId) {
    | Some(capability) => Some(Interface_node.Resolver.TrustedCapabilityReference(capability))
    | None =>
      decoded.internalId
      ->BackendSchema.trustedCapabilityById
      ->Option.map(capability => Interface_node.Resolver.TrustedCapabilityReference(capability))
    }
  | User =>
    switch await BackendSchema.loadUserById(ctx, decoded.internalId) {
    | Some(user) => Some(Interface_node.Resolver.User(user))
    | None =>
      decoded.internalId->BackendSchema.userById->Option.map(user => Interface_node.Resolver.User(user))
    }
  }

let nodeById = async (
  ctx: ResGraphContext.context,
  nodeId: ResGraph.id,
): option<Interface_node.Resolver.t> =>
  switch nodeId->decodeGlobalId {
  | Some(decoded) => await nodeByDecodedId(ctx, decoded)
  | None => None
  }

/** Relay global-object lookup over the DB-backed slice with fixture fallback. */
@gql.field
let node = async (
  _: BackendSchema.query,
  ~id: ResGraph.id,
  ~ctx: ResGraphContext.context,
): option<Interface_node.Resolver.t> =>
  await nodeById(ctx, id)

/** Relay batched global-object lookup over the DB-backed slice with fixture fallback. */
@gql.field
let nodes = async (
  _: BackendSchema.query,
  ~ids: array<ResGraph.id>,
  ~ctx: ResGraphContext.context,
): array<option<Interface_node.Resolver.t>> =>
  // Calling nodeById for every id in the same tick still allows request-scoped
  // DataLoaders to batch same-type DB lookups.
  await ids->Array.map(id => nodeById(ctx, id))->promiseAll
