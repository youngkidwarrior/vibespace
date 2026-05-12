/* @generated */

@@warning("-27-34-37")

module Resolver = {
  @gql.interfaceResolver("node")
  type t =
    | AgentConversationSummary(BackendSchema.agentConversationSummary)
    | FriendConnection(BackendSchema.friendConnection)
    | Invite(BackendSchema.invite)
    | Profile(BackendSchema.profile)
    | ProfileEditSession(BackendSchema.profileEditSession)
    | ProfileUpdateEvent(BackendSchema.profileUpdateEvent)
    | ProfileVersion(BackendSchema.profileVersion)
    | SelectionSnapshot(BackendSchema.selectionSnapshot)
    | TrustedCapabilityReference(BackendSchema.trustedCapabilityReference)
    | User(BackendSchema.user)
}

module ImplementedBy = {
  type t =
    | AgentConversationSummary
    | FriendConnection
    | Invite
    | Profile
    | ProfileEditSession
    | ProfileUpdateEvent
    | ProfileVersion
    | SelectionSnapshot
    | TrustedCapabilityReference
    | User

  let decode = (str: string) =>
    switch str {
    | "AgentConversationSummary" => Some(AgentConversationSummary)
    | "FriendConnection" => Some(FriendConnection)
    | "Invite" => Some(Invite)
    | "Profile" => Some(Profile)
    | "ProfileEditSession" => Some(ProfileEditSession)
    | "ProfileUpdateEvent" => Some(ProfileUpdateEvent)
    | "ProfileVersion" => Some(ProfileVersion)
    | "SelectionSnapshot" => Some(SelectionSnapshot)
    | "TrustedCapabilityReference" => Some(TrustedCapabilityReference)
    | "User" => Some(User)
    | _ => None
    }

  external toString: t => string = "%identity"
}

type typeMap<'a> = {
  @as("AgentConversationSummary") agentConversationSummary: 'a,
  @as("FriendConnection") friendConnection: 'a,
  @as("Invite") invite: 'a,
  @as("Profile") profile: 'a,
  @as("ProfileEditSession") profileEditSession: 'a,
  @as("ProfileUpdateEvent") profileUpdateEvent: 'a,
  @as("ProfileVersion") profileVersion: 'a,
  @as("SelectionSnapshot") selectionSnapshot: 'a,
  @as("TrustedCapabilityReference") trustedCapabilityReference: 'a,
  @as("User") user: 'a,
}

module TypeMap: {
  type t<'value>
  let make: (typeMap<'value>, ~valueToString: 'value => string) => t<'value>

  /** Takes a (stringified) value and returns what type it represents, if any. */
  let getTypeByStringifiedValue: (t<'value>, string) => option<ImplementedBy.t>

  /** Takes a type and returns what value it represents, as string. */
  let getStringifiedValueByType: (t<'value>, ImplementedBy.t) => string
} = {
  external unsafe_toDict: typeMap<'value> => dict<'value> = "%identity"
  external unsafe_toType: string => ImplementedBy.t = "%identity"
  type t<'value> = {
    typeToValue: dict<'value>,
    valueToTypeAsString: dict<string>,
    valueToString: 'value => string,
  }
  let make = (typeMap, ~valueToString) => {
    typeToValue: typeMap->unsafe_toDict,
    valueToTypeAsString: typeMap
    ->unsafe_toDict
    ->Dict.toArray
    ->Array.map(((key, value)) => (valueToString(value), key))
    ->Dict.fromArray,
    valueToString,
  }

  let getStringifiedValueByType = (t, typ) =>
    t.typeToValue
    ->Dict.get(typ->ImplementedBy.toString)
    ->Option.getOrThrow
    ->t.valueToString
  let getTypeByStringifiedValue = (t, str) =>
    t.valueToTypeAsString->Dict.get(str)->Option.map(unsafe_toType)
}
