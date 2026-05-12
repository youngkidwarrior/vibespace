@@warning("-27-32")

open ResGraph__GraphQLJs

let typeUnwrapper: 'src => 'return = %raw(`function typeUnwrapper(src) { if (src == null) return null; if (typeof src === 'object' && src.hasOwnProperty('_0')) return src['_0']; if (typeof src === 'object' && src.hasOwnProperty('VAL')) return src['VAL']; return src;}`)
let inputUnionUnwrapper: (
  'src,
  array<string>,
  array<string>,
) => 'return = %raw(`function inputUnionUnwrapper(src, inlineRecordTypenames, emptyPayloadTypenames) {
      if (src == null) return null;
    
      let targetKey = null;
      let targetValue = null;
    
      Object.entries(src).forEach(([key, value]) => {
        if (value != null) {
          targetKey = key;
          targetValue = value;
        }
      });
    
      if (targetKey != null && targetValue != null) {
        let tagName = targetKey.slice(0, 1).toUpperCase() + targetKey.slice(1);
    
        if (inlineRecordTypenames.includes(tagName)) {
          return Object.assign({ TAG: tagName }, targetValue);
        }

        if (emptyPayloadTypenames.includes(tagName)) {
          return tagName;
        }
    
        return {
          TAG: tagName,
          _0: targetValue,
        };
      }
    
      return null;
    }
    `)
type inputObjectFieldConverterFn
external makeInputObjectFieldConverterFn: ('a => 'b) => inputObjectFieldConverterFn = "%identity"

let applyConversionToInputObject: (
  'a,
  array<(string, inputObjectFieldConverterFn)>,
) => 'a = %raw(`function applyConversionToInputObject(obj, instructions) {
      if (instructions.length === 0) return obj;
      let newObj = Object.assign({}, obj);
      instructions.forEach(instruction => {
        let value = newObj[instruction[0]];
         newObj[instruction[0]] = instruction[1](value);
      })
      return newObj;
    }`)

let enum_ActivityVisibility = GraphQLEnumType.make({
  name: "ActivityVisibility",
  description: ?None,
  values: {
    "FRIENDS": {GraphQLEnumType.value: "FRIENDS", description: ?None, deprecationReason: ?None},
  }->makeEnumValues,
})
let enum_AssistantEditMode = GraphQLEnumType.make({
  name: "AssistantEditMode",
  description: ?None,
  values: {
    "FAST": {GraphQLEnumType.value: "FAST", description: ?None, deprecationReason: ?None},
    "REASONING": {GraphQLEnumType.value: "REASONING", description: ?None, deprecationReason: ?None},
  }->makeEnumValues,
})
let enum_EditProgressPhase = GraphQLEnumType.make({
  name: "EditProgressPhase",
  description: ?None,
  values: {
    "PREPARING": {GraphQLEnumType.value: "PREPARING", description: ?None, deprecationReason: ?None},
    "PLANNING": {GraphQLEnumType.value: "PLANNING", description: ?None, deprecationReason: ?None},
    "CHECKING_WEB_CONTEXT": {
      GraphQLEnumType.value: "CHECKING_WEB_CONTEXT",
      description: ?None,
      deprecationReason: ?None,
    },
    "EXTRACTING_ASSETS": {
      GraphQLEnumType.value: "EXTRACTING_ASSETS",
      description: ?None,
      deprecationReason: ?None,
    },
    "GENERATING": {
      GraphQLEnumType.value: "GENERATING",
      description: ?None,
      deprecationReason: ?None,
    },
    "VALIDATING": {
      GraphQLEnumType.value: "VALIDATING",
      description: ?None,
      deprecationReason: ?None,
    },
    "REPAIRING": {GraphQLEnumType.value: "REPAIRING", description: ?None, deprecationReason: ?None},
    "APPLYING": {GraphQLEnumType.value: "APPLYING", description: ?None, deprecationReason: ?None},
  }->makeEnumValues,
})
let enum_FriendConnectionSource = GraphQLEnumType.make({
  name: "FriendConnectionSource",
  description: ?None,
  values: {
    "INVITE": {GraphQLEnumType.value: "INVITE", description: ?None, deprecationReason: ?None},
    "MANUAL": {GraphQLEnumType.value: "MANUAL", description: ?None, deprecationReason: ?None},
  }->makeEnumValues,
})
let enum_FriendConnectionStatus = GraphQLEnumType.make({
  name: "FriendConnectionStatus",
  description: ?None,
  values: {
    "ACCEPTED": {GraphQLEnumType.value: "ACCEPTED", description: ?None, deprecationReason: ?None},
    "BLOCKED": {GraphQLEnumType.value: "BLOCKED", description: ?None, deprecationReason: ?None},
  }->makeEnumValues,
})
let enum_InviteStatus = GraphQLEnumType.make({
  name: "InviteStatus",
  description: ?None,
  values: {
    "AVAILABLE": {GraphQLEnumType.value: "AVAILABLE", description: ?None, deprecationReason: ?None},
    "REDEEMED": {GraphQLEnumType.value: "REDEEMED", description: ?None, deprecationReason: ?None},
    "REVOKED": {GraphQLEnumType.value: "REVOKED", description: ?None, deprecationReason: ?None},
    "EXPIRED": {GraphQLEnumType.value: "EXPIRED", description: ?None, deprecationReason: ?None},
  }->makeEnumValues,
})
let enum_ProfileEditSessionStatus = GraphQLEnumType.make({
  name: "ProfileEditSessionStatus",
  description: ?None,
  values: {
    "DRAFT": {GraphQLEnumType.value: "DRAFT", description: ?None, deprecationReason: ?None},
    "RUNNING": {GraphQLEnumType.value: "RUNNING", description: ?None, deprecationReason: ?None},
    "APPLIED": {GraphQLEnumType.value: "APPLIED", description: ?None, deprecationReason: ?None},
    "FAILED": {GraphQLEnumType.value: "FAILED", description: ?None, deprecationReason: ?None},
    "CANCELED": {GraphQLEnumType.value: "CANCELED", description: ?None, deprecationReason: ?None},
  }->makeEnumValues,
})
let enum_ProfileUpdateEventKind = GraphQLEnumType.make({
  name: "ProfileUpdateEventKind",
  description: ?None,
  values: {
    "PROFILE_PUBLISHED": {
      GraphQLEnumType.value: "PROFILE_PUBLISHED",
      description: ?None,
      deprecationReason: ?None,
    },
    "PROFILE_RESTORED": {
      GraphQLEnumType.value: "PROFILE_RESTORED",
      description: ?None,
      deprecationReason: ?None,
    },
  }->makeEnumValues,
})
let enum_ProfileVersionSource = GraphQLEnumType.make({
  name: "ProfileVersionSource",
  description: ?None,
  values: {
    "MANUAL": {GraphQLEnumType.value: "MANUAL", description: ?None, deprecationReason: ?None},
    "AGENT": {GraphQLEnumType.value: "AGENT", description: ?None, deprecationReason: ?None},
    "RESTORE": {GraphQLEnumType.value: "RESTORE", description: ?None, deprecationReason: ?None},
    "IMPORT": {GraphQLEnumType.value: "IMPORT", description: ?None, deprecationReason: ?None},
  }->makeEnumValues,
})
let enum_ProfileVisibility = GraphQLEnumType.make({
  name: "ProfileVisibility",
  description: ?None,
  values: {
    "FRIENDS": {GraphQLEnumType.value: "FRIENDS", description: ?None, deprecationReason: ?None},
    "DISABLED": {GraphQLEnumType.value: "DISABLED", description: ?None, deprecationReason: ?None},
  }->makeEnumValues,
})
let enum_SelectionSnapshotKind = GraphQLEnumType.make({
  name: "SelectionSnapshotKind",
  description: ?None,
  values: {
    "NONE": {GraphQLEnumType.value: "NONE", description: ?None, deprecationReason: ?None},
    "ELEMENT": {GraphQLEnumType.value: "ELEMENT", description: ?None, deprecationReason: ?None},
    "AREA": {GraphQLEnumType.value: "AREA", description: ?None, deprecationReason: ?None},
  }->makeEnumValues,
})
let enum_TrustedCapabilityKind = GraphQLEnumType.make({
  name: "TrustedCapabilityKind",
  description: ?None,
  values: {
    "TRUSTED_IMAGE": {
      GraphQLEnumType.value: "TRUSTED_IMAGE",
      description: ?None,
      deprecationReason: ?None,
    },
    "TRUSTED_FRAME": {
      GraphQLEnumType.value: "TRUSTED_FRAME",
      description: ?None,
      deprecationReason: ?None,
    },
  }->makeEnumValues,
})
let enum_UserRole = GraphQLEnumType.make({
  name: "UserRole",
  description: ?None,
  values: {
    "USER": {GraphQLEnumType.value: "USER", description: ?None, deprecationReason: ?None},
    "ADMIN": {GraphQLEnumType.value: "ADMIN", description: ?None, deprecationReason: ?None},
  }->makeEnumValues,
})
let enum_UserStatus = GraphQLEnumType.make({
  name: "UserStatus",
  description: ?None,
  values: {
    "ENABLED": {GraphQLEnumType.value: "ENABLED", description: ?None, deprecationReason: ?None},
    "DISABLED": {GraphQLEnumType.value: "DISABLED", description: ?None, deprecationReason: ?None},
  }->makeEnumValues,
})
let enum_ValidationStatus = GraphQLEnumType.make({
  name: "ValidationStatus",
  description: ?None,
  values: {
    "VALID": {GraphQLEnumType.value: "VALID", description: ?None, deprecationReason: ?None},
    "INVALID": {GraphQLEnumType.value: "INVALID", description: ?None, deprecationReason: ?None},
  }->makeEnumValues,
})
let i_Node: ref<GraphQLInterfaceType.t> = Obj.magic({"contents": null})
let get_Node = () => i_Node.contents
let t_AdminCreateInviteSucceeded: ref<GraphQLObjectType.t> = Obj.magic({"contents": null})
let get_AdminCreateInviteSucceeded = () => t_AdminCreateInviteSucceeded.contents
let t_AdminCreateSeedUserSucceeded: ref<GraphQLObjectType.t> = Obj.magic({"contents": null})
let get_AdminCreateSeedUserSucceeded = () => t_AdminCreateSeedUserSucceeded.contents
let t_AdminCreateSeedUserUnavailable: ref<GraphQLObjectType.t> = Obj.magic({"contents": null})
let get_AdminCreateSeedUserUnavailable = () => t_AdminCreateSeedUserUnavailable.contents
let t_AdminCreateSeedUserValidationFailed: ref<GraphQLObjectType.t> = Obj.magic({"contents": null})
let get_AdminCreateSeedUserValidationFailed = () => t_AdminCreateSeedUserValidationFailed.contents
let t_AgentConversationSummary: ref<GraphQLObjectType.t> = Obj.magic({"contents": null})
let get_AgentConversationSummary = () => t_AgentConversationSummary.contents
let t_DisableProfileSucceeded: ref<GraphQLObjectType.t> = Obj.magic({"contents": null})
let get_DisableProfileSucceeded = () => t_DisableProfileSucceeded.contents
let t_DisableUserSucceeded: ref<GraphQLObjectType.t> = Obj.magic({"contents": null})
let get_DisableUserSucceeded = () => t_DisableUserSucceeded.contents
let t_FriendConnection: ref<GraphQLObjectType.t> = Obj.magic({"contents": null})
let get_FriendConnection = () => t_FriendConnection.contents
let t_Invite: ref<GraphQLObjectType.t> = Obj.magic({"contents": null})
let get_Invite = () => t_Invite.contents
let t_InviteChainFriend: ref<GraphQLObjectType.t> = Obj.magic({"contents": null})
let get_InviteChainFriend = () => t_InviteChainFriend.contents
let t_InviteChainFriendConnection: ref<GraphQLObjectType.t> = Obj.magic({"contents": null})
let get_InviteChainFriendConnection = () => t_InviteChainFriendConnection.contents
let t_InviteChainFriendEdge: ref<GraphQLObjectType.t> = Obj.magic({"contents": null})
let get_InviteChainFriendEdge = () => t_InviteChainFriendEdge.contents
let t_Mutation: ref<GraphQLObjectType.t> = Obj.magic({"contents": null})
let get_Mutation = () => t_Mutation.contents
let t_MutationFailed: ref<GraphQLObjectType.t> = Obj.magic({"contents": null})
let get_MutationFailed = () => t_MutationFailed.contents
let t_PageInfo: ref<GraphQLObjectType.t> = Obj.magic({"contents": null})
let get_PageInfo = () => t_PageInfo.contents
let t_Profile: ref<GraphQLObjectType.t> = Obj.magic({"contents": null})
let get_Profile = () => t_Profile.contents
let t_ProfileEditSession: ref<GraphQLObjectType.t> = Obj.magic({"contents": null})
let get_ProfileEditSession = () => t_ProfileEditSession.contents
let t_ProfileEditSessionConnection: ref<GraphQLObjectType.t> = Obj.magic({"contents": null})
let get_ProfileEditSessionConnection = () => t_ProfileEditSessionConnection.contents
let t_ProfileEditSessionEdge: ref<GraphQLObjectType.t> = Obj.magic({"contents": null})
let get_ProfileEditSessionEdge = () => t_ProfileEditSessionEdge.contents
let t_ProfileEditSessionMutationFailed: ref<GraphQLObjectType.t> = Obj.magic({"contents": null})
let get_ProfileEditSessionMutationFailed = () => t_ProfileEditSessionMutationFailed.contents
let t_ProfileEditSessionMutationSucceeded: ref<GraphQLObjectType.t> = Obj.magic({"contents": null})
let get_ProfileEditSessionMutationSucceeded = () => t_ProfileEditSessionMutationSucceeded.contents
let t_ProfileUpdateEvent: ref<GraphQLObjectType.t> = Obj.magic({"contents": null})
let get_ProfileUpdateEvent = () => t_ProfileUpdateEvent.contents
let t_ProfileUpdateEventConnection: ref<GraphQLObjectType.t> = Obj.magic({"contents": null})
let get_ProfileUpdateEventConnection = () => t_ProfileUpdateEventConnection.contents
let t_ProfileUpdateEventEdge: ref<GraphQLObjectType.t> = Obj.magic({"contents": null})
let get_ProfileUpdateEventEdge = () => t_ProfileUpdateEventEdge.contents
let t_ProfileVersion: ref<GraphQLObjectType.t> = Obj.magic({"contents": null})
let get_ProfileVersion = () => t_ProfileVersion.contents
let t_ProfileVersionConnection: ref<GraphQLObjectType.t> = Obj.magic({"contents": null})
let get_ProfileVersionConnection = () => t_ProfileVersionConnection.contents
let t_ProfileVersionEdge: ref<GraphQLObjectType.t> = Obj.magic({"contents": null})
let get_ProfileVersionEdge = () => t_ProfileVersionEdge.contents
let t_ProfileVersionMutationFailed: ref<GraphQLObjectType.t> = Obj.magic({"contents": null})
let get_ProfileVersionMutationFailed = () => t_ProfileVersionMutationFailed.contents
let t_ProfileVersionMutationSucceeded: ref<GraphQLObjectType.t> = Obj.magic({"contents": null})
let get_ProfileVersionMutationSucceeded = () => t_ProfileVersionMutationSucceeded.contents
let t_Query: ref<GraphQLObjectType.t> = Obj.magic({"contents": null})
let get_Query = () => t_Query.contents
let t_ReactivateUsedInviteSucceeded: ref<GraphQLObjectType.t> = Obj.magic({"contents": null})
let get_ReactivateUsedInviteSucceeded = () => t_ReactivateUsedInviteSucceeded.contents
let t_RedeemInviteSucceeded: ref<GraphQLObjectType.t> = Obj.magic({"contents": null})
let get_RedeemInviteSucceeded = () => t_RedeemInviteSucceeded.contents
let t_SelectedElementMetadata: ref<GraphQLObjectType.t> = Obj.magic({"contents": null})
let get_SelectedElementMetadata = () => t_SelectedElementMetadata.contents
let t_SelectionSnapshot: ref<GraphQLObjectType.t> = Obj.magic({"contents": null})
let get_SelectionSnapshot = () => t_SelectionSnapshot.contents
let t_SendtagLookupResult: ref<GraphQLObjectType.t> = Obj.magic({"contents": null})
let get_SendtagLookupResult = () => t_SendtagLookupResult.contents
let t_TrustedCapabilityReference: ref<GraphQLObjectType.t> = Obj.magic({"contents": null})
let get_TrustedCapabilityReference = () => t_TrustedCapabilityReference.contents
let t_User: ref<GraphQLObjectType.t> = Obj.magic({"contents": null})
let get_User = () => t_User.contents
let input_AdminCreateInviteInput: ref<GraphQLInputObjectType.t> = Obj.magic({"contents": null})
let get_AdminCreateInviteInput = () => input_AdminCreateInviteInput.contents
let input_AdminCreateInviteInput_conversionInstructions = []
let input_AdminCreateSeedUserInput: ref<GraphQLInputObjectType.t> = Obj.magic({"contents": null})
let get_AdminCreateSeedUserInput = () => input_AdminCreateSeedUserInput.contents
let input_AdminCreateSeedUserInput_conversionInstructions = []
let input_CancelProfileEditSessionInput: ref<GraphQLInputObjectType.t> = Obj.magic({
  "contents": null,
})
let get_CancelProfileEditSessionInput = () => input_CancelProfileEditSessionInput.contents
let input_CancelProfileEditSessionInput_conversionInstructions = []
let input_DisableProfileInput: ref<GraphQLInputObjectType.t> = Obj.magic({"contents": null})
let get_DisableProfileInput = () => input_DisableProfileInput.contents
let input_DisableProfileInput_conversionInstructions = []
let input_DisableUserInput: ref<GraphQLInputObjectType.t> = Obj.magic({"contents": null})
let get_DisableUserInput = () => input_DisableUserInput.contents
let input_DisableUserInput_conversionInstructions = []
let input_ReactivateUsedInviteInput: ref<GraphQLInputObjectType.t> = Obj.magic({"contents": null})
let get_ReactivateUsedInviteInput = () => input_ReactivateUsedInviteInput.contents
let input_ReactivateUsedInviteInput_conversionInstructions = []
let input_RedeemInviteInput: ref<GraphQLInputObjectType.t> = Obj.magic({"contents": null})
let get_RedeemInviteInput = () => input_RedeemInviteInput.contents
let input_RedeemInviteInput_conversionInstructions = []
let input_RestoreProfileVersionInput: ref<GraphQLInputObjectType.t> = Obj.magic({"contents": null})
let get_RestoreProfileVersionInput = () => input_RestoreProfileVersionInput.contents
let input_RestoreProfileVersionInput_conversionInstructions = []
let input_SaveManualProfileVersionInput: ref<GraphQLInputObjectType.t> = Obj.magic({
  "contents": null,
})
let get_SaveManualProfileVersionInput = () => input_SaveManualProfileVersionInput.contents
let input_SaveManualProfileVersionInput_conversionInstructions = []
let input_SubmitAgentEditInput: ref<GraphQLInputObjectType.t> = Obj.magic({"contents": null})
let get_SubmitAgentEditInput = () => input_SubmitAgentEditInput.contents
let input_SubmitAgentEditInput_conversionInstructions = []
input_AdminCreateInviteInput_conversionInstructions->Array.pushMany([])
input_AdminCreateSeedUserInput_conversionInstructions->Array.pushMany([
  ("role", makeInputObjectFieldConverterFn(v => v->Nullable.toOption)),
])
input_CancelProfileEditSessionInput_conversionInstructions->Array.pushMany([])
input_DisableProfileInput_conversionInstructions->Array.pushMany([
  ("reason", makeInputObjectFieldConverterFn(v => v->Nullable.toOption)),
])
input_DisableUserInput_conversionInstructions->Array.pushMany([])
input_ReactivateUsedInviteInput_conversionInstructions->Array.pushMany([])
input_RedeemInviteInput_conversionInstructions->Array.pushMany([
  ("displayName", makeInputObjectFieldConverterFn(v => v->Nullable.toOption)),
])
input_RestoreProfileVersionInput_conversionInstructions->Array.pushMany([])
input_SaveManualProfileVersionInput_conversionInstructions->Array.pushMany([
  ("summary", makeInputObjectFieldConverterFn(v => v->Nullable.toOption)),
])
input_SubmitAgentEditInput_conversionInstructions->Array.pushMany([
  ("currentVersionId", makeInputObjectFieldConverterFn(v => v->Nullable.toOption)),
  ("selectionLabel", makeInputObjectFieldConverterFn(v => v->Nullable.toOption)),
  ("selectionAgentContext", makeInputObjectFieldConverterFn(v => v->Nullable.toOption)),
  ("selectedRegionScreenshotDataUrl", makeInputObjectFieldConverterFn(v => v->Nullable.toOption)),
  ("fullPageScreenshotDataUrl", makeInputObjectFieldConverterFn(v => v->Nullable.toOption)),
  ("referenceImageDataUrl", makeInputObjectFieldConverterFn(v => v->Nullable.toOption)),
  ("previousFailedHtml", makeInputObjectFieldConverterFn(v => v->Nullable.toOption)),
  ("previousFailedCss", makeInputObjectFieldConverterFn(v => v->Nullable.toOption)),
  ("previousFailedSummary", makeInputObjectFieldConverterFn(v => v->Nullable.toOption)),
  ("previousFailedWarnings", makeInputObjectFieldConverterFn(v => v->Nullable.toOption)),
  ("previousFailedValidationMessage", makeInputObjectFieldConverterFn(v => v->Nullable.toOption)),
  ("profileName", makeInputObjectFieldConverterFn(v => v->Nullable.toOption)),
  ("sendtag", makeInputObjectFieldConverterFn(v => v->Nullable.toOption)),
  ("mode", makeInputObjectFieldConverterFn(v => v->Nullable.toOption)),
])
let union_AdminCreateInviteResult: ref<GraphQLUnionType.t> = Obj.magic({"contents": null})
let get_AdminCreateInviteResult = () => union_AdminCreateInviteResult.contents
let union_AdminCreateSeedUserResult: ref<GraphQLUnionType.t> = Obj.magic({"contents": null})
let get_AdminCreateSeedUserResult = () => union_AdminCreateSeedUserResult.contents
let union_CancelProfileEditSessionResult: ref<GraphQLUnionType.t> = Obj.magic({"contents": null})
let get_CancelProfileEditSessionResult = () => union_CancelProfileEditSessionResult.contents
let union_DisableProfileResult: ref<GraphQLUnionType.t> = Obj.magic({"contents": null})
let get_DisableProfileResult = () => union_DisableProfileResult.contents
let union_DisableUserResult: ref<GraphQLUnionType.t> = Obj.magic({"contents": null})
let get_DisableUserResult = () => union_DisableUserResult.contents
let union_ReactivateUsedInviteResult: ref<GraphQLUnionType.t> = Obj.magic({"contents": null})
let get_ReactivateUsedInviteResult = () => union_ReactivateUsedInviteResult.contents
let union_RedeemInviteResult: ref<GraphQLUnionType.t> = Obj.magic({"contents": null})
let get_RedeemInviteResult = () => union_RedeemInviteResult.contents
let union_RestoreProfileVersionResult: ref<GraphQLUnionType.t> = Obj.magic({"contents": null})
let get_RestoreProfileVersionResult = () => union_RestoreProfileVersionResult.contents
let union_SaveManualProfileVersionResult: ref<GraphQLUnionType.t> = Obj.magic({"contents": null})
let get_SaveManualProfileVersionResult = () => union_SaveManualProfileVersionResult.contents
let union_StartAgentEditResult: ref<GraphQLUnionType.t> = Obj.magic({"contents": null})
let get_StartAgentEditResult = () => union_StartAgentEditResult.contents
let union_SubmitAgentEditResult: ref<GraphQLUnionType.t> = Obj.magic({"contents": null})
let get_SubmitAgentEditResult = () => union_SubmitAgentEditResult.contents

let union_AdminCreateInviteResult_resolveType = (v: BackendSchema.adminCreateInviteResult) =>
  switch v {
  | AdminCreateInviteSucceeded(_) => "AdminCreateInviteSucceeded"
  | AdminCreateInviteFailed(_) => "MutationFailed"
  }

let union_AdminCreateSeedUserResult_resolveType = (v: BackendSchema.adminCreateSeedUserResult) =>
  switch v {
  | Succeeded(_) => "AdminCreateSeedUserSucceeded"
  | ValidationFailed(_) => "AdminCreateSeedUserValidationFailed"
  | Unavailable(_) => "AdminCreateSeedUserUnavailable"
  }

let union_CancelProfileEditSessionResult_resolveType = (
  v: BackendSchema.cancelProfileEditSessionResult,
) =>
  switch v {
  | CancelProfileEditSessionSucceeded(_) => "ProfileEditSessionMutationSucceeded"
  | CancelProfileEditSessionFailed(_) => "ProfileEditSessionMutationFailed"
  }

let union_DisableProfileResult_resolveType = (v: BackendSchema.disableProfileResult) =>
  switch v {
  | DisableProfileSucceeded(_) => "DisableProfileSucceeded"
  | DisableProfileFailed(_) => "MutationFailed"
  }

let union_DisableUserResult_resolveType = (v: BackendSchema.disableUserResult) =>
  switch v {
  | DisableUserSucceeded(_) => "DisableUserSucceeded"
  | DisableUserFailed(_) => "MutationFailed"
  }

let union_ReactivateUsedInviteResult_resolveType = (v: BackendSchema.reactivateUsedInviteResult) =>
  switch v {
  | ReactivateUsedInviteSucceeded(_) => "ReactivateUsedInviteSucceeded"
  | ReactivateUsedInviteFailed(_) => "MutationFailed"
  }

let union_RedeemInviteResult_resolveType = (v: BackendSchema.redeemInviteResult) =>
  switch v {
  | RedeemInviteSucceeded(_) => "RedeemInviteSucceeded"
  | RedeemInviteFailed(_) => "MutationFailed"
  }

let union_RestoreProfileVersionResult_resolveType = (
  v: BackendSchema.restoreProfileVersionResult,
) =>
  switch v {
  | RestoreProfileVersionSucceeded(_) => "ProfileVersionMutationSucceeded"
  | RestoreProfileVersionFailed(_) => "ProfileVersionMutationFailed"
  }

let union_SaveManualProfileVersionResult_resolveType = (
  v: BackendSchema.saveManualProfileVersionResult,
) =>
  switch v {
  | SaveManualProfileVersionSucceeded(_) => "ProfileVersionMutationSucceeded"
  | SaveManualProfileVersionFailed(_) => "ProfileVersionMutationFailed"
  }

let union_StartAgentEditResult_resolveType = (v: BackendSchema.startAgentEditResult) =>
  switch v {
  | StartAgentEditSucceeded(_) => "ProfileEditSessionMutationSucceeded"
  | StartAgentEditFailed(_) => "ProfileEditSessionMutationFailed"
  }

let union_SubmitAgentEditResult_resolveType = (v: BackendSchema.submitAgentEditResult) =>
  switch v {
  | SubmitAgentEditSucceeded(_) => "ProfileEditSessionMutationSucceeded"
  | SubmitAgentEditFailed(_) => "ProfileEditSessionMutationFailed"
  }

let interface_Node_resolveType = (v: Interface_node.Resolver.t) =>
  switch v {
  | ProfileUpdateEvent(_) => "ProfileUpdateEvent"
  | AgentConversationSummary(_) => "AgentConversationSummary"
  | TrustedCapabilityReference(_) => "TrustedCapabilityReference"
  | ProfileVersion(_) => "ProfileVersion"
  | ProfileEditSession(_) => "ProfileEditSession"
  | SelectionSnapshot(_) => "SelectionSnapshot"
  | Profile(_) => "Profile"
  | FriendConnection(_) => "FriendConnection"
  | Invite(_) => "Invite"
  | User(_) => "User"
  }

i_Node.contents = GraphQLInterfaceType.make({
  name: "Node",
  description: ?None,
  interfaces: [],
  fields: () =>
    {
      "id": {
        typ: Scalars.id->Scalars.toGraphQLType->nonNull,
        description: "Relay global id for every type implementing Node.",
        deprecationReason: ?None,
      },
    }->makeFields,
  resolveType: GraphQLInterfaceType.makeResolveInterfaceTypeFn(interface_Node_resolveType),
})
t_AdminCreateInviteSucceeded.contents = GraphQLObjectType.make({
  name: "AdminCreateInviteSucceeded",
  description: "An invite was created by an admin action.",
  interfaces: [],
  fields: () =>
    {
      "invite": {
        typ: get_Invite()->GraphQLObjectType.toGraphQLType->nonNull,
        description: ?None,
        deprecationReason: ?None,
        resolve: makeResolveFn((src, _args, _ctx, _info) => {
          let src = typeUnwrapper(src)
          src["invite"]
        }),
      },
    }->makeFields,
})
t_AdminCreateSeedUserSucceeded.contents = GraphQLObjectType.make({
  name: "AdminCreateSeedUserSucceeded",
  description: "The seed user and invite were created.",
  interfaces: [],
  fields: () =>
    {
      "invite": {
        typ: get_Invite()->GraphQLObjectType.toGraphQLType->nonNull,
        description: ?None,
        deprecationReason: ?None,
        resolve: makeResolveFn((src, _args, _ctx, _info) => {
          let src = typeUnwrapper(src)
          src["invite"]
        }),
      },
      "sessionToken": {
        typ: Scalars.string->Scalars.toGraphQLType->nonNull,
        description: ?None,
        deprecationReason: ?None,
        resolve: makeResolveFn((src, _args, _ctx, _info) => {
          let src = typeUnwrapper(src)
          src["sessionToken"]
        }),
      },
      "user": {
        typ: get_User()->GraphQLObjectType.toGraphQLType->nonNull,
        description: ?None,
        deprecationReason: ?None,
        resolve: makeResolveFn((src, _args, _ctx, _info) => {
          let src = typeUnwrapper(src)
          src["user"]
        }),
      },
      "warnings": {
        typ: GraphQLListType.make(Scalars.string->Scalars.toGraphQLType->nonNull)
        ->GraphQLListType.toGraphQLType
        ->nonNull,
        description: ?None,
        deprecationReason: ?None,
        resolve: makeResolveFn((src, _args, _ctx, _info) => {
          let src = typeUnwrapper(src)
          src["warnings"]
        }),
      },
    }->makeFields,
})
t_AdminCreateSeedUserUnavailable.contents = GraphQLObjectType.make({
  name: "AdminCreateSeedUserUnavailable",
  description: "The configured persistence layer could not create the seed user.",
  interfaces: [],
  fields: () =>
    {
      "message": {
        typ: Scalars.string->Scalars.toGraphQLType->nonNull,
        description: ?None,
        deprecationReason: ?None,
        resolve: makeResolveFn((src, _args, _ctx, _info) => {
          let src = typeUnwrapper(src)
          src["message"]
        }),
      },
    }->makeFields,
})
t_AdminCreateSeedUserValidationFailed.contents = GraphQLObjectType.make({
  name: "AdminCreateSeedUserValidationFailed",
  description: "The seed-user request did not pass validation.",
  interfaces: [],
  fields: () =>
    {
      "fields": {
        typ: GraphQLListType.make(Scalars.string->Scalars.toGraphQLType->nonNull)
        ->GraphQLListType.toGraphQLType
        ->nonNull,
        description: ?None,
        deprecationReason: ?None,
        resolve: makeResolveFn((src, _args, _ctx, _info) => {
          let src = typeUnwrapper(src)
          src["fields"]
        }),
      },
      "message": {
        typ: Scalars.string->Scalars.toGraphQLType->nonNull,
        description: ?None,
        deprecationReason: ?None,
        resolve: makeResolveFn((src, _args, _ctx, _info) => {
          let src = typeUnwrapper(src)
          src["message"]
        }),
      },
    }->makeFields,
})
t_AgentConversationSummary.contents = GraphQLObjectType.make({
  name: "AgentConversationSummary",
  description: ?None,
  interfaces: [get_Node()],
  fields: () =>
    {
      "createdAt": {
        typ: Scalars.string->Scalars.toGraphQLType->nonNull,
        description: ?None,
        deprecationReason: ?None,
        resolve: makeResolveFn((src, _args, _ctx, _info) => {
          let src = typeUnwrapper(src)
          src["createdAt"]
        }),
      },
      "editSessionId": {
        typ: Scalars.id->Scalars.toGraphQLType->nonNull,
        description: ?None,
        deprecationReason: ?None,
        resolve: makeResolveFn((src, _args, _ctx, _info) => {
          let src = typeUnwrapper(src)
          src["editSessionId"]
        }),
      },
      "error": {
        typ: Scalars.string->Scalars.toGraphQLType,
        description: ?None,
        deprecationReason: ?None,
        resolve: makeResolveFn((src, _args, _ctx, _info) => {
          let src = typeUnwrapper(src)
          src["error"]
        }),
      },
      "id": {
        typ: Scalars.id->Scalars.toGraphQLType->nonNull,
        description: "Relay global id for every type implementing Node.",
        deprecationReason: ?None,
        resolve: makeResolveFn((src, args, ctx, info) => {
          let src = typeUnwrapper(src)
          BackendNodeResolvers.id(src, ~typename=AgentConversationSummary)
        }),
      },
      "model": {
        typ: Scalars.string->Scalars.toGraphQLType,
        description: ?None,
        deprecationReason: ?None,
        resolve: makeResolveFn((src, _args, _ctx, _info) => {
          let src = typeUnwrapper(src)
          src["model"]
        }),
      },
      "prompt": {
        typ: Scalars.string->Scalars.toGraphQLType->nonNull,
        description: ?None,
        deprecationReason: ?None,
        resolve: makeResolveFn((src, _args, _ctx, _info) => {
          let src = typeUnwrapper(src)
          src["prompt"]
        }),
      },
      "provider": {
        typ: Scalars.string->Scalars.toGraphQLType->nonNull,
        description: ?None,
        deprecationReason: ?None,
        resolve: makeResolveFn((src, _args, _ctx, _info) => {
          let src = typeUnwrapper(src)
          src["provider"]
        }),
      },
      "providerConversationId": {
        typ: Scalars.string->Scalars.toGraphQLType,
        description: ?None,
        deprecationReason: ?None,
        resolve: makeResolveFn((src, _args, _ctx, _info) => {
          let src = typeUnwrapper(src)
          src["providerConversationId"]
        }),
      },
      "resultVersionId": {
        typ: Scalars.id->Scalars.toGraphQLType,
        description: ?None,
        deprecationReason: ?None,
        resolve: makeResolveFn((src, _args, _ctx, _info) => {
          let src = typeUnwrapper(src)
          src["resultVersionId"]
        }),
      },
      "selectionLabel": {
        typ: Scalars.string->Scalars.toGraphQLType,
        description: ?None,
        deprecationReason: ?None,
        resolve: makeResolveFn((src, _args, _ctx, _info) => {
          let src = typeUnwrapper(src)
          src["selectionLabel"]
        }),
      },
      "selectionSnapshotId": {
        typ: Scalars.id->Scalars.toGraphQLType,
        description: ?None,
        deprecationReason: ?None,
        resolve: makeResolveFn((src, _args, _ctx, _info) => {
          let src = typeUnwrapper(src)
          src["selectionSnapshotId"]
        }),
      },
      "summary": {
        typ: Scalars.string->Scalars.toGraphQLType->nonNull,
        description: ?None,
        deprecationReason: ?None,
        resolve: makeResolveFn((src, _args, _ctx, _info) => {
          let src = typeUnwrapper(src)
          src["summary"]
        }),
      },
      "warnings": {
        typ: GraphQLListType.make(Scalars.string->Scalars.toGraphQLType->nonNull)
        ->GraphQLListType.toGraphQLType
        ->nonNull,
        description: ?None,
        deprecationReason: ?None,
        resolve: makeResolveFn((src, _args, _ctx, _info) => {
          let src = typeUnwrapper(src)
          src["warnings"]
        }),
      },
    }->makeFields,
})
t_DisableProfileSucceeded.contents = GraphQLObjectType.make({
  name: "DisableProfileSucceeded",
  description: "An admin disabled a profile.",
  interfaces: [],
  fields: () =>
    {
      "profile": {
        typ: get_Profile()->GraphQLObjectType.toGraphQLType->nonNull,
        description: ?None,
        deprecationReason: ?None,
        resolve: makeResolveFn((src, _args, _ctx, _info) => {
          let src = typeUnwrapper(src)
          src["profile"]
        }),
      },
    }->makeFields,
})
t_DisableUserSucceeded.contents = GraphQLObjectType.make({
  name: "DisableUserSucceeded",
  description: "An admin disabled a user.",
  interfaces: [],
  fields: () =>
    {
      "user": {
        typ: get_User()->GraphQLObjectType.toGraphQLType->nonNull,
        description: ?None,
        deprecationReason: ?None,
        resolve: makeResolveFn((src, _args, _ctx, _info) => {
          let src = typeUnwrapper(src)
          src["user"]
        }),
      },
    }->makeFields,
})
t_FriendConnection.contents = GraphQLObjectType.make({
  name: "FriendConnection",
  description: ?None,
  interfaces: [get_Node()],
  fields: () =>
    {
      "createdAt": {
        typ: Scalars.string->Scalars.toGraphQLType->nonNull,
        description: ?None,
        deprecationReason: ?None,
        resolve: makeResolveFn((src, _args, _ctx, _info) => {
          let src = typeUnwrapper(src)
          src["createdAt"]
        }),
      },
      "id": {
        typ: Scalars.id->Scalars.toGraphQLType->nonNull,
        description: "Relay global id for every type implementing Node.",
        deprecationReason: ?None,
        resolve: makeResolveFn((src, args, ctx, info) => {
          let src = typeUnwrapper(src)
          BackendNodeResolvers.id(src, ~typename=FriendConnection)
        }),
      },
      "source": {
        typ: enum_FriendConnectionSource->GraphQLEnumType.toGraphQLType->nonNull,
        description: ?None,
        deprecationReason: ?None,
        resolve: makeResolveFn((src, _args, _ctx, _info) => {
          let src = typeUnwrapper(src)
          src["source"]
        }),
      },
      "status": {
        typ: enum_FriendConnectionStatus->GraphQLEnumType.toGraphQLType->nonNull,
        description: ?None,
        deprecationReason: ?None,
        resolve: makeResolveFn((src, _args, _ctx, _info) => {
          let src = typeUnwrapper(src)
          src["status"]
        }),
      },
      "updatedAt": {
        typ: Scalars.string->Scalars.toGraphQLType->nonNull,
        description: ?None,
        deprecationReason: ?None,
        resolve: makeResolveFn((src, _args, _ctx, _info) => {
          let src = typeUnwrapper(src)
          src["updatedAt"]
        }),
      },
      "userA": {
        typ: get_User()->GraphQLObjectType.toGraphQLType,
        description: "User A in this friendship.",
        deprecationReason: ?None,
        resolve: makeResolveFn((src, args, ctx, info) => {
          let src = typeUnwrapper(src)
          BackendSchema.userA(src, ~ctx)
        }),
      },
      "userAId": {
        typ: Scalars.id->Scalars.toGraphQLType->nonNull,
        description: ?None,
        deprecationReason: ?None,
        resolve: makeResolveFn((src, _args, _ctx, _info) => {
          let src = typeUnwrapper(src)
          src["userAId"]
        }),
      },
      "userB": {
        typ: get_User()->GraphQLObjectType.toGraphQLType,
        description: "User B in this friendship.",
        deprecationReason: ?None,
        resolve: makeResolveFn((src, args, ctx, info) => {
          let src = typeUnwrapper(src)
          BackendSchema.userB(src, ~ctx)
        }),
      },
      "userBId": {
        typ: Scalars.id->Scalars.toGraphQLType->nonNull,
        description: ?None,
        deprecationReason: ?None,
        resolve: makeResolveFn((src, _args, _ctx, _info) => {
          let src = typeUnwrapper(src)
          src["userBId"]
        }),
      },
    }->makeFields,
})
t_Invite.contents = GraphQLObjectType.make({
  name: "Invite",
  description: ?None,
  interfaces: [get_Node()],
  fields: () =>
    {
      "code": {
        typ: Scalars.string->Scalars.toGraphQLType,
        description: ?None,
        deprecationReason: ?None,
        resolve: makeResolveFn((src, _args, _ctx, _info) => {
          let src = typeUnwrapper(src)
          src["code"]
        }),
      },
      "codeHash": {
        typ: Scalars.string->Scalars.toGraphQLType->nonNull,
        description: ?None,
        deprecationReason: ?None,
        resolve: makeResolveFn((src, _args, _ctx, _info) => {
          let src = typeUnwrapper(src)
          src["codeHash"]
        }),
      },
      "createdAt": {
        typ: Scalars.string->Scalars.toGraphQLType->nonNull,
        description: ?None,
        deprecationReason: ?None,
        resolve: makeResolveFn((src, _args, _ctx, _info) => {
          let src = typeUnwrapper(src)
          src["createdAt"]
        }),
      },
      "expiresAt": {
        typ: Scalars.string->Scalars.toGraphQLType,
        description: ?None,
        deprecationReason: ?None,
        resolve: makeResolveFn((src, _args, _ctx, _info) => {
          let src = typeUnwrapper(src)
          src["expiresAt"]
        }),
      },
      "id": {
        typ: Scalars.id->Scalars.toGraphQLType->nonNull,
        description: "Relay global id for every type implementing Node.",
        deprecationReason: ?None,
        resolve: makeResolveFn((src, args, ctx, info) => {
          let src = typeUnwrapper(src)
          BackendNodeResolvers.id(src, ~typename=Invite)
        }),
      },
      "invitee": {
        typ: get_User()->GraphQLObjectType.toGraphQLType,
        description: "The invitee for this invite, when already redeemed.",
        deprecationReason: ?None,
        resolve: makeResolveFn((src, args, ctx, info) => {
          let src = typeUnwrapper(src)
          BackendSchema.invitee(src, ~ctx)
        }),
      },
      "inviteeUserId": {
        typ: Scalars.id->Scalars.toGraphQLType,
        description: ?None,
        deprecationReason: ?None,
        resolve: makeResolveFn((src, _args, _ctx, _info) => {
          let src = typeUnwrapper(src)
          src["inviteeUserId"]
        }),
      },
      "inviter": {
        typ: get_User()->GraphQLObjectType.toGraphQLType,
        description: "The inviter for this invite.",
        deprecationReason: ?None,
        resolve: makeResolveFn((src, args, ctx, info) => {
          let src = typeUnwrapper(src)
          BackendSchema.inviter(src, ~ctx)
        }),
      },
      "inviterUserId": {
        typ: Scalars.id->Scalars.toGraphQLType->nonNull,
        description: ?None,
        deprecationReason: ?None,
        resolve: makeResolveFn((src, _args, _ctx, _info) => {
          let src = typeUnwrapper(src)
          src["inviterUserId"]
        }),
      },
      "redeemedAt": {
        typ: Scalars.string->Scalars.toGraphQLType,
        description: ?None,
        deprecationReason: ?None,
        resolve: makeResolveFn((src, _args, _ctx, _info) => {
          let src = typeUnwrapper(src)
          src["redeemedAt"]
        }),
      },
      "status": {
        typ: enum_InviteStatus->GraphQLEnumType.toGraphQLType->nonNull,
        description: ?None,
        deprecationReason: ?None,
        resolve: makeResolveFn((src, _args, _ctx, _info) => {
          let src = typeUnwrapper(src)
          src["status"]
        }),
      },
    }->makeFields,
})
t_InviteChainFriend.contents = GraphQLObjectType.make({
  name: "InviteChainFriend",
  description: ?None,
  interfaces: [],
  fields: () =>
    {
      "avatarColor": {
        typ: Scalars.string->Scalars.toGraphQLType->nonNull,
        description: ?None,
        deprecationReason: ?None,
        resolve: makeResolveFn((src, _args, _ctx, _info) => {
          let src = typeUnwrapper(src)
          src["avatarColor"]
        }),
      },
      "avatarInitials": {
        typ: Scalars.string->Scalars.toGraphQLType->nonNull,
        description: ?None,
        deprecationReason: ?None,
        resolve: makeResolveFn((src, _args, _ctx, _info) => {
          let src = typeUnwrapper(src)
          src["avatarInitials"]
        }),
      },
      "avatarUrl": {
        typ: Scalars.string->Scalars.toGraphQLType,
        description: "The current Send avatar URL for this friend profile's stored Sendtag.",
        deprecationReason: ?None,
        resolve: makeResolveFn((src, args, ctx, info) => {
          let src = typeUnwrapper(src)
          BackendSchema.avatarUrl(src, ~ctx)
        }),
      },
      "createdAt": {
        typ: Scalars.string->Scalars.toGraphQLType->nonNull,
        description: ?None,
        deprecationReason: ?None,
        resolve: makeResolveFn((src, _args, _ctx, _info) => {
          let src = typeUnwrapper(src)
          src["createdAt"]
        }),
      },
      "displayName": {
        typ: Scalars.string->Scalars.toGraphQLType->nonNull,
        description: ?None,
        deprecationReason: ?None,
        resolve: makeResolveFn((src, _args, _ctx, _info) => {
          let src = typeUnwrapper(src)
          src["displayName"]
        }),
      },
      "handle": {
        typ: Scalars.string->Scalars.toGraphQLType->nonNull,
        description: ?None,
        deprecationReason: ?None,
        resolve: makeResolveFn((src, _args, _ctx, _info) => {
          let src = typeUnwrapper(src)
          src["handle"]
        }),
      },
      "id": {
        typ: Scalars.id->Scalars.toGraphQLType->nonNull,
        description: ?None,
        deprecationReason: ?None,
        resolve: makeResolveFn((src, _args, _ctx, _info) => {
          let src = typeUnwrapper(src)
          src["id"]
        }),
      },
      "profileId": {
        typ: Scalars.id->Scalars.toGraphQLType->nonNull,
        description: ?None,
        deprecationReason: ?None,
        resolve: makeResolveFn((src, _args, _ctx, _info) => {
          let src = typeUnwrapper(src)
          src["profileId"]
        }),
      },
      "profileSlug": {
        typ: Scalars.string->Scalars.toGraphQLType->nonNull,
        description: ?None,
        deprecationReason: ?None,
        resolve: makeResolveFn((src, _args, _ctx, _info) => {
          let src = typeUnwrapper(src)
          src["profileSlug"]
        }),
      },
      "profileTitle": {
        typ: Scalars.string->Scalars.toGraphQLType->nonNull,
        description: ?None,
        deprecationReason: ?None,
        resolve: makeResolveFn((src, _args, _ctx, _info) => {
          let src = typeUnwrapper(src)
          src["profileTitle"]
        }),
      },
      "userId": {
        typ: Scalars.id->Scalars.toGraphQLType->nonNull,
        description: ?None,
        deprecationReason: ?None,
        resolve: makeResolveFn((src, _args, _ctx, _info) => {
          let src = typeUnwrapper(src)
          src["userId"]
        }),
      },
    }->makeFields,
})
t_InviteChainFriendConnection.contents = GraphQLObjectType.make({
  name: "InviteChainFriendConnection",
  description: ?None,
  interfaces: [],
  fields: () =>
    {
      "edges": {
        typ: GraphQLListType.make(
          get_InviteChainFriendEdge()->GraphQLObjectType.toGraphQLType,
        )->GraphQLListType.toGraphQLType,
        description: ?None,
        deprecationReason: ?None,
        resolve: makeResolveFn((src, _args, _ctx, _info) => {
          let src = typeUnwrapper(src)
          src["edges"]
        }),
      },
      "pageInfo": {
        typ: get_PageInfo()->GraphQLObjectType.toGraphQLType->nonNull,
        description: ?None,
        deprecationReason: ?None,
        resolve: makeResolveFn((src, _args, _ctx, _info) => {
          let src = typeUnwrapper(src)
          src["pageInfo"]
        }),
      },
      "totalCount": {
        typ: Scalars.int->Scalars.toGraphQLType->nonNull,
        description: ?None,
        deprecationReason: ?None,
        resolve: makeResolveFn((src, _args, _ctx, _info) => {
          let src = typeUnwrapper(src)
          src["totalCount"]
        }),
      },
    }->makeFields,
})
t_InviteChainFriendEdge.contents = GraphQLObjectType.make({
  name: "InviteChainFriendEdge",
  description: ?None,
  interfaces: [],
  fields: () =>
    {
      "cursor": {
        typ: Scalars.string->Scalars.toGraphQLType->nonNull,
        description: ?None,
        deprecationReason: ?None,
        resolve: makeResolveFn((src, _args, _ctx, _info) => {
          let src = typeUnwrapper(src)
          src["cursor"]
        }),
      },
      "node": {
        typ: get_InviteChainFriend()->GraphQLObjectType.toGraphQLType,
        description: ?None,
        deprecationReason: ?None,
        resolve: makeResolveFn((src, _args, _ctx, _info) => {
          let src = typeUnwrapper(src)
          src["node"]
        }),
      },
    }->makeFields,
})
t_Mutation.contents = GraphQLObjectType.make({
  name: "Mutation",
  description: ?None,
  interfaces: [],
  fields: () =>
    {
      "adminCreateInvite": {
        typ: get_AdminCreateInviteResult()->GraphQLUnionType.toGraphQLType->nonNull,
        description: "Dev-key admin invite creation. Uses pgtyped-rescript when DATABASE_URL is configured.",
        deprecationReason: ?None,
        args: {
          "input": {
            typ: get_AdminCreateInviteInput()->GraphQLInputObjectType.toGraphQLType->nonNull,
          },
        }->makeArgs,
        resolve: makeResolveFn((src, args, ctx, info) => {
          let src = typeUnwrapper(src)
          BackendSchema.adminCreateInvite(
            src,
            ~ctx,
            ~input=args["input"]->applyConversionToInputObject(
              input_AdminCreateInviteInput_conversionInstructions,
            ),
          )
        }),
      },
      "adminCreateSeedUser": {
        typ: get_AdminCreateSeedUserResult()->GraphQLUnionType.toGraphQLType->nonNull,
        description: "Dev-key admin seed user. Uses pgtyped-rescript when DATABASE_URL is configured.",
        deprecationReason: ?None,
        args: {
          "input": {
            typ: get_AdminCreateSeedUserInput()->GraphQLInputObjectType.toGraphQLType->nonNull,
          },
        }->makeArgs,
        resolve: makeResolveFn((src, args, ctx, info) => {
          let src = typeUnwrapper(src)
          BackendSchema.adminCreateSeedUser(
            src,
            ~ctx,
            ~input=args["input"]->applyConversionToInputObject(
              input_AdminCreateSeedUserInput_conversionInstructions,
            ),
          )
        }),
      },
      "cancelProfileEditSession": {
        typ: get_CancelProfileEditSessionResult()->GraphQLUnionType.toGraphQLType->nonNull,
        description: "Cancel an edit session and persist the canceled state when DATABASE_URL is configured.",
        deprecationReason: ?None,
        args: {
          "input": {
            typ: get_CancelProfileEditSessionInput()->GraphQLInputObjectType.toGraphQLType->nonNull,
          },
        }->makeArgs,
        resolve: makeResolveFn((src, args, ctx, info) => {
          let src = typeUnwrapper(src)
          BackendSchema.cancelProfileEditSession(
            src,
            ~ctx,
            ~input=args["input"]->applyConversionToInputObject(
              input_CancelProfileEditSessionInput_conversionInstructions,
            ),
          )
        }),
      },
      "disableProfile": {
        typ: get_DisableProfileResult()->GraphQLUnionType.toGraphQLType->nonNull,
        description: "Disable-profile admin stub, only available in local fixture mode.",
        deprecationReason: ?None,
        args: {
          "input": {typ: get_DisableProfileInput()->GraphQLInputObjectType.toGraphQLType->nonNull},
        }->makeArgs,
        resolve: makeResolveFn((src, args, ctx, info) => {
          let src = typeUnwrapper(src)
          BackendSchema.disableProfile(
            src,
            ~ctx,
            ~input=args["input"]->applyConversionToInputObject(
              input_DisableProfileInput_conversionInstructions,
            ),
          )
        }),
      },
      "disableUser": {
        typ: get_DisableUserResult()->GraphQLUnionType.toGraphQLType->nonNull,
        description: "Disable-user admin stub, only available in local fixture mode.",
        deprecationReason: ?None,
        args: {
          "input": {typ: get_DisableUserInput()->GraphQLInputObjectType.toGraphQLType->nonNull},
        }->makeArgs,
        resolve: makeResolveFn((src, args, ctx, info) => {
          let src = typeUnwrapper(src)
          BackendSchema.disableUser(
            src,
            ~ctx,
            ~input=args["input"]->applyConversionToInputObject(
              input_DisableUserInput_conversionInstructions,
            ),
          )
        }),
      },
      "reactivateUsedInvite": {
        typ: get_ReactivateUsedInviteResult()->GraphQLUnionType.toGraphQLType->nonNull,
        description: "Reactivate the invite code the current viewer used by disabling the viewer account.",
        deprecationReason: ?None,
        args: {
          "input": {
            typ: get_ReactivateUsedInviteInput()->GraphQLInputObjectType.toGraphQLType->nonNull,
          },
        }->makeArgs,
        resolve: makeResolveFn((src, args, ctx, info) => {
          let src = typeUnwrapper(src)
          BackendSchema.reactivateUsedInvite(
            src,
            ~ctx,
            ~input=args["input"]->applyConversionToInputObject(
              input_ReactivateUsedInviteInput_conversionInstructions,
            ),
          )
        }),
      },
      "redeemInvite": {
        typ: get_RedeemInviteResult()->GraphQLUnionType.toGraphQLType->nonNull,
        description: "Invite redemption. This atomically creates the user, profile, invite grant, and invite friendship.",
        deprecationReason: ?None,
        args: {
          "input": {typ: get_RedeemInviteInput()->GraphQLInputObjectType.toGraphQLType->nonNull},
        }->makeArgs,
        resolve: makeResolveFn((src, args, ctx, info) => {
          let src = typeUnwrapper(src)
          BackendSchema.redeemInvite(
            src,
            ~ctx,
            ~input=args["input"]->applyConversionToInputObject(
              input_RedeemInviteInput_conversionInstructions,
            ),
          )
        }),
      },
      "restoreProfileVersion": {
        typ: get_RestoreProfileVersionResult()->GraphQLUnionType.toGraphQLType->nonNull,
        description: "Restore profile version backed by pgtyped-rescript when DATABASE_URL is configured.",
        deprecationReason: ?None,
        args: {
          "input": {
            typ: get_RestoreProfileVersionInput()->GraphQLInputObjectType.toGraphQLType->nonNull,
          },
        }->makeArgs,
        resolve: makeResolveFn((src, args, ctx, info) => {
          let src = typeUnwrapper(src)
          BackendSchema.restoreProfileVersion(
            src,
            ~ctx,
            ~input=args["input"]->applyConversionToInputObject(
              input_RestoreProfileVersionInput_conversionInstructions,
            ),
          )
        }),
      },
      "saveManualProfileVersion": {
        typ: get_SaveManualProfileVersionResult()->GraphQLUnionType.toGraphQLType->nonNull,
        description: "Manual profile save backed by pgtyped-rescript when DATABASE_URL is configured.",
        deprecationReason: ?None,
        args: {
          "input": {
            typ: get_SaveManualProfileVersionInput()->GraphQLInputObjectType.toGraphQLType->nonNull,
          },
        }->makeArgs,
        resolve: makeResolveFn((src, args, ctx, info) => {
          let src = typeUnwrapper(src)
          BackendSchema.saveManualProfileVersion(
            src,
            ~ctx,
            ~input=args["input"]->applyConversionToInputObject(
              input_SaveManualProfileVersionInput_conversionInstructions,
            ),
          )
        }),
      },
      "startAgentEdit": {
        typ: get_StartAgentEditResult()->GraphQLUnionType.toGraphQLType->nonNull,
        description: "Starts an agent edit and returns the initial edit session immediately for polling.",
        deprecationReason: ?None,
        args: {
          "input": {typ: get_SubmitAgentEditInput()->GraphQLInputObjectType.toGraphQLType->nonNull},
        }->makeArgs,
        resolve: makeResolveFn((src, args, ctx, info) => {
          let src = typeUnwrapper(src)
          BackendSchema.startAgentEdit(
            src,
            ~ctx,
            ~input=args["input"]->applyConversionToInputObject(
              input_SubmitAgentEditInput_conversionInstructions,
            ),
          )
        }),
      },
      "submitAgentEdit": {
        typ: get_SubmitAgentEditResult()->GraphQLUnionType.toGraphQLType->nonNull,
        description: "Agent edit submission backed by the server-side OpenAI provider.",
        deprecationReason: ?None,
        args: {
          "input": {typ: get_SubmitAgentEditInput()->GraphQLInputObjectType.toGraphQLType->nonNull},
        }->makeArgs,
        resolve: makeResolveFn((src, args, ctx, info) => {
          let src = typeUnwrapper(src)
          BackendSchema.submitAgentEdit(
            src,
            ~ctx,
            ~input=args["input"]->applyConversionToInputObject(
              input_SubmitAgentEditInput_conversionInstructions,
            ),
          )
        }),
      },
    }->makeFields,
})
t_MutationFailed.contents = GraphQLObjectType.make({
  name: "MutationFailed",
  description: "A mutation failed for an expected domain reason.",
  interfaces: [],
  fields: () =>
    {
      "message": {
        typ: Scalars.string->Scalars.toGraphQLType->nonNull,
        description: ?None,
        deprecationReason: ?None,
        resolve: makeResolveFn((src, _args, _ctx, _info) => {
          let src = typeUnwrapper(src)
          src["message"]
        }),
      },
    }->makeFields,
})
t_PageInfo.contents = GraphQLObjectType.make({
  name: "PageInfo",
  description: "Information about pagination in a connection.",
  interfaces: [],
  fields: () =>
    {
      "endCursor": {
        typ: Scalars.string->Scalars.toGraphQLType,
        description: "When paginating forwards, the cursor to continue.",
        deprecationReason: ?None,
        resolve: makeResolveFn((src, _args, _ctx, _info) => {
          let src = typeUnwrapper(src)
          src["endCursor"]
        }),
      },
      "hasNextPage": {
        typ: Scalars.boolean->Scalars.toGraphQLType->nonNull,
        description: "When paginating forwards, are there more items?",
        deprecationReason: ?None,
        resolve: makeResolveFn((src, _args, _ctx, _info) => {
          let src = typeUnwrapper(src)
          src["hasNextPage"]
        }),
      },
      "hasPreviousPage": {
        typ: Scalars.boolean->Scalars.toGraphQLType->nonNull,
        description: "When paginating backwards, are there more items?",
        deprecationReason: ?None,
        resolve: makeResolveFn((src, _args, _ctx, _info) => {
          let src = typeUnwrapper(src)
          src["hasPreviousPage"]
        }),
      },
      "startCursor": {
        typ: Scalars.string->Scalars.toGraphQLType,
        description: "When paginating backwards, the cursor to continue.",
        deprecationReason: ?None,
        resolve: makeResolveFn((src, _args, _ctx, _info) => {
          let src = typeUnwrapper(src)
          src["startCursor"]
        }),
      },
    }->makeFields,
})
t_Profile.contents = GraphQLObjectType.make({
  name: "Profile",
  description: ?None,
  interfaces: [get_Node()],
  fields: () =>
    {
      "createdAt": {
        typ: Scalars.string->Scalars.toGraphQLType->nonNull,
        description: ?None,
        deprecationReason: ?None,
        resolve: makeResolveFn((src, _args, _ctx, _info) => {
          let src = typeUnwrapper(src)
          src["createdAt"]
        }),
      },
      "currentVersion": {
        typ: get_ProfileVersion()->GraphQLObjectType.toGraphQLType,
        description: "The profile's current published version.",
        deprecationReason: ?None,
        resolve: makeResolveFn((src, args, ctx, info) => {
          let src = typeUnwrapper(src)
          BackendSchema.currentVersion(src, ~ctx)
        }),
      },
      "currentVersionId": {
        typ: Scalars.id->Scalars.toGraphQLType,
        description: ?None,
        deprecationReason: ?None,
        resolve: makeResolveFn((src, _args, _ctx, _info) => {
          let src = typeUnwrapper(src)
          src["currentVersionId"]
        }),
      },
      "disabledAt": {
        typ: Scalars.string->Scalars.toGraphQLType,
        description: ?None,
        deprecationReason: ?None,
        resolve: makeResolveFn((src, _args, _ctx, _info) => {
          let src = typeUnwrapper(src)
          src["disabledAt"]
        }),
      },
      "disabledReason": {
        typ: Scalars.string->Scalars.toGraphQLType,
        description: ?None,
        deprecationReason: ?None,
        resolve: makeResolveFn((src, _args, _ctx, _info) => {
          let src = typeUnwrapper(src)
          src["disabledReason"]
        }),
      },
      "editSessions": {
        typ: get_ProfileEditSessionConnection()->GraphQLObjectType.toGraphQLType->nonNull,
        description: "Prompt/edit history for this profile.",
        deprecationReason: ?None,
        args: {
          "after": {typ: Scalars.string->Scalars.toGraphQLType},
          "before": {typ: Scalars.string->Scalars.toGraphQLType},
          "first": {typ: Scalars.int->Scalars.toGraphQLType},
          "last": {typ: Scalars.int->Scalars.toGraphQLType},
        }->makeArgs,
        resolve: makeResolveFn((src, args, ctx, info) => {
          let src = typeUnwrapper(src)
          BackendSchema.editSessions(
            src,
            ~after=args["after"]->Nullable.toOption,
            ~before=args["before"]->Nullable.toOption,
            ~ctx,
            ~first=args["first"]->Nullable.toOption,
            ~last=args["last"]->Nullable.toOption,
          )
        }),
      },
      "id": {
        typ: Scalars.id->Scalars.toGraphQLType->nonNull,
        description: "Relay global id for every type implementing Node.",
        deprecationReason: ?None,
        resolve: makeResolveFn((src, args, ctx, info) => {
          let src = typeUnwrapper(src)
          BackendNodeResolvers.id(src, ~typename=Profile)
        }),
      },
      "inviteChainFriends": {
        typ: get_InviteChainFriendConnection()->GraphQLObjectType.toGraphQLType->nonNull,
        description: "Required Myspace-style friends list for the profile's invite-chain community.",
        deprecationReason: ?None,
        args: {
          "after": {typ: Scalars.string->Scalars.toGraphQLType},
          "before": {typ: Scalars.string->Scalars.toGraphQLType},
          "first": {typ: Scalars.int->Scalars.toGraphQLType},
          "last": {typ: Scalars.int->Scalars.toGraphQLType},
        }->makeArgs,
        resolve: makeResolveFn((src, args, ctx, info) => {
          let src = typeUnwrapper(src)
          BackendSchema.inviteChainFriends(
            src,
            ~after=args["after"]->Nullable.toOption,
            ~before=args["before"]->Nullable.toOption,
            ~ctx,
            ~first=args["first"]->Nullable.toOption,
            ~last=args["last"]->Nullable.toOption,
          )
        }),
      },
      "owner": {
        typ: get_User()->GraphQLObjectType.toGraphQLType,
        description: "The profile owner.",
        deprecationReason: ?None,
        resolve: makeResolveFn((src, args, ctx, info) => {
          let src = typeUnwrapper(src)
          BackendSchema.owner(src, ~ctx)
        }),
      },
      "ownerUserId": {
        typ: Scalars.id->Scalars.toGraphQLType->nonNull,
        description: ?None,
        deprecationReason: ?None,
        resolve: makeResolveFn((src, _args, _ctx, _info) => {
          let src = typeUnwrapper(src)
          src["ownerUserId"]
        }),
      },
      "publishedAt": {
        typ: Scalars.string->Scalars.toGraphQLType,
        description: ?None,
        deprecationReason: ?None,
        resolve: makeResolveFn((src, _args, _ctx, _info) => {
          let src = typeUnwrapper(src)
          src["publishedAt"]
        }),
      },
      "sendAvatarUrl": {
        typ: Scalars.string->Scalars.toGraphQLType,
        description: "The current Send avatar URL for this profile's optional Sendtag.",
        deprecationReason: ?None,
        resolve: makeResolveFn((src, args, ctx, info) => {
          let src = typeUnwrapper(src)
          BackendSchema.sendAvatarUrl(src, ~ctx)
        }),
      },
      "sendtag": {
        typ: Scalars.string->Scalars.toGraphQLType,
        description: ?None,
        deprecationReason: ?None,
        resolve: makeResolveFn((src, _args, _ctx, _info) => {
          let src = typeUnwrapper(src)
          src["sendtag"]
        }),
      },
      "slug": {
        typ: Scalars.string->Scalars.toGraphQLType->nonNull,
        description: ?None,
        deprecationReason: ?None,
        resolve: makeResolveFn((src, _args, _ctx, _info) => {
          let src = typeUnwrapper(src)
          src["slug"]
        }),
      },
      "title": {
        typ: Scalars.string->Scalars.toGraphQLType->nonNull,
        description: ?None,
        deprecationReason: ?None,
        resolve: makeResolveFn((src, _args, _ctx, _info) => {
          let src = typeUnwrapper(src)
          src["title"]
        }),
      },
      "updatedAt": {
        typ: Scalars.string->Scalars.toGraphQLType->nonNull,
        description: ?None,
        deprecationReason: ?None,
        resolve: makeResolveFn((src, _args, _ctx, _info) => {
          let src = typeUnwrapper(src)
          src["updatedAt"]
        }),
      },
      "versionHistory": {
        typ: get_ProfileVersionConnection()->GraphQLObjectType.toGraphQLType->nonNull,
        description: "Version history for this profile.",
        deprecationReason: ?None,
        args: {
          "after": {typ: Scalars.string->Scalars.toGraphQLType},
          "before": {typ: Scalars.string->Scalars.toGraphQLType},
          "first": {typ: Scalars.int->Scalars.toGraphQLType},
          "last": {typ: Scalars.int->Scalars.toGraphQLType},
        }->makeArgs,
        resolve: makeResolveFn((src, args, ctx, info) => {
          let src = typeUnwrapper(src)
          BackendSchema.versionHistory(
            src,
            ~after=args["after"]->Nullable.toOption,
            ~before=args["before"]->Nullable.toOption,
            ~ctx,
            ~first=args["first"]->Nullable.toOption,
            ~last=args["last"]->Nullable.toOption,
          )
        }),
      },
      "visibility": {
        typ: enum_ProfileVisibility->GraphQLEnumType.toGraphQLType->nonNull,
        description: ?None,
        deprecationReason: ?None,
        resolve: makeResolveFn((src, _args, _ctx, _info) => {
          let src = typeUnwrapper(src)
          src["visibility"]
        }),
      },
    }->makeFields,
})
t_ProfileEditSession.contents = GraphQLObjectType.make({
  name: "ProfileEditSession",
  description: ?None,
  interfaces: [get_Node()],
  fields: () =>
    {
      "conversationSummary": {
        typ: get_AgentConversationSummary()->GraphQLObjectType.toGraphQLType,
        description: "Lightweight provider conversation summary for this edit session.",
        deprecationReason: ?None,
        resolve: makeResolveFn((src, args, ctx, info) => {
          let src = typeUnwrapper(src)
          BackendSchema.conversationSummary(src, ~ctx)
        }),
      },
      "createdAt": {
        typ: Scalars.string->Scalars.toGraphQLType->nonNull,
        description: ?None,
        deprecationReason: ?None,
        resolve: makeResolveFn((src, _args, _ctx, _info) => {
          let src = typeUnwrapper(src)
          src["createdAt"]
        }),
      },
      "error": {
        typ: Scalars.string->Scalars.toGraphQLType,
        description: ?None,
        deprecationReason: ?None,
        resolve: makeResolveFn((src, _args, _ctx, _info) => {
          let src = typeUnwrapper(src)
          src["error"]
        }),
      },
      "id": {
        typ: Scalars.id->Scalars.toGraphQLType->nonNull,
        description: "Relay global id for every type implementing Node.",
        deprecationReason: ?None,
        resolve: makeResolveFn((src, args, ctx, info) => {
          let src = typeUnwrapper(src)
          BackendNodeResolvers.id(src, ~typename=ProfileEditSession)
        }),
      },
      "profileId": {
        typ: Scalars.id->Scalars.toGraphQLType->nonNull,
        description: ?None,
        deprecationReason: ?None,
        resolve: makeResolveFn((src, _args, _ctx, _info) => {
          let src = typeUnwrapper(src)
          src["profileId"]
        }),
      },
      "progressPhase": {
        typ: enum_EditProgressPhase->GraphQLEnumType.toGraphQLType->nonNull,
        description: ?None,
        deprecationReason: ?None,
        resolve: makeResolveFn((src, _args, _ctx, _info) => {
          let src = typeUnwrapper(src)
          src["progressPhase"]
        }),
      },
      "prompt": {
        typ: Scalars.string->Scalars.toGraphQLType->nonNull,
        description: ?None,
        deprecationReason: ?None,
        resolve: makeResolveFn((src, _args, _ctx, _info) => {
          let src = typeUnwrapper(src)
          src["prompt"]
        }),
      },
      "providerConversationId": {
        typ: Scalars.string->Scalars.toGraphQLType,
        description: ?None,
        deprecationReason: ?None,
        resolve: makeResolveFn((src, _args, _ctx, _info) => {
          let src = typeUnwrapper(src)
          src["providerConversationId"]
        }),
      },
      "resultVersion": {
        typ: get_ProfileVersion()->GraphQLObjectType.toGraphQLType,
        description: "The applied result version for this edit session.",
        deprecationReason: ?None,
        resolve: makeResolveFn((src, args, ctx, info) => {
          let src = typeUnwrapper(src)
          BackendSchema.resultVersion(src, ~ctx)
        }),
      },
      "resultVersionId": {
        typ: Scalars.id->Scalars.toGraphQLType,
        description: ?None,
        deprecationReason: ?None,
        resolve: makeResolveFn((src, _args, _ctx, _info) => {
          let src = typeUnwrapper(src)
          src["resultVersionId"]
        }),
      },
      "selectionSnapshot": {
        typ: get_SelectionSnapshot()->GraphQLObjectType.toGraphQLType,
        description: "The selected context for this edit session.",
        deprecationReason: ?None,
        resolve: makeResolveFn((src, args, ctx, info) => {
          let src = typeUnwrapper(src)
          BackendSchema.selectionSnapshot(src, ~ctx)
        }),
      },
      "selectionSnapshotId": {
        typ: Scalars.id->Scalars.toGraphQLType,
        description: ?None,
        deprecationReason: ?None,
        resolve: makeResolveFn((src, _args, _ctx, _info) => {
          let src = typeUnwrapper(src)
          src["selectionSnapshotId"]
        }),
      },
      "status": {
        typ: enum_ProfileEditSessionStatus->GraphQLEnumType.toGraphQLType->nonNull,
        description: ?None,
        deprecationReason: ?None,
        resolve: makeResolveFn((src, _args, _ctx, _info) => {
          let src = typeUnwrapper(src)
          src["status"]
        }),
      },
      "summary": {
        typ: Scalars.string->Scalars.toGraphQLType->nonNull,
        description: ?None,
        deprecationReason: ?None,
        resolve: makeResolveFn((src, _args, _ctx, _info) => {
          let src = typeUnwrapper(src)
          src["summary"]
        }),
      },
      "updatedAt": {
        typ: Scalars.string->Scalars.toGraphQLType->nonNull,
        description: ?None,
        deprecationReason: ?None,
        resolve: makeResolveFn((src, _args, _ctx, _info) => {
          let src = typeUnwrapper(src)
          src["updatedAt"]
        }),
      },
      "userId": {
        typ: Scalars.id->Scalars.toGraphQLType->nonNull,
        description: ?None,
        deprecationReason: ?None,
        resolve: makeResolveFn((src, _args, _ctx, _info) => {
          let src = typeUnwrapper(src)
          src["userId"]
        }),
      },
      "warnings": {
        typ: GraphQLListType.make(Scalars.string->Scalars.toGraphQLType->nonNull)
        ->GraphQLListType.toGraphQLType
        ->nonNull,
        description: ?None,
        deprecationReason: ?None,
        resolve: makeResolveFn((src, _args, _ctx, _info) => {
          let src = typeUnwrapper(src)
          src["warnings"]
        }),
      },
    }->makeFields,
})
t_ProfileEditSessionConnection.contents = GraphQLObjectType.make({
  name: "ProfileEditSessionConnection",
  description: ?None,
  interfaces: [],
  fields: () =>
    {
      "edges": {
        typ: GraphQLListType.make(
          get_ProfileEditSessionEdge()->GraphQLObjectType.toGraphQLType,
        )->GraphQLListType.toGraphQLType,
        description: ?None,
        deprecationReason: ?None,
        resolve: makeResolveFn((src, _args, _ctx, _info) => {
          let src = typeUnwrapper(src)
          src["edges"]
        }),
      },
      "pageInfo": {
        typ: get_PageInfo()->GraphQLObjectType.toGraphQLType->nonNull,
        description: ?None,
        deprecationReason: ?None,
        resolve: makeResolveFn((src, _args, _ctx, _info) => {
          let src = typeUnwrapper(src)
          src["pageInfo"]
        }),
      },
      "totalCount": {
        typ: Scalars.int->Scalars.toGraphQLType->nonNull,
        description: ?None,
        deprecationReason: ?None,
        resolve: makeResolveFn((src, _args, _ctx, _info) => {
          let src = typeUnwrapper(src)
          src["totalCount"]
        }),
      },
    }->makeFields,
})
t_ProfileEditSessionEdge.contents = GraphQLObjectType.make({
  name: "ProfileEditSessionEdge",
  description: ?None,
  interfaces: [],
  fields: () =>
    {
      "cursor": {
        typ: Scalars.string->Scalars.toGraphQLType->nonNull,
        description: ?None,
        deprecationReason: ?None,
        resolve: makeResolveFn((src, _args, _ctx, _info) => {
          let src = typeUnwrapper(src)
          src["cursor"]
        }),
      },
      "node": {
        typ: get_ProfileEditSession()->GraphQLObjectType.toGraphQLType,
        description: ?None,
        deprecationReason: ?None,
        resolve: makeResolveFn((src, _args, _ctx, _info) => {
          let src = typeUnwrapper(src)
          src["node"]
        }),
      },
    }->makeFields,
})
t_ProfileEditSessionMutationFailed.contents = GraphQLObjectType.make({
  name: "ProfileEditSessionMutationFailed",
  description: "An edit-session mutation failed for an expected domain reason.",
  interfaces: [],
  fields: () =>
    {
      "editSession": {
        typ: get_ProfileEditSession()->GraphQLObjectType.toGraphQLType,
        description: ?None,
        deprecationReason: ?None,
        resolve: makeResolveFn((src, _args, _ctx, _info) => {
          let src = typeUnwrapper(src)
          src["editSession"]
        }),
      },
      "message": {
        typ: Scalars.string->Scalars.toGraphQLType->nonNull,
        description: ?None,
        deprecationReason: ?None,
        resolve: makeResolveFn((src, _args, _ctx, _info) => {
          let src = typeUnwrapper(src)
          src["message"]
        }),
      },
      "providerConversationId": {
        typ: Scalars.string->Scalars.toGraphQLType,
        description: ?None,
        deprecationReason: ?None,
        resolve: makeResolveFn((src, _args, _ctx, _info) => {
          let src = typeUnwrapper(src)
          src["providerConversationId"]
        }),
      },
      "resultVersionId": {
        typ: Scalars.id->Scalars.toGraphQLType,
        description: ?None,
        deprecationReason: ?None,
        resolve: makeResolveFn((src, _args, _ctx, _info) => {
          let src = typeUnwrapper(src)
          src["resultVersionId"]
        }),
      },
      "summary": {
        typ: Scalars.string->Scalars.toGraphQLType->nonNull,
        description: ?None,
        deprecationReason: ?None,
        resolve: makeResolveFn((src, _args, _ctx, _info) => {
          let src = typeUnwrapper(src)
          src["summary"]
        }),
      },
      "validationErrors": {
        typ: GraphQLListType.make(Scalars.string->Scalars.toGraphQLType->nonNull)
        ->GraphQLListType.toGraphQLType
        ->nonNull,
        description: ?None,
        deprecationReason: ?None,
        resolve: makeResolveFn((src, _args, _ctx, _info) => {
          let src = typeUnwrapper(src)
          src["validationErrors"]
        }),
      },
      "warnings": {
        typ: GraphQLListType.make(Scalars.string->Scalars.toGraphQLType->nonNull)
        ->GraphQLListType.toGraphQLType
        ->nonNull,
        description: ?None,
        deprecationReason: ?None,
        resolve: makeResolveFn((src, _args, _ctx, _info) => {
          let src = typeUnwrapper(src)
          src["warnings"]
        }),
      },
    }->makeFields,
})
t_ProfileEditSessionMutationSucceeded.contents = GraphQLObjectType.make({
  name: "ProfileEditSessionMutationSucceeded",
  description: "An edit-session mutation completed with a persisted session.",
  interfaces: [],
  fields: () =>
    {
      "editSession": {
        typ: get_ProfileEditSession()->GraphQLObjectType.toGraphQLType->nonNull,
        description: ?None,
        deprecationReason: ?None,
        resolve: makeResolveFn((src, _args, _ctx, _info) => {
          let src = typeUnwrapper(src)
          src["editSession"]
        }),
      },
      "providerConversationId": {
        typ: Scalars.string->Scalars.toGraphQLType,
        description: ?None,
        deprecationReason: ?None,
        resolve: makeResolveFn((src, _args, _ctx, _info) => {
          let src = typeUnwrapper(src)
          src["providerConversationId"]
        }),
      },
      "resultVersionId": {
        typ: Scalars.id->Scalars.toGraphQLType,
        description: ?None,
        deprecationReason: ?None,
        resolve: makeResolveFn((src, _args, _ctx, _info) => {
          let src = typeUnwrapper(src)
          src["resultVersionId"]
        }),
      },
      "summary": {
        typ: Scalars.string->Scalars.toGraphQLType->nonNull,
        description: ?None,
        deprecationReason: ?None,
        resolve: makeResolveFn((src, _args, _ctx, _info) => {
          let src = typeUnwrapper(src)
          src["summary"]
        }),
      },
      "validationErrors": {
        typ: GraphQLListType.make(Scalars.string->Scalars.toGraphQLType->nonNull)
        ->GraphQLListType.toGraphQLType
        ->nonNull,
        description: ?None,
        deprecationReason: ?None,
        resolve: makeResolveFn((src, _args, _ctx, _info) => {
          let src = typeUnwrapper(src)
          src["validationErrors"]
        }),
      },
      "warnings": {
        typ: GraphQLListType.make(Scalars.string->Scalars.toGraphQLType->nonNull)
        ->GraphQLListType.toGraphQLType
        ->nonNull,
        description: ?None,
        deprecationReason: ?None,
        resolve: makeResolveFn((src, _args, _ctx, _info) => {
          let src = typeUnwrapper(src)
          src["warnings"]
        }),
      },
    }->makeFields,
})
t_ProfileUpdateEvent.contents = GraphQLObjectType.make({
  name: "ProfileUpdateEvent",
  description: ?None,
  interfaces: [get_Node()],
  fields: () =>
    {
      "actor": {
        typ: get_User()->GraphQLObjectType.toGraphQLType,
        description: "The actor that created this activity event.",
        deprecationReason: ?None,
        resolve: makeResolveFn((src, args, ctx, info) => {
          let src = typeUnwrapper(src)
          BackendSchema.actor(src, ~ctx)
        }),
      },
      "actorUserId": {
        typ: Scalars.id->Scalars.toGraphQLType->nonNull,
        description: ?None,
        deprecationReason: ?None,
        resolve: makeResolveFn((src, _args, _ctx, _info) => {
          let src = typeUnwrapper(src)
          src["actorUserId"]
        }),
      },
      "createdAt": {
        typ: Scalars.string->Scalars.toGraphQLType->nonNull,
        description: ?None,
        deprecationReason: ?None,
        resolve: makeResolveFn((src, _args, _ctx, _info) => {
          let src = typeUnwrapper(src)
          src["createdAt"]
        }),
      },
      "eventProfile": {
        typ: get_Profile()->GraphQLObjectType.toGraphQLType,
        description: "The profile for this activity event.",
        deprecationReason: ?None,
        resolve: makeResolveFn((src, args, ctx, info) => {
          let src = typeUnwrapper(src)
          BackendSchema.eventProfile(src, ~ctx)
        }),
      },
      "eventProfileVersion": {
        typ: get_ProfileVersion()->GraphQLObjectType.toGraphQLType,
        description: "The version published by this activity event.",
        deprecationReason: ?None,
        resolve: makeResolveFn((src, args, ctx, info) => {
          let src = typeUnwrapper(src)
          BackendSchema.eventProfileVersion(src, ~ctx)
        }),
      },
      "id": {
        typ: Scalars.id->Scalars.toGraphQLType->nonNull,
        description: "Relay global id for every type implementing Node.",
        deprecationReason: ?None,
        resolve: makeResolveFn((src, args, ctx, info) => {
          let src = typeUnwrapper(src)
          BackendNodeResolvers.id(src, ~typename=ProfileUpdateEvent)
        }),
      },
      "kind": {
        typ: enum_ProfileUpdateEventKind->GraphQLEnumType.toGraphQLType->nonNull,
        description: ?None,
        deprecationReason: ?None,
        resolve: makeResolveFn((src, _args, _ctx, _info) => {
          let src = typeUnwrapper(src)
          src["kind"]
        }),
      },
      "profileId": {
        typ: Scalars.id->Scalars.toGraphQLType->nonNull,
        description: ?None,
        deprecationReason: ?None,
        resolve: makeResolveFn((src, _args, _ctx, _info) => {
          let src = typeUnwrapper(src)
          src["profileId"]
        }),
      },
      "profileVersionId": {
        typ: Scalars.id->Scalars.toGraphQLType->nonNull,
        description: ?None,
        deprecationReason: ?None,
        resolve: makeResolveFn((src, _args, _ctx, _info) => {
          let src = typeUnwrapper(src)
          src["profileVersionId"]
        }),
      },
      "summary": {
        typ: Scalars.string->Scalars.toGraphQLType->nonNull,
        description: ?None,
        deprecationReason: ?None,
        resolve: makeResolveFn((src, _args, _ctx, _info) => {
          let src = typeUnwrapper(src)
          src["summary"]
        }),
      },
      "title": {
        typ: Scalars.string->Scalars.toGraphQLType->nonNull,
        description: ?None,
        deprecationReason: ?None,
        resolve: makeResolveFn((src, _args, _ctx, _info) => {
          let src = typeUnwrapper(src)
          src["title"]
        }),
      },
      "visibility": {
        typ: enum_ActivityVisibility->GraphQLEnumType.toGraphQLType->nonNull,
        description: ?None,
        deprecationReason: ?None,
        resolve: makeResolveFn((src, _args, _ctx, _info) => {
          let src = typeUnwrapper(src)
          src["visibility"]
        }),
      },
    }->makeFields,
})
t_ProfileUpdateEventConnection.contents = GraphQLObjectType.make({
  name: "ProfileUpdateEventConnection",
  description: ?None,
  interfaces: [],
  fields: () =>
    {
      "edges": {
        typ: GraphQLListType.make(
          get_ProfileUpdateEventEdge()->GraphQLObjectType.toGraphQLType,
        )->GraphQLListType.toGraphQLType,
        description: ?None,
        deprecationReason: ?None,
        resolve: makeResolveFn((src, _args, _ctx, _info) => {
          let src = typeUnwrapper(src)
          src["edges"]
        }),
      },
      "pageInfo": {
        typ: get_PageInfo()->GraphQLObjectType.toGraphQLType->nonNull,
        description: ?None,
        deprecationReason: ?None,
        resolve: makeResolveFn((src, _args, _ctx, _info) => {
          let src = typeUnwrapper(src)
          src["pageInfo"]
        }),
      },
      "totalCount": {
        typ: Scalars.int->Scalars.toGraphQLType->nonNull,
        description: ?None,
        deprecationReason: ?None,
        resolve: makeResolveFn((src, _args, _ctx, _info) => {
          let src = typeUnwrapper(src)
          src["totalCount"]
        }),
      },
    }->makeFields,
})
t_ProfileUpdateEventEdge.contents = GraphQLObjectType.make({
  name: "ProfileUpdateEventEdge",
  description: ?None,
  interfaces: [],
  fields: () =>
    {
      "cursor": {
        typ: Scalars.string->Scalars.toGraphQLType->nonNull,
        description: ?None,
        deprecationReason: ?None,
        resolve: makeResolveFn((src, _args, _ctx, _info) => {
          let src = typeUnwrapper(src)
          src["cursor"]
        }),
      },
      "node": {
        typ: get_ProfileUpdateEvent()->GraphQLObjectType.toGraphQLType,
        description: ?None,
        deprecationReason: ?None,
        resolve: makeResolveFn((src, _args, _ctx, _info) => {
          let src = typeUnwrapper(src)
          src["node"]
        }),
      },
    }->makeFields,
})
t_ProfileVersion.contents = GraphQLObjectType.make({
  name: "ProfileVersion",
  description: ?None,
  interfaces: [get_Node()],
  fields: () =>
    {
      "createdAt": {
        typ: Scalars.string->Scalars.toGraphQLType->nonNull,
        description: ?None,
        deprecationReason: ?None,
        resolve: makeResolveFn((src, _args, _ctx, _info) => {
          let src = typeUnwrapper(src)
          src["createdAt"]
        }),
      },
      "createdBy": {
        typ: get_User()->GraphQLObjectType.toGraphQLType,
        description: "The user that created this version.",
        deprecationReason: ?None,
        resolve: makeResolveFn((src, args, ctx, info) => {
          let src = typeUnwrapper(src)
          BackendSchema.createdBy(src, ~ctx)
        }),
      },
      "createdByUserId": {
        typ: Scalars.id->Scalars.toGraphQLType->nonNull,
        description: ?None,
        deprecationReason: ?None,
        resolve: makeResolveFn((src, _args, _ctx, _info) => {
          let src = typeUnwrapper(src)
          src["createdByUserId"]
        }),
      },
      "css": {
        typ: Scalars.string->Scalars.toGraphQLType->nonNull,
        description: ?None,
        deprecationReason: ?None,
        resolve: makeResolveFn((src, _args, _ctx, _info) => {
          let src = typeUnwrapper(src)
          src["css"]
        }),
      },
      "html": {
        typ: Scalars.string->Scalars.toGraphQLType->nonNull,
        description: ?None,
        deprecationReason: ?None,
        resolve: makeResolveFn((src, _args, _ctx, _info) => {
          let src = typeUnwrapper(src)
          src["html"]
        }),
      },
      "id": {
        typ: Scalars.id->Scalars.toGraphQLType->nonNull,
        description: "Relay global id for every type implementing Node.",
        deprecationReason: ?None,
        resolve: makeResolveFn((src, args, ctx, info) => {
          let src = typeUnwrapper(src)
          BackendNodeResolvers.id(src, ~typename=ProfileVersion)
        }),
      },
      "parentVersionId": {
        typ: Scalars.id->Scalars.toGraphQLType,
        description: ?None,
        deprecationReason: ?None,
        resolve: makeResolveFn((src, _args, _ctx, _info) => {
          let src = typeUnwrapper(src)
          src["parentVersionId"]
        }),
      },
      "profileForVersion": {
        typ: get_Profile()->GraphQLObjectType.toGraphQLType,
        description: "The profile attached to this version.",
        deprecationReason: ?None,
        resolve: makeResolveFn((src, args, ctx, info) => {
          let src = typeUnwrapper(src)
          BackendSchema.profileForVersion(src, ~ctx)
        }),
      },
      "profileId": {
        typ: Scalars.id->Scalars.toGraphQLType->nonNull,
        description: ?None,
        deprecationReason: ?None,
        resolve: makeResolveFn((src, _args, _ctx, _info) => {
          let src = typeUnwrapper(src)
          src["profileId"]
        }),
      },
      "promptSessionId": {
        typ: Scalars.id->Scalars.toGraphQLType,
        description: ?None,
        deprecationReason: ?None,
        resolve: makeResolveFn((src, _args, _ctx, _info) => {
          let src = typeUnwrapper(src)
          src["promptSessionId"]
        }),
      },
      "revisionNumber": {
        typ: Scalars.int->Scalars.toGraphQLType->nonNull,
        description: ?None,
        deprecationReason: ?None,
        resolve: makeResolveFn((src, _args, _ctx, _info) => {
          let src = typeUnwrapper(src)
          src["revisionNumber"]
        }),
      },
      "source": {
        typ: enum_ProfileVersionSource->GraphQLEnumType.toGraphQLType->nonNull,
        description: ?None,
        deprecationReason: ?None,
        resolve: makeResolveFn((src, _args, _ctx, _info) => {
          let src = typeUnwrapper(src)
          src["source"]
        }),
      },
      "summary": {
        typ: Scalars.string->Scalars.toGraphQLType->nonNull,
        description: ?None,
        deprecationReason: ?None,
        resolve: makeResolveFn((src, _args, _ctx, _info) => {
          let src = typeUnwrapper(src)
          src["summary"]
        }),
      },
      "trustedCapabilities": {
        typ: GraphQLListType.make(
          get_TrustedCapabilityReference()->GraphQLObjectType.toGraphQLType->nonNull,
        )
        ->GraphQLListType.toGraphQLType
        ->nonNull,
        description: "Approved trusted capabilities extracted for this version.",
        deprecationReason: ?None,
        resolve: makeResolveFn((src, args, ctx, info) => {
          let src = typeUnwrapper(src)
          BackendSchema.trustedCapabilities(src, ~ctx)
        }),
      },
      "validationErrors": {
        typ: GraphQLListType.make(Scalars.string->Scalars.toGraphQLType->nonNull)
        ->GraphQLListType.toGraphQLType
        ->nonNull,
        description: ?None,
        deprecationReason: ?None,
        resolve: makeResolveFn((src, _args, _ctx, _info) => {
          let src = typeUnwrapper(src)
          src["validationErrors"]
        }),
      },
      "validationStatus": {
        typ: enum_ValidationStatus->GraphQLEnumType.toGraphQLType->nonNull,
        description: ?None,
        deprecationReason: ?None,
        resolve: makeResolveFn((src, _args, _ctx, _info) => {
          let src = typeUnwrapper(src)
          src["validationStatus"]
        }),
      },
    }->makeFields,
})
t_ProfileVersionConnection.contents = GraphQLObjectType.make({
  name: "ProfileVersionConnection",
  description: ?None,
  interfaces: [],
  fields: () =>
    {
      "edges": {
        typ: GraphQLListType.make(
          get_ProfileVersionEdge()->GraphQLObjectType.toGraphQLType,
        )->GraphQLListType.toGraphQLType,
        description: ?None,
        deprecationReason: ?None,
        resolve: makeResolveFn((src, _args, _ctx, _info) => {
          let src = typeUnwrapper(src)
          src["edges"]
        }),
      },
      "pageInfo": {
        typ: get_PageInfo()->GraphQLObjectType.toGraphQLType->nonNull,
        description: ?None,
        deprecationReason: ?None,
        resolve: makeResolveFn((src, _args, _ctx, _info) => {
          let src = typeUnwrapper(src)
          src["pageInfo"]
        }),
      },
      "totalCount": {
        typ: Scalars.int->Scalars.toGraphQLType->nonNull,
        description: ?None,
        deprecationReason: ?None,
        resolve: makeResolveFn((src, _args, _ctx, _info) => {
          let src = typeUnwrapper(src)
          src["totalCount"]
        }),
      },
    }->makeFields,
})
t_ProfileVersionEdge.contents = GraphQLObjectType.make({
  name: "ProfileVersionEdge",
  description: ?None,
  interfaces: [],
  fields: () =>
    {
      "cursor": {
        typ: Scalars.string->Scalars.toGraphQLType->nonNull,
        description: ?None,
        deprecationReason: ?None,
        resolve: makeResolveFn((src, _args, _ctx, _info) => {
          let src = typeUnwrapper(src)
          src["cursor"]
        }),
      },
      "node": {
        typ: get_ProfileVersion()->GraphQLObjectType.toGraphQLType,
        description: ?None,
        deprecationReason: ?None,
        resolve: makeResolveFn((src, _args, _ctx, _info) => {
          let src = typeUnwrapper(src)
          src["node"]
        }),
      },
    }->makeFields,
})
t_ProfileVersionMutationFailed.contents = GraphQLObjectType.make({
  name: "ProfileVersionMutationFailed",
  description: "A profile version mutation failed before publishing a version.",
  interfaces: [],
  fields: () =>
    {
      "message": {
        typ: Scalars.string->Scalars.toGraphQLType->nonNull,
        description: ?None,
        deprecationReason: ?None,
        resolve: makeResolveFn((src, _args, _ctx, _info) => {
          let src = typeUnwrapper(src)
          src["message"]
        }),
      },
      "profile": {
        typ: get_Profile()->GraphQLObjectType.toGraphQLType,
        description: ?None,
        deprecationReason: ?None,
        resolve: makeResolveFn((src, _args, _ctx, _info) => {
          let src = typeUnwrapper(src)
          src["profile"]
        }),
      },
      "summary": {
        typ: Scalars.string->Scalars.toGraphQLType->nonNull,
        description: ?None,
        deprecationReason: ?None,
        resolve: makeResolveFn((src, _args, _ctx, _info) => {
          let src = typeUnwrapper(src)
          src["summary"]
        }),
      },
      "validationErrors": {
        typ: GraphQLListType.make(Scalars.string->Scalars.toGraphQLType->nonNull)
        ->GraphQLListType.toGraphQLType
        ->nonNull,
        description: ?None,
        deprecationReason: ?None,
        resolve: makeResolveFn((src, _args, _ctx, _info) => {
          let src = typeUnwrapper(src)
          src["validationErrors"]
        }),
      },
    }->makeFields,
})
t_ProfileVersionMutationSucceeded.contents = GraphQLObjectType.make({
  name: "ProfileVersionMutationSucceeded",
  description: "A profile version mutation persisted a new version.",
  interfaces: [],
  fields: () =>
    {
      "activityEvent": {
        typ: get_ProfileUpdateEvent()->GraphQLObjectType.toGraphQLType,
        description: ?None,
        deprecationReason: ?None,
        resolve: makeResolveFn((src, _args, _ctx, _info) => {
          let src = typeUnwrapper(src)
          src["activityEvent"]
        }),
      },
      "profile": {
        typ: get_Profile()->GraphQLObjectType.toGraphQLType,
        description: ?None,
        deprecationReason: ?None,
        resolve: makeResolveFn((src, _args, _ctx, _info) => {
          let src = typeUnwrapper(src)
          src["profile"]
        }),
      },
      "profileVersion": {
        typ: get_ProfileVersion()->GraphQLObjectType.toGraphQLType->nonNull,
        description: ?None,
        deprecationReason: ?None,
        resolve: makeResolveFn((src, _args, _ctx, _info) => {
          let src = typeUnwrapper(src)
          src["profileVersion"]
        }),
      },
      "summary": {
        typ: Scalars.string->Scalars.toGraphQLType->nonNull,
        description: ?None,
        deprecationReason: ?None,
        resolve: makeResolveFn((src, _args, _ctx, _info) => {
          let src = typeUnwrapper(src)
          src["summary"]
        }),
      },
      "warnings": {
        typ: GraphQLListType.make(Scalars.string->Scalars.toGraphQLType->nonNull)
        ->GraphQLListType.toGraphQLType
        ->nonNull,
        description: ?None,
        deprecationReason: ?None,
        resolve: makeResolveFn((src, _args, _ctx, _info) => {
          let src = typeUnwrapper(src)
          src["warnings"]
        }),
      },
    }->makeFields,
})
t_Query.contents = GraphQLObjectType.make({
  name: "Query",
  description: ?None,
  interfaces: [],
  fields: () =>
    {
      "availableInvite": {
        typ: get_Invite()->GraphQLObjectType.toGraphQLType,
        description: "The current viewer's available invite grant, if any.",
        deprecationReason: ?None,
        resolve: makeResolveFn((src, args, ctx, info) => {
          let src = typeUnwrapper(src)
          BackendSchema.availableInvite(src, ~ctx)
        }),
      },
      "currentTime": {
        typ: Scalars.float->Scalars.toGraphQLType->nonNull,
        description: "Backend readiness timestamp.",
        deprecationReason: ?None,
        resolve: makeResolveFn((src, args, ctx, info) => {
          let src = typeUnwrapper(src)
          BackendSchema.currentTime(src)
        }),
      },
      "currentUserId": {
        typ: Scalars.id->Scalars.toGraphQLType->nonNull,
        description: "Current signed-in user id as a Relay global id.",
        deprecationReason: ?None,
        resolve: makeResolveFn((src, args, ctx, info) => {
          let src = typeUnwrapper(src)
          BackendNodeResolvers.currentUserId(src, ~ctx)
        }),
      },
      "friendActivity": {
        typ: get_ProfileUpdateEventConnection()->GraphQLObjectType.toGraphQLType->nonNull,
        description: "Recent profile update events for accepted friends.",
        deprecationReason: ?None,
        args: {
          "after": {typ: Scalars.string->Scalars.toGraphQLType},
          "before": {typ: Scalars.string->Scalars.toGraphQLType},
          "first": {typ: Scalars.int->Scalars.toGraphQLType},
          "last": {typ: Scalars.int->Scalars.toGraphQLType},
        }->makeArgs,
        resolve: makeResolveFn((src, args, ctx, info) => {
          let src = typeUnwrapper(src)
          BackendSchema.friendActivity(
            src,
            ~after=args["after"]->Nullable.toOption,
            ~before=args["before"]->Nullable.toOption,
            ~ctx,
            ~first=args["first"]->Nullable.toOption,
            ~last=args["last"]->Nullable.toOption,
          )
        }),
      },
      "inviteByCode": {
        typ: get_Invite()->GraphQLObjectType.toGraphQLType,
        description: "Invite lookup for the invite-link onboarding route.",
        deprecationReason: ?None,
        args: {"code": {typ: Scalars.string->Scalars.toGraphQLType->nonNull}}->makeArgs,
        resolve: makeResolveFn((src, args, ctx, info) => {
          let src = typeUnwrapper(src)
          BackendSchema.inviteByCode(src, ~code=args["code"], ~ctx)
        }),
      },
      "node": {
        typ: get_Node()->GraphQLInterfaceType.toGraphQLType,
        description: "Relay global-object lookup over the DB-backed slice with fixture fallback.",
        deprecationReason: ?None,
        args: {"id": {typ: Scalars.id->Scalars.toGraphQLType->nonNull}}->makeArgs,
        resolve: makeResolveFn((src, args, ctx, info) => {
          let src = typeUnwrapper(src)
          BackendNodeResolvers.node(src, ~ctx, ~id=args["id"])
        }),
      },
      "nodes": {
        typ: GraphQLListType.make(get_Node()->GraphQLInterfaceType.toGraphQLType)
        ->GraphQLListType.toGraphQLType
        ->nonNull,
        description: "Relay batched global-object lookup over the DB-backed slice with fixture fallback.",
        deprecationReason: ?None,
        args: {
          "ids": {
            typ: GraphQLListType.make(Scalars.id->Scalars.toGraphQLType->nonNull)
            ->GraphQLListType.toGraphQLType
            ->nonNull,
          },
        }->makeArgs,
        resolve: makeResolveFn((src, args, ctx, info) => {
          let src = typeUnwrapper(src)
          BackendNodeResolvers.nodes(src, ~ctx, ~ids=args["ids"])
        }),
      },
      "profileByHandle": {
        typ: get_Profile()->GraphQLObjectType.toGraphQLType,
        description: "Friend-visible profile by handle.",
        deprecationReason: ?None,
        args: {"handle": {typ: Scalars.string->Scalars.toGraphQLType->nonNull}}->makeArgs,
        resolve: makeResolveFn((src, args, ctx, info) => {
          let src = typeUnwrapper(src)
          BackendSchema.profileByHandle(src, ~ctx, ~handle=args["handle"])
        }),
      },
      "profileEditSessionById": {
        typ: get_ProfileEditSession()->GraphQLObjectType.toGraphQLType,
        description: "Profile edit session resolver backed by pgtyped-rescript when DATABASE_URL is configured.",
        deprecationReason: ?None,
        args: {"id": {typ: Scalars.id->Scalars.toGraphQLType->nonNull}}->makeArgs,
        resolve: makeResolveFn((src, args, ctx, info) => {
          let src = typeUnwrapper(src)
          BackendSchema.profileEditSessionById(src, ~ctx, ~id=args["id"])
        }),
      },
      "profileEditSessions": {
        typ: get_ProfileEditSessionConnection()->GraphQLObjectType.toGraphQLType->nonNull,
        description: "Prompt/edit history for a profile.",
        deprecationReason: ?None,
        args: {
          "after": {typ: Scalars.string->Scalars.toGraphQLType},
          "before": {typ: Scalars.string->Scalars.toGraphQLType},
          "first": {typ: Scalars.int->Scalars.toGraphQLType},
          "last": {typ: Scalars.int->Scalars.toGraphQLType},
          "profileId": {typ: Scalars.id->Scalars.toGraphQLType->nonNull},
        }->makeArgs,
        resolve: makeResolveFn((src, args, ctx, info) => {
          let src = typeUnwrapper(src)
          BackendSchema.profileEditSessions(
            src,
            ~after=args["after"]->Nullable.toOption,
            ~before=args["before"]->Nullable.toOption,
            ~ctx,
            ~first=args["first"]->Nullable.toOption,
            ~last=args["last"]->Nullable.toOption,
            ~profileId=args["profileId"],
          )
        }),
      },
      "profileVersionById": {
        typ: get_ProfileVersion()->GraphQLObjectType.toGraphQLType,
        description: "Profile version resolver backed by pgtyped-rescript when DATABASE_URL is configured.",
        deprecationReason: ?None,
        args: {"id": {typ: Scalars.id->Scalars.toGraphQLType->nonNull}}->makeArgs,
        resolve: makeResolveFn((src, args, ctx, info) => {
          let src = typeUnwrapper(src)
          BackendSchema.profileVersionById(src, ~ctx, ~id=args["id"])
        }),
      },
      "profileVersions": {
        typ: get_ProfileVersionConnection()->GraphQLObjectType.toGraphQLType->nonNull,
        description: "Version history for a profile.",
        deprecationReason: ?None,
        args: {
          "after": {typ: Scalars.string->Scalars.toGraphQLType},
          "before": {typ: Scalars.string->Scalars.toGraphQLType},
          "first": {typ: Scalars.int->Scalars.toGraphQLType},
          "last": {typ: Scalars.int->Scalars.toGraphQLType},
          "profileId": {typ: Scalars.id->Scalars.toGraphQLType->nonNull},
        }->makeArgs,
        resolve: makeResolveFn((src, args, ctx, info) => {
          let src = typeUnwrapper(src)
          BackendSchema.profileVersions(
            src,
            ~after=args["after"]->Nullable.toOption,
            ~before=args["before"]->Nullable.toOption,
            ~ctx,
            ~first=args["first"]->Nullable.toOption,
            ~last=args["last"]->Nullable.toOption,
            ~profileId=args["profileId"],
          )
        }),
      },
      "randomProfile": {
        typ: get_Profile()->GraphQLObjectType.toGraphQLType,
        description: "Random friend-visible profile that belongs to an enabled user and has completed onboarding.",
        deprecationReason: ?None,
        resolve: makeResolveFn((src, args, ctx, info) => {
          let src = typeUnwrapper(src)
          BackendSchema.randomProfile(src, ~ctx)
        }),
      },
      "sendtagLookup": {
        typ: get_SendtagLookupResult()->GraphQLObjectType.toGraphQLType->nonNull,
        description: "Validate a public Sendtag through the server-owned Send lookup integration.",
        deprecationReason: ?None,
        args: {"sendtag": {typ: Scalars.string->Scalars.toGraphQLType->nonNull}}->makeArgs,
        resolve: makeResolveFn((src, args, ctx, info) => {
          let src = typeUnwrapper(src)
          BackendSchema.sendtagLookup(src, ~ctx, ~sendtag=args["sendtag"])
        }),
      },
      "viewer": {
        typ: get_User()->GraphQLObjectType.toGraphQLType,
        description: "The current viewer account.",
        deprecationReason: ?None,
        resolve: makeResolveFn((src, args, ctx, info) => {
          let src = typeUnwrapper(src)
          BackendSchema.viewer(src, ~ctx)
        }),
      },
      "viewerProfile": {
        typ: get_Profile()->GraphQLObjectType.toGraphQLType,
        description: "The current viewer's canonical profile.",
        deprecationReason: ?None,
        resolve: makeResolveFn((src, args, ctx, info) => {
          let src = typeUnwrapper(src)
          BackendSchema.viewerProfile(src, ~ctx)
        }),
      },
      "viewerUsedInvite": {
        typ: get_Invite()->GraphQLObjectType.toGraphQLType,
        description: "The redeemed invite the current viewer used to join, if any.",
        deprecationReason: ?None,
        resolve: makeResolveFn((src, args, ctx, info) => {
          let src = typeUnwrapper(src)
          BackendSchema.viewerUsedInvite(src, ~ctx)
        }),
      },
    }->makeFields,
})
t_ReactivateUsedInviteSucceeded.contents = GraphQLObjectType.make({
  name: "ReactivateUsedInviteSucceeded",
  description: "A used invite was made available again.",
  interfaces: [],
  fields: () =>
    {
      "invite": {
        typ: get_Invite()->GraphQLObjectType.toGraphQLType->nonNull,
        description: ?None,
        deprecationReason: ?None,
        resolve: makeResolveFn((src, _args, _ctx, _info) => {
          let src = typeUnwrapper(src)
          src["invite"]
        }),
      },
      "user": {
        typ: get_User()->GraphQLObjectType.toGraphQLType->nonNull,
        description: ?None,
        deprecationReason: ?None,
        resolve: makeResolveFn((src, _args, _ctx, _info) => {
          let src = typeUnwrapper(src)
          src["user"]
        }),
      },
    }->makeFields,
})
t_RedeemInviteSucceeded.contents = GraphQLObjectType.make({
  name: "RedeemInviteSucceeded",
  description: "A new user profile was created from an invite.",
  interfaces: [],
  fields: () =>
    {
      "friendConnection": {
        typ: get_FriendConnection()->GraphQLObjectType.toGraphQLType->nonNull,
        description: ?None,
        deprecationReason: ?None,
        resolve: makeResolveFn((src, _args, _ctx, _info) => {
          let src = typeUnwrapper(src)
          src["friendConnection"]
        }),
      },
      "invite": {
        typ: get_Invite()->GraphQLObjectType.toGraphQLType->nonNull,
        description: ?None,
        deprecationReason: ?None,
        resolve: makeResolveFn((src, _args, _ctx, _info) => {
          let src = typeUnwrapper(src)
          src["invite"]
        }),
      },
      "profile": {
        typ: get_Profile()->GraphQLObjectType.toGraphQLType->nonNull,
        description: ?None,
        deprecationReason: ?None,
        resolve: makeResolveFn((src, _args, _ctx, _info) => {
          let src = typeUnwrapper(src)
          src["profile"]
        }),
      },
      "sessionToken": {
        typ: Scalars.string->Scalars.toGraphQLType,
        description: ?None,
        deprecationReason: ?None,
        resolve: makeResolveFn((src, _args, _ctx, _info) => {
          let src = typeUnwrapper(src)
          src["sessionToken"]
        }),
      },
      "user": {
        typ: get_User()->GraphQLObjectType.toGraphQLType->nonNull,
        description: ?None,
        deprecationReason: ?None,
        resolve: makeResolveFn((src, _args, _ctx, _info) => {
          let src = typeUnwrapper(src)
          src["user"]
        }),
      },
    }->makeFields,
})
t_SelectedElementMetadata.contents = GraphQLObjectType.make({
  name: "SelectedElementMetadata",
  description: ?None,
  interfaces: [],
  fields: () =>
    {
      "boundsJson": {
        typ: Scalars.string->Scalars.toGraphQLType->nonNull,
        description: ?None,
        deprecationReason: ?None,
        resolve: makeResolveFn((src, _args, _ctx, _info) => {
          let src = typeUnwrapper(src)
          src["boundsJson"]
        }),
      },
      "className": {
        typ: Scalars.string->Scalars.toGraphQLType->nonNull,
        description: ?None,
        deprecationReason: ?None,
        resolve: makeResolveFn((src, _args, _ctx, _info) => {
          let src = typeUnwrapper(src)
          src["className"]
        }),
      },
      "friendlyDescription": {
        typ: Scalars.string->Scalars.toGraphQLType->nonNull,
        description: ?None,
        deprecationReason: ?None,
        resolve: makeResolveFn((src, _args, _ctx, _info) => {
          let src = typeUnwrapper(src)
          src["friendlyDescription"]
        }),
      },
      "friendlyName": {
        typ: Scalars.string->Scalars.toGraphQLType->nonNull,
        description: ?None,
        deprecationReason: ?None,
        resolve: makeResolveFn((src, _args, _ctx, _info) => {
          let src = typeUnwrapper(src)
          src["friendlyName"]
        }),
      },
      "selector": {
        typ: Scalars.string->Scalars.toGraphQLType->nonNull,
        description: ?None,
        deprecationReason: ?None,
        resolve: makeResolveFn((src, _args, _ctx, _info) => {
          let src = typeUnwrapper(src)
          src["selector"]
        }),
      },
      "tagName": {
        typ: Scalars.string->Scalars.toGraphQLType->nonNull,
        description: ?None,
        deprecationReason: ?None,
        resolve: makeResolveFn((src, _args, _ctx, _info) => {
          let src = typeUnwrapper(src)
          src["tagName"]
        }),
      },
      "text": {
        typ: Scalars.string->Scalars.toGraphQLType->nonNull,
        description: ?None,
        deprecationReason: ?None,
        resolve: makeResolveFn((src, _args, _ctx, _info) => {
          let src = typeUnwrapper(src)
          src["text"]
        }),
      },
      "vibespaceId": {
        typ: Scalars.string->Scalars.toGraphQLType->nonNull,
        description: ?None,
        deprecationReason: ?None,
        resolve: makeResolveFn((src, _args, _ctx, _info) => {
          let src = typeUnwrapper(src)
          src["vibespaceId"]
        }),
      },
    }->makeFields,
})
t_SelectionSnapshot.contents = GraphQLObjectType.make({
  name: "SelectionSnapshot",
  description: ?None,
  interfaces: [get_Node()],
  fields: () =>
    {
      "agentContext": {
        typ: Scalars.string->Scalars.toGraphQLType->nonNull,
        description: ?None,
        deprecationReason: ?None,
        resolve: makeResolveFn((src, _args, _ctx, _info) => {
          let src = typeUnwrapper(src)
          src["agentContext"]
        }),
      },
      "boundsJson": {
        typ: Scalars.string->Scalars.toGraphQLType->nonNull,
        description: ?None,
        deprecationReason: ?None,
        resolve: makeResolveFn((src, _args, _ctx, _info) => {
          let src = typeUnwrapper(src)
          src["boundsJson"]
        }),
      },
      "createdAt": {
        typ: Scalars.string->Scalars.toGraphQLType->nonNull,
        description: ?None,
        deprecationReason: ?None,
        resolve: makeResolveFn((src, _args, _ctx, _info) => {
          let src = typeUnwrapper(src)
          src["createdAt"]
        }),
      },
      "description": {
        typ: Scalars.string->Scalars.toGraphQLType->nonNull,
        description: ?None,
        deprecationReason: ?None,
        resolve: makeResolveFn((src, _args, _ctx, _info) => {
          let src = typeUnwrapper(src)
          src["description"]
        }),
      },
      "id": {
        typ: Scalars.id->Scalars.toGraphQLType->nonNull,
        description: "Relay global id for every type implementing Node.",
        deprecationReason: ?None,
        resolve: makeResolveFn((src, args, ctx, info) => {
          let src = typeUnwrapper(src)
          BackendNodeResolvers.id(src, ~typename=SelectionSnapshot)
        }),
      },
      "kind": {
        typ: enum_SelectionSnapshotKind->GraphQLEnumType.toGraphQLType->nonNull,
        description: ?None,
        deprecationReason: ?None,
        resolve: makeResolveFn((src, _args, _ctx, _info) => {
          let src = typeUnwrapper(src)
          src["kind"]
        }),
      },
      "label": {
        typ: Scalars.string->Scalars.toGraphQLType->nonNull,
        description: ?None,
        deprecationReason: ?None,
        resolve: makeResolveFn((src, _args, _ctx, _info) => {
          let src = typeUnwrapper(src)
          src["label"]
        }),
      },
      "nearestElement": {
        typ: get_SelectedElementMetadata()->GraphQLObjectType.toGraphQLType,
        description: ?None,
        deprecationReason: ?None,
        resolve: makeResolveFn((src, _args, _ctx, _info) => {
          let src = typeUnwrapper(src)
          src["nearestElement"]
        }),
      },
      "profileId": {
        typ: Scalars.id->Scalars.toGraphQLType->nonNull,
        description: ?None,
        deprecationReason: ?None,
        resolve: makeResolveFn((src, _args, _ctx, _info) => {
          let src = typeUnwrapper(src)
          src["profileId"]
        }),
      },
      "requestId": {
        typ: Scalars.string->Scalars.toGraphQLType->nonNull,
        description: ?None,
        deprecationReason: ?None,
        resolve: makeResolveFn((src, _args, _ctx, _info) => {
          let src = typeUnwrapper(src)
          src["requestId"]
        }),
      },
      "selectedElements": {
        typ: GraphQLListType.make(
          get_SelectedElementMetadata()->GraphQLObjectType.toGraphQLType->nonNull,
        )
        ->GraphQLListType.toGraphQLType
        ->nonNull,
        description: ?None,
        deprecationReason: ?None,
        resolve: makeResolveFn((src, _args, _ctx, _info) => {
          let src = typeUnwrapper(src)
          src["selectedElements"]
        }),
      },
      "viewportJson": {
        typ: Scalars.string->Scalars.toGraphQLType->nonNull,
        description: ?None,
        deprecationReason: ?None,
        resolve: makeResolveFn((src, _args, _ctx, _info) => {
          let src = typeUnwrapper(src)
          src["viewportJson"]
        }),
      },
    }->makeFields,
})
t_SendtagLookupResult.contents = GraphQLObjectType.make({
  name: "SendtagLookupResult",
  description: ?None,
  interfaces: [],
  fields: () =>
    {
      "message": {
        typ: Scalars.string->Scalars.toGraphQLType->nonNull,
        description: ?None,
        deprecationReason: ?None,
        resolve: makeResolveFn((src, _args, _ctx, _info) => {
          let src = typeUnwrapper(src)
          src["message"]
        }),
      },
      "ok": {
        typ: Scalars.boolean->Scalars.toGraphQLType->nonNull,
        description: ?None,
        deprecationReason: ?None,
        resolve: makeResolveFn((src, _args, _ctx, _info) => {
          let src = typeUnwrapper(src)
          src["ok"]
        }),
      },
      "sendtag": {
        typ: Scalars.string->Scalars.toGraphQLType->nonNull,
        description: ?None,
        deprecationReason: ?None,
        resolve: makeResolveFn((src, _args, _ctx, _info) => {
          let src = typeUnwrapper(src)
          src["sendtag"]
        }),
      },
    }->makeFields,
})
t_TrustedCapabilityReference.contents = GraphQLObjectType.make({
  name: "TrustedCapabilityReference",
  description: ?None,
  interfaces: [get_Node()],
  fields: () =>
    {
      "canonicalUrl": {
        typ: Scalars.string->Scalars.toGraphQLType->nonNull,
        description: ?None,
        deprecationReason: ?None,
        resolve: makeResolveFn((src, _args, _ctx, _info) => {
          let src = typeUnwrapper(src)
          src["canonicalUrl"]
        }),
      },
      "createdAt": {
        typ: Scalars.string->Scalars.toGraphQLType->nonNull,
        description: ?None,
        deprecationReason: ?None,
        resolve: makeResolveFn((src, _args, _ctx, _info) => {
          let src = typeUnwrapper(src)
          src["createdAt"]
        }),
      },
      "id": {
        typ: Scalars.id->Scalars.toGraphQLType->nonNull,
        description: "Relay global id for every type implementing Node.",
        deprecationReason: ?None,
        resolve: makeResolveFn((src, args, ctx, info) => {
          let src = typeUnwrapper(src)
          BackendNodeResolvers.id(src, ~typename=TrustedCapabilityReference)
        }),
      },
      "kind": {
        typ: enum_TrustedCapabilityKind->GraphQLEnumType.toGraphQLType->nonNull,
        description: ?None,
        deprecationReason: ?None,
        resolve: makeResolveFn((src, _args, _ctx, _info) => {
          let src = typeUnwrapper(src)
          src["kind"]
        }),
      },
      "metadataJson": {
        typ: Scalars.string->Scalars.toGraphQLType->nonNull,
        description: ?None,
        deprecationReason: ?None,
        resolve: makeResolveFn((src, _args, _ctx, _info) => {
          let src = typeUnwrapper(src)
          src["metadataJson"]
        }),
      },
      "origin": {
        typ: Scalars.string->Scalars.toGraphQLType->nonNull,
        description: ?None,
        deprecationReason: ?None,
        resolve: makeResolveFn((src, _args, _ctx, _info) => {
          let src = typeUnwrapper(src)
          src["origin"]
        }),
      },
      "profileVersionId": {
        typ: Scalars.id->Scalars.toGraphQLType->nonNull,
        description: ?None,
        deprecationReason: ?None,
        resolve: makeResolveFn((src, _args, _ctx, _info) => {
          let src = typeUnwrapper(src)
          src["profileVersionId"]
        }),
      },
      "source": {
        typ: Scalars.string->Scalars.toGraphQLType->nonNull,
        description: ?None,
        deprecationReason: ?None,
        resolve: makeResolveFn((src, _args, _ctx, _info) => {
          let src = typeUnwrapper(src)
          src["source"]
        }),
      },
      "validationStatus": {
        typ: enum_ValidationStatus->GraphQLEnumType.toGraphQLType->nonNull,
        description: ?None,
        deprecationReason: ?None,
        resolve: makeResolveFn((src, _args, _ctx, _info) => {
          let src = typeUnwrapper(src)
          src["validationStatus"]
        }),
      },
    }->makeFields,
})
t_User.contents = GraphQLObjectType.make({
  name: "User",
  description: ?None,
  interfaces: [get_Node()],
  fields: () =>
    {
      "activatedAt": {
        typ: Scalars.string->Scalars.toGraphQLType,
        description: ?None,
        deprecationReason: ?None,
        resolve: makeResolveFn((src, _args, _ctx, _info) => {
          let src = typeUnwrapper(src)
          src["activatedAt"]
        }),
      },
      "createdAt": {
        typ: Scalars.string->Scalars.toGraphQLType->nonNull,
        description: ?None,
        deprecationReason: ?None,
        resolve: makeResolveFn((src, _args, _ctx, _info) => {
          let src = typeUnwrapper(src)
          src["createdAt"]
        }),
      },
      "displayName": {
        typ: Scalars.string->Scalars.toGraphQLType->nonNull,
        description: ?None,
        deprecationReason: ?None,
        resolve: makeResolveFn((src, _args, _ctx, _info) => {
          let src = typeUnwrapper(src)
          src["displayName"]
        }),
      },
      "handle": {
        typ: Scalars.string->Scalars.toGraphQLType->nonNull,
        description: ?None,
        deprecationReason: ?None,
        resolve: makeResolveFn((src, _args, _ctx, _info) => {
          let src = typeUnwrapper(src)
          src["handle"]
        }),
      },
      "id": {
        typ: Scalars.id->Scalars.toGraphQLType->nonNull,
        description: "Relay global id for every type implementing Node.",
        deprecationReason: ?None,
        resolve: makeResolveFn((src, args, ctx, info) => {
          let src = typeUnwrapper(src)
          BackendNodeResolvers.id(src, ~typename=User)
        }),
      },
      "invitedByUserId": {
        typ: Scalars.id->Scalars.toGraphQLType,
        description: ?None,
        deprecationReason: ?None,
        resolve: makeResolveFn((src, _args, _ctx, _info) => {
          let src = typeUnwrapper(src)
          src["invitedByUserId"]
        }),
      },
      "profile": {
        typ: get_Profile()->GraphQLObjectType.toGraphQLType,
        description: "The canonical profile owned by this user.",
        deprecationReason: ?None,
        resolve: makeResolveFn((src, args, ctx, info) => {
          let src = typeUnwrapper(src)
          BackendSchema.profile(src, ~ctx)
        }),
      },
      "role": {
        typ: enum_UserRole->GraphQLEnumType.toGraphQLType->nonNull,
        description: ?None,
        deprecationReason: ?None,
        resolve: makeResolveFn((src, _args, _ctx, _info) => {
          let src = typeUnwrapper(src)
          src["role"]
        }),
      },
      "status": {
        typ: enum_UserStatus->GraphQLEnumType.toGraphQLType->nonNull,
        description: ?None,
        deprecationReason: ?None,
        resolve: makeResolveFn((src, _args, _ctx, _info) => {
          let src = typeUnwrapper(src)
          src["status"]
        }),
      },
      "updatedAt": {
        typ: Scalars.string->Scalars.toGraphQLType->nonNull,
        description: ?None,
        deprecationReason: ?None,
        resolve: makeResolveFn((src, _args, _ctx, _info) => {
          let src = typeUnwrapper(src)
          src["updatedAt"]
        }),
      },
    }->makeFields,
})
input_AdminCreateInviteInput.contents = GraphQLInputObjectType.make({
  name: "AdminCreateInviteInput",
  description: ?None,
  fields: () =>
    {
      "inviterUserId": {
        GraphQLInputObjectType.typ: Scalars.id->Scalars.toGraphQLType->nonNull,
        description: ?None,
        deprecationReason: ?None,
      },
    }->makeFields,
})
input_AdminCreateSeedUserInput.contents = GraphQLInputObjectType.make({
  name: "AdminCreateSeedUserInput",
  description: ?None,
  fields: () =>
    {
      "displayName": {
        GraphQLInputObjectType.typ: Scalars.string->Scalars.toGraphQLType->nonNull,
        description: ?None,
        deprecationReason: ?None,
      },
      "handle": {
        GraphQLInputObjectType.typ: Scalars.string->Scalars.toGraphQLType->nonNull,
        description: ?None,
        deprecationReason: ?None,
      },
      "role": {
        GraphQLInputObjectType.typ: enum_UserRole->GraphQLEnumType.toGraphQLType,
        description: ?None,
        deprecationReason: ?None,
      },
    }->makeFields,
})
input_CancelProfileEditSessionInput.contents = GraphQLInputObjectType.make({
  name: "CancelProfileEditSessionInput",
  description: ?None,
  fields: () =>
    {
      "editSessionId": {
        GraphQLInputObjectType.typ: Scalars.id->Scalars.toGraphQLType->nonNull,
        description: ?None,
        deprecationReason: ?None,
      },
    }->makeFields,
})
input_DisableProfileInput.contents = GraphQLInputObjectType.make({
  name: "DisableProfileInput",
  description: ?None,
  fields: () =>
    {
      "profileId": {
        GraphQLInputObjectType.typ: Scalars.id->Scalars.toGraphQLType->nonNull,
        description: ?None,
        deprecationReason: ?None,
      },
      "reason": {
        GraphQLInputObjectType.typ: Scalars.string->Scalars.toGraphQLType,
        description: ?None,
        deprecationReason: ?None,
      },
    }->makeFields,
})
input_DisableUserInput.contents = GraphQLInputObjectType.make({
  name: "DisableUserInput",
  description: ?None,
  fields: () =>
    {
      "userId": {
        GraphQLInputObjectType.typ: Scalars.id->Scalars.toGraphQLType->nonNull,
        description: ?None,
        deprecationReason: ?None,
      },
    }->makeFields,
})
input_ReactivateUsedInviteInput.contents = GraphQLInputObjectType.make({
  name: "ReactivateUsedInviteInput",
  description: ?None,
  fields: () =>
    {
      "confirmDisable": {
        GraphQLInputObjectType.typ: Scalars.boolean->Scalars.toGraphQLType->nonNull,
        description: ?None,
        deprecationReason: ?None,
      },
    }->makeFields,
})
input_RedeemInviteInput.contents = GraphQLInputObjectType.make({
  name: "RedeemInviteInput",
  description: ?None,
  fields: () =>
    {
      "code": {
        GraphQLInputObjectType.typ: Scalars.string->Scalars.toGraphQLType->nonNull,
        description: ?None,
        deprecationReason: ?None,
      },
      "displayName": {
        GraphQLInputObjectType.typ: Scalars.string->Scalars.toGraphQLType,
        description: ?None,
        deprecationReason: ?None,
      },
    }->makeFields,
})
input_RestoreProfileVersionInput.contents = GraphQLInputObjectType.make({
  name: "RestoreProfileVersionInput",
  description: ?None,
  fields: () =>
    {
      "profileId": {
        GraphQLInputObjectType.typ: Scalars.id->Scalars.toGraphQLType->nonNull,
        description: ?None,
        deprecationReason: ?None,
      },
      "versionId": {
        GraphQLInputObjectType.typ: Scalars.id->Scalars.toGraphQLType->nonNull,
        description: ?None,
        deprecationReason: ?None,
      },
    }->makeFields,
})
input_SaveManualProfileVersionInput.contents = GraphQLInputObjectType.make({
  name: "SaveManualProfileVersionInput",
  description: ?None,
  fields: () =>
    {
      "css": {
        GraphQLInputObjectType.typ: Scalars.string->Scalars.toGraphQLType->nonNull,
        description: ?None,
        deprecationReason: ?None,
      },
      "html": {
        GraphQLInputObjectType.typ: Scalars.string->Scalars.toGraphQLType->nonNull,
        description: ?None,
        deprecationReason: ?None,
      },
      "profileId": {
        GraphQLInputObjectType.typ: Scalars.id->Scalars.toGraphQLType->nonNull,
        description: ?None,
        deprecationReason: ?None,
      },
      "summary": {
        GraphQLInputObjectType.typ: Scalars.string->Scalars.toGraphQLType,
        description: ?None,
        deprecationReason: ?None,
      },
    }->makeFields,
})
input_SubmitAgentEditInput.contents = GraphQLInputObjectType.make({
  name: "SubmitAgentEditInput",
  description: ?None,
  fields: () =>
    {
      "currentVersionId": {
        GraphQLInputObjectType.typ: Scalars.id->Scalars.toGraphQLType,
        description: ?None,
        deprecationReason: ?None,
      },
      "fullPageScreenshotDataUrl": {
        GraphQLInputObjectType.typ: Scalars.string->Scalars.toGraphQLType,
        description: ?None,
        deprecationReason: ?None,
      },
      "mode": {
        GraphQLInputObjectType.typ: enum_AssistantEditMode->GraphQLEnumType.toGraphQLType,
        description: ?None,
        deprecationReason: ?None,
      },
      "previousFailedCss": {
        GraphQLInputObjectType.typ: Scalars.string->Scalars.toGraphQLType,
        description: ?None,
        deprecationReason: ?None,
      },
      "previousFailedHtml": {
        GraphQLInputObjectType.typ: Scalars.string->Scalars.toGraphQLType,
        description: ?None,
        deprecationReason: ?None,
      },
      "previousFailedSummary": {
        GraphQLInputObjectType.typ: Scalars.string->Scalars.toGraphQLType,
        description: ?None,
        deprecationReason: ?None,
      },
      "previousFailedValidationMessage": {
        GraphQLInputObjectType.typ: Scalars.string->Scalars.toGraphQLType,
        description: ?None,
        deprecationReason: ?None,
      },
      "previousFailedWarnings": {
        GraphQLInputObjectType.typ: Scalars.string->Scalars.toGraphQLType,
        description: ?None,
        deprecationReason: ?None,
      },
      "profileId": {
        GraphQLInputObjectType.typ: Scalars.id->Scalars.toGraphQLType->nonNull,
        description: ?None,
        deprecationReason: ?None,
      },
      "profileName": {
        GraphQLInputObjectType.typ: Scalars.string->Scalars.toGraphQLType,
        description: ?None,
        deprecationReason: ?None,
      },
      "prompt": {
        GraphQLInputObjectType.typ: Scalars.string->Scalars.toGraphQLType->nonNull,
        description: ?None,
        deprecationReason: ?None,
      },
      "referenceImageDataUrl": {
        GraphQLInputObjectType.typ: Scalars.string->Scalars.toGraphQLType,
        description: ?None,
        deprecationReason: ?None,
      },
      "selectedRegionScreenshotDataUrl": {
        GraphQLInputObjectType.typ: Scalars.string->Scalars.toGraphQLType,
        description: ?None,
        deprecationReason: ?None,
      },
      "selectionAgentContext": {
        GraphQLInputObjectType.typ: Scalars.string->Scalars.toGraphQLType,
        description: ?None,
        deprecationReason: ?None,
      },
      "selectionLabel": {
        GraphQLInputObjectType.typ: Scalars.string->Scalars.toGraphQLType,
        description: ?None,
        deprecationReason: ?None,
      },
      "sendtag": {
        GraphQLInputObjectType.typ: Scalars.string->Scalars.toGraphQLType,
        description: ?None,
        deprecationReason: ?None,
      },
    }->makeFields,
})
union_AdminCreateInviteResult.contents = GraphQLUnionType.make({
  name: "AdminCreateInviteResult",
  description: ?None,
  types: () => [get_AdminCreateInviteSucceeded(), get_MutationFailed()],
  resolveType: GraphQLUnionType.makeResolveUnionTypeFn(union_AdminCreateInviteResult_resolveType),
})
union_AdminCreateSeedUserResult.contents = GraphQLUnionType.make({
  name: "AdminCreateSeedUserResult",
  description: "Result of creating a seed user from the admin GraphQL mutation.",
  types: () => [
    get_AdminCreateSeedUserSucceeded(),
    get_AdminCreateSeedUserUnavailable(),
    get_AdminCreateSeedUserValidationFailed(),
  ],
  resolveType: GraphQLUnionType.makeResolveUnionTypeFn(union_AdminCreateSeedUserResult_resolveType),
})
union_CancelProfileEditSessionResult.contents = GraphQLUnionType.make({
  name: "CancelProfileEditSessionResult",
  description: ?None,
  types: () => [get_ProfileEditSessionMutationFailed(), get_ProfileEditSessionMutationSucceeded()],
  resolveType: GraphQLUnionType.makeResolveUnionTypeFn(
    union_CancelProfileEditSessionResult_resolveType,
  ),
})
union_DisableProfileResult.contents = GraphQLUnionType.make({
  name: "DisableProfileResult",
  description: ?None,
  types: () => [get_DisableProfileSucceeded(), get_MutationFailed()],
  resolveType: GraphQLUnionType.makeResolveUnionTypeFn(union_DisableProfileResult_resolveType),
})
union_DisableUserResult.contents = GraphQLUnionType.make({
  name: "DisableUserResult",
  description: ?None,
  types: () => [get_DisableUserSucceeded(), get_MutationFailed()],
  resolveType: GraphQLUnionType.makeResolveUnionTypeFn(union_DisableUserResult_resolveType),
})
union_ReactivateUsedInviteResult.contents = GraphQLUnionType.make({
  name: "ReactivateUsedInviteResult",
  description: ?None,
  types: () => [get_MutationFailed(), get_ReactivateUsedInviteSucceeded()],
  resolveType: GraphQLUnionType.makeResolveUnionTypeFn(
    union_ReactivateUsedInviteResult_resolveType,
  ),
})
union_RedeemInviteResult.contents = GraphQLUnionType.make({
  name: "RedeemInviteResult",
  description: ?None,
  types: () => [get_MutationFailed(), get_RedeemInviteSucceeded()],
  resolveType: GraphQLUnionType.makeResolveUnionTypeFn(union_RedeemInviteResult_resolveType),
})
union_RestoreProfileVersionResult.contents = GraphQLUnionType.make({
  name: "RestoreProfileVersionResult",
  description: ?None,
  types: () => [get_ProfileVersionMutationFailed(), get_ProfileVersionMutationSucceeded()],
  resolveType: GraphQLUnionType.makeResolveUnionTypeFn(
    union_RestoreProfileVersionResult_resolveType,
  ),
})
union_SaveManualProfileVersionResult.contents = GraphQLUnionType.make({
  name: "SaveManualProfileVersionResult",
  description: ?None,
  types: () => [get_ProfileVersionMutationFailed(), get_ProfileVersionMutationSucceeded()],
  resolveType: GraphQLUnionType.makeResolveUnionTypeFn(
    union_SaveManualProfileVersionResult_resolveType,
  ),
})
union_StartAgentEditResult.contents = GraphQLUnionType.make({
  name: "StartAgentEditResult",
  description: ?None,
  types: () => [get_ProfileEditSessionMutationFailed(), get_ProfileEditSessionMutationSucceeded()],
  resolveType: GraphQLUnionType.makeResolveUnionTypeFn(union_StartAgentEditResult_resolveType),
})
union_SubmitAgentEditResult.contents = GraphQLUnionType.make({
  name: "SubmitAgentEditResult",
  description: ?None,
  types: () => [get_ProfileEditSessionMutationFailed(), get_ProfileEditSessionMutationSucceeded()],
  resolveType: GraphQLUnionType.makeResolveUnionTypeFn(union_SubmitAgentEditResult_resolveType),
})

let schema = GraphQLSchemaType.make({
  "query": get_Query(),
  "mutation": get_Mutation(),
  "types": [
    get_DisableProfileSucceeded()->GraphQLObjectType.toGraphQLType,
    get_AdminCreateSeedUserUnavailable()->GraphQLObjectType.toGraphQLType,
    get_DisableUserSucceeded()->GraphQLObjectType.toGraphQLType,
    get_ProfileUpdateEventConnection()->GraphQLObjectType.toGraphQLType,
    get_Query()->GraphQLObjectType.toGraphQLType,
    get_ProfileVersionEdge()->GraphQLObjectType.toGraphQLType,
    get_FriendConnection()->GraphQLObjectType.toGraphQLType,
    get_AgentConversationSummary()->GraphQLObjectType.toGraphQLType,
    get_AdminCreateSeedUserSucceeded()->GraphQLObjectType.toGraphQLType,
    get_RedeemInviteSucceeded()->GraphQLObjectType.toGraphQLType,
    get_SelectionSnapshot()->GraphQLObjectType.toGraphQLType,
    get_InviteChainFriendEdge()->GraphQLObjectType.toGraphQLType,
    get_ProfileVersionMutationSucceeded()->GraphQLObjectType.toGraphQLType,
    get_MutationFailed()->GraphQLObjectType.toGraphQLType,
    get_ProfileUpdateEvent()->GraphQLObjectType.toGraphQLType,
    get_Profile()->GraphQLObjectType.toGraphQLType,
    get_PageInfo()->GraphQLObjectType.toGraphQLType,
    get_ProfileUpdateEventEdge()->GraphQLObjectType.toGraphQLType,
    get_InviteChainFriendConnection()->GraphQLObjectType.toGraphQLType,
    get_ProfileEditSessionMutationFailed()->GraphQLObjectType.toGraphQLType,
    get_ProfileEditSessionEdge()->GraphQLObjectType.toGraphQLType,
    get_ReactivateUsedInviteSucceeded()->GraphQLObjectType.toGraphQLType,
    get_ProfileVersionMutationFailed()->GraphQLObjectType.toGraphQLType,
    get_Invite()->GraphQLObjectType.toGraphQLType,
    get_AdminCreateInviteSucceeded()->GraphQLObjectType.toGraphQLType,
    get_AdminCreateSeedUserValidationFailed()->GraphQLObjectType.toGraphQLType,
    get_ProfileEditSessionConnection()->GraphQLObjectType.toGraphQLType,
    get_ProfileEditSessionMutationSucceeded()->GraphQLObjectType.toGraphQLType,
    get_InviteChainFriend()->GraphQLObjectType.toGraphQLType,
    get_User()->GraphQLObjectType.toGraphQLType,
    get_SendtagLookupResult()->GraphQLObjectType.toGraphQLType,
    get_TrustedCapabilityReference()->GraphQLObjectType.toGraphQLType,
    get_ProfileEditSession()->GraphQLObjectType.toGraphQLType,
    get_ProfileVersionConnection()->GraphQLObjectType.toGraphQLType,
    get_SelectedElementMetadata()->GraphQLObjectType.toGraphQLType,
    get_Mutation()->GraphQLObjectType.toGraphQLType,
    get_ProfileVersion()->GraphQLObjectType.toGraphQLType,
    get_Node()->GraphQLInterfaceType.toGraphQLType,
    get_SubmitAgentEditResult()->GraphQLUnionType.toGraphQLType,
    get_ReactivateUsedInviteResult()->GraphQLUnionType.toGraphQLType,
    get_DisableProfileResult()->GraphQLUnionType.toGraphQLType,
    get_RedeemInviteResult()->GraphQLUnionType.toGraphQLType,
    get_DisableUserResult()->GraphQLUnionType.toGraphQLType,
    get_AdminCreateInviteResult()->GraphQLUnionType.toGraphQLType,
    get_CancelProfileEditSessionResult()->GraphQLUnionType.toGraphQLType,
    get_StartAgentEditResult()->GraphQLUnionType.toGraphQLType,
    get_SaveManualProfileVersionResult()->GraphQLUnionType.toGraphQLType,
    get_AdminCreateSeedUserResult()->GraphQLUnionType.toGraphQLType,
    get_RestoreProfileVersionResult()->GraphQLUnionType.toGraphQLType,
    get_SaveManualProfileVersionInput()->GraphQLInputObjectType.toGraphQLType,
    get_AdminCreateSeedUserInput()->GraphQLInputObjectType.toGraphQLType,
    get_SubmitAgentEditInput()->GraphQLInputObjectType.toGraphQLType,
    get_AdminCreateInviteInput()->GraphQLInputObjectType.toGraphQLType,
    get_RedeemInviteInput()->GraphQLInputObjectType.toGraphQLType,
    get_CancelProfileEditSessionInput()->GraphQLInputObjectType.toGraphQLType,
    get_RestoreProfileVersionInput()->GraphQLInputObjectType.toGraphQLType,
    get_DisableUserInput()->GraphQLInputObjectType.toGraphQLType,
    get_ReactivateUsedInviteInput()->GraphQLInputObjectType.toGraphQLType,
    get_DisableProfileInput()->GraphQLInputObjectType.toGraphQLType,
    enum_ValidationStatus->GraphQLEnumType.toGraphQLType,
    enum_TrustedCapabilityKind->GraphQLEnumType.toGraphQLType,
    enum_ProfileUpdateEventKind->GraphQLEnumType.toGraphQLType,
    enum_UserStatus->GraphQLEnumType.toGraphQLType,
    enum_ProfileEditSessionStatus->GraphQLEnumType.toGraphQLType,
    enum_UserRole->GraphQLEnumType.toGraphQLType,
    enum_FriendConnectionStatus->GraphQLEnumType.toGraphQLType,
    enum_ActivityVisibility->GraphQLEnumType.toGraphQLType,
    enum_ProfileVersionSource->GraphQLEnumType.toGraphQLType,
    enum_EditProgressPhase->GraphQLEnumType.toGraphQLType,
    enum_FriendConnectionSource->GraphQLEnumType.toGraphQLType,
    enum_AssistantEditMode->GraphQLEnumType.toGraphQLType,
    enum_SelectionSnapshotKind->GraphQLEnumType.toGraphQLType,
    enum_InviteStatus->GraphQLEnumType.toGraphQLType,
    enum_ProfileVisibility->GraphQLEnumType.toGraphQLType,
  ],
})
