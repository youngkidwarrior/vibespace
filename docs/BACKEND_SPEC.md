# Vibespace Backend SPEC

**Status:** Draft (frontend-derived, backend-tech-agnostic)  
**Last Updated:** 2026-05-12  
**Source of Truth:** Current frontend contracts in `apps/web/src/`, product direction from the Vibespace MVP, and Cos-style spec organization.
**Tooling Decision:** See `docs/RESCRIPT_GRAPHQL_BACKEND_TOOLING.md`.

## Implementation Status

- First-pass ResGraph schema and resolvers live in `packages/schema/src`.
- The runnable GraphQL Yoga/Bun app lives in `api/graphql/src`.
- Generated GraphQL SDL lives at `packages/schema/src/__generated__/schema.graphql`.
- First-pass Postgres desired-state SQL lives in `db/schemas/vibespace.sql`; database-level bootstrap lives in `db/bootstrap/vibespace.sql`.
- The viewer/profile/profile-version vertical slice is DB-backed through `pgtyped-rescript` when `DATABASE_URL` is configured, with deterministic fixture fallback when no database row is available.
- Remaining invite redemption, friend activity, edit-session persistence, agent conversation summaries, trusted capability references, and admin takedown paths still use fixture/stub behavior.

## Purpose

This document defines the expected backend shape for Vibespace and is the product/data contract the ReScript GraphQL backend should implement.

The frontend is currently a local-only profile editor where raw HTML and CSS are the durable profile source. The backend must preserve that authoring model while adding invite-only users, friend-visible profiles, durable profile versions, lightweight agent conversation persistence, and profile update activity.

## Scope

- Invite-only account creation and invite-chain provenance.
- Handle-only internal identity for the first backend MVP.
- One canonical profile per user.
- Friend-visible profile publishing by default.
- Instant publishing after generated or manual HTML/CSS passes validation.
- Immutable profile version history and restore.
- Lightweight prompt/session persistence with provider conversation ids.
- Friend graph bootstrapped from invite redemption.
- Basic profile update activity for friends.
- Minimal dev-key admin controls for internal testing and takedown.

## Non-Goals

- Re-specifying the backend tooling decision. This product/data spec stays mostly technology-neutral; backend tooling is tracked in `docs/RESCRIPT_GRAPHQL_BACKEND_TOOLING.md`.
- Building Send Stores integration.
- Integrating Send web extension crypto login or Sendtags in the first backend MVP.
- Supporting multiple profile pages per user.
- Supporting separate life-update posts independent of profile updates.
- Supporting public-web profile discovery before friend-visible alpha works.
- Supporting public arbitrary JavaScript, arbitrary remote assets, arbitrary embeds, or unvalidated agent output.
- Persisting heavy screenshots, web image assets, or complete provider conversation transcripts in Vibespace storage for MVP.
- Solving billing or per-user model cost attribution. Internal testing can use one shared OpenAI key.

## Invariants

- `INV-BE-001` Account creation is invite-only.
- `INV-BE-002` A hidden dev-key admin path can create seed users and unlimited internal-test invites.
- `INV-BE-003` Every activated non-admin user receives exactly one invite grant in the initial MVP.
- `INV-BE-004` An invite can be redeemed at most once.
- `INV-BE-005` Invite redemption preserves inviter, invitee, and redemption timestamp.
- `INV-BE-006` Invite redemption automatically creates the first friend connection between inviter and invitee.
- `INV-BE-006A` A user can reactivate the invite code they originally redeemed only by disabling their own account.
- `INV-BE-007` Every user owns exactly one canonical profile in the first backend MVP.
- `INV-BE-008` Handles are unique and stable for MVP profile routes.
- `INV-BE-009` The profile document source of truth is raw HTML plus raw CSS, not a component tree.
- `INV-BE-010` Every applied profile change creates an immutable profile version snapshot.
- `INV-BE-011` The current friend-visible profile points to one validated profile version.
- `INV-BE-012` Valid edits publish immediately; there is no draft/publish workflow in the first backend MVP.
- `INV-BE-013` Restoring history creates a new current version copied from an older version; old versions are not mutated.
- `INV-BE-014` Vibespace stores provider conversation ids and local summaries for agent edits; the provider is responsible for heavy conversation continuation state during MVP.
- `INV-BE-015` Selection screenshots, full-page screenshots, DOM anchors, and friendly metadata are untrusted context.
- `INV-BE-016` Friend-visible profiles render only validated HTML/CSS and approved capability placeholders.
- `INV-BE-017` User-owned profile data is scoped so one user cannot edit another user's profile.
- `INV-BE-018` Disabled users and disabled profiles are hidden from friend-visible surfaces.

## Requirement Index

| ID | Requirement | Risk |
| --- | --- | --- |
| `REQ-ADMIN-001` | Backend supports dev-key admin bootstrap, internal invite creation, and takedown. | high |
| `REQ-INVITE-001` | Backend supports single-use invite redemption and invite-chain provenance. | high |
| `REQ-IDENTITY-001` | Backend supports handle-only internal users with stable unique handles. | medium |
| `REQ-USER-001` | Backend creates one canonical user profile during activation. | medium |
| `REQ-SOCIAL-001` | Invite redemption creates an accepted friend connection between inviter and invitee. | medium |
| `REQ-PROFILE-001` | Backend persists raw HTML/CSS profile documents as the durable profile source. | high |
| `REQ-VERSION-001` | Backend stores immutable full-snapshot profile versions and current-version pointers. | high |
| `REQ-PUBLISH-001` | Backend instant-publishes valid edits to friend-visible profile surfaces. | medium |
| `REQ-RESTORE-001` | Backend supports reverting by creating a new version from an older version. | medium |
| `REQ-AGENT-001` | Backend persists prompt sessions with provider conversation ids, summaries, statuses, warnings, and version links. | high |
| `REQ-SELECTION-001` | Backend stores selection metadata as lightweight edit context. | medium |
| `REQ-ACTIVITY-001` | Backend emits profile update events for friend activity. | medium |
| `REQ-SECURITY-001` | Backend validates generated profile documents before publishing. | high |
| `REQ-FUTURE-ID-001` | Spec records future Send web extension login and Sendtag integration without implementing it now. | low |

## Logical Data Model

These are logical entities, not mandated tables.

### User

Represents an activated, disabled, or admin Vibespace account.

Required fields:

- `id`
- `handle`
- `displayName`
- `status`: `enabled`, `disabled`
- `role`: `user`, `admin`
- `invitedByUserId`
- `createdAt`
- `activatedAt`
- `updatedAt`

Rules:

- MVP identity is handle-only for internal testing.
- Handles are unique and stable. Handle changes, redirects, and history are not part of MVP.
- A disabled user keeps profile/version records for audit unless deletion policy later says otherwise.
- Future TODO: replace handle-only identity with Send web extension crypto login and Sendtags. Reference code exists at `~/Documents/Send/canton-monorepo/apps/webext/`, but it is intentionally not part of this MVP spec.

### Invite

Represents one invite grant and optional redemption.

Required fields:

- `id`
- `codeHash`
- `inviterUserId`
- `inviteeUserId`
- `status`: `available`, `redeemed`, `revoked`, `expired`
- `createdAt`
- `redeemedAt`
- `expiresAt`

Rules:

- Store only a hashed invite code server-side.
- Normal users receive exactly one available invite after activation.
- Admin users can create unlimited internal-test invites through the dev-key admin path.
- Redeeming an invite atomically marks it redeemed, creates or activates the user, creates the user's default profile, grants the new user one invite, and creates the inviter/invitee friend connection.
- A second redemption attempt for the same invite must fail without creating partial records.
- Reactivating a redeemed invite is allowed only for the account that redeemed it. The backend atomically disables that account, clears the invite's `inviteeUserId` and `redeemedAt`, and marks the invite `available` again.
- Disabled accounts keep profile/version records but are hidden from active invite-chain friend lists.
- Future TODO: invite purchase may happen through the Send web extension. Do not design purchase flows for this MVP.

### FriendConnection

Represents the first social graph for profile exploration.

Required fields:

- `id`
- `userAId`
- `userBId`
- `status`: `accepted`, `blocked`
- `source`: `invite`, `manual`
- `createdAt`
- `updatedAt`

Rules:

- Invite redemption creates an `accepted` connection with `source = invite`.
- Future manual friend requests can add `pending`, but the first MVP does not need pending requests.
- Blocked or disabled users are excluded from friend-visible profile and activity surfaces.

### Profile

Represents a user's canonical Vibespace profile.

Required fields:

- `id`
- `ownerUserId`
- `slug`
- `title`
- `visibility`: `friends`, `disabled`
- `currentVersionId`
- `createdAt`
- `updatedAt`
- `publishedAt`
- `disabledAt`
- `disabledReason`

Rules:

- First MVP defaults to one profile per user.
- Profile visibility defaults to `friends`.
- Public-web profile discovery is deferred.
- Friend-visible rendering uses `currentVersionId`.
- A disabled profile is hidden from friend-visible profile and activity surfaces.

### ProfileVersion

Represents an immutable HTML/CSS snapshot.

Required fields:

- `id`
- `profileId`
- `revisionNumber`
- `parentVersionId`
- `html`
- `css`
- `source`: `manual`, `agent`, `restore`, `import`
- `promptSessionId`
- `summary`
- `validationStatus`: `valid`, `invalid`
- `validationErrors`
- `createdByUserId`
- `createdAt`

Rules:

- Versions are append-only.
- `html` and `css` are full snapshots, not diffs, for the first backend MVP.
- The backend may store diffs or compressed blobs later, but consumers must be able to retrieve complete source strings.
- Invalid versions may be stored for debugging but must not become the friend-visible current version.
- Version history UI shows version metadata plus prompt summaries, not raw model trace payloads.
- Version history is exposed as a Relay-style connection with stable opaque cursors. Do not use array-index cursors for profile versions because new versions are inserted at the front.

### ProfileEditSession

Represents one prompt bubble, source-edit save, or resumable agent conversation.

Required fields:

- `id`
- `profileId`
- `userId`
- `providerConversationId`
- `status`: `draft`, `running`, `applied`, `failed`, `canceled`
- `prompt`
- `selectionSnapshotId`
- `resultVersionId`
- `summary`
- `warnings`
- `error`
- `createdAt`
- `updatedAt`

Frontend-derived progress phases:

- `preparing`
- `planning`
- `checking_web_context`
- `extracting_assets`
- `generating`
- `validating`
- `repairing`
- `applying`

Rules:

- Sessions are durable so a user can continue unfinished work later.
- The API response for agent edits must return `providerConversationId` when the provider supplies one.
- Vibespace stores enough local metadata to show history, restore versions, and resume a conversation through the provider.
- Vibespace does not need to persist full model request/response transcripts, screenshots, or image blobs for MVP.
- A session can produce zero or one applied profile version.
- Failed sessions retain local status, prompt, summary if any, warnings, errors, and provider conversation id if available.

### AgentConversationSummary

Represents lightweight local agent audit data.

Required fields:

- `id`
- `editSessionId`
- `provider`
- `providerConversationId`
- `model`
- `prompt`
- `selectionLabel`
- `selectionSnapshotId`
- `resultVersionId`
- `summary`
- `warnings`
- `error`
- `createdAt`

Rules:

- Store no API keys, auth headers, cookies, provider credentials, or private provider payloads.
- Treat provider conversation state as externally retained for MVP.
- If the provider cannot return a conversation id, the session still records the prompt and result version but cannot be resumed.

### SelectionSnapshot

Represents lightweight visual/DOM context behind an edit.

Required fields:

- `id`
- `profileId`
- `requestId`
- `kind`: `none`, `element`, `area`
- `label`
- `description`
- `agentContext`
- `bounds`
- `viewport`
- `nearestElement`
- `selectedElements`
- `createdAt`

Element metadata should include:

- `vibespaceId`
- `friendlyName`
- `friendlyDescription`
- `tagName`
- `text`
- `className`
- `selector`
- `bounds`

Rules:

- Friendly names and descriptions are user-facing labels, not implementation labels.
- Raw selectors and tag names are useful for agents and audit, but should not leak into consumer-facing UI by default.
- Area selections should preserve all sufficiently visible selected element metadata from the frontend selection buffer.
- Screenshot blobs and full-page images can remain in provider conversation state for MVP instead of Vibespace storage.

### TrustedCapabilityReference

Represents an approved external capability embedded through a placeholder, not raw HTML.

Required fields:

- `id`
- `profileVersionId`
- `kind`: `trusted_image`, `trusted_frame`
- `origin`
- `source`
- `canonicalUrl`
- `metadata`
- `validationStatus`
- `createdAt`

Rules:

- Generated HTML may reference trusted capabilities only through validated Vibespace placeholders.
- The backend validates exact origins and source URLs against the capability resolver output for that edit.
- Durable Vibespace asset proxy/cache is deferred. Direct local/internal trusted-origin use may continue only as a prototype constraint.

### ProfileUpdateEvent

Represents activity shown to friends.

Required fields:

- `id`
- `actorUserId`
- `profileId`
- `profileVersionId`
- `kind`: `profile_published`, `profile_restored`
- `title`
- `summary`
- `visibility`: `friends`
- `createdAt`

Rules:

- The first activity feed is derived from profile version publication events.
- Separate life-update posts are deferred until the profile authoring loop is stable.
- Events from disabled users or disabled profiles are hidden.

## API Contracts

These are behavior-level contracts, not REST or RPC route names.

### Admin

Admin APIs are hidden behind a dev key for internal MVP testing.

Required operations:

- Create a seed admin or seed user.
- Create unlimited internal-test invites.
- Disable a user.
- Disable a profile.

Rules:

- Dev-key admin APIs are not user-facing.
- Admin invite creation does not weaken the one-invite-per-normal-user rule.
- Disabled users/profiles are excluded from friend-visible profile loads and friend activity.

### Invites And Identity

Required operations:

- Redeem invite with a requested handle and display name.
- Return whether the current user has an available invite.
- Return the current user's invite code once available.
- Return the invite the current user originally redeemed, if any.
- Reactivate the current user's redeemed invite in exchange for disabling the current account.

Rules:

- Handle collisions return a user-facing error.
- Invite redemption is atomic.
- Invite code values are never stored in plaintext.

### Profiles

Required operations:

- Load current viewer profile.
- Load friend-visible profile by handle.
- Save a manual profile version.
- Restore an older version.
- List profile versions with prompt summaries.

Rules:

- The server loads the current profile source from storage when applying edits; client-supplied source is treated as candidate input, not authority.
- Valid saves publish instantly by updating `Profile.currentVersionId`.
- Profile viewers cannot access private edit sessions or provider conversation ids.

### Agent Edits

Required operations:

- Submit prompt for a profile and current version id.
- Attach lightweight selection metadata.
- Return progress/status.
- Return resulting version id on success.
- Return validation errors on failure.
- Return provider conversation id when available.
- Resume or continue an edit by provider conversation id where the provider supports it.

Response fields should include:

- `editSessionId`
- `providerConversationId`
- `status`
- `resultVersionId`
- `summary`
- `warnings`
- `error`
- `validationErrors`

Rules:

- Valid agent edits publish instantly after server-side validation.
- Invalid generated output does not update the current profile pointer.
- Vibespace relies on provider-retained context for heavy conversation state in MVP.

### Activity

Required operations:

- List recent profile update events for accepted friends.

Rules:

- Only friend-visible events are returned.
- Events from disabled users/profiles are hidden.
- The feed can be chronological; ranking is not required for MVP.

## Core Flows

### Admin Bootstrap

1. Internal operator calls the dev-key admin bootstrap path.
2. Backend creates the first admin or seed user.
3. Backend creates an initial invite for the first normal user or directly creates the seed user's profile.
4. Backend can create additional internal-test invites when needed.

### Invite Redemption

1. User submits invite code, handle, and display name.
2. Backend validates the invite is available and unexpired.
3. Backend validates handle uniqueness.
4. Backend creates or activates the handle-only user.
5. Backend creates the user's default friend-visible profile.
6. Backend grants the new normal user exactly one invite.
7. Backend marks the original invite redeemed.
8. Backend creates an accepted friend connection between inviter and invitee.

### Invite Reactivation

1. User requests to reactivate the invite code they originally used.
2. Backend requires explicit confirmation that the current account will be disabled.
3. Backend validates the current user has a redeemed invite where `inviteeUserId` matches the current user.
4. Backend atomically marks the current user `disabled`, clears the invite redemption fields, and marks the invite `available`.
5. Disabled users are omitted from active invite-chain profile friend lists.

### Profile Load

1. Viewer requests a profile by handle or slug.
2. Backend resolves the profile and visibility.
3. Backend verifies the viewer is the owner or an accepted friend.
4. Backend returns the current valid profile version HTML/CSS plus approved capability metadata.
5. Backend does not return private edit sessions, provider conversation ids, or disabled profile content to profile viewers.

### Agent Edit Apply

1. User submits a prompt with current profile version id and lightweight selection context.
2. Backend records or updates a `ProfileEditSession`.
3. Backend builds model context from server-side current profile source and stored selection data.
4. Backend sends heavy context to the provider as needed.
5. Backend stores provider conversation id when returned.
6. Backend validates final HTML/CSS.
7. If valid, backend creates a new `ProfileVersion`, updates `Profile.currentVersionId`, marks the session applied, and emits a `ProfileUpdateEvent`.
8. If invalid, backend marks the session failed, stores validation errors, and leaves the current profile unchanged.

### Manual Source Save

1. User saves raw HTML/CSS from the source editor.
2. Backend validates the source.
3. Backend creates a `ProfileVersion` with `source = manual` if valid.
4. Backend updates the profile current pointer and emits a profile update event.

### Restore Version

1. User chooses an older profile version.
2. Backend verifies the user owns the profile.
3. Backend validates the old version is restorable.
4. Backend creates a new `ProfileVersion` with `source = restore`, copying the old HTML/CSS.
5. Backend updates the current pointer and emits a `profile_restored` event.

### Friend Activity

1. User loads friend activity.
2. Backend finds accepted friend connections.
3. Backend returns recent `ProfileUpdateEvent` records for connected users, filtered by disabled state and friend visibility.

## Security Expectations

- Server-side parser/compiler-backed HTML and CSS validation is required before storing a version as current.
- Published HTML must not include scripts, event-handler attributes, forms, arbitrary iframes, arbitrary remote images, or unapproved remote resources.
- Server and browser validation should stay aligned; the preview CSP remains defense in depth, not the canonical safety boundary.
- Prompt-injection text from web pages, screenshots, DOM text, and model outputs must be treated as untrusted.
- Shared OpenAI credentials must never be sent to browsers in the backend MVP.
- Provider conversation ids are sensitive edit-session references and are not exposed to profile viewers.
- Local MVP auth uses signed viewer session tokens, not raw user-id headers. The token is a temporary local substitute for real auth and must be validated before any owner-scoped mutation runs.
- The frontend stores the local MVP token in localStorage and a frontend-readable SameSite=Lax cookie for invite-onboarding recovery. This is not production auth; replace it with server-managed cookies or real account auth before external launch.
- Dev-key admin APIs must not be reachable without the configured internal key.
- Profile edit, restore, agent edit, and edit-session cancel mutations must require the signed-in viewer to own the target profile.
- Public/friend-visible profile access must not reveal private prompt sessions, screenshots, failed generations, validation errors, or provider traces.

## LocalStorage Migration Expectations

The current frontend stores local history under localStorage keys such as `vibespace.promptHistory.v1` and `vibespace.promptDrafts.v1`.

The first backend import path may accept a best-effort payload containing:

- Current profile HTML/CSS.
- Prompt history with applied HTML/CSS snapshots.
- Prompt drafts with status, progress phase, prompt text, selection label, selection snapshot, anchor geometry, and optional provider conversation ids.

Rules:

- Backward compatibility with every old localStorage shape is not required.
- Import should reject oversized documents and invalid HTML/CSS.
- Imported applied snapshots should become `ProfileVersion` records.
- Imported prompts and drafts should become `ProfileEditSession` and `AgentConversationSummary` records where enough data exists.
- Screenshot data URLs can be ignored by backend import for MVP unless the provider conversation already retains them.

## Future TODOs

- Replace handle-only internal identity with Send web extension crypto login.
- Replace Vibespace handles with Sendtags when Send identity integration is ready.
- Explore invite purchase through the Send web extension.
- Add Vibespace-owned asset proxy/cache before public-web profiles or public-web image-heavy pages.
- Add deletion/export policy for users, profiles, versions, prompt summaries, and provider conversation references.
- Add manual friend requests and blocking UI after invite-chain social graph works.
- Add separate life-update posts only after profile version activity feels useful.
- Add public-web visibility only after moderation, asset policy, and abuse controls are stronger.

## Acceptance Criteria

- A seed admin or seed user can be created through a dev-key admin path.
- Admin can create unlimited internal-test invites without changing normal user invite limits.
- Redeeming an invite creates the invitee user, one friend-visible profile, one invite grant, and an accepted friend connection.
- The same invite cannot be redeemed twice.
- Handle collisions fail with a user-facing error.
- A user can reload Vibespace in a later session and receive the same current profile HTML/CSS.
- Every valid manual or agent edit instantly publishes to friends and creates a new immutable profile version.
- Agent edit responses include `providerConversationId` when the provider returns one.
- Version history shows versions plus prompt summaries and supports restore.
- Restoring an old version creates a new current version and leaves old versions unchanged.
- A friend sees a profile update event after a connected user publishes or restores a profile.
- A non-friend cannot load a friend-visible profile.
- A user cannot edit another user's profile.
- Disabled users and profiles disappear from friend-visible profile loads and activity feeds.
- Invalid generated HTML/CSS is retained as failed edit-session metadata but is not published as the current profile.

## Backend Tooling Selection Constraints

The product/data contract is complete enough to choose backend tooling next. Tooling should optimize for:

- Fast internal MVP delivery.
- Typed API contracts.
- Simple hidden dev-key admin guardrails.
- Durable full-snapshot version storage.
- Server-side HTML/CSS validation.
- Provider conversation id persistence.
- A credible path to future Send web extension identity and Sendtag integration.
