@gql.type
type query

@gql.type
type mutation

@val @scope("process") external processEnv: Dict.t<string> = "env"

@gql.interface
type node = {id: ResGraph.id}

@gql.enum
type userStatus =
  | @as("ENABLED") UserStatusEnabled
  | @as("DISABLED") UserStatusDisabled

@gql.enum
type userRole =
  | @as("USER") UserRoleUser
  | @as("ADMIN") UserRoleAdmin

@gql.enum
type inviteStatus =
  | @as("AVAILABLE") InviteStatusAvailable
  | @as("REDEEMED") InviteStatusRedeemed
  | @as("REVOKED") InviteStatusRevoked
  | @as("EXPIRED") InviteStatusExpired

@gql.enum
type friendConnectionStatus =
  | @as("ACCEPTED") FriendConnectionStatusAccepted
  | @as("BLOCKED") FriendConnectionStatusBlocked

@gql.enum
type friendConnectionSource =
  | @as("INVITE") FriendConnectionSourceInvite
  | @as("MANUAL") FriendConnectionSourceManual

@gql.enum
type profileVisibility =
  | @as("FRIENDS") ProfileVisibilityFriends
  | @as("DISABLED") ProfileVisibilityDisabled

@gql.enum
type profileVersionSource =
  | @as("MANUAL") ProfileVersionSourceManual
  | @as("AGENT") ProfileVersionSourceAgent
  | @as("RESTORE") ProfileVersionSourceRestore
  | @as("IMPORT") ProfileVersionSourceImport

@gql.enum
type validationStatus =
  | @as("VALID") ValidationStatusValid
  | @as("INVALID") ValidationStatusInvalid

@gql.enum
type profileEditSessionStatus =
  | @as("DRAFT") EditSessionStatusDraft
  | @as("RUNNING") EditSessionStatusRunning
  | @as("APPLIED") EditSessionStatusApplied
  | @as("FAILED") EditSessionStatusFailed
  | @as("CANCELED") EditSessionStatusCanceled

@gql.enum
type editProgressPhase =
  | @as("PREPARING") EditProgressPreparing
  | @as("PLANNING") EditProgressPlanning
  | @as("CHECKING_WEB_CONTEXT") EditProgressCheckingWebContext
  | @as("EXTRACTING_ASSETS") EditProgressExtractingAssets
  | @as("GENERATING") EditProgressGenerating
  | @as("VALIDATING") EditProgressValidating
  | @as("REPAIRING") EditProgressRepairing
  | @as("APPLYING") EditProgressApplying

@gql.enum
type assistantEditMode =
  | @live @as("FAST") AssistantEditModeFast
  | @live @as("REASONING") AssistantEditModeReasoning

@gql.enum
type selectionSnapshotKind =
  | @as("NONE") SelectionSnapshotKindNone
  | @as("ELEMENT") SelectionSnapshotKindElement
  | @as("AREA") SelectionSnapshotKindArea

@gql.enum
type trustedCapabilityKind =
  | @as("TRUSTED_IMAGE") TrustedCapabilityKindImage
  | @as("TRUSTED_FRAME") TrustedCapabilityKindFrame

@gql.enum
type profileUpdateEventKind =
  | @as("PROFILE_PUBLISHED") ProfileUpdateEventKindProfilePublished
  | @as("PROFILE_RESTORED") ProfileUpdateEventKindProfileRestored

@gql.enum
type activityVisibility =
  | @as("FRIENDS") ActivityVisibilityFriends

@gql.type
type user = {
  ...node,
  @live @gql.field handle: string,
  @live @gql.field displayName: string,
  @live @gql.field status: userStatus,
  @live @gql.field role: userRole,
  @live @gql.field invitedByUserId: option<ResGraph.id>,
  @live @gql.field createdAt: string,
  @live @gql.field activatedAt: option<string>,
  @live @gql.field updatedAt: string,
}

@gql.type
type invite = {
  ...node,
  @live @gql.field code: option<string>,
  @live @gql.field codeHash: string,
  @live @gql.field inviterUserId: ResGraph.id,
  @live @gql.field inviteeUserId: option<ResGraph.id>,
  @live @gql.field status: inviteStatus,
  @live @gql.field createdAt: string,
  @live @gql.field redeemedAt: option<string>,
  @live @gql.field expiresAt: option<string>,
}

@gql.type
type friendConnection = {
  ...node,
  @live @gql.field userAId: ResGraph.id,
  @live @gql.field userBId: ResGraph.id,
  @live @gql.field status: friendConnectionStatus,
  @live @gql.field source: friendConnectionSource,
  @live @gql.field createdAt: string,
  @live @gql.field updatedAt: string,
}

@gql.type
type profile = {
  ...node,
  @live @gql.field ownerUserId: ResGraph.id,
  @live @gql.field slug: string,
  @live @gql.field title: string,
  @live @gql.field sendtag: option<string>,
  @live @gql.field visibility: profileVisibility,
  @live @gql.field currentVersionId: option<ResGraph.id>,
  @live @gql.field createdAt: string,
  @live @gql.field updatedAt: string,
  @live @gql.field publishedAt: option<string>,
  @live @gql.field disabledAt: option<string>,
  @live @gql.field disabledReason: option<string>,
}

@gql.type
type selectedElementMetadata = {
  @live @gql.field vibespaceId: string,
  @live @gql.field friendlyName: string,
  @live @gql.field friendlyDescription: string,
  @live @gql.field tagName: string,
  @live @gql.field text: string,
  @live @gql.field className: string,
  @live @gql.field selector: string,
  @live @gql.field boundsJson: string,
}

@gql.type
type selectionSnapshot = {
  ...node,
  @live @gql.field profileId: ResGraph.id,
  @live @gql.field requestId: string,
  @live @gql.field kind: selectionSnapshotKind,
  @live @gql.field label: string,
  @live @gql.field description: string,
  @live @gql.field agentContext: string,
  @live @gql.field boundsJson: string,
  @live @gql.field viewportJson: string,
  @live @gql.field nearestElement: option<selectedElementMetadata>,
  @live @gql.field selectedElements: array<selectedElementMetadata>,
  @live @gql.field createdAt: string,
}

@gql.type
type profileEditSession = {
  ...node,
  @live @gql.field profileId: ResGraph.id,
  @live @gql.field userId: ResGraph.id,
  @live @gql.field providerConversationId: option<string>,
  @live @gql.field status: profileEditSessionStatus,
  @live @gql.field progressPhase: editProgressPhase,
  @live @gql.field prompt: string,
  @live @gql.field selectionSnapshotId: option<ResGraph.id>,
  @live @gql.field resultVersionId: option<ResGraph.id>,
  @live @gql.field summary: string,
  @live @gql.field warnings: array<string>,
  @live @gql.field error: option<string>,
  @live @gql.field createdAt: string,
  @live @gql.field updatedAt: string,
}

@gql.type
type profileVersion = {
  ...node,
  @live @gql.field profileId: ResGraph.id,
  @live @gql.field revisionNumber: int,
  @live @gql.field parentVersionId: option<ResGraph.id>,
  @live @gql.field html: string,
  @live @gql.field css: string,
  @live @gql.field source: profileVersionSource,
  @live @gql.field promptSessionId: option<ResGraph.id>,
  @live @gql.field summary: string,
  @live @gql.field validationStatus: validationStatus,
  @live @gql.field validationErrors: array<string>,
  @live @gql.field createdByUserId: ResGraph.id,
  @live @gql.field createdAt: string,
}

@gql.type
type trustedCapabilityReference = {
  ...node,
  @live @gql.field profileVersionId: ResGraph.id,
  @live @gql.field kind: trustedCapabilityKind,
  @live @gql.field origin: string,
  @live @gql.field source: string,
  @live @gql.field canonicalUrl: string,
  @live @gql.field metadataJson: string,
  @live @gql.field validationStatus: validationStatus,
  @live @gql.field createdAt: string,
}

@gql.type
type agentConversationSummary = {
  ...node,
  @live @gql.field editSessionId: ResGraph.id,
  @live @gql.field provider: string,
  @live @gql.field providerConversationId: option<string>,
  @live @gql.field model: option<string>,
  @live @gql.field prompt: string,
  @live @gql.field selectionLabel: option<string>,
  @live @gql.field selectionSnapshotId: option<ResGraph.id>,
  @live @gql.field resultVersionId: option<ResGraph.id>,
  @live @gql.field summary: string,
  @live @gql.field warnings: array<string>,
  @live @gql.field error: option<string>,
  @live @gql.field createdAt: string,
}

@gql.type
type profileUpdateEvent = {
  ...node,
  @live @gql.field actorUserId: ResGraph.id,
  @live @gql.field profileId: ResGraph.id,
  @live @gql.field profileVersionId: ResGraph.id,
  @live @gql.field kind: profileUpdateEventKind,
  @live @gql.field title: string,
  @live @gql.field summary: string,
  @live @gql.field visibility: activityVisibility,
  @live @gql.field createdAt: string,
}

@gql.type
type inviteChainFriend = {
  @live @gql.field id: ResGraph.id,
  @live @gql.field userId: ResGraph.id,
  @live @gql.field handle: string,
  @live @gql.field displayName: string,
  @live @gql.field createdAt: string,
  @live @gql.field profileId: ResGraph.id,
  @live @gql.field profileSlug: string,
  @live @gql.field profileTitle: string,
  @live @gql.field avatarInitials: string,
  @live @gql.field avatarColor: string,
}

@gql.type
type profileVersionEdge = {
  @live @gql.field cursor: string,
  @live @gql.field node: option<profileVersion>,
}

@gql.type
type profileVersionConnection = {
  @live @gql.field pageInfo: ResGraph.Connections.pageInfo,
  @live @gql.field edges: option<array<option<profileVersionEdge>>>,
  @live @gql.field totalCount: int,
}

@gql.type
type profileEditSessionEdge = {
  @live @gql.field cursor: string,
  @live @gql.field node: option<profileEditSession>,
}

@gql.type
type profileEditSessionConnection = {
  @live @gql.field pageInfo: ResGraph.Connections.pageInfo,
  @live @gql.field edges: option<array<option<profileEditSessionEdge>>>,
  @live @gql.field totalCount: int,
}

@gql.type
type profileUpdateEventEdge = {
  @live @gql.field cursor: string,
  @live @gql.field node: option<profileUpdateEvent>,
}

@gql.type
type profileUpdateEventConnection = {
  @live @gql.field pageInfo: ResGraph.Connections.pageInfo,
  @live @gql.field edges: option<array<option<profileUpdateEventEdge>>>,
  @live @gql.field totalCount: int,
}

@gql.type
type inviteChainFriendEdge = {
  @live @gql.field cursor: string,
  @live @gql.field node: option<inviteChainFriend>,
}

@gql.type
type inviteChainFriendConnection = {
  @live @gql.field pageInfo: ResGraph.Connections.pageInfo,
  @live @gql.field edges: option<array<option<inviteChainFriendEdge>>>,
  @live @gql.field totalCount: int,
}

@gql.inputObject
type adminCreateSeedUserInput = {
  handle: string,
  displayName: string,
  role?: userRole,
}

@gql.inputObject
type adminCreateInviteInput = {inviterUserId: ResGraph.id}

@gql.inputObject
type redeemInviteInput = {
  code: string,
  displayName?: string,
}

@gql.inputObject
type saveManualProfileVersionInput = {
  profileId: ResGraph.id,
  html: string,
  css: string,
  summary?: string,
}

@gql.inputObject
type restoreProfileVersionInput = {
  profileId: ResGraph.id,
  versionId: ResGraph.id,
}

@gql.inputObject
type submitAgentEditInput = {
  profileId: ResGraph.id,
  currentVersionId?: ResGraph.id,
  prompt: string,
  selectionLabel?: string,
  selectionAgentContext?: string,
  selectedRegionScreenshotDataUrl?: string,
  fullPageScreenshotDataUrl?: string,
  referenceImageDataUrl?: string,
  previousFailedHtml?: string,
  previousFailedCss?: string,
  previousFailedSummary?: string,
  previousFailedWarnings?: string,
  previousFailedValidationMessage?: string,
  profileName?: string,
  sendtag?: string,
  mode?: assistantEditMode,
}

@gql.inputObject
type cancelProfileEditSessionInput = {editSessionId: ResGraph.id}

@gql.inputObject
type reactivateUsedInviteInput = {confirmDisable: bool}

@gql.inputObject
type disableUserInput = {
  userId: ResGraph.id,
}

@gql.inputObject
type disableProfileInput = {
  profileId: ResGraph.id,
  reason?: string,
}

/** The seed user and invite were created. */
@gql.type
type adminCreateSeedUserSucceeded = {
  @live @gql.field user: user,
  @live @gql.field invite: invite,
  @live @gql.field sessionToken: string,
  @live @gql.field warnings: array<string>,
}

/** The seed-user request did not pass validation. */
@gql.type
type adminCreateSeedUserValidationFailed = {
  @live @gql.field message: string,
  @live @gql.field fields: array<string>,
}

/** The configured persistence layer could not create the seed user. */
@gql.type
type adminCreateSeedUserUnavailable = {@live @gql.field message: string}

/** Result of creating a seed user from the admin GraphQL mutation. */
@gql.union
type adminCreateSeedUserResult =
  | Succeeded(adminCreateSeedUserSucceeded)
  | ValidationFailed(adminCreateSeedUserValidationFailed)
  | Unavailable(adminCreateSeedUserUnavailable)

type adminCreateSeedUserOutcome =
  | SeedUserCreated({user: user, invite: invite, sessionToken: string, warnings: array<string>})
  | SeedUserInvalid({message: string, fields: array<string>})
  | SeedUserPersistenceUnavailable({message: string})

let adminCreateSeedUserResultFromOutcome = (
  outcome: adminCreateSeedUserOutcome,
): adminCreateSeedUserResult =>
  switch outcome {
  | SeedUserCreated({user, invite, sessionToken, warnings}) =>
    Succeeded({user: user, invite: invite, sessionToken: sessionToken, warnings: warnings})
  | SeedUserInvalid({message, fields}) => ValidationFailed({message: message, fields: fields})
  | SeedUserPersistenceUnavailable({message}) => Unavailable({message: message})
  }

/** A mutation failed for an expected domain reason. */
@gql.type
type mutationFailed = {@live @gql.field message: string}

/** An invite was created by an admin action. */
@gql.type
type adminCreateInviteSucceeded = {@live @gql.field invite: invite}

/** A new user profile was created from an invite. */
@gql.type
type redeemInviteSucceeded = {
  @live @gql.field invite: invite,
  @live @gql.field user: user,
  @live @gql.field friendConnection: friendConnection,
  @live @gql.field profile: profile,
  @live @gql.field sessionToken: option<string>,
}

/** A used invite was made available again. */
@gql.type
type reactivateUsedInviteSucceeded = {
  @live @gql.field invite: invite,
  @live @gql.field user: user,
}

/** A profile version mutation persisted a new version. */
@gql.type
type profileVersionMutationSucceeded = {
  @live @gql.field profile: option<profile>,
  @live @gql.field profileVersion: profileVersion,
  @live @gql.field activityEvent: option<profileUpdateEvent>,
  @live @gql.field summary: string,
  @live @gql.field warnings: array<string>,
}

/** A profile version mutation failed before publishing a version. */
@gql.type
type profileVersionMutationFailed = {
  @live @gql.field profile: option<profile>,
  @live @gql.field summary: string,
  @live @gql.field validationErrors: array<string>,
  @live @gql.field message: string,
}

/** An edit-session mutation completed with a persisted session. */
@gql.type
type profileEditSessionMutationSucceeded = {
  @live @gql.field editSession: profileEditSession,
  @live @gql.field providerConversationId: option<string>,
  @live @gql.field resultVersionId: option<ResGraph.id>,
  @live @gql.field summary: string,
  @live @gql.field warnings: array<string>,
  @live @gql.field validationErrors: array<string>,
}

/** An edit-session mutation failed for an expected domain reason. */
@gql.type
type profileEditSessionMutationFailed = {
  @live @gql.field editSession: option<profileEditSession>,
  @live @gql.field providerConversationId: option<string>,
  @live @gql.field resultVersionId: option<ResGraph.id>,
  @live @gql.field summary: string,
  @live @gql.field warnings: array<string>,
  @live @gql.field validationErrors: array<string>,
  @live @gql.field message: string,
}

/** An admin disabled a user. */
@gql.type
type disableUserSucceeded = {@live @gql.field user: user}

/** An admin disabled a profile. */
@gql.type
type disableProfileSucceeded = {@live @gql.field profile: profile}

@gql.union
type adminCreateInviteResult =
  | AdminCreateInviteSucceeded(adminCreateInviteSucceeded)
  | AdminCreateInviteFailed(mutationFailed)

@gql.union
type redeemInviteResult =
  | RedeemInviteSucceeded(redeemInviteSucceeded)
  | RedeemInviteFailed(mutationFailed)

@gql.union
type reactivateUsedInviteResult =
  | ReactivateUsedInviteSucceeded(reactivateUsedInviteSucceeded)
  | ReactivateUsedInviteFailed(mutationFailed)

@gql.union
type saveManualProfileVersionResult =
  | SaveManualProfileVersionSucceeded(profileVersionMutationSucceeded)
  | SaveManualProfileVersionFailed(profileVersionMutationFailed)

@gql.union
type restoreProfileVersionResult =
  | RestoreProfileVersionSucceeded(profileVersionMutationSucceeded)
  | RestoreProfileVersionFailed(profileVersionMutationFailed)

@gql.union
type submitAgentEditResult =
  | SubmitAgentEditSucceeded(profileEditSessionMutationSucceeded)
  | SubmitAgentEditFailed(profileEditSessionMutationFailed)

@gql.union
type cancelProfileEditSessionResult =
  | CancelProfileEditSessionSucceeded(profileEditSessionMutationSucceeded)
  | CancelProfileEditSessionFailed(profileEditSessionMutationFailed)

@gql.union
type disableUserResult =
  | DisableUserSucceeded(disableUserSucceeded)
  | DisableUserFailed(mutationFailed)

@gql.union
type disableProfileResult =
  | DisableProfileSucceeded(disableProfileSucceeded)
  | DisableProfileFailed(mutationFailed)

let id = (raw: string): ResGraph.id => ResGraph.id(raw)
let idToString = (value: ResGraph.id): string => value->ResGraph.idToString

let internalIdFromMaybeGlobal = (value: ResGraph.id): ResGraph.id =>
  switch value->idToString->String.split(":") {
  | [_typename, internalId] => id(internalId)
  | _ => value
  }

let sameId = (left: ResGraph.id, right: ResGraph.id): bool =>
  idToString(internalIdFromMaybeGlobal(left)) == idToString(internalIdFromMaybeGlobal(right))

let createdAt = "2026-05-12T00:00:00.000Z"
let updatedAt = "2026-05-12T00:10:00.000Z"

let fixtureViewerId = id("fixture-viewer")
let fixtureFriendId = id("fixture-friend")
let fixtureInviteId = id("fixture-invite")
let fixtureFriendConnectionId = id("fixture-viewer-friend")
let fixtureProfileId = id("fixture-profile")
let fixtureFriendProfileId = id("fixture-friend-profile")
let fixtureVersion1Id = id("fixture-profile-v1")
let fixtureVersion2Id = id("fixture-profile-v2")
let fixtureFriendVersionId = id("fixture-friend-v1")
let fixtureSelectionId = id("fixture-selection")
let fixtureSessionId = id("fixture-session")
let fixtureCapabilityId = id("fixture-image")
let fixtureSummaryId = id("fixture-summary")
let fixtureActivityId = id("fixture-activity")

let fixtureHtml =
  "<main class=\"profile-page\" data-vibespace-id=\"profile-root\" data-vibespace-name=\"Whole Profile\" data-vibespace-description=\"The full customizable profile page\">\n" ++
  "  <section class=\"profile-intro\" data-vibespace-id=\"profile-intro\" data-vibespace-name=\"Intro Banner\" data-vibespace-description=\"Top profile area with image, title, and intro text\">\n" ++
  "    <div class=\"profile-photo\" data-vibespace-id=\"profile-photo\" data-vibespace-name=\"Profile Image\" data-vibespace-description=\"Square profile image placeholder\">\n" ++
  "      <span data-vibespace-id=\"profile-photo-initials\" data-vibespace-name=\"Profile Initials\" data-vibespace-description=\"Initials inside the profile image\">VS</span>\n" ++
  "    </div>\n" ++
  "    <div class=\"profile-copy\" data-vibespace-id=\"profile-copy\" data-vibespace-name=\"Intro Copy\" data-vibespace-description=\"Name and short profile description\">\n" ++
  "      <p class=\"profile-kicker\" data-vibespace-id=\"profile-kicker\" data-vibespace-name=\"Profile Link\" data-vibespace-description=\"Small label above the profile title\">vibespace.local/new</p>\n" ++
  "      <h1 data-vibespace-id=\"profile-title\" data-vibespace-name=\"Profile Title\" data-vibespace-description=\"Main name or profile headline\">Your profile page</h1>\n" ++
  "      <p class=\"profile-description\" data-vibespace-id=\"profile-description\" data-vibespace-name=\"Profile Description\" data-vibespace-description=\"Short intro paragraph for visitors\">A plain starting point for an agent-written profile. Select any area and describe the page you want.</p>\n" ++
  "    </div>\n" ++
  "  </section>\n" ++
  "  <section class=\"profile-sections\" data-vibespace-id=\"profile-sections\" data-vibespace-name=\"Profile Blocks\" data-vibespace-description=\"Grid of smaller editable profile sections\">\n" ++
  "    <article class=\"profile-section\" data-vibespace-id=\"about-section\" data-vibespace-name=\"About Card\" data-vibespace-description=\"Short bio or personal note card\">\n" ++
  "      <h2 data-vibespace-id=\"about-title\" data-vibespace-name=\"About Heading\" data-vibespace-description=\"Title for the about card\">About</h2>\n" ++
  "      <p data-vibespace-id=\"about-copy\" data-vibespace-name=\"About Text\" data-vibespace-description=\"Bio text inside the about card\">Write a short bio, a mood, a manifesto, or nothing at all.</p>\n" ++
  "    </article>\n" ++
  "    <article class=\"profile-section\" data-vibespace-id=\"links-section\" data-vibespace-name=\"Links Card\" data-vibespace-description=\"Small list of places or interests\">\n" ++
  "      <h2 data-vibespace-id=\"links-title\" data-vibespace-name=\"Links Heading\" data-vibespace-description=\"Title for the links card\">Links</h2>\n" ++
  "      <ul data-vibespace-id=\"links-list\" data-vibespace-name=\"Links List\" data-vibespace-description=\"List of profile links or interests\">\n" ++
  "        <li>website</li>\n" ++
  "        <li>shop</li>\n" ++
  "        <li>playlist</li>\n" ++
  "      </ul>\n" ++
  "    </article>\n" ++
  "    <article class=\"profile-section profile-section--wide\" data-vibespace-id=\"custom-section\" data-vibespace-name=\"Custom Zone\" data-vibespace-description=\"Wide section for a personal feature or experiment\">\n" ++
  "      <h2 data-vibespace-id=\"custom-title\" data-vibespace-name=\"Custom Heading\" data-vibespace-description=\"Title for the custom zone\">Custom zone</h2>\n" ++
  "      <p data-vibespace-id=\"custom-copy\" data-vibespace-name=\"Custom Text\" data-vibespace-description=\"Starter text for the custom zone\">This empty block is ready to become a shrine, flyer, portfolio, storefront teaser, or personal web page.</p>\n" ++
  "    </article>\n" ++
  "  </section>\n" ++
  "</main>"

let fixtureCss =
  ":root { color-scheme: light; }\n" ++
  "body { margin: 0; font-family: Inter, ui-sans-serif, system-ui, -apple-system, BlinkMacSystemFont, \"Segoe UI\", sans-serif; background: #ffffff; color: #111111; }\n" ++
  ".profile-page { min-height: 100vh; padding: 56px; background: #ffffff; }\n" ++
  ".profile-intro { max-width: 960px; margin: 0 auto; display: grid; grid-template-columns: 180px minmax(0, 1fr); gap: 36px; align-items: center; border: 1px solid #111111; padding: 28px; }\n" ++
  ".profile-photo { aspect-ratio: 1; border: 1px solid #111111; display: grid; place-items: center; background: repeating-linear-gradient(45deg, #ffffff 0 12px, #f4f4f4 12px 24px); }\n" ++
  ".profile-photo span { width: 86px; height: 86px; border: 1px solid #111111; display: grid; place-items: center; background: #ffffff; font-size: 28px; font-weight: 700; letter-spacing: 0; }\n" ++
  ".profile-kicker { margin: 0 0 10px; font-size: 12px; text-transform: uppercase; letter-spacing: .08em; }\n" ++
  "h1 { margin: 0; font-size: 54px; line-height: 1; letter-spacing: 0; }\n" ++
  ".profile-description { max-width: 620px; margin: 18px 0 0; font-size: 18px; line-height: 1.55; }\n" ++
  ".profile-sections { max-width: 960px; margin: 24px auto 0; display: grid; grid-template-columns: repeat(2, minmax(0, 1fr)); gap: 24px; }\n" ++
  ".profile-section { min-height: 180px; border: 1px solid #111111; padding: 24px; background: #ffffff; }\n" ++
  ".profile-section--wide { grid-column: 1 / -1; }\n" ++
  "h2 { margin: 0 0 12px; font-size: 18px; letter-spacing: 0; }\n" ++
  "p, li { font-size: 15px; line-height: 1.6; }\n" ++
  "ul { margin: 0; padding-left: 18px; }\n" ++
  "[data-vibespace-selected=\"true\"] { outline: 3px solid #111111 !important; outline-offset: 5px; }\n" ++
  "@media (max-width: 760px) { .profile-page { padding: 24px; } .profile-intro { grid-template-columns: 1fr; } .profile-photo { max-width: 220px; } h1 { font-size: 38px; } .profile-sections { grid-template-columns: 1fr; } }"

let fixtureViewer: user = {
  id: fixtureViewerId,
  handle: "vic",
  displayName: "Vic",
  status: UserStatusEnabled,
  role: UserRoleAdmin,
  invitedByUserId: None,
  createdAt,
  activatedAt: Some(createdAt),
  updatedAt,
}

let fixtureFriend: user = {
  id: fixtureFriendId,
  handle: "mira",
  displayName: "Mira",
  status: UserStatusEnabled,
  role: UserRoleUser,
  invitedByUserId: Some(fixtureViewerId),
  createdAt,
  activatedAt: Some(createdAt),
  updatedAt,
}

let fixtureUsers = [fixtureViewer, fixtureFriend]

let fixtureInvite: invite = {
  id: fixtureInviteId,
  code: Some("VIBE-ALPHA"),
  codeHash: "stubbed-hash-vibe-alpha",
  inviterUserId: fixtureViewerId,
  inviteeUserId: None,
  status: InviteStatusAvailable,
  createdAt,
  redeemedAt: None,
  expiresAt: None,
}

let fixtureFriendConnection: friendConnection = {
  id: fixtureFriendConnectionId,
  userAId: fixtureViewerId,
  userBId: fixtureFriendId,
  status: FriendConnectionStatusAccepted,
  source: FriendConnectionSourceInvite,
  createdAt,
  updatedAt,
}

let fixtureProfile: profile = {
  id: fixtureProfileId,
  ownerUserId: fixtureViewerId,
  slug: "vic",
  title: "Vic's Vibespace",
  sendtag: None,
  visibility: ProfileVisibilityFriends,
  currentVersionId: Some(fixtureVersion2Id),
  createdAt,
  updatedAt,
  publishedAt: Some(updatedAt),
  disabledAt: None,
  disabledReason: None,
}

let fixtureFriendProfile: profile = {
  id: fixtureFriendProfileId,
  ownerUserId: fixtureFriendId,
  slug: "mira",
  title: "Mira's Vibespace",
  sendtag: None,
  visibility: ProfileVisibilityFriends,
  currentVersionId: Some(fixtureFriendVersionId),
  createdAt,
  updatedAt,
  publishedAt: Some(updatedAt),
  disabledAt: None,
  disabledReason: None,
}

let fixtureProfiles = [fixtureProfile, fixtureFriendProfile]

let fixtureVersion1: profileVersion = {
  id: fixtureVersion1Id,
  profileId: fixtureProfileId,
  revisionNumber: 1,
  parentVersionId: None,
  html: fixtureHtml,
  css: fixtureCss,
  source: ProfileVersionSourceImport,
  promptSessionId: None,
  summary: "Imported starter profile.",
  validationStatus: ValidationStatusValid,
  validationErrors: [],
  createdByUserId: fixtureViewerId,
  createdAt,
}

let fixtureVersion2: profileVersion = {
  ...fixtureVersion1,
  id: fixtureVersion2Id,
  revisionNumber: 2,
  parentVersionId: Some(fixtureVersion1Id),
  source: ProfileVersionSourceAgent,
  promptSessionId: Some(fixtureSessionId),
  summary: "Agent-styled fixture profile.",
  createdAt: updatedAt,
}

let fixtureFriendVersion: profileVersion = {
  ...fixtureVersion1,
  id: fixtureFriendVersionId,
  profileId: fixtureFriendProfileId,
  createdByUserId: fixtureFriendId,
  summary: "Friend profile fixture.",
}

let fixtureProfileVersions = [fixtureVersion2, fixtureVersion1, fixtureFriendVersion]

let fixtureSelectedElement: selectedElementMetadata = {
  vibespaceId: "profile-title",
  friendlyName: "Profile Title",
  friendlyDescription: "Main profile headline",
  tagName: "h1",
  text: "Your profile page",
  className: "",
  selector: "[data-vibespace-id=\"profile-title\"]",
  boundsJson: "{\"x\":48,\"y\":48,\"width\":720,\"height\":96}",
}

let fixtureSelectionSnapshot: selectionSnapshot = {
  id: fixtureSelectionId,
  profileId: fixtureProfileId,
  requestId: "fixture-request",
  kind: SelectionSnapshotKindElement,
  label: "Profile Title",
  description: "Main profile headline",
  agentContext: "Selected profile part name: Profile Title description: Main profile headline",
  boundsJson: "{\"x\":48,\"y\":48,\"width\":720,\"height\":96}",
  viewportJson: "{\"width\":1440,\"height\":900}",
  nearestElement: Some(fixtureSelectedElement),
  selectedElements: [fixtureSelectedElement],
  createdAt,
}

let fixtureEditSession: profileEditSession = {
  id: fixtureSessionId,
  profileId: fixtureProfileId,
  userId: fixtureViewerId,
  providerConversationId: Some("stub-openai-conversation"),
  status: EditSessionStatusApplied,
  progressPhase: EditProgressApplying,
  prompt: "Make my starter profile feel more like Vibespace.",
  selectionSnapshotId: Some(fixtureSelectionId),
  resultVersionId: Some(fixtureVersion2Id),
  summary: "Applied a fixture agent edit.",
  warnings: [],
  error: None,
  createdAt,
  updatedAt,
}

let fixtureTrustedCapability: trustedCapabilityReference = {
  id: fixtureCapabilityId,
  profileVersionId: fixtureVersion2Id,
  kind: TrustedCapabilityKindImage,
  origin: "https://upload.wikimedia.org",
  source: "fixture resolver",
  canonicalUrl: "https://commons.wikimedia.org/",
  metadataJson: "{\"altText\":\"Fixture trusted image reference\"}",
  validationStatus: ValidationStatusValid,
  createdAt,
}

let fixtureConversationSummary: agentConversationSummary = {
  id: fixtureSummaryId,
  editSessionId: fixtureSessionId,
  provider: "openai",
  providerConversationId: Some("stub-openai-conversation"),
  model: Some("stub-model"),
  prompt: fixtureEditSession.prompt,
  selectionLabel: Some(fixtureSelectionSnapshot.label),
  selectionSnapshotId: Some(fixtureSelectionId),
  resultVersionId: Some(fixtureVersion2Id),
  summary: fixtureEditSession.summary,
  warnings: [],
  error: None,
  createdAt,
}

let fixtureActivity: profileUpdateEvent = {
  id: fixtureActivityId,
  actorUserId: fixtureViewerId,
  profileId: fixtureProfileId,
  profileVersionId: fixtureVersion2Id,
  kind: ProfileUpdateEventKindProfilePublished,
  title: "Vic updated their profile",
  summary: "Agent-styled fixture profile.",
  visibility: ActivityVisibilityFriends,
  createdAt: updatedAt,
}

let fixtureActivities = [fixtureActivity]
let fixtureInvites = [fixtureInvite]
let fixtureFriendConnections = [fixtureFriendConnection]
let fixtureSelectionSnapshots = [fixtureSelectionSnapshot]
let fixtureEditSessions = [fixtureEditSession]
let fixtureTrustedCapabilities = [fixtureTrustedCapability]
let fixtureConversationSummaries = [fixtureConversationSummary]

let findById = (items, needle: ResGraph.id, getId) =>
  items->Array.find(item => sameId(getId(item), needle))

let userById = (userId: ResGraph.id): option<user> =>
  findById(fixtureUsers, userId, (user: user) => user.id)
let profileById = (profileId: ResGraph.id): option<profile> =>
  findById(fixtureProfiles, profileId, (profile: profile) => profile.id)
let inviteById = (inviteId: ResGraph.id): option<invite> =>
  findById(fixtureInvites, inviteId, (invite: invite) => invite.id)
let friendConnectionById = (connectionId: ResGraph.id): option<friendConnection> =>
  findById(fixtureFriendConnections, connectionId, (connection: friendConnection) => connection.id)
let profileVersionByRawId = (versionId: ResGraph.id): option<profileVersion> =>
  findById(fixtureProfileVersions, versionId, version => version.id)
let selectionSnapshotById = (snapshotId: ResGraph.id): option<selectionSnapshot> =>
  findById(fixtureSelectionSnapshots, snapshotId, (snapshot: selectionSnapshot) => snapshot.id)
let profileEditSessionByRawId = (sessionId: ResGraph.id): option<profileEditSession> =>
  findById(fixtureEditSessions, sessionId, session => session.id)
let trustedCapabilityById = (
  capabilityId: ResGraph.id,
): option<trustedCapabilityReference> =>
  findById(
    fixtureTrustedCapabilities,
    capabilityId,
    (capability: trustedCapabilityReference) => capability.id,
  )
let conversationSummaryById = (summaryId: ResGraph.id): option<agentConversationSummary> =>
  findById(fixtureConversationSummaries, summaryId, (summary: agentConversationSummary) => summary.id)
let profileUpdateEventById = (eventId: ResGraph.id): option<profileUpdateEvent> =>
  findById(fixtureActivities, eventId, (event: profileUpdateEvent) => event.id)

let profileByOwnerId = (ownerUserId: ResGraph.id): option<profile> =>
  fixtureProfiles->Array.find(profile => sameId(profile.ownerUserId, ownerUserId))

let currentProfileVersion = (profile: profile): option<profileVersion> =>
  switch profile.currentVersionId {
  | None => None
  | Some(versionId) => profileVersionByRawId(versionId)
  }

let profileHasCompletedCurrentVersion = (profile: profile): bool =>
  switch profile->currentProfileVersion {
  | Some(version) =>
    switch (version.source, version.validationStatus) {
    | (ProfileVersionSourceImport, _) => false
    | (_, ValidationStatusValid) => true
    | (_, ValidationStatusInvalid) => false
    }
  | None => false
  }

let profileVersionsForProfile = (profileId: ResGraph.id): array<profileVersion> =>
  fixtureProfileVersions->Array.filter(version => sameId(version.profileId, profileId))

let profileEditSessionsForProfile = (profileId: ResGraph.id): array<profileEditSession> =>
  fixtureEditSessions->Array.filter(session => sameId(session.profileId, profileId))

let trustedCapabilitiesForVersion = (profileVersionId: ResGraph.id): array<trustedCapabilityReference> =>
  fixtureTrustedCapabilities->Array.filter(capability =>
    sameId(capability.profileVersionId, profileVersionId)
  )

let conversationSummaryForSession = (
  editSessionId: ResGraph.id,
): option<agentConversationSummary> =>
  fixtureConversationSummaries->Array.find(summary => sameId(summary.editSessionId, editSessionId))

let intMin = (left, right) => left < right ? left : right
let intMax = (left, right) => left > right ? left : right

let profileVersionCursor = (version: profileVersion): string =>
  "profile-version:" ++ version.revisionNumber->Int.toString ++ ":" ++ version.id->idToString

let profileVersionCursorIndex = (
  versions: array<profileVersion>,
  cursor: string,
): option<int> => {
  let found = ref(None)
  let versionCount = versions->Array.length

  if versionCount > 0 {
    for index in 0 to versionCount - 1 {
      switch found.contents {
      | Some(_) => ()
      | None =>
        switch versions->Array.get(index) {
        | Some(version) if version->profileVersionCursor == cursor =>
          found.contents = Some(index)
        | Some(_) | None => ()
        }
      }
    }
  }

  found.contents
}

let nonNegativeLimit = value =>
  switch value {
  | Some(value) => Some(value->intMax(0))
  | None => None
  }

let profileVersionConnectionFromArray = (
  versions: array<profileVersion>,
  ~first: option<int>,
  ~after: option<string>,
  ~before: option<string>,
  ~last: option<int>,
): profileVersionConnection => {
  let totalCount = versions->Array.length
  let startFromAfter = switch after->Option.flatMap(cursor =>
    profileVersionCursorIndex(versions, cursor)
  ) {
  | Some(index) => index + 1
  | None => 0
  }
  let endBefore = switch before->Option.flatMap(cursor =>
    profileVersionCursorIndex(versions, cursor)
  ) {
  | Some(index) => index
  | None => totalCount
  }
  let startIndex = startFromAfter->intMin(totalCount)
  let endIndex = endBefore->intMax(startIndex)->intMin(totalCount)
  let windowLength = endIndex - startIndex
  let firstLimitedEnd = switch first->nonNegativeLimit {
  | Some(limit) => startIndex + (limit->intMin(windowLength))
  | None => endIndex
  }
  let firstLimitedLength = firstLimitedEnd - startIndex
  let finalStart = switch last->nonNegativeLimit {
  | Some(limit) => firstLimitedEnd - (limit->intMin(firstLimitedLength))
  | None => startIndex
  }
  let finalEnd = firstLimitedEnd
  let page = versions->Array.slice(~start=finalStart, ~end=finalEnd)
  let pageLength = page->Array.length
  let cursorAt = index =>
    switch page->Array.get(index) {
    | Some(version) => Some(version->profileVersionCursor)
    | None => None
    }

  {
    pageInfo: {
      hasNextPage: finalEnd < totalCount,
      hasPreviousPage: finalStart > 0,
      startCursor: cursorAt(0),
      endCursor: cursorAt(pageLength - 1),
    },
    totalCount,
    edges: Some(page->Array.map(version =>
      Some({
        cursor: version->profileVersionCursor,
        node: Some(version),
      }: profileVersionEdge)
    )),
  }
}

let connectionFromSyntheticArray = (
  items,
  ~first: option<int>,
  ~after: option<string>,
  ~before: option<string>,
  ~last: option<int>,
  mapEdge,
  totalCount,
) => {
  let connection = items->ResGraph.Connections.connectionFromArray(
    ~args={first, after, before, last},
  )

  (
    connection.pageInfo,
    connection.edges->Option.map(edges =>
      edges->Array.map(edge => edge->Option.map(mapEdge))
    ),
    totalCount,
  )
}

let profileEditSessionConnectionFromArray = (
  sessions: array<profileEditSession>,
  ~first: option<int>,
  ~after: option<string>,
  ~before: option<string>,
  ~last: option<int>,
): profileEditSessionConnection => {
  let (pageInfo, edges, totalCount) = connectionFromSyntheticArray(
    sessions,
    ~first,
    ~after,
    ~before,
    ~last,
    edge => ({
      cursor: edge.cursor,
      node: edge.node,
    }: profileEditSessionEdge),
    sessions->Array.length,
  )

  {
    pageInfo,
    edges,
    totalCount,
  }
}

let profileUpdateEventConnectionFromArray = (
  events: array<profileUpdateEvent>,
  ~first: option<int>,
  ~after: option<string>,
  ~before: option<string>,
  ~last: option<int>,
): profileUpdateEventConnection => {
  let (pageInfo, edges, totalCount) = connectionFromSyntheticArray(
    events,
    ~first,
    ~after,
    ~before,
    ~last,
    edge => ({
      cursor: edge.cursor,
      node: edge.node,
    }: profileUpdateEventEdge),
    events->Array.length,
  )

  {
    pageInfo,
    edges,
    totalCount,
  }
}

let inviteChainFriendCursor = (friend: inviteChainFriend): string =>
  "invite-chain-friend:" ++ friend.createdAt ++ ":" ++ friend.userId->idToString

let inviteChainFriendCursorIndex = (
  friends: array<inviteChainFriend>,
  cursor: string,
): option<int> => {
  let found = ref(None)
  let friendCount = friends->Array.length

  if friendCount > 0 {
    for index in 0 to friendCount - 1 {
      switch found.contents {
      | Some(_) => ()
      | None =>
        switch friends->Array.get(index) {
        | Some(friend) if friend->inviteChainFriendCursor == cursor =>
          found.contents = Some(index)
        | Some(_) | None => ()
        }
      }
    }
  }

  found.contents
}

let inviteChainFriendConnectionFromArray = (
  friends: array<inviteChainFriend>,
  ~first: option<int>,
  ~after: option<string>,
  ~before: option<string>,
  ~last: option<int>,
): inviteChainFriendConnection => {
  let totalCount = friends->Array.length
  let startFromAfter = switch after->Option.flatMap(cursor =>
    inviteChainFriendCursorIndex(friends, cursor)
  ) {
  | Some(index) => index + 1
  | None => 0
  }
  let endBefore = switch before->Option.flatMap(cursor =>
    inviteChainFriendCursorIndex(friends, cursor)
  ) {
  | Some(index) => index
  | None => totalCount
  }
  let startIndex = startFromAfter->intMin(totalCount)
  let endIndex = endBefore->intMax(startIndex)->intMin(totalCount)
  let windowLength = endIndex - startIndex
  let firstLimitedEnd = switch first->nonNegativeLimit {
  | Some(limit) => startIndex + (limit->intMin(windowLength))
  | None => endIndex
  }
  let firstLimitedLength = firstLimitedEnd - startIndex
  let finalStart = switch last->nonNegativeLimit {
  | Some(limit) => firstLimitedEnd - (limit->intMin(firstLimitedLength))
  | None => startIndex
  }
  let finalEnd = firstLimitedEnd
  let page = friends->Array.slice(~start=finalStart, ~end=finalEnd)
  let pageLength = page->Array.length
  let cursorAt = index =>
    switch page->Array.get(index) {
    | Some(friend) => Some(friend->inviteChainFriendCursor)
    | None => None
    }

  {
    pageInfo: {
      hasNextPage: finalEnd < totalCount,
      hasPreviousPage: finalStart > 0,
      startCursor: cursorAt(0),
      endCursor: cursorAt(pageLength - 1),
    },
    totalCount,
    edges: Some(page->Array.map(friend =>
      Some({
        cursor: friend->inviteChainFriendCursor,
        node: Some(friend),
      }: inviteChainFriendEdge)
    )),
  }
}

module DbQueries = Profile_versions__sql

@module("./InviteCode.js") external inviteCodeNeedsRotation: string => bool =
  "inviteCodeNeedsRotation"

@module("./InviteCode.js") external insertRandomInviteForUserOnServer: (
  BackendDatabase.Client.t,
  string,
) => promise<Nullable.t<DbQueries.ensureInviteForUserResult>> = "insertRandomInviteForUser"

@module("./InviteCode.js") external rotateAvailableInviteCodeOnServer: (
  BackendDatabase.Client.t,
  string,
) => promise<Nullable.t<DbQueries.ensureInviteForUserResult>> = "rotateAvailableInviteCode"

type dbVersionMutationResult = {
  profile: option<profile>,
  profileVersion: profileVersion,
  activityEvent: option<profileUpdateEvent>,
}

type dbSeedUserResult = {
  user: user,
  invite: invite,
}

type dbRedeemInviteResult = {
  user: user,
  invite: invite,
  friendConnection: friendConnection,
  profile: profile,
}

type dbRedeemInviteOutcome =
  | InviteRedeemed(dbRedeemInviteResult)
  | InviteRedeemInvalid
  | InviteRedeemHandleTaken

type dbReactivateUsedInviteResult = {
  user: user,
  invite: invite,
}

type dbReactivateUsedInviteOutcome =
  | UsedInviteReactivated(dbReactivateUsedInviteResult)
  | UsedInviteNotFound
  | UsedInviteConfirmationMissing

type agentServiceInput = {
  @live databaseUrl: string,
  @live profileId: string,
  @live currentVersionId?: string,
  @live actorUserId: string,
  @live prompt: string,
  @live selectionLabel?: string,
  @live selectionAgentContext?: string,
  @live selectedRegionScreenshotDataUrl?: string,
  @live fullPageScreenshotDataUrl?: string,
  @live referenceImageDataUrl?: string,
  @live previousFailedHtml?: string,
  @live previousFailedCss?: string,
  @live previousFailedSummary?: string,
  @live previousFailedWarnings?: string,
  @live previousFailedValidationMessage?: string,
  @live profileName?: string,
  @live sendtag?: string,
  @live mode?: string,
}

type agentServiceProfileVersion = {
  id: string,
}

type agentServiceSession = {
  id: string,
  profileId: string,
  userId: string,
  providerConversationId: Nullable.t<string>,
  status: string,
  progressPhase: string,
  prompt: string,
  selectionSnapshotId: Nullable.t<string>,
  resultVersionId: Nullable.t<string>,
  summary: string,
  warnings: array<string>,
  error: Nullable.t<string>,
  createdAt: option<string>,
  updatedAt: option<string>,
}

type agentServiceResult = {
  ok: bool,
  summary: string,
  warnings: array<string>,
  validationErrors: array<string>,
  error: option<string>,
  providerConversationId: option<string>,
  session: option<agentServiceSession>,
  version: option<agentServiceProfileVersion>,
}

@module("./AgentEditService.js") external submitAgentEditOnServer: agentServiceInput => promise<
  agentServiceResult,
> = "submitAgentEdit"

@module("./SendProfileLookup.js")
external lookupSendAvatarUrl: string => promise<Nullable.t<string>> = "lookupSendAvatarUrl"

let optionJoin = value => value->Option.flatMap(value => value)

let idString = value => value->idToString
let rawDbIdString = (value: ResGraph.id): string => value->internalIdFromMaybeGlobal->idString
let fallbackCreatedAt = createdAt
let fallbackUpdatedAt = updatedAt

let stringOrDefault = (value, fallback) => value->Option.getOr(fallback)

let inviteCodeKey = code => code->String.trim

let avatarColorPalette = [
  "#0f172a",
  "#7f1d1d",
  "#854d0e",
  "#14532d",
  "#164e63",
  "#3730a3",
  "#701a75",
  "#831843",
]

let firstInitial = value => value->String.trim->String.slice(~start=0, ~end=1)->String.toUpperCase

let avatarInitialsForFriend = (~displayName: string, ~handle: string): string => {
  let trimmedName = displayName->String.trim
  let fallback = handle->firstInitial

  if trimmedName == "" {
    fallback == "" ? "VS" : fallback
  } else {
    let parts = trimmedName->String.split(" ")->Array.filter(part => part != "")
    switch (parts->Array.get(0), parts->Array.get(1)) {
    | (Some(first), Some(second)) =>
      let initials = first->firstInitial ++ second->firstInitial
      initials == "" ? fallback : initials
    | (Some(first), None) =>
      let initial = first->firstInitial
      initial == "" ? fallback : initial
    | _ => fallback == "" ? "VS" : fallback
    }
  }
}

let avatarColorForFriend = (~handle: string): string => {
  // TODO(profile-uploads): Replace fallback colors/initials with uploaded profile
  // picture metadata once profile image uploads exist.
  let paletteLength = avatarColorPalette->Array.length
  if paletteLength == 0 {
    "#0f172a"
  } else {
    let rec wrapIndex = index =>
      if index < paletteLength {
        index
      } else {
        wrapIndex(index - paletteLength)
      }
    let index = handle->String.length->wrapIndex
    avatarColorPalette->Array.get(index)->Option.getOr("#0f172a")
  }
}

let stringArrayFromJson = (rawJson: option<string>): array<string> =>
  switch rawJson {
  | None => []
  | Some(raw) =>
    try {
      switch raw->JSON.parseOrThrow->JSON.Decode.array {
      | Some(items) => items->Array.filterMap(JSON.Decode.string)
      | None => []
      }
    } catch {
    | _ => []
    }
  }

let jsonObject = value => value->JSON.Decode.object
let jsonField = (object, name) => object->Dict.get(name)

let jsonStringField = (object, name): string =>
  object->jsonField(name)->Option.flatMap(JSON.Decode.string)->Option.getOr("")

let selectedElementFromJson = value =>
  switch value->jsonObject {
  | None => None
  | Some(object) =>
    Some({
      vibespaceId: object->jsonStringField("vibespaceId"),
      friendlyName: object->jsonStringField("friendlyName"),
      friendlyDescription: object->jsonStringField("friendlyDescription"),
      tagName: object->jsonStringField("tagName"),
      text: object->jsonStringField("text"),
      className: object->jsonStringField("className"),
      selector: object->jsonStringField("selector"),
      boundsJson: object->jsonStringField("boundsJson"),
    })
  }

let selectedElementFromJsonString = raw =>
  try {
    raw->JSON.parseOrThrow->selectedElementFromJson
  } catch {
  | _ => None
  }

let selectedElementsFromJsonString = (rawJson: option<string>): array<selectedElementMetadata> =>
  switch rawJson {
  | None => []
  | Some(raw) =>
    try {
      switch raw->JSON.parseOrThrow->JSON.Decode.array {
      | Some(items) => items->Array.filterMap(selectedElementFromJson)
      | None => []
      }
    } catch {
    | _ => []
    }
  }

let userStatusFromDb = value =>
  switch value {
  | "disabled" => UserStatusDisabled
  | _ => UserStatusEnabled
  }

let userRoleFromDb = value =>
  switch value {
  | "admin" => UserRoleAdmin
  | _ => UserRoleUser
  }

let userRoleToDb = role =>
  switch role {
  | UserRoleAdmin => "admin"
  | UserRoleUser => "user"
  }

let inviteStatusFromDb = value =>
  switch value {
  | "redeemed" => InviteStatusRedeemed
  | "revoked" => InviteStatusRevoked
  | "expired" => InviteStatusExpired
  | _ => InviteStatusAvailable
  }

let friendConnectionStatusFromDb = value =>
  switch value {
  | "blocked" => FriendConnectionStatusBlocked
  | _ => FriendConnectionStatusAccepted
  }

let friendConnectionSourceFromDb = value =>
  switch value {
  | "manual" => FriendConnectionSourceManual
  | _ => FriendConnectionSourceInvite
  }

let profileVisibilityFromDb = value =>
  switch value {
  | "disabled" => ProfileVisibilityDisabled
  | _ => ProfileVisibilityFriends
  }

let profileVersionSourceFromDb = value =>
  switch value {
  | "agent" => ProfileVersionSourceAgent
  | "restore" => ProfileVersionSourceRestore
  | "import" => ProfileVersionSourceImport
  | _ => ProfileVersionSourceManual
  }

let validationStatusFromDb = value =>
  switch value {
  | "invalid" => ValidationStatusInvalid
  | _ => ValidationStatusValid
  }

let selectionSnapshotKindFromDb = value =>
  switch value {
  | "element" => SelectionSnapshotKindElement
  | "area" => SelectionSnapshotKindArea
  | _ => SelectionSnapshotKindNone
  }

let profileEditSessionStatusFromDb = value =>
  switch value {
  | "running" => EditSessionStatusRunning
  | "applied" => EditSessionStatusApplied
  | "failed" => EditSessionStatusFailed
  | "canceled" => EditSessionStatusCanceled
  | _ => EditSessionStatusDraft
  }

let editProgressPhaseFromDb = value =>
  switch value {
  | "planning" => EditProgressPlanning
  | "checking_web_context" => EditProgressCheckingWebContext
  | "extracting_assets" => EditProgressExtractingAssets
  | "generating" => EditProgressGenerating
  | "validating" => EditProgressValidating
  | "repairing" => EditProgressRepairing
  | "applying" => EditProgressApplying
  | _ => EditProgressPreparing
  }

let assistantEditModeToWire = mode =>
  switch mode {
  | AssistantEditModeReasoning => "reasoning"
  | AssistantEditModeFast => "fast"
  }

let trustedCapabilityKindFromDb = value =>
  switch value {
  | "trusted_frame" => TrustedCapabilityKindFrame
  | _ => TrustedCapabilityKindImage
  }

let profileUpdateEventKindFromDb = value =>
  switch value {
  | "profile_restored" => ProfileUpdateEventKindProfileRestored
  | _ => ProfileUpdateEventKindProfilePublished
  }

let profileUpdateEventKindToDb = kind =>
  switch kind {
  | ProfileUpdateEventKindProfileRestored => "profile_restored"
  | ProfileUpdateEventKindProfilePublished => "profile_published"
  }

let activityVisibilityFromDb = _value => ActivityVisibilityFriends

let userFromDbFields = (
  ~id: string,
  ~handle: string,
  ~displayName: string,
  ~status: string,
  ~role: string,
  ~invitedByUserId: option<string>,
  ~createdAt: option<string>,
  ~activatedAt: option<string>,
  ~updatedAt: option<string>,
): user => {
  id: id->ResGraph.id,
  handle,
  displayName,
  status: status->userStatusFromDb,
  role: role->userRoleFromDb,
  invitedByUserId: invitedByUserId->Option.map(ResGraph.id),
  createdAt: createdAt->stringOrDefault(fallbackCreatedAt),
  activatedAt,
  updatedAt: updatedAt->stringOrDefault(fallbackUpdatedAt),
}

let userFromGetUsersByIds = (row: DbQueries.getUsersByIdsResult): user =>
  userFromDbFields(
    ~id=row.id,
    ~handle=row.handle,
    ~displayName=row.displayName,
    ~status=row.status,
    ~role=row.role,
    ~invitedByUserId=row.invitedByUserId,
    ~createdAt=row.createdAt,
    ~activatedAt=row.activatedAt,
    ~updatedAt=row.updatedAt,
  )

let userFromGetUserByHandle = (row: DbQueries.getUserByHandleResult): user =>
  userFromDbFields(
    ~id=row.id,
    ~handle=row.handle,
    ~displayName=row.displayName,
    ~status=row.status,
    ~role=row.role,
    ~invitedByUserId=row.invitedByUserId,
    ~createdAt=row.createdAt,
    ~activatedAt=row.activatedAt,
    ~updatedAt=row.updatedAt,
  )

let userFromUpsertSeedUser = (row: DbQueries.upsertSeedUserResult): user =>
  userFromDbFields(
    ~id=row.id,
    ~handle=row.handle,
    ~displayName=row.displayName,
    ~status=row.status,
    ~role=row.role,
    ~invitedByUserId=row.invitedByUserId,
    ~createdAt=row.createdAt,
    ~activatedAt=row.activatedAt,
    ~updatedAt=row.updatedAt,
  )

let userFromInsertInviteeUser = (row: DbQueries.insertInviteeUserWithNumericHandleResult): user =>
  userFromDbFields(
    ~id=row.id,
    ~handle=row.handle,
    ~displayName=row.displayName,
    ~status=row.status,
    ~role=row.role,
    ~invitedByUserId=row.invitedByUserId,
    ~createdAt=row.createdAt,
    ~activatedAt=row.activatedAt,
    ~updatedAt=row.updatedAt,
  )

let inviteFromEnsureInvite = (row: DbQueries.ensureInviteForUserResult): invite => {
  id: row.id->ResGraph.id,
  code: Some(row.codeHash),
  codeHash: row.codeHash,
  inviterUserId: row.inviterUserId->ResGraph.id,
  inviteeUserId: row.inviteeUserId->Option.map(ResGraph.id),
  status: row.status->inviteStatusFromDb,
  createdAt: row.createdAt->stringOrDefault(createdAt),
  redeemedAt: row.redeemedAt,
  expiresAt: row.expiresAt,
}

let inviteFromGetAvailableInvite = (row: DbQueries.getAvailableInviteForUserResult): invite => {
  id: row.id->ResGraph.id,
  code: Some(row.codeHash),
  codeHash: row.codeHash,
  inviterUserId: row.inviterUserId->ResGraph.id,
  inviteeUserId: row.inviteeUserId->Option.map(ResGraph.id),
  status: row.status->inviteStatusFromDb,
  createdAt: row.createdAt->stringOrDefault(createdAt),
  redeemedAt: row.redeemedAt,
  expiresAt: row.expiresAt,
}

let inviteFromGetUsedInvite = (row: DbQueries.getUsedInviteForUserResult): invite => {
  id: row.id->ResGraph.id,
  code: Some(row.codeHash),
  codeHash: row.codeHash,
  inviterUserId: row.inviterUserId->ResGraph.id,
  inviteeUserId: row.inviteeUserId->Option.map(ResGraph.id),
  status: row.status->inviteStatusFromDb,
  createdAt: row.createdAt->stringOrDefault(createdAt),
  redeemedAt: row.redeemedAt,
  expiresAt: row.expiresAt,
}

let inviteFromGetByCode = (row: DbQueries.getInviteByCodeResult): invite => {
  id: row.id->ResGraph.id,
  code: Some(row.codeHash),
  codeHash: row.codeHash,
  inviterUserId: row.inviterUserId->ResGraph.id,
  inviteeUserId: row.inviteeUserId->Option.map(ResGraph.id),
  status: row.status->inviteStatusFromDb,
  createdAt: row.createdAt->stringOrDefault(createdAt),
  redeemedAt: row.redeemedAt,
  expiresAt: row.expiresAt,
}

let inviteFromAvailableByCode = (
  row: DbQueries.getAvailableInviteByCodeForUpdateResult,
): invite => {
  id: row.id->ResGraph.id,
  code: Some(row.codeHash),
  codeHash: row.codeHash,
  inviterUserId: row.inviterUserId->ResGraph.id,
  inviteeUserId: row.inviteeUserId->Option.map(ResGraph.id),
  status: row.status->inviteStatusFromDb,
  createdAt: row.createdAt->stringOrDefault(createdAt),
  redeemedAt: row.redeemedAt,
  expiresAt: row.expiresAt,
}

let inviteFromRedeemById = (row: DbQueries.redeemInviteByIdResult): invite => {
  id: row.id->ResGraph.id,
  code: Some(row.codeHash),
  codeHash: row.codeHash,
  inviterUserId: row.inviterUserId->ResGraph.id,
  inviteeUserId: row.inviteeUserId->Option.map(ResGraph.id),
  status: row.status->inviteStatusFromDb,
  createdAt: row.createdAt->stringOrDefault(createdAt),
  redeemedAt: row.redeemedAt,
  expiresAt: row.expiresAt,
}

let userFromReactivateUsedInvite = (
  row: DbQueries.reactivateUsedInviteForUserResult,
): user =>
  userFromDbFields(
    ~id=row.userId,
    ~handle=row.userHandle,
    ~displayName=row.userDisplayName,
    ~status=row.userStatus,
    ~role=row.userRole,
    ~invitedByUserId=row.userInvitedByUserId,
    ~createdAt=row.userCreatedAt,
    ~activatedAt=row.userActivatedAt,
    ~updatedAt=row.userUpdatedAt,
  )

let inviteFromReactivateUsedInvite = (
  row: DbQueries.reactivateUsedInviteForUserResult,
): invite => {
  id: row.inviteId->ResGraph.id,
  code: Some(row.inviteCodeHash),
  codeHash: row.inviteCodeHash,
  inviterUserId: row.inviteInviterUserId->ResGraph.id,
  inviteeUserId: row.inviteInviteeUserId->Option.map(ResGraph.id),
  status: row.inviteStatus->inviteStatusFromDb,
  createdAt: row.inviteCreatedAt->stringOrDefault(createdAt),
  redeemedAt: row.inviteRedeemedAt,
  expiresAt: row.inviteExpiresAt,
}

let rotateInviteCodeIfPredictable = async (
  client: BackendDatabase.Client.t,
  invite: invite,
): option<invite> =>
  switch invite.code {
  | Some(code) if code->inviteCodeNeedsRotation =>
    switch (await rotateAvailableInviteCodeOnServer(client, invite.id->idString))->Nullable.toOption {
    | Some(row) => Some(row->inviteFromEnsureInvite)
    | None => Some(invite)
    }
  | Some(_) | None => Some(invite)
  }

let insertRandomInviteForUser = async (
  client: BackendDatabase.Client.t,
  inviterUserId: string,
): option<invite> => {
  (await insertRandomInviteForUserOnServer(client, inviterUserId))
  ->Nullable.toOption
  ->Option.map(inviteFromEnsureInvite)
}

let ensureRandomAvailableInviteForUser = async (
  client: BackendDatabase.Client.t,
  inviterUserId: string,
): option<invite> =>
  switch await DbQueries.GetAvailableInviteForUser.one(client, {userId: inviterUserId}) {
  | Some(row) => await rotateInviteCodeIfPredictable(client, row->inviteFromGetAvailableInvite)
  | None => await insertRandomInviteForUser(client, inviterUserId)
  }

let friendConnectionFromEnsureInvite = (
  row: DbQueries.ensureInviteFriendConnectionResult,
): friendConnection => {
  id: row.id->ResGraph.id,
  userAId: row.userAId->ResGraph.id,
  userBId: row.userBId->ResGraph.id,
  status: row.status->friendConnectionStatusFromDb,
  source: row.source->friendConnectionSourceFromDb,
  createdAt: row.createdAt->stringOrDefault(createdAt),
  updatedAt: row.updatedAt->stringOrDefault(updatedAt),
}

let profileFromDbFields = (
  ~id: string,
  ~ownerUserId: string,
  ~slug: string,
  ~title: string,
  ~sendtag: option<string>,
  ~visibility: string,
  ~currentVersionId: option<string>,
  ~createdAt: option<string>,
  ~updatedAt: option<string>,
  ~publishedAt: option<string>,
  ~disabledAt: option<string>,
  ~disabledReason: option<string>,
): profile => {
  id: id->ResGraph.id,
  ownerUserId: ownerUserId->ResGraph.id,
  slug,
  title,
  sendtag,
  visibility: visibility->profileVisibilityFromDb,
  currentVersionId: currentVersionId->Option.map(ResGraph.id),
  createdAt: createdAt->stringOrDefault(fallbackCreatedAt),
  updatedAt: updatedAt->stringOrDefault(fallbackUpdatedAt),
  publishedAt,
  disabledAt,
  disabledReason,
}

let profileFromGetProfileById = (row: DbQueries.getProfileByIdResult): profile =>
  profileFromDbFields(
    ~id=row.id,
    ~ownerUserId=row.ownerUserId,
    ~slug=row.slug,
    ~title=row.title,
    ~sendtag=row.sendtag,
    ~visibility=row.visibility,
    ~currentVersionId=row.currentVersionId,
    ~createdAt=row.createdAt,
    ~updatedAt=row.updatedAt,
    ~publishedAt=row.publishedAt,
    ~disabledAt=row.disabledAt,
    ~disabledReason=row.disabledReason,
  )

let profileFromGetProfilesByIds = (row: DbQueries.getProfilesByIdsResult): profile =>
  profileFromDbFields(
    ~id=row.id,
    ~ownerUserId=row.ownerUserId,
    ~slug=row.slug,
    ~title=row.title,
    ~sendtag=row.sendtag,
    ~visibility=row.visibility,
    ~currentVersionId=row.currentVersionId,
    ~createdAt=row.createdAt,
    ~updatedAt=row.updatedAt,
    ~publishedAt=row.publishedAt,
    ~disabledAt=row.disabledAt,
    ~disabledReason=row.disabledReason,
  )

let profileFromGetProfilesByOwnerIds = (row: DbQueries.getProfilesByOwnerIdsResult): profile =>
  profileFromDbFields(
    ~id=row.id,
    ~ownerUserId=row.ownerUserId,
    ~slug=row.slug,
    ~title=row.title,
    ~sendtag=row.sendtag,
    ~visibility=row.visibility,
    ~currentVersionId=row.currentVersionId,
    ~createdAt=row.createdAt,
    ~updatedAt=row.updatedAt,
    ~publishedAt=row.publishedAt,
    ~disabledAt=row.disabledAt,
    ~disabledReason=row.disabledReason,
  )

let profileFromGetProfileBySlug = (row: DbQueries.getProfileBySlugResult): profile =>
  profileFromDbFields(
    ~id=row.id,
    ~ownerUserId=row.ownerUserId,
    ~slug=row.slug,
    ~title=row.title,
    ~sendtag=row.sendtag,
    ~visibility=row.visibility,
    ~currentVersionId=row.currentVersionId,
    ~createdAt=row.createdAt,
    ~updatedAt=row.updatedAt,
    ~publishedAt=row.publishedAt,
    ~disabledAt=row.disabledAt,
    ~disabledReason=row.disabledReason,
  )

let profileFromEnsureProfile = (row: DbQueries.ensureProfileForUserResult): profile =>
  profileFromDbFields(
    ~id=row.id,
    ~ownerUserId=row.ownerUserId,
    ~slug=row.slug,
    ~title=row.title,
    ~sendtag=row.sendtag,
    ~visibility=row.visibility,
    ~currentVersionId=row.currentVersionId,
    ~createdAt=row.createdAt,
    ~updatedAt=row.updatedAt,
    ~publishedAt=row.publishedAt,
    ~disabledAt=row.disabledAt,
    ~disabledReason=row.disabledReason,
  )

let profileVersionFromDbFields = (
  ~id: string,
  ~profileId: string,
  ~revisionNumber: int,
  ~parentVersionId: option<string>,
  ~html: string,
  ~css: string,
  ~source: string,
  ~promptSessionId: option<string>,
  ~summary: string,
  ~validationStatus: string,
  ~validationErrorsJson: option<string>,
  ~createdByUserId: string,
  ~createdAt: option<string>,
): profileVersion => {
  id: id->ResGraph.id,
  profileId: profileId->ResGraph.id,
  revisionNumber,
  parentVersionId: parentVersionId->Option.map(ResGraph.id),
  html,
  css,
  source: source->profileVersionSourceFromDb,
  promptSessionId: promptSessionId->Option.map(ResGraph.id),
  summary,
  validationStatus: validationStatus->validationStatusFromDb,
  validationErrors: validationErrorsJson->stringArrayFromJson,
  createdByUserId: createdByUserId->ResGraph.id,
  createdAt: createdAt->stringOrDefault(fallbackUpdatedAt),
}

let profileVersionFromGetByIds = (row: DbQueries.getProfileVersionsByIdsResult): profileVersion =>
  profileVersionFromDbFields(
    ~id=row.id,
    ~profileId=row.profileId,
    ~revisionNumber=row.revisionNumber,
    ~parentVersionId=row.parentVersionId,
    ~html=row.html,
    ~css=row.css,
    ~source=row.source,
    ~promptSessionId=row.promptSessionId,
    ~summary=row.summary,
    ~validationStatus=row.validationStatus,
    ~validationErrorsJson=row.validationErrorsJson,
    ~createdByUserId=row.createdByUserId,
    ~createdAt=row.createdAt,
  )

let profileVersionFromCurrentByProfileIds = (
  row: DbQueries.getCurrentProfileVersionsByProfileIdsResult,
): profileVersion =>
  profileVersionFromDbFields(
    ~id=row.id,
    ~profileId=row.profileId,
    ~revisionNumber=row.revisionNumber,
    ~parentVersionId=row.parentVersionId,
    ~html=row.html,
    ~css=row.css,
    ~source=row.source,
    ~promptSessionId=row.promptSessionId,
    ~summary=row.summary,
    ~validationStatus=row.validationStatus,
    ~validationErrorsJson=row.validationErrorsJson,
    ~createdByUserId=row.createdByUserId,
    ~createdAt=row.createdAt,
  )

let profileVersionFromList = (row: DbQueries.listProfileVersionsForProfileResult): profileVersion =>
  profileVersionFromDbFields(
    ~id=row.id,
    ~profileId=row.profileId,
    ~revisionNumber=row.revisionNumber,
    ~parentVersionId=row.parentVersionId,
    ~html=row.html,
    ~css=row.css,
    ~source=row.source,
    ~promptSessionId=row.promptSessionId,
    ~summary=row.summary,
    ~validationStatus=row.validationStatus,
    ~validationErrorsJson=row.validationErrorsJson,
    ~createdByUserId=row.createdByUserId,
    ~createdAt=row.createdAt,
  )

let profileVersionFromInsertManual = (
  row: DbQueries.insertManualProfileVersionResult,
): profileVersion =>
  profileVersionFromDbFields(
    ~id=row.id,
    ~profileId=row.profileId,
    ~revisionNumber=row.revisionNumber,
    ~parentVersionId=row.parentVersionId,
    ~html=row.html,
    ~css=row.css,
    ~source=row.source,
    ~promptSessionId=row.promptSessionId,
    ~summary=row.summary,
    ~validationStatus=row.validationStatus,
    ~validationErrorsJson=row.validationErrorsJson,
    ~createdByUserId=row.createdByUserId,
    ~createdAt=row.createdAt,
  )

let profileVersionFromRestore = (row: DbQueries.restoreProfileVersionResult): profileVersion =>
  profileVersionFromDbFields(
    ~id=row.id,
    ~profileId=row.profileId,
    ~revisionNumber=row.revisionNumber,
    ~parentVersionId=row.parentVersionId,
    ~html=row.html,
    ~css=row.css,
    ~source=row.source,
    ~promptSessionId=row.promptSessionId,
    ~summary=row.summary,
    ~validationStatus=row.validationStatus,
    ~validationErrorsJson=row.validationErrorsJson,
    ~createdByUserId=row.createdByUserId,
    ~createdAt=row.createdAt,
  )

let profileEditSessionFromFields = (
  ~id: string,
  ~profileId: string,
  ~userId: string,
  ~providerConversationId: option<string>,
  ~status: string,
  ~progressPhase: string,
  ~prompt: string,
  ~selectionSnapshotId: option<string>,
  ~resultVersionId: option<string>,
  ~summary: string,
  ~warnings: array<string>,
  ~error: option<string>,
  ~createdAt: option<string>,
  ~updatedAt: option<string>,
): profileEditSession => {
  id: id->ResGraph.id,
  profileId: profileId->ResGraph.id,
  userId: userId->ResGraph.id,
  providerConversationId,
  status: status->profileEditSessionStatusFromDb,
  progressPhase: progressPhase->editProgressPhaseFromDb,
  prompt,
  selectionSnapshotId: selectionSnapshotId->Option.map(ResGraph.id),
  resultVersionId: resultVersionId->Option.map(ResGraph.id),
  summary,
  warnings,
  error,
  createdAt: createdAt->stringOrDefault(fallbackUpdatedAt),
  updatedAt: updatedAt->stringOrDefault(fallbackUpdatedAt),
}

let profileEditSessionFromDbFields = (
  ~id: string,
  ~profileId: string,
  ~userId: string,
  ~providerConversationId: option<string>,
  ~status: string,
  ~progressPhase: string,
  ~prompt: string,
  ~selectionSnapshotId: option<string>,
  ~resultVersionId: option<string>,
  ~summary: string,
  ~warningsJson: option<string>,
  ~error: option<string>,
  ~createdAt: option<string>,
  ~updatedAt: option<string>,
): profileEditSession =>
  profileEditSessionFromFields(
    ~id,
    ~profileId,
    ~userId,
    ~providerConversationId,
    ~status,
    ~progressPhase,
    ~prompt,
    ~selectionSnapshotId,
    ~resultVersionId,
    ~summary,
    ~warnings=warningsJson->stringArrayFromJson,
    ~error,
    ~createdAt,
    ~updatedAt,
  )

let profileEditSessionFromAgentService = (row: agentServiceSession): profileEditSession =>
  profileEditSessionFromFields(
    ~id=row.id,
    ~profileId=row.profileId,
    ~userId=row.userId,
    ~providerConversationId=row.providerConversationId->Nullable.toOption,
    ~status=row.status,
    ~progressPhase=row.progressPhase,
    ~prompt=row.prompt,
    ~selectionSnapshotId=row.selectionSnapshotId->Nullable.toOption,
    ~resultVersionId=row.resultVersionId->Nullable.toOption,
    ~summary=row.summary,
    ~warnings=row.warnings,
    ~error=row.error->Nullable.toOption,
    ~createdAt=row.createdAt,
    ~updatedAt=row.updatedAt,
  )

let profileEditSessionFromGetById = (
  row: DbQueries.getProfileEditSessionByIdResult,
): profileEditSession =>
  profileEditSessionFromDbFields(
    ~id=row.id,
    ~profileId=row.profileId,
    ~userId=row.userId,
    ~providerConversationId=row.providerConversationId,
    ~status=row.status,
    ~progressPhase=row.progressPhase,
    ~prompt=row.prompt,
    ~selectionSnapshotId=row.selectionSnapshotId,
    ~resultVersionId=row.resultVersionId,
    ~summary=row.summary,
    ~warningsJson=row.warningsJson,
    ~error=row.error,
    ~createdAt=row.createdAt,
    ~updatedAt=row.updatedAt,
  )

let profileEditSessionFromList = (
  row: DbQueries.listProfileEditSessionsForProfileResult,
): profileEditSession =>
  profileEditSessionFromDbFields(
    ~id=row.id,
    ~profileId=row.profileId,
    ~userId=row.userId,
    ~providerConversationId=row.providerConversationId,
    ~status=row.status,
    ~progressPhase=row.progressPhase,
    ~prompt=row.prompt,
    ~selectionSnapshotId=row.selectionSnapshotId,
    ~resultVersionId=row.resultVersionId,
    ~summary=row.summary,
    ~warningsJson=row.warningsJson,
    ~error=row.error,
    ~createdAt=row.createdAt,
    ~updatedAt=row.updatedAt,
  )

let profileEditSessionFromCancel = (
  row: DbQueries.cancelProfileEditSessionResult,
): profileEditSession =>
  profileEditSessionFromDbFields(
    ~id=row.id,
    ~profileId=row.profileId,
    ~userId=row.userId,
    ~providerConversationId=row.providerConversationId,
    ~status=row.status,
    ~progressPhase=row.progressPhase,
    ~prompt=row.prompt,
    ~selectionSnapshotId=row.selectionSnapshotId,
    ~resultVersionId=row.resultVersionId,
    ~summary=row.summary,
    ~warningsJson=row.warningsJson,
    ~error=row.error,
    ~createdAt=row.createdAt,
    ~updatedAt=row.updatedAt,
  )

let selectionSnapshotFromGetById = (row: DbQueries.getSelectionSnapshotByIdResult): selectionSnapshot => {
  id: row.id->ResGraph.id,
  profileId: row.profileId->ResGraph.id,
  requestId: row.requestId,
  kind: row.kind->selectionSnapshotKindFromDb,
  label: row.label,
  description: row.description,
  agentContext: row.agentContext,
  boundsJson: row.boundsJson,
  viewportJson: row.viewportJson,
  nearestElement: row.nearestElementJson->Option.flatMap(selectedElementFromJsonString),
  selectedElements: row.selectedElementsJson->selectedElementsFromJsonString,
  createdAt: row.createdAt->stringOrDefault(fallbackCreatedAt),
}

let trustedCapabilityFromDbFields = (
  ~id: string,
  ~profileVersionId: string,
  ~kind: string,
  ~origin: string,
  ~source: string,
  ~canonicalUrl: string,
  ~metadataJson: string,
  ~validationStatus: string,
  ~createdAt: option<string>,
): trustedCapabilityReference => {
  id: id->ResGraph.id,
  profileVersionId: profileVersionId->ResGraph.id,
  kind: kind->trustedCapabilityKindFromDb,
  origin,
  source,
  canonicalUrl,
  metadataJson,
  validationStatus: validationStatus->validationStatusFromDb,
  createdAt: createdAt->stringOrDefault(fallbackCreatedAt),
}

let trustedCapabilityFromList = (
  row: DbQueries.listTrustedCapabilitiesForVersionResult,
): trustedCapabilityReference =>
  trustedCapabilityFromDbFields(
    ~id=row.id,
    ~profileVersionId=row.profileVersionId,
    ~kind=row.kind,
    ~origin=row.origin,
    ~source=row.source,
    ~canonicalUrl=row.canonicalUrl,
    ~metadataJson=row.metadataJson,
    ~validationStatus=row.validationStatus,
    ~createdAt=row.createdAt,
  )

let trustedCapabilityFromGetById = (
  row: DbQueries.getTrustedCapabilityByIdResult,
): trustedCapabilityReference =>
  trustedCapabilityFromDbFields(
    ~id=row.id,
    ~profileVersionId=row.profileVersionId,
    ~kind=row.kind,
    ~origin=row.origin,
    ~source=row.source,
    ~canonicalUrl=row.canonicalUrl,
    ~metadataJson=row.metadataJson,
    ~validationStatus=row.validationStatus,
    ~createdAt=row.createdAt,
  )

let agentConversationSummaryFromDbFields = (
  ~id: string,
  ~editSessionId: string,
  ~provider: string,
  ~providerConversationId: option<string>,
  ~model: option<string>,
  ~prompt: string,
  ~selectionLabel: option<string>,
  ~selectionSnapshotId: option<string>,
  ~resultVersionId: option<string>,
  ~summary: string,
  ~warningsJson: option<string>,
  ~error: option<string>,
  ~createdAt: option<string>,
): agentConversationSummary => {
  id: id->ResGraph.id,
  editSessionId: editSessionId->ResGraph.id,
  provider,
  providerConversationId,
  model,
  prompt,
  selectionLabel,
  selectionSnapshotId: selectionSnapshotId->Option.map(ResGraph.id),
  resultVersionId: resultVersionId->Option.map(ResGraph.id),
  summary,
  warnings: warningsJson->stringArrayFromJson,
  error,
  createdAt: createdAt->stringOrDefault(fallbackCreatedAt),
}

let agentConversationSummaryFromSession = (
  row: DbQueries.getAgentConversationSummaryForSessionResult,
): agentConversationSummary =>
  agentConversationSummaryFromDbFields(
    ~id=row.id,
    ~editSessionId=row.editSessionId,
    ~provider=row.provider,
    ~providerConversationId=row.providerConversationId,
    ~model=row.model,
    ~prompt=row.prompt,
    ~selectionLabel=row.selectionLabel,
    ~selectionSnapshotId=row.selectionSnapshotId,
    ~resultVersionId=row.resultVersionId,
    ~summary=row.summary,
    ~warningsJson=row.warningsJson,
    ~error=row.error,
    ~createdAt=row.createdAt,
  )

let agentConversationSummaryFromGetById = (
  row: DbQueries.getAgentConversationSummaryByIdResult,
): agentConversationSummary =>
  agentConversationSummaryFromDbFields(
    ~id=row.id,
    ~editSessionId=row.editSessionId,
    ~provider=row.provider,
    ~providerConversationId=row.providerConversationId,
    ~model=row.model,
    ~prompt=row.prompt,
    ~selectionLabel=row.selectionLabel,
    ~selectionSnapshotId=row.selectionSnapshotId,
    ~resultVersionId=row.resultVersionId,
    ~summary=row.summary,
    ~warningsJson=row.warningsJson,
    ~error=row.error,
    ~createdAt=row.createdAt,
  )

let activityEventFromDbFields = (
  ~id: string,
  ~actorUserId: string,
  ~profileId: string,
  ~profileVersionId: string,
  ~kind: string,
  ~title: string,
  ~summary: string,
  ~visibility: string,
  ~createdAt: option<string>,
): profileUpdateEvent => {
  id: id->ResGraph.id,
  actorUserId: actorUserId->ResGraph.id,
  profileId: profileId->ResGraph.id,
  profileVersionId: profileVersionId->ResGraph.id,
  kind: kind->profileUpdateEventKindFromDb,
  title,
  summary,
  visibility: visibility->activityVisibilityFromDb,
  createdAt: createdAt->stringOrDefault(updatedAt),
}

let activityEventFromDb = (row: DbQueries.insertProfileUpdateEventResult): profileUpdateEvent =>
  activityEventFromDbFields(
    ~id=row.id,
    ~actorUserId=row.actorUserId,
    ~profileId=row.profileId,
    ~profileVersionId=row.profileVersionId,
    ~kind=row.kind,
    ~title=row.title,
    ~summary=row.summary,
    ~visibility=row.visibility,
    ~createdAt=row.createdAt,
  )

let activityEventFromListFriendActivity = (
  row: DbQueries.listFriendActivityForUserResult,
): profileUpdateEvent =>
  activityEventFromDbFields(
    ~id=row.id,
    ~actorUserId=row.actorUserId,
    ~profileId=row.profileId,
    ~profileVersionId=row.profileVersionId,
    ~kind=row.kind,
    ~title=row.title,
    ~summary=row.summary,
    ~visibility=row.visibility,
    ~createdAt=row.createdAt,
  )

let inviteChainFriendFromFields = (
  ~userId: string,
  ~handle: string,
  ~displayName: string,
  ~createdAt: option<string>,
  ~profileId: string,
  ~profileSlug: string,
  ~profileTitle: string,
): inviteChainFriend => {
  id: ("invite-chain-friend:" ++ userId)->ResGraph.id,
  userId: userId->ResGraph.id,
  handle,
  displayName,
  createdAt: createdAt->stringOrDefault(fallbackCreatedAt),
  profileId: profileId->ResGraph.id,
  profileSlug,
  profileTitle,
  avatarInitials: avatarInitialsForFriend(~displayName, ~handle),
  avatarColor: avatarColorForFriend(~handle),
}

let inviteChainFriendFromList = (
  row: DbQueries.listInviteChainFriendsForUserResult,
): inviteChainFriend =>
  inviteChainFriendFromFields(
    ~userId=row.userId,
    ~handle=row.handle,
    ~displayName=row.displayName,
    ~createdAt=row.createdAt,
    ~profileId=row.profileId,
    ~profileSlug=row.profileSlug,
    ~profileTitle=row.profileTitle,
  )

let fixtureInviteChainFriendsForProfile = (profile: profile): array<inviteChainFriend> =>
  fixtureUsers->Array.filterMap(user =>
    switch (sameId(user.id, profile.ownerUserId), user.status, profileByOwnerId(user.id)) {
    | (false, UserStatusEnabled, Some(friendProfile)) =>
      switch (friendProfile.visibility, friendProfile->profileHasCompletedCurrentVersion) {
      | (ProfileVisibilityFriends, true) =>
        Some(inviteChainFriendFromFields(
          ~userId=user.id->idToString,
          ~handle=user.handle,
          ~displayName=user.displayName,
          ~createdAt=Some(user.createdAt),
          ~profileId=friendProfile.id->idToString,
          ~profileSlug=friendProfile.slug,
          ~profileTitle=friendProfile.title,
        ))
      | (ProfileVisibilityDisabled, _) | (_, false) => None
      }
    | _ => None
    }
  )

let activityEventFromGetById = (row: DbQueries.getProfileUpdateEventByIdResult): profileUpdateEvent =>
  activityEventFromDbFields(
    ~id=row.id,
    ~actorUserId=row.actorUserId,
    ~profileId=row.profileId,
    ~profileVersionId=row.profileVersionId,
    ~kind=row.kind,
    ~title=row.title,
    ~summary=row.summary,
    ~visibility=row.visibility,
    ~createdAt=row.createdAt,
  )

let loadUserById = async (
  ctx: ResGraphContext.context,
  userId: ResGraph.id,
): option<user> =>
  (await DataLoader.load(ctx.dataLoaders.users.byId, userId->rawDbIdString))
  ->Option.map(userFromGetUsersByIds)

let loadUserByHandle = async (
  ctx: ResGraphContext.context,
  handle: string,
): option<user> => {
  let result = await BackendDatabase.withClient(ctx.databaseUrl, async client =>
    await DbQueries.GetUserByHandle.one(client, {handle: handle})
  )

  result->optionJoin->Option.map(userFromGetUserByHandle)
}

let isProductionEnvironment = (): bool =>
  processEnv->Dict.get("VIBESPACE_ENV")->Option.getOr("")->String.trim->String.toLowerCase ==
    "production"

let allowFixtureData = (ctx: ResGraphContext.context): bool =>
  switch ctx.databaseUrl {
  | None => !isProductionEnvironment()
  | Some(_) => false
  }

let loadViewer = async (ctx: ResGraphContext.context): option<user> =>
  switch ctx.currentUserId {
  | Some(value) => await loadUserById(ctx, value->id)
  | None if ctx->allowFixtureData => Some(fixtureViewer)
  | None => None
  }

let loadProfileById = async (
  ctx: ResGraphContext.context,
  profileId: ResGraph.id,
): option<profile> =>
  (await DataLoader.load(ctx.dataLoaders.profiles.byId, profileId->rawDbIdString))
  ->Option.map(profileFromGetProfilesByIds)

let loadProfileByOwnerId = async (
  ctx: ResGraphContext.context,
  ownerUserId: ResGraph.id,
): option<profile> =>
  (await DataLoader.load(ctx.dataLoaders.profiles.byOwnerId, ownerUserId->rawDbIdString))
  ->Option.map(profileFromGetProfilesByOwnerIds)

let loadProfileBySlug = async (
  ctx: ResGraphContext.context,
  slug: string,
): option<profile> => {
  let result = await BackendDatabase.withClient(ctx.databaseUrl, async client =>
    await DbQueries.GetProfileBySlug.one(client, {slug: slug})
  )

  result->optionJoin->Option.map(profileFromGetProfileBySlug)
}

let loadProfileVersionById = async (
  ctx: ResGraphContext.context,
  versionId: ResGraph.id,
): option<profileVersion> =>
  (await DataLoader.load(ctx.dataLoaders.profileVersions.byId, versionId->rawDbIdString))
  ->Option.map(profileVersionFromGetByIds)

let loadCurrentProfileVersion = async (
  ctx: ResGraphContext.context,
  profileId: ResGraph.id,
): option<profileVersion> =>
  (await DataLoader.load(ctx.dataLoaders.profileVersions.currentByProfileId, profileId->rawDbIdString))
  ->Option.map(profileVersionFromCurrentByProfileIds)

let loadProfileVersionsForProfile = async (
  ctx: ResGraphContext.context,
  profileId: ResGraph.id,
): option<array<profileVersion>> => {
  // TODO(dataloader): Keep this as a paginated/list query for now. If nested
  // profile version histories become common, add a dedicated by-profile-id list loader
  // with pagination-aware keys instead of reusing entity lookup loaders.
  let result = await BackendDatabase.withClient(ctx.databaseUrl, async client =>
    await DbQueries.ListProfileVersionsForProfile.many(client, {profileId: profileId->rawDbIdString})
  )

  result->Option.map(rows => rows->Array.map(profileVersionFromList))
}

let loadProfileEditSessionById = async (
  ctx: ResGraphContext.context,
  sessionId: ResGraph.id,
): option<profileEditSession> => {
  let result = await BackendDatabase.withClient(ctx.databaseUrl, async client =>
    await DbQueries.GetProfileEditSessionById.one(client, {id: sessionId->rawDbIdString})
  )

  result->optionJoin->Option.map(profileEditSessionFromGetById)
}

let loadProfileEditSessionsForProfile = async (
  ctx: ResGraphContext.context,
  profileId: ResGraph.id,
): option<array<profileEditSession>> => {
  let result = await BackendDatabase.withClient(ctx.databaseUrl, async client =>
    await DbQueries.ListProfileEditSessionsForProfile.many(client, {
      profileId: profileId->rawDbIdString,
    })
  )

  result->Option.map(rows => rows->Array.map(profileEditSessionFromList))
}

let loadSelectionSnapshotById = async (
  ctx: ResGraphContext.context,
  snapshotId: ResGraph.id,
): option<selectionSnapshot> => {
  let result = await BackendDatabase.withClient(ctx.databaseUrl, async client =>
    await DbQueries.GetSelectionSnapshotById.one(client, {id: snapshotId->rawDbIdString})
  )

  result->optionJoin->Option.map(selectionSnapshotFromGetById)
}

let loadTrustedCapabilitiesForVersion = async (
  ctx: ResGraphContext.context,
  profileVersionId: ResGraph.id,
): option<array<trustedCapabilityReference>> => {
  let result = await BackendDatabase.withClient(ctx.databaseUrl, async client =>
    await DbQueries.ListTrustedCapabilitiesForVersion.many(client, {
      profileVersionId: profileVersionId->rawDbIdString,
    })
  )

  result->Option.map(rows => rows->Array.map(trustedCapabilityFromList))
}

let loadTrustedCapabilityById = async (
  ctx: ResGraphContext.context,
  capabilityId: ResGraph.id,
): option<trustedCapabilityReference> => {
  let result = await BackendDatabase.withClient(ctx.databaseUrl, async client =>
    await DbQueries.GetTrustedCapabilityById.one(client, {id: capabilityId->rawDbIdString})
  )

  result->optionJoin->Option.map(trustedCapabilityFromGetById)
}

let loadConversationSummaryForSession = async (
  ctx: ResGraphContext.context,
  editSessionId: ResGraph.id,
): option<agentConversationSummary> => {
  let result = await BackendDatabase.withClient(ctx.databaseUrl, async client =>
    await DbQueries.GetAgentConversationSummaryForSession.one(client, {
      editSessionId: editSessionId->rawDbIdString,
    })
  )

  result->optionJoin->Option.map(agentConversationSummaryFromSession)
}

let loadConversationSummaryById = async (
  ctx: ResGraphContext.context,
  summaryId: ResGraph.id,
): option<agentConversationSummary> => {
  let result = await BackendDatabase.withClient(ctx.databaseUrl, async client =>
    await DbQueries.GetAgentConversationSummaryById.one(client, {id: summaryId->rawDbIdString})
  )

  result->optionJoin->Option.map(agentConversationSummaryFromGetById)
}

let loadAvailableInviteForViewer = async (ctx: ResGraphContext.context): option<invite> =>
  switch await loadViewer(ctx) {
  | None => None
  | Some(user) =>
    let result = await BackendDatabase.withClient(ctx.databaseUrl, async client =>
      switch await DbQueries.GetAvailableInviteForUser.one(client, {userId: user.id->rawDbIdString}) {
      | Some(row) => await rotateInviteCodeIfPredictable(client, row->inviteFromGetAvailableInvite)
      | None => None
      }
    )

    result->optionJoin
  }

let loadUsedInviteForViewer = async (ctx: ResGraphContext.context): option<invite> =>
  switch await loadViewer(ctx) {
  | None => None
  | Some(user) =>
    let result = await BackendDatabase.withClient(ctx.databaseUrl, async client =>
      await DbQueries.GetUsedInviteForUser.one(client, {userId: user.id->rawDbIdString})
    )

    result->optionJoin->Option.map(inviteFromGetUsedInvite)
  }

let loadInviteByCode = async (ctx: ResGraphContext.context, code: string): option<invite> => {
  let codeHash = code->inviteCodeKey
  let result = await BackendDatabase.withClient(ctx.databaseUrl, async client =>
    await DbQueries.GetInviteByCode.one(client, {codeHash: codeHash})
  )

  result->optionJoin->Option.map(inviteFromGetByCode)
}

let loadFriendActivityForViewer = async (
  ctx: ResGraphContext.context,
): option<array<profileUpdateEvent>> =>
  switch await loadViewer(ctx) {
  | None => None
  | Some(user) =>
    let result = await BackendDatabase.withClient(ctx.databaseUrl, async client =>
      await DbQueries.ListFriendActivityForUser.many(client, {userId: user.id->rawDbIdString})
    )

    result->Option.map(rows => rows->Array.map(activityEventFromListFriendActivity))
  }

let loadInviteChainFriendsForProfile = async (
  ctx: ResGraphContext.context,
  profile: profile,
): option<array<inviteChainFriend>> => {
  let result = await BackendDatabase.withClient(ctx.databaseUrl, async client =>
    await DbQueries.ListInviteChainFriendsForUser.many(client, {
      ownerUserId: profile.ownerUserId->rawDbIdString,
    })
  )

  result->Option.map(rows => rows->Array.map(inviteChainFriendFromList))
}

let loadProfileUpdateEventById = async (
  ctx: ResGraphContext.context,
  eventId: ResGraph.id,
): option<profileUpdateEvent> => {
  let result = await BackendDatabase.withClient(ctx.databaseUrl, async client =>
    await DbQueries.GetProfileUpdateEventById.one(client, {id: eventId->rawDbIdString})
  )

  result->optionJoin->Option.map(activityEventFromGetById)
}

let dbCancelProfileEditSession = async (
  ctx: ResGraphContext.context,
  input: cancelProfileEditSessionInput,
): option<profileEditSession> => {
  let result = await BackendDatabase.withClient(ctx.databaseUrl, async client =>
    await DbQueries.CancelProfileEditSession.one(client, {id: input.editSessionId->rawDbIdString})
  )

  result->optionJoin->Option.map(profileEditSessionFromCancel)
}

let dbCreateSeedUser = async (
  ctx: ResGraphContext.context,
  input: adminCreateSeedUserInput,
): option<dbSeedUserResult> => {
  let result = await BackendDatabase.withTransaction(ctx.databaseUrl, async client => {
    let seededUser = await DbQueries.UpsertSeedUser.expectOne(client, {
      handle: input.handle,
      displayName: input.displayName,
      role: input.role->Option.getOr(UserRoleUser)->userRoleToDb,
    })
    let user = seededUser->userFromUpsertSeedUser
    switch await ensureRandomAvailableInviteForUser(client, user.id->idString) {
    | None => None
    | Some(invite) =>
      let profile = await DbQueries.EnsureProfileForUser.expectOne(client, {
        ownerUserId: user.id->idString,
        slug: user.handle,
        title: user.displayName ++ "'s Vibespace",
      })
      ignore(await DbQueries.EnsureInitialProfileVersion.one(client, {
        profileId: profile.id,
        html: fixtureHtml,
        css: fixtureCss,
        createdByUserId: user.id->idString,
      }))

      Some({
        user,
        invite,
      }: dbSeedUserResult)
    }
  })

  result->optionJoin
}

let dbCreateAdminInvite = async (
  ctx: ResGraphContext.context,
  inviterUserId: ResGraph.id,
): option<invite> => {
  let result = await BackendDatabase.withClient(ctx.databaseUrl, async client =>
    await ensureRandomAvailableInviteForUser(client, inviterUserId->rawDbIdString)
  )

  result->optionJoin
}

let dbRedeemInvite = async (
  ctx: ResGraphContext.context,
  input: redeemInviteInput,
): option<dbRedeemInviteOutcome> => {
  let codeHash = input.code->inviteCodeKey
  let displayName = input.displayName->Option.mapOr("New Vibespace", value =>
    value->String.trim == "" ? "New Vibespace" : value->String.trim
  )

  await BackendDatabase.withTransaction(ctx.databaseUrl, async client => {
    switch await DbQueries.GetAvailableInviteByCodeForUpdate.one(client, {codeHash: codeHash}) {
    | None => InviteRedeemInvalid
    | Some(inviteRow) =>
      let availableInvite = inviteRow->inviteFromAvailableByCode
      ignore(await DbQueries.LockNumericHandleAllocator.expectOne(client, ()))
      switch await DbQueries.InsertInviteeUserWithNumericHandle.one(client, {
        displayName,
        invitedByUserId: availableInvite.inviterUserId->rawDbIdString,
      }) {
      | None => InviteRedeemHandleTaken
      | Some(userRow) =>
        let user = userRow->userFromInsertInviteeUser
        let profileRow = await DbQueries.EnsureProfileForUser.expectOne(client, {
          ownerUserId: user.id->idString,
          slug: user.handle,
          title: user.displayName ++ "'s Vibespace",
        })
        let profile = profileRow->profileFromEnsureProfile
        ignore(await DbQueries.EnsureInitialProfileVersion.one(client, {
          profileId: profile.id->idString,
          html: fixtureHtml,
          css: fixtureCss,
          createdByUserId: user.id->idString,
        }))
        let connectionRow = await DbQueries.EnsureInviteFriendConnection.expectOne(client, {
          userAId: availableInvite.inviterUserId->rawDbIdString,
          userBId: user.id->idString,
        })
        let redeemedInviteRow = await DbQueries.RedeemInviteById.expectOne(client, {
          id: availableInvite.id->rawDbIdString,
          inviteeUserId: user.id->idString,
        })
        ignore(await ensureRandomAvailableInviteForUser(client, user.id->idString))

        InviteRedeemed({
          user,
          invite: redeemedInviteRow->inviteFromRedeemById,
          friendConnection: connectionRow->friendConnectionFromEnsureInvite,
          profile,
        })
      }
    }
  })
}

let dbReactivateUsedInvite = async (
  ctx: ResGraphContext.context,
  input: reactivateUsedInviteInput,
): option<dbReactivateUsedInviteOutcome> => {
  if !input.confirmDisable {
    Some(UsedInviteConfirmationMissing)
  } else {
    switch await loadViewer(ctx) {
    | None => Some(UsedInviteNotFound)
    | Some(user) =>
      await BackendDatabase.withTransaction(ctx.databaseUrl, async client => {
        switch await DbQueries.ReactivateUsedInviteForUser.one(client, {
          userId: user.id->rawDbIdString,
        }) {
        | Some(row) =>
          UsedInviteReactivated({
            user: row->userFromReactivateUsedInvite,
            invite: row->inviteFromReactivateUsedInvite,
          })
        | None => UsedInviteNotFound
        }
      })
    }
  }
}

let currentUserIdForWrite = (ctx: ResGraphContext.context): option<ResGraph.id> =>
  ctx.currentUserId->Option.map(value => value->id->internalIdFromMaybeGlobal)

let profileWriteActorId = (
  ctx: ResGraphContext.context,
  profile: profile,
): option<string> =>
  switch currentUserIdForWrite(ctx) {
  | Some(userId) if sameId(userId, profile.ownerUserId) => Some(userId->idString)
  | Some(_) | None => None
  }

let profileWriteActorIdForViewer = async (
  ctx: ResGraphContext.context,
  profile: profile,
): option<string> =>
  switch await loadViewer(ctx) {
  | Some(user) if user.status == UserStatusEnabled && sameId(user.id, profile.ownerUserId) =>
    Some(user.id->idString)
  | Some(_) | None => None
  }

let dbSaveManualProfileVersion = async (
  ctx: ResGraphContext.context,
  input: saveManualProfileVersionInput,
): option<dbVersionMutationResult> => {
  let profileId = input.profileId->rawDbIdString
  let result = await BackendDatabase.withTransaction(ctx.databaseUrl, async client => {
    switch await DbQueries.GetProfileById.one(client, {id: profileId}) {
    | None => None
    | Some(profileRow) =>
      let profile = profileRow->profileFromGetProfileById
      switch profileWriteActorId(ctx, profile) {
      | None => None
      | Some(actorUserId) =>
        let summary = input.summary->Option.getOr("Manual profile save.")
        switch await DbQueries.InsertManualProfileVersion.one(client, {
          profileId,
          html: input.html,
          css: input.css,
          summary,
          createdByUserId: actorUserId,
        }) {
        | None => None
        | Some(versionRow) =>
          let version = versionRow->profileVersionFromInsertManual
          let updatedProfile = (await DbQueries.GetProfileById.one(client, {id: profileId}))
            ->Option.map(profileFromGetProfileById)
          let event = await DbQueries.InsertProfileUpdateEvent.one(client, {
            actorUserId,
            profileId,
            profileVersionId: version.id->idString,
            kind: ProfileUpdateEventKindProfilePublished->profileUpdateEventKindToDb,
            title: "Profile updated",
            summary: version.summary,
          })

          Some({
            profile: updatedProfile,
            profileVersion: version,
            activityEvent: event->Option.map(activityEventFromDb),
          })
        }
      }
    }
  })

  result->optionJoin
}

let dbRestoreProfileVersion = async (
  ctx: ResGraphContext.context,
  input: restoreProfileVersionInput,
): option<dbVersionMutationResult> => {
  let profileId = input.profileId->rawDbIdString
  let versionId = input.versionId->rawDbIdString
  let result = await BackendDatabase.withTransaction(ctx.databaseUrl, async client => {
    switch await DbQueries.GetProfileById.one(client, {id: profileId}) {
    | None => None
    | Some(profileRow) =>
      let profile = profileRow->profileFromGetProfileById
      switch profileWriteActorId(ctx, profile) {
      | None => None
      | Some(actorUserId) =>
        switch await DbQueries.RestoreProfileVersion.one(client, {
          profileId,
          versionId,
          createdByUserId: actorUserId,
          summary: "Restored an older profile version.",
        }) {
        | None => None
        | Some(versionRow) =>
          let version = versionRow->profileVersionFromRestore
          let updatedProfile = (await DbQueries.GetProfileById.one(client, {id: profileId}))
            ->Option.map(profileFromGetProfileById)
          let event = await DbQueries.InsertProfileUpdateEvent.one(client, {
            actorUserId,
            profileId,
            profileVersionId: version.id->idString,
            kind: ProfileUpdateEventKindProfileRestored->profileUpdateEventKindToDb,
            title: "Profile restored",
            summary: version.summary,
          })

          Some({
            profile: updatedProfile,
            profileVersion: version,
            activityEvent: event->Option.map(activityEventFromDb),
          })
        }
      }
    }
  })

  result->optionJoin
}

let isBlank = value => value->String.trim == ""

let profileVersionFailure = (
  ~profile: option<profile>,
  ~summary: string,
  ~validationErrors: array<string>,
  ~error: string,
): profileVersionMutationFailed => {
  profile,
  summary,
  validationErrors,
  message: error,
}

let profileVersionSuccess = (result: dbVersionMutationResult): profileVersionMutationSucceeded => {
  profile: result.profile,
  profileVersion: result.profileVersion,
  activityEvent: result.activityEvent,
  summary: result.profileVersion.summary,
  warnings: [],
}

let profileEditSessionFailure = (
  ~editSession: option<profileEditSession>=?,
  ~providerConversationId: option<string>=?,
  ~resultVersionId: option<ResGraph.id>=?,
  ~summary: string,
  ~warnings: array<string>=[],
  ~validationErrors: array<string>,
  ~error: string,
): profileEditSessionMutationFailed => {
  editSession,
  providerConversationId,
  resultVersionId,
  summary,
  warnings,
  validationErrors,
  message: error,
}

let profileEditSessionSuccess = (
  ~editSession: profileEditSession,
  ~providerConversationId: option<string>,
  ~resultVersionId: option<ResGraph.id>,
  ~summary: string,
  ~warnings: array<string>,
  ~validationErrors: array<string>,
): profileEditSessionMutationSucceeded => {
  editSession,
  providerConversationId,
  resultVersionId,
  summary,
  warnings,
  validationErrors,
}

let profileWriteAuthError = "You need to be signed in as this profile owner to edit it."

let stubSavedVersion = (~input: saveManualProfileVersionInput): profileVersion => {
  let profileId = input.profileId->internalIdFromMaybeGlobal
  let parentVersionId = profileById(profileId)->Option.flatMap(profile => profile.currentVersionId)

  {
    id: id("stub-manual-save"),
    profileId,
    revisionNumber: 3,
    parentVersionId,
    html: input.html,
    css: input.css,
    source: ProfileVersionSourceManual,
    promptSessionId: None,
    summary: input.summary->Option.getOr("Manual profile save."),
    validationStatus: ValidationStatusValid,
    validationErrors: [],
    createdByUserId: fixtureViewerId,
    createdAt: updatedAt,
  }
}

let stubRestoredVersion = (~sourceVersion: profileVersion): profileVersion => {
  {
    ...sourceVersion,
    id: id("stub-restore"),
    revisionNumber: 3,
    parentVersionId: Some(sourceVersion.id),
    source: ProfileVersionSourceRestore,
    promptSessionId: None,
    summary: "Restored an older profile version.",
    createdAt: updatedAt,
  }
}

let stubAgentVersionForSession = (session: profileEditSession): profileVersion => {
  let parentVersionId = profileById(session.profileId)->Option.flatMap(profile => profile.currentVersionId)

  {
    id: id("stub-agent-result"),
    profileId: session.profileId,
    revisionNumber: 3,
    parentVersionId,
    html: fixtureHtml,
    css: fixtureCss,
    source: ProfileVersionSourceAgent,
    promptSessionId: Some(session.id),
    summary: session.summary,
    validationStatus: ValidationStatusValid,
    validationErrors: [],
    createdByUserId: session.userId,
    createdAt: updatedAt,
  }
}

let stubPublishedProfile = (~profileId, ~versionId): option<profile> =>
  profileById(profileId)->Option.map(profile => {
    ...profile,
    currentVersionId: Some(versionId),
    updatedAt,
    publishedAt: Some(updatedAt),
  })

let stubActivity = (~version: profileVersion, ~kind): profileUpdateEvent => {
  id: id("stub-profile-update"),
  actorUserId: fixtureViewerId,
  profileId: version.profileId,
  profileVersionId: version.id,
  kind,
  title: "Profile updated",
  summary: version.summary,
  visibility: ActivityVisibilityFriends,
  createdAt: updatedAt,
}

/** Backend readiness timestamp. */
@live @gql.field
let currentTime = (_: query): float => Date.now()

/** Current signed-in internal user id from the request context. */
let currentUserIdFromContext = (ctx: ResGraphContext.context): ResGraph.id =>
  switch ctx.currentUserId {
  | Some(value) => id(value)
  | None if ctx->allowFixtureData => fixtureViewerId
  | None => id("anonymous-viewer")
  }

/** The current viewer account. */
@live @gql.field
let viewer = async (_: query, ~ctx: ResGraphContext.context): option<user> => {
  switch await loadViewer(ctx) {
  | Some(user) => Some(user)
  | None if ctx->allowFixtureData =>
    let currentId = currentUserIdFromContext(ctx)
    switch userById(currentId) {
    | Some(user) => Some(user)
    | None => Some(fixtureViewer)
    }
  | None => None
  }
}

/** The current viewer's canonical profile. */
@live @gql.field
let viewerProfile = async (_: query, ~ctx: ResGraphContext.context): option<profile> => {
  switch await loadViewer(ctx) {
  | Some(user) =>
    switch await loadProfileByOwnerId(ctx, user.id) {
    | Some(profile) => Some(profile)
    | None if ctx->allowFixtureData => profileByOwnerId(user.id)
    | None => None
    }
  | None =>
    let currentUser = if ctx->allowFixtureData {
      let currentId = currentUserIdFromContext(ctx)
      switch userById(currentId) {
      | Some(user) => Some(user)
      | None => Some(fixtureViewer)
      }
    } else {
      None
    }

    currentUser->Option.flatMap(user => profileByOwnerId(user.id))
  }
}

/** Friend-visible profile by handle. */
@live @gql.field
let profileByHandle = async (
  _: query,
  ~handle: string,
  ~ctx: ResGraphContext.context,
): option<profile> =>
  switch await loadProfileBySlug(ctx, handle) {
  | Some(profile) => Some(profile)
  | None if ctx->allowFixtureData => fixtureProfiles->Array.find(profile => profile.slug == handle)
  | None => None
  }

/** Invite lookup for the invite-link onboarding route. */
@live @gql.field
let inviteByCode = async (
  _: query,
  ~code: string,
  ~ctx: ResGraphContext.context,
): option<invite> => {
  let code = code->inviteCodeKey
  if code == "" {
    None
  } else {
    switch await loadInviteByCode(ctx, code) {
    | Some(invite) => Some(invite)
    | None if ctx->allowFixtureData =>
      switch fixtureInvite.code {
      | Some(fixtureCode) if fixtureCode == code => Some(fixtureInvite)
      | _ => None
      }
    | None => None
    }
  }
}

/** Profile version resolver backed by pgtyped-rescript when DATABASE_URL is configured. */
@live @gql.field
let profileVersionById = async (
  _: query,
  ~id: ResGraph.id,
  ~ctx: ResGraphContext.context,
): option<profileVersion> =>
  switch await loadProfileVersionById(ctx, id) {
  | Some(version) => Some(version)
  | None if ctx->allowFixtureData => profileVersionByRawId(id)
  | None => None
  }

/** Profile edit session resolver backed by pgtyped-rescript when DATABASE_URL is configured. */
@live @gql.field
let profileEditSessionById = async (
  _: query,
  ~id: ResGraph.id,
  ~ctx: ResGraphContext.context,
): option<profileEditSession> =>
  switch await loadProfileEditSessionById(ctx, id) {
  | Some(session) => Some(session)
  | None if ctx->allowFixtureData => profileEditSessionByRawId(id)
  | None => None
  }

/** Version history for a profile. */
@live @gql.field
let profileVersions = async (
  _: query,
  ~profileId: ResGraph.id,
  ~first: option<int>,
  ~after: option<string>,
  ~before: option<string>,
  ~last: option<int>,
  ~ctx: ResGraphContext.context,
): profileVersionConnection => {
  let profileId = profileId->internalIdFromMaybeGlobal
  let versions = switch await loadProfileVersionsForProfile(ctx, profileId) {
  | Some(versions) => versions
  | None if ctx->allowFixtureData => profileVersionsForProfile(profileId)
  | None => []
  }

  versions->profileVersionConnectionFromArray(
    ~first,
    ~after,
    ~before,
    ~last,
  )
}

/** Prompt/edit history for a profile. */
@live @gql.field
let profileEditSessions = async (
  _: query,
  ~profileId: ResGraph.id,
  ~first: option<int>,
  ~after: option<string>,
  ~before: option<string>,
  ~last: option<int>,
  ~ctx: ResGraphContext.context,
): profileEditSessionConnection => {
  let profileId = profileId->internalIdFromMaybeGlobal
  let sessions = switch await loadProfileEditSessionsForProfile(ctx, profileId) {
  | Some(sessions) => sessions
  | None if ctx->allowFixtureData => profileEditSessionsForProfile(profileId)
  | None => []
  }

  sessions->profileEditSessionConnectionFromArray(
    ~first,
    ~after,
    ~before,
    ~last,
  )
}

/** Recent profile update events for accepted friends. */
@live @gql.field
let friendActivity = async (
  _: query,
  ~first: option<int>,
  ~after: option<string>,
  ~before: option<string>,
  ~last: option<int>,
  ~ctx: ResGraphContext.context,
): profileUpdateEventConnection => {
  let events = switch await loadFriendActivityForViewer(ctx) {
  | Some(events) => events
  | None if ctx->allowFixtureData => fixtureActivities
  | None => []
  }

  events->profileUpdateEventConnectionFromArray(~first, ~after, ~before, ~last)
}

/** The current viewer's available invite grant, if any. */
@live @gql.field
let availableInvite = async (_: query, ~ctx: ResGraphContext.context): option<invite> =>
  switch await loadAvailableInviteForViewer(ctx) {
  | Some(invite) => Some(invite)
  | None if ctx->allowFixtureData => Some(fixtureInvite)
  | None => None
  }

/** The redeemed invite the current viewer used to join, if any. */
@live @gql.field
let viewerUsedInvite = async (_: query, ~ctx: ResGraphContext.context): option<invite> =>
  switch await loadUsedInviteForViewer(ctx) {
  | Some(invite) => Some(invite)
  | None if ctx->allowFixtureData =>
    Some({...fixtureInvite, status: InviteStatusRedeemed, inviteeUserId: Some(fixtureFriendId), redeemedAt: Some(updatedAt)})
  | None => None
  }

/** The profile owner. */
@live @gql.field
let owner = async (
  profile: profile,
  ~ctx: ResGraphContext.context,
): option<user> =>
  // Request-scoped DataLoader batches DB-backed profile owner lookups.
  switch await loadUserById(ctx, profile.ownerUserId) {
  | Some(user) => Some(user)
  | None => userById(profile.ownerUserId)
  }

/** The current Send avatar URL for this profile's optional Sendtag. */
@live @gql.field
let sendAvatarUrl = async (
  profile: profile,
  ~ctx: ResGraphContext.context,
): option<string> => {
  let _ = ctx
  switch profile.sendtag {
  | Some(sendtag) =>
    let avatarUrl = await lookupSendAvatarUrl(sendtag)
    avatarUrl->Nullable.toOption
  | None => None
  }
}

/** The current Send avatar URL for this friend profile's stored Sendtag. */
@live @gql.field
let avatarUrl = async (
  friend: inviteChainFriend,
  ~ctx: ResGraphContext.context,
): option<string> => {
  let profile = switch await loadProfileById(ctx, friend.profileId) {
  | Some(profile) => Some(profile)
  | None if ctx->allowFixtureData => profileById(friend.profileId)
  | None => None
  }

  switch profile {
  | Some({sendtag: Some(sendtag)}) =>
    let avatarUrl = await lookupSendAvatarUrl(sendtag)
    avatarUrl->Nullable.toOption
  | Some({sendtag: None}) | None => None
  }
}

/** The profile's current published version. */
@live @gql.field
let currentVersion = async (
  profile: profile,
  ~ctx: ResGraphContext.context,
): option<profileVersion> =>
  // Request-scoped DataLoader batches DB-backed current-version lookups.
  switch await loadCurrentProfileVersion(ctx, profile.id) {
  | Some(version) => Some(version)
  | None if ctx->allowFixtureData => currentProfileVersion(profile)
  | None => None
  }

/** Version history for this profile. */
@live @gql.field
let versionHistory = async (
  profile: profile,
  ~first: option<int>,
  ~after: option<string>,
  ~before: option<string>,
  ~last: option<int>,
  ~ctx: ResGraphContext.context,
): profileVersionConnection => {
  // TODO(dataloader): This is a list resolver, not a simple entity lookup.
  // Keep it as a direct paginated query until we add pagination-aware batch keys.
  let versions = switch await loadProfileVersionsForProfile(ctx, profile.id) {
  | Some(versions) => versions
  | None if ctx->allowFixtureData => profileVersionsForProfile(profile.id)
  | None => []
  }

  versions->profileVersionConnectionFromArray(
    ~first,
    ~after,
    ~before,
    ~last,
  )
}

/** Prompt/edit history for this profile. */
@live @gql.field
let editSessions = async (
  profile: profile,
  ~first: option<int>,
  ~after: option<string>,
  ~before: option<string>,
  ~last: option<int>,
  ~ctx: ResGraphContext.context,
): profileEditSessionConnection => {
  let sessions = switch await loadProfileEditSessionsForProfile(ctx, profile.id) {
  | Some(sessions) => sessions
  | None if ctx->allowFixtureData => profileEditSessionsForProfile(profile.id)
  | None => []
  }

  sessions->profileEditSessionConnectionFromArray(
    ~first,
    ~after,
    ~before,
    ~last,
  )
}

/** Required Myspace-style friends list for the profile's invite-chain community. */
@live @gql.field
let inviteChainFriends = async (
  profile: profile,
  ~first: option<int>,
  ~after: option<string>,
  ~before: option<string>,
  ~last: option<int>,
  ~ctx: ResGraphContext.context,
): inviteChainFriendConnection => {
  let friends = switch await loadInviteChainFriendsForProfile(ctx, profile) {
  | Some(friends) => friends
  | None if ctx->allowFixtureData => profile->fixtureInviteChainFriendsForProfile
  | None => []
  }
  let first = switch (first, last) {
  | (None, None) => Some(12)
  | _ => first
  }

  friends->inviteChainFriendConnectionFromArray(~first, ~after, ~before, ~last)
}

/** The canonical profile owned by this user. */
@live @gql.field
let profile = async (
  user: user,
  ~ctx: ResGraphContext.context,
): option<profile> =>
  // Request-scoped DataLoader batches DB-backed owner profile lookups.
  switch await loadProfileByOwnerId(ctx, user.id) {
  | Some(profile) => Some(profile)
  | None if ctx->allowFixtureData => profileByOwnerId(user.id)
  | None => None
  }

/** The inviter for this invite. */
@live @gql.field
let inviter = async (
  invite: invite,
  ~ctx: ResGraphContext.context,
): option<user> =>
  // Request-scoped DataLoader batches DB-backed user lookups.
  switch await loadUserById(ctx, invite.inviterUserId) {
  | Some(user) => Some(user)
  | None if ctx->allowFixtureData => userById(invite.inviterUserId)
  | None => None
  }

/** The invitee for this invite, when already redeemed. */
@live @gql.field
let invitee = async (
  invite: invite,
  ~ctx: ResGraphContext.context,
): option<user> =>
  switch invite.inviteeUserId {
  | None => None
  | Some(inviteeUserId) =>
    // Request-scoped DataLoader batches DB-backed user lookups.
    switch await loadUserById(ctx, inviteeUserId) {
    | Some(user) => Some(user)
    | None if ctx->allowFixtureData => userById(inviteeUserId)
    | None => None
    }
  }

/** User A in this friendship. */
@live @gql.field
let userA = async (
  connection: friendConnection,
  ~ctx: ResGraphContext.context,
): option<user> =>
  // Request-scoped DataLoader batches DB-backed user lookups.
  switch await loadUserById(ctx, connection.userAId) {
  | Some(user) => Some(user)
  | None if ctx->allowFixtureData => userById(connection.userAId)
  | None => None
  }

/** User B in this friendship. */
@live @gql.field
let userB = async (
  connection: friendConnection,
  ~ctx: ResGraphContext.context,
): option<user> =>
  // Request-scoped DataLoader batches DB-backed user lookups.
  switch await loadUserById(ctx, connection.userBId) {
  | Some(user) => Some(user)
  | None if ctx->allowFixtureData => userById(connection.userBId)
  | None => None
  }

/** The profile attached to this version. */
@live @gql.field
let profileForVersion = async (
  version: profileVersion,
  ~ctx: ResGraphContext.context,
): option<profile> =>
  // Request-scoped DataLoader batches DB-backed profile lookups.
  switch await loadProfileById(ctx, version.profileId) {
  | Some(profile) => Some(profile)
  | None if ctx->allowFixtureData => profileById(version.profileId)
  | None => None
  }

/** The user that created this version. */
@live @gql.field
let createdBy = async (
  version: profileVersion,
  ~ctx: ResGraphContext.context,
): option<user> =>
  // Request-scoped DataLoader batches repeated creator lookups in version histories.
  switch await loadUserById(ctx, version.createdByUserId) {
  | Some(user) => Some(user)
  | None if ctx->allowFixtureData => userById(version.createdByUserId)
  | None => None
  }

/** Approved trusted capabilities extracted for this version. */
@live @gql.field
let trustedCapabilities = async (
  version: profileVersion,
  ~ctx: ResGraphContext.context,
): array<trustedCapabilityReference> =>
  switch await loadTrustedCapabilitiesForVersion(ctx, version.id) {
  | Some(capabilities) => capabilities
  | None if ctx->allowFixtureData => trustedCapabilitiesForVersion(version.id)
  | None => []
  }

/** Lightweight provider conversation summary for this edit session. */
@live @gql.field
let conversationSummary = async (
  session: profileEditSession,
  ~ctx: ResGraphContext.context,
): option<agentConversationSummary> =>
  switch await loadConversationSummaryForSession(ctx, session.id) {
  | Some(summary) => Some(summary)
  | None if ctx->allowFixtureData => conversationSummaryForSession(session.id)
  | None => None
  }

/** The selected context for this edit session. */
@live @gql.field
let selectionSnapshot = async (
  session: profileEditSession,
  ~ctx: ResGraphContext.context,
): option<selectionSnapshot> =>
  switch session.selectionSnapshotId {
  | None => None
  | Some(id) =>
    switch await loadSelectionSnapshotById(ctx, id) {
    | Some(snapshot) => Some(snapshot)
    | None if ctx->allowFixtureData && sameId(id, fixtureSelectionId) => Some(fixtureSelectionSnapshot)
    | None => None
    }
  }

/** The applied result version for this edit session. */
@live @gql.field
let resultVersion = async (
  session: profileEditSession,
  ~ctx: ResGraphContext.context,
): option<profileVersion> =>
  switch session.resultVersionId {
  | None => None
  | Some(versionId) =>
    // Request-scoped DataLoader batches DB-backed version lookups.
    switch await loadProfileVersionById(ctx, versionId) {
    | Some(version) => Some(version)
    | None if ctx->allowFixtureData =>
      switch profileVersionByRawId(versionId) {
      | Some(version) => Some(version)
      | None if versionId->internalIdFromMaybeGlobal->idToString == "stub-agent-result" =>
        Some(stubAgentVersionForSession(session))
      | None => None
      }
    | None => None
    }
  }

/** The actor that created this activity event. */
@live @gql.field
let actor = async (
  event: profileUpdateEvent,
  ~ctx: ResGraphContext.context,
): option<user> =>
  // Request-scoped DataLoader batches DB-backed friend activity actor lookups.
  switch await loadUserById(ctx, event.actorUserId) {
  | Some(user) => Some(user)
  | None if ctx->allowFixtureData => userById(event.actorUserId)
  | None => None
  }

/** The profile for this activity event. */
@live @gql.field
let eventProfile = async (
  event: profileUpdateEvent,
  ~ctx: ResGraphContext.context,
): option<profile> =>
  // Request-scoped DataLoader batches DB-backed friend activity profile lookups.
  switch await loadProfileById(ctx, event.profileId) {
  | Some(profile) => Some(profile)
  | None if ctx->allowFixtureData => profileById(event.profileId)
  | None => None
  }

/** The version published by this activity event. */
@live @gql.field
let eventProfileVersion = async (
  event: profileUpdateEvent,
  ~ctx: ResGraphContext.context,
): option<profileVersion> =>
  // Request-scoped DataLoader batches DB-backed friend activity version lookups.
  switch await loadProfileVersionById(ctx, event.profileVersionId) {
  | Some(version) => Some(version)
  | None if ctx->allowFixtureData => profileVersionByRawId(event.profileVersionId)
  | None => None
  }

/** Dev-key admin seed user. Uses pgtyped-rescript when DATABASE_URL is configured. */
@live @gql.field
let adminCreateSeedUser = async (
  _: mutation,
  ~input: adminCreateSeedUserInput,
  ~ctx: ResGraphContext.context,
): adminCreateSeedUserResult => {
  let outcome =
    if !ctx.isDevAdmin {
      SeedUserPersistenceUnavailable({
        message: "Dev admin token is required to create a seed user.",
      })
    } else if input.handle->isBlank || input.displayName->isBlank {
      let fields = switch (input.handle->isBlank, input.displayName->isBlank) {
      | (true, true) => ["handle", "displayName"]
      | (true, false) => ["handle"]
      | (false, true) => ["displayName"]
      | (false, false) => []
      }

      SeedUserInvalid({
        message: "Handle and display name are required.",
        fields,
      })
    } else {
      switch await dbCreateSeedUser(ctx, input) {
      | Some(result) =>
        SeedUserCreated({
          user: result.user,
          invite: result.invite,
          sessionToken: LocalSessionToken.issueForUserId(result.user.id->idString)->Option.getOr(""),
          warnings: [],
        })
      | None =>
        if !(ctx->allowFixtureData) {
          SeedUserPersistenceUnavailable({
            message: "Unable to create seed user with the configured database.",
          })
        } else {
          let seededUser = {
            ...fixtureViewer,
            id: id("stub-seed-" ++ input.handle),
            handle: input.handle,
            displayName: input.displayName,
            role: input.role->Option.getOr(UserRoleUser),
          }

          SeedUserCreated({
            user: seededUser,
            invite: {...fixtureInvite, inviterUserId: seededUser.id},
            sessionToken: LocalSessionToken.issueForUserId(seededUser.id->idString)->Option.getOr(""),
            warnings: ["Stub response only; no database write happened."],
          })
        }
      }
    }

  outcome->adminCreateSeedUserResultFromOutcome
}

/** Dev-key admin invite creation. Uses pgtyped-rescript when DATABASE_URL is configured. */
@live @gql.field
let adminCreateInvite = async (
  _: mutation,
  ~input: adminCreateInviteInput,
  ~ctx: ResGraphContext.context,
): adminCreateInviteResult => {
  let inviterUserId = input.inviterUserId->internalIdFromMaybeGlobal
  if !ctx.isDevAdmin {
    AdminCreateInviteFailed({message: "Dev admin token is required to create an invite."})
  } else {
    switch await dbCreateAdminInvite(ctx, inviterUserId) {
    | Some(invite) => AdminCreateInviteSucceeded({invite: invite})
    | None =>
      if !(ctx->allowFixtureData) {
        AdminCreateInviteFailed({message: "Unable to create an invite for that user."})
      } else {
        let invite = {
          ...fixtureInvite,
          id: id("stub-admin-created"),
          inviterUserId,
          code: Some("VIBE-STUB"),
        }

        AdminCreateInviteSucceeded({invite: invite})
      }
    }
  }
}

/** Invite redemption. This atomically creates the user, profile, invite grant, and invite friendship. */
@live @gql.field
let redeemInvite = async (
  _: mutation,
  ~input: redeemInviteInput,
  ~ctx: ResGraphContext.context,
): redeemInviteResult => {
  if input.code->isBlank {
    RedeemInviteFailed({message: "Invite code is required."})
  } else {
    switch await dbRedeemInvite(ctx, input) {
    | Some(InviteRedeemed(result)) =>
      RedeemInviteSucceeded({
        invite: result.invite,
        user: result.user,
        friendConnection: result.friendConnection,
        profile: result.profile,
        sessionToken: LocalSessionToken.issueForUserId(result.user.id->idString),
      })
    | Some(InviteRedeemInvalid) => RedeemInviteFailed({message: "This invite is not available."})
    | Some(InviteRedeemHandleTaken) =>
      RedeemInviteFailed({message: "Could not allocate a numeric handle for this profile."})
    | None =>
      if !(ctx->allowFixtureData) {
        RedeemInviteFailed({message: "Invite redemption is unavailable."})
      } else {
        let stubHandle = "0"
        let displayName = input.displayName->Option.getOr("New Vibespace")
        let user = {
          ...fixtureFriend,
          id: id("stub-redeemed-" ++ stubHandle),
          handle: stubHandle,
          displayName,
        }
        let invite = {
          ...fixtureInvite,
          code: None,
          inviteeUserId: Some(user.id),
          status: InviteStatusRedeemed,
          redeemedAt: Some(updatedAt),
        }
        let profile = {
          ...fixtureFriendProfile,
          id: id("stub-" ++ stubHandle),
          ownerUserId: user.id,
          slug: stubHandle,
          title: displayName ++ "'s Vibespace",
        }

        RedeemInviteSucceeded({
          invite,
          user,
          friendConnection: {...fixtureFriendConnection, userBId: user.id},
          profile,
          sessionToken: LocalSessionToken.issueForUserId(user.id->idString),
        })
      }
    }
  }
}

/** Manual profile save backed by pgtyped-rescript when DATABASE_URL is configured. */
@live @gql.field
let saveManualProfileVersion = async (
  _: mutation,
  ~input: saveManualProfileVersionInput,
  ~ctx: ResGraphContext.context,
): saveManualProfileVersionResult => {
  if input.html->isBlank || input.css->isBlank {
    SaveManualProfileVersionFailed(profileVersionFailure(
      ~profile=profileById(input.profileId),
      ~summary="Manual save failed validation.",
      ~validationErrors=["Profile HTML and CSS are required."],
      ~error="Profile HTML and CSS are required.",
    ))
  } else {
    switch ctx.databaseUrl {
    | Some(_) =>
      switch await loadProfileById(ctx, input.profileId) {
      | None =>
        SaveManualProfileVersionFailed(profileVersionFailure(
          ~profile=None,
          ~summary="Manual save failed.",
          ~validationErrors=[],
          ~error="Profile was not found.",
        ))
      | Some(profile) =>
        switch await profileWriteActorIdForViewer(ctx, profile) {
        | None =>
          SaveManualProfileVersionFailed(profileVersionFailure(
            ~profile=Some(profile),
            ~summary="Manual save was not authorized.",
            ~validationErrors=[],
            ~error=profileWriteAuthError,
          ))
        | Some(_) =>
          switch await ProfileHtmlValidation.validateDocument(~html=input.html, ~css=input.css) {
          | Invalid(message) =>
            SaveManualProfileVersionFailed(profileVersionFailure(
              ~profile=Some(profile),
              ~summary="Manual save failed validation.",
              ~validationErrors=[message],
              ~error=message,
            ))
          | Valid =>
            switch await dbSaveManualProfileVersion(ctx, input) {
            | Some(result) => SaveManualProfileVersionSucceeded(profileVersionSuccess(result))
            | None =>
              SaveManualProfileVersionFailed(profileVersionFailure(
                ~profile=Some(profile),
                ~summary="Manual save failed.",
                ~validationErrors=[],
                ~error="Unable to persist this profile version.",
              ))
            }
          }
        }
      }
    | None if ctx->allowFixtureData =>
      switch await ProfileHtmlValidation.validateDocument(~html=input.html, ~css=input.css) {
      | Invalid(message) =>
        SaveManualProfileVersionFailed(profileVersionFailure(
          ~profile=profileById(input.profileId),
          ~summary="Manual save failed validation.",
          ~validationErrors=[message],
          ~error=message,
        ))
      | Valid =>
        let version = stubSavedVersion(~input)
        SaveManualProfileVersionSucceeded({
          profile: stubPublishedProfile(~profileId=input.profileId, ~versionId=version.id),
          profileVersion: version,
          activityEvent: Some(stubActivity(~version, ~kind=ProfileUpdateEventKindProfilePublished)),
          summary: version.summary,
          warnings: ["Stub response only; no database write happened."],
        })
      }
    | None =>
      SaveManualProfileVersionFailed(profileVersionFailure(
        ~profile=None,
        ~summary="Manual save failed.",
        ~validationErrors=[],
        ~error="Manual profile saves require a database-backed profile.",
      ))
    }
  }
}

/** Restore profile version backed by pgtyped-rescript when DATABASE_URL is configured. */
@live @gql.field
let restoreProfileVersion = async (
  _: mutation,
  ~input: restoreProfileVersionInput,
  ~ctx: ResGraphContext.context,
): restoreProfileVersionResult =>
  switch ctx.databaseUrl {
  | Some(_) =>
    switch await loadProfileById(ctx, input.profileId) {
    | None =>
      RestoreProfileVersionFailed(profileVersionFailure(
        ~profile=None,
        ~summary="Restore failed.",
        ~validationErrors=[],
        ~error="Profile was not found.",
      ))
    | Some(profile) =>
      switch await profileWriteActorIdForViewer(ctx, profile) {
      | None =>
        RestoreProfileVersionFailed(profileVersionFailure(
          ~profile=Some(profile),
          ~summary="Restore was not authorized.",
          ~validationErrors=[],
          ~error=profileWriteAuthError,
        ))
      | Some(_) =>
        switch await dbRestoreProfileVersion(ctx, input) {
        | Some(result) => RestoreProfileVersionSucceeded(profileVersionSuccess(result))
        | None =>
          RestoreProfileVersionFailed(profileVersionFailure(
            ~profile=Some(profile),
            ~summary="Restore failed.",
            ~validationErrors=[],
            ~error="Profile version was not found.",
          ))
        }
      }
    }
  | None if ctx->allowFixtureData =>
    switch profileVersionByRawId(input.versionId) {
    | None =>
      RestoreProfileVersionFailed(profileVersionFailure(
        ~profile=profileById(input.profileId),
        ~summary="Restore failed.",
        ~validationErrors=[],
        ~error="Profile version was not found in fixture data.",
      ))
    | Some(sourceVersion) =>
      let version = stubRestoredVersion(~sourceVersion)
      RestoreProfileVersionSucceeded({
        profile: stubPublishedProfile(~profileId=input.profileId, ~versionId=version.id),
        profileVersion: version,
        activityEvent: Some(stubActivity(~version, ~kind=ProfileUpdateEventKindProfileRestored)),
        summary: version.summary,
        warnings: ["Stub response only; restore was not persisted."],
      })
    }
  | None =>
    RestoreProfileVersionFailed(profileVersionFailure(
      ~profile=None,
      ~summary="Restore failed.",
      ~validationErrors=[],
      ~error="Profile restores require a database-backed profile.",
    ))
  }

/** Agent edit submission backed by the server-side OpenAI provider. */
@live @gql.field
let submitAgentEdit = async (
  _: mutation,
  ~input: submitAgentEditInput,
  ~ctx: ResGraphContext.context,
): submitAgentEditResult => {
  if input.prompt->isBlank {
    SubmitAgentEditFailed(profileEditSessionFailure(
      ~summary="Agent edit was not submitted.",
      ~validationErrors=[],
      ~error="Prompt is required.",
    ))
  } else {
    switch ctx.databaseUrl {
    | None =>
      SubmitAgentEditFailed(profileEditSessionFailure(
        ~summary="Agent edit was not submitted.",
        ~validationErrors=[],
        ~error="Assistant changes require a database-backed profile.",
      ))
    | Some(databaseUrl) =>
      switch await loadProfileById(ctx, input.profileId) {
      | None =>
        SubmitAgentEditFailed(profileEditSessionFailure(
          ~summary="Agent edit was not submitted.",
          ~validationErrors=[],
          ~error="Profile was not found.",
        ))
      | Some(profile) =>
        switch await profileWriteActorIdForViewer(ctx, profile) {
        | None =>
          SubmitAgentEditFailed(profileEditSessionFailure(
            ~summary="Agent edit was not authorized.",
            ~validationErrors=[],
            ~error=profileWriteAuthError,
          ))
        | Some(actorUserId) =>
          let currentVersionId = input.currentVersionId->Option.map(rawDbIdString)
          let selectionLabel = input.selectionLabel
          let selectionAgentContext = input.selectionAgentContext
          let selectedRegionScreenshotDataUrl = input.selectedRegionScreenshotDataUrl
          let fullPageScreenshotDataUrl = input.fullPageScreenshotDataUrl
          let referenceImageDataUrl = input.referenceImageDataUrl
          let previousFailedHtml = input.previousFailedHtml
          let previousFailedCss = input.previousFailedCss
          let previousFailedSummary = input.previousFailedSummary
          let previousFailedWarnings = input.previousFailedWarnings
          let previousFailedValidationMessage = input.previousFailedValidationMessage
          let profileName = input.profileName
          let sendtag = input.sendtag
          let mode = input.mode->Option.map(assistantEditModeToWire)
          let result = await submitAgentEditOnServer({
            databaseUrl,
            profileId: input.profileId->rawDbIdString,
            currentVersionId: ?currentVersionId,
            actorUserId,
            prompt: input.prompt,
            selectionLabel: ?selectionLabel,
            selectionAgentContext: ?selectionAgentContext,
            selectedRegionScreenshotDataUrl: ?selectedRegionScreenshotDataUrl,
            fullPageScreenshotDataUrl: ?fullPageScreenshotDataUrl,
            referenceImageDataUrl: ?referenceImageDataUrl,
            previousFailedHtml: ?previousFailedHtml,
            previousFailedCss: ?previousFailedCss,
            previousFailedSummary: ?previousFailedSummary,
            previousFailedWarnings: ?previousFailedWarnings,
            previousFailedValidationMessage: ?previousFailedValidationMessage,
            profileName: ?profileName,
            sendtag: ?sendtag,
            mode: ?mode,
          })
          let editSession = result.session->Option.map(profileEditSessionFromAgentService)
          let resultVersionId = switch editSession {
          | Some(session) => session.resultVersionId
          | None => result.version->Option.map(version => version.id->ResGraph.id)
          }

          if result.ok {
            switch editSession {
            | Some(editSession) =>
              SubmitAgentEditSucceeded(profileEditSessionSuccess(
                ~editSession,
                ~providerConversationId=result.providerConversationId,
                ~resultVersionId,
                ~summary=result.summary,
                ~warnings=result.warnings,
                ~validationErrors=result.validationErrors,
              ))
            | None =>
              SubmitAgentEditFailed(profileEditSessionFailure(
                ~providerConversationId=?result.providerConversationId,
                ~resultVersionId=?resultVersionId,
                ~summary=result.summary,
                ~warnings=result.warnings,
                ~validationErrors=result.validationErrors,
                ~error=result.error->Option.getOr("Assistant request did not return an edit session."),
              ))
            }
          } else {
            SubmitAgentEditFailed(profileEditSessionFailure(
              ~editSession=?editSession,
              ~providerConversationId=?result.providerConversationId,
              ~resultVersionId=?resultVersionId,
              ~summary=result.summary,
              ~warnings=result.warnings,
              ~validationErrors=result.validationErrors,
              ~error=result.error->Option.getOr("Assistant request failed."),
            ))
          }
        }
      }
    }
  }
}

/** Cancel an edit session and persist the canceled state when DATABASE_URL is configured. */
@live @gql.field
let cancelProfileEditSession = async (
  _: mutation,
  ~input: cancelProfileEditSessionInput,
  ~ctx: ResGraphContext.context,
): cancelProfileEditSessionResult =>
  switch ctx.databaseUrl {
  | Some(_) =>
    switch await loadProfileEditSessionById(ctx, input.editSessionId) {
    | None =>
      CancelProfileEditSessionFailed(profileEditSessionFailure(
        ~summary="Edit session was not canceled.",
        ~validationErrors=[],
        ~error="Edit session was not found.",
      ))
    | Some(existingSession) =>
      switch await loadProfileById(ctx, existingSession.profileId) {
      | None =>
        CancelProfileEditSessionFailed(profileEditSessionFailure(
          ~summary="Edit session was not canceled.",
          ~validationErrors=[],
          ~error="Profile was not found.",
        ))
      | Some(profile) =>
        switch await profileWriteActorIdForViewer(ctx, profile) {
        | None =>
          CancelProfileEditSessionFailed(profileEditSessionFailure(
            ~summary="Edit session was not authorized.",
            ~validationErrors=[],
            ~error=profileWriteAuthError,
          ))
        | Some(_) =>
          switch await dbCancelProfileEditSession(ctx, input) {
          | Some(session) =>
            CancelProfileEditSessionSucceeded(profileEditSessionSuccess(
              ~editSession=session,
              ~providerConversationId=session.providerConversationId,
              ~resultVersionId=session.resultVersionId,
              ~summary="Edit session canceled.",
              ~warnings=[],
              ~validationErrors=[],
            ))
          | None =>
            CancelProfileEditSessionFailed(profileEditSessionFailure(
              ~summary="Edit session was not canceled.",
              ~validationErrors=[],
              ~error="Unable to persist the canceled edit session.",
            ))
          }
        }
      }
    }
  | None if ctx->allowFixtureData =>
    let session = {
      ...fixtureEditSession,
      id: input.editSessionId->internalIdFromMaybeGlobal,
      status: EditSessionStatusCanceled,
      progressPhase: EditProgressPreparing,
      error: Some("Canceled by user."),
    }

    CancelProfileEditSessionSucceeded(profileEditSessionSuccess(
      ~editSession=session,
      ~providerConversationId=session.providerConversationId,
      ~resultVersionId=session.resultVersionId,
      ~summary="Edit session canceled.",
      ~warnings=["Stub response only; cancellation was not persisted."],
      ~validationErrors=[],
    ))
  | None =>
    CancelProfileEditSessionFailed(profileEditSessionFailure(
      ~summary="Edit session was not canceled.",
      ~validationErrors=[],
      ~error="Edit session cancellation requires a database-backed profile.",
    ))
  }

/** Reactivate the invite code the current viewer used by disabling the viewer account. */
@live @gql.field
let reactivateUsedInvite = async (
  _: mutation,
  ~input: reactivateUsedInviteInput,
  ~ctx: ResGraphContext.context,
): reactivateUsedInviteResult => {
  switch await dbReactivateUsedInvite(ctx, input) {
  | Some(UsedInviteReactivated(result)) =>
    ReactivateUsedInviteSucceeded({invite: result.invite, user: result.user})
  | Some(UsedInviteConfirmationMissing) =>
    ReactivateUsedInviteFailed({
      message: "Confirm disabling this account before reactivating the invite code.",
    })
  | Some(UsedInviteNotFound) =>
    ReactivateUsedInviteFailed({message: "No redeemed invite was found for this account."})
  | None =>
    if !(ctx->allowFixtureData) {
      ReactivateUsedInviteFailed({message: "Invite reactivation is unavailable."})
    } else {
      if !input.confirmDisable {
        ReactivateUsedInviteFailed({
          message: "Confirm disabling this account before reactivating the invite code.",
        })
      } else {
        ReactivateUsedInviteSucceeded({
          invite: {...fixtureInvite, status: InviteStatusAvailable, inviteeUserId: None, redeemedAt: None},
          user: {...fixtureViewer, status: UserStatusDisabled, updatedAt},
        })
      }
    }
  }
}

/** Disable-user admin stub, only available in local fixture mode. */
@live @gql.field
let disableUser = (
  _: mutation,
  ~input: disableUserInput,
  ~ctx: ResGraphContext.context,
): disableUserResult =>
  if !ctx.isDevAdmin {
    DisableUserFailed({message: "Dev admin token is required to disable a user."})
  } else if !(ctx->allowFixtureData) {
    DisableUserFailed({message: "User disabling is not implemented for the configured database."})
  } else {
    switch userById(input.userId) {
    | None => DisableUserFailed({message: "User was not found in fixture data."})
    | Some(user) => DisableUserSucceeded({user: {...user, status: UserStatusDisabled, updatedAt}})
    }
  }

/** Disable-profile admin stub, only available in local fixture mode. */
@live @gql.field
let disableProfile = (
  _: mutation,
  ~input: disableProfileInput,
  ~ctx: ResGraphContext.context,
): disableProfileResult =>
  if !ctx.isDevAdmin {
    DisableProfileFailed({message: "Dev admin token is required to disable a profile."})
  } else if !(ctx->allowFixtureData) {
    DisableProfileFailed({message: "Profile disabling is not implemented for the configured database."})
  } else {
    switch profileById(input.profileId) {
    | None => DisableProfileFailed({message: "Profile was not found in fixture data."})
    | Some(profile) =>
      DisableProfileSucceeded({
        profile: {
          ...profile,
          visibility: ProfileVisibilityDisabled,
          disabledAt: Some(updatedAt),
          disabledReason: input.reason,
          updatedAt,
        },
      })
    }
  }
