/* @generated */
@@warning("-30")

@live @unboxed
type enum_ActivityVisibility = 
  | FRIENDS
  | FutureAddedValue(string)


@live
type enum_ActivityVisibility_input = 
  | FRIENDS


@live @unboxed
type enum_AssistantEditMode = 
  | FAST
  | REASONING
  | FutureAddedValue(string)


@live @unboxed
type enum_AssistantEditMode_input = 
  | FAST
  | REASONING


@live @unboxed
type enum_EditProgressPhase = 
  | PREPARING
  | PLANNING
  | CHECKING_WEB_CONTEXT
  | EXTRACTING_ASSETS
  | GENERATING
  | VALIDATING
  | REPAIRING
  | APPLYING
  | FutureAddedValue(string)


@live @unboxed
type enum_EditProgressPhase_input = 
  | PREPARING
  | PLANNING
  | CHECKING_WEB_CONTEXT
  | EXTRACTING_ASSETS
  | GENERATING
  | VALIDATING
  | REPAIRING
  | APPLYING


@live @unboxed
type enum_FriendConnectionSource = 
  | INVITE
  | MANUAL
  | FutureAddedValue(string)


@live @unboxed
type enum_FriendConnectionSource_input = 
  | INVITE
  | MANUAL


@live @unboxed
type enum_FriendConnectionStatus = 
  | ACCEPTED
  | BLOCKED
  | FutureAddedValue(string)


@live @unboxed
type enum_FriendConnectionStatus_input = 
  | ACCEPTED
  | BLOCKED


@live @unboxed
type enum_InviteStatus = 
  | AVAILABLE
  | REDEEMED
  | REVOKED
  | EXPIRED
  | FutureAddedValue(string)


@live @unboxed
type enum_InviteStatus_input = 
  | AVAILABLE
  | REDEEMED
  | REVOKED
  | EXPIRED


@live @unboxed
type enum_ProfileEditSessionStatus = 
  | DRAFT
  | RUNNING
  | APPLIED
  | FAILED
  | CANCELED
  | FutureAddedValue(string)


@live @unboxed
type enum_ProfileEditSessionStatus_input = 
  | DRAFT
  | RUNNING
  | APPLIED
  | FAILED
  | CANCELED


@live @unboxed
type enum_ProfileUpdateEventKind = 
  | PROFILE_PUBLISHED
  | PROFILE_RESTORED
  | FutureAddedValue(string)


@live @unboxed
type enum_ProfileUpdateEventKind_input = 
  | PROFILE_PUBLISHED
  | PROFILE_RESTORED


@live @unboxed
type enum_ProfileVersionSource = 
  | MANUAL
  | AGENT
  | RESTORE
  | IMPORT
  | FutureAddedValue(string)


@live @unboxed
type enum_ProfileVersionSource_input = 
  | MANUAL
  | AGENT
  | RESTORE
  | IMPORT


@live @unboxed
type enum_ProfileVisibility = 
  | FRIENDS
  | DISABLED
  | FutureAddedValue(string)


@live @unboxed
type enum_ProfileVisibility_input = 
  | FRIENDS
  | DISABLED


@live @unboxed
type enum_SelectionSnapshotKind = 
  | NONE
  | ELEMENT
  | AREA
  | FutureAddedValue(string)


@live @unboxed
type enum_SelectionSnapshotKind_input = 
  | NONE
  | ELEMENT
  | AREA


@live @unboxed
type enum_TrustedCapabilityKind = 
  | TRUSTED_IMAGE
  | TRUSTED_FRAME
  | FutureAddedValue(string)


@live @unboxed
type enum_TrustedCapabilityKind_input = 
  | TRUSTED_IMAGE
  | TRUSTED_FRAME


@live @unboxed
type enum_UserRole = 
  | USER
  | ADMIN
  | FutureAddedValue(string)


@live @unboxed
type enum_UserRole_input = 
  | USER
  | ADMIN


@live @unboxed
type enum_UserStatus = 
  | ENABLED
  | DISABLED
  | FutureAddedValue(string)


@live @unboxed
type enum_UserStatus_input = 
  | ENABLED
  | DISABLED


@live @unboxed
type enum_ValidationStatus = 
  | VALID
  | INVALID
  | FutureAddedValue(string)


@live @unboxed
type enum_ValidationStatus_input = 
  | VALID
  | INVALID


@live @unboxed
type enum_RequiredFieldAction = 
  | NONE
  | LOG
  | THROW
  | FutureAddedValue(string)


@live @unboxed
type enum_RequiredFieldAction_input = 
  | NONE
  | LOG
  | THROW


@live @unboxed
type enum_CatchFieldTo = 
  | NULL
  | RESULT
  | FutureAddedValue(string)


@live @unboxed
type enum_CatchFieldTo_input = 
  | NULL
  | RESULT


@live
type rec input_AdminCreateInviteInput = {
  inviterUserId: string,
}

@live
and input_AdminCreateInviteInput_nullable = {
  inviterUserId: string,
}

@live
and input_AdminCreateSeedUserInput = {
  handle: string,
  displayName: string,
  role?: enum_UserRole_input,
}

@live
and input_AdminCreateSeedUserInput_nullable = {
  handle: string,
  displayName: string,
  role?: Null.t<enum_UserRole_input>,
}

@live
and input_CancelProfileEditSessionInput = {
  editSessionId: string,
}

@live
and input_CancelProfileEditSessionInput_nullable = {
  editSessionId: string,
}

@live
and input_DisableProfileInput = {
  profileId: string,
  reason?: string,
}

@live
and input_DisableProfileInput_nullable = {
  profileId: string,
  reason?: Null.t<string>,
}

@live
and input_DisableUserInput = {
  userId: string,
}

@live
and input_DisableUserInput_nullable = {
  userId: string,
}

@live
and input_ReactivateUsedInviteInput = {
  confirmDisable: bool,
}

@live
and input_ReactivateUsedInviteInput_nullable = {
  confirmDisable: bool,
}

@live
and input_RedeemInviteInput = {
  code: string,
  displayName?: string,
}

@live
and input_RedeemInviteInput_nullable = {
  code: string,
  displayName?: Null.t<string>,
}

@live
and input_RestoreProfileVersionInput = {
  profileId: string,
  versionId: string,
}

@live
and input_RestoreProfileVersionInput_nullable = {
  profileId: string,
  versionId: string,
}

@live
and input_SaveManualProfileVersionInput = {
  profileId: string,
  html: string,
  css: string,
  summary?: string,
}

@live
and input_SaveManualProfileVersionInput_nullable = {
  profileId: string,
  html: string,
  css: string,
  summary?: Null.t<string>,
}

@live
and input_SubmitAgentEditInput = {
  profileId: string,
  currentVersionId?: string,
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
  mode?: enum_AssistantEditMode_input,
}

@live
and input_SubmitAgentEditInput_nullable = {
  profileId: string,
  currentVersionId?: Null.t<string>,
  prompt: string,
  selectionLabel?: Null.t<string>,
  selectionAgentContext?: Null.t<string>,
  selectedRegionScreenshotDataUrl?: Null.t<string>,
  fullPageScreenshotDataUrl?: Null.t<string>,
  referenceImageDataUrl?: Null.t<string>,
  previousFailedHtml?: Null.t<string>,
  previousFailedCss?: Null.t<string>,
  previousFailedSummary?: Null.t<string>,
  previousFailedWarnings?: Null.t<string>,
  previousFailedValidationMessage?: Null.t<string>,
  profileName?: Null.t<string>,
  sendtag?: Null.t<string>,
  mode?: Null.t<enum_AssistantEditMode_input>,
}
