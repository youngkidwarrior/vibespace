/* @sourceLoc ProfileVersionMutations.res */
/* @generated */
%%raw("/* @generated */")
module Types = {
  @@warning("-30")

  @live type redeemInviteInput = RelaySchemaAssets_graphql.input_RedeemInviteInput
  @live
  type rec response_redeemInvite_RedeemInviteSucceeded_friendConnection = {
    @live id: string,
    status: RelaySchemaAssets_graphql.enum_FriendConnectionStatus,
  }
  @live
  and response_redeemInvite_RedeemInviteSucceeded_invite = {
    code: option<string>,
    @live id: string,
    status: RelaySchemaAssets_graphql.enum_InviteStatus,
  }
  @live
  and response_redeemInvite_RedeemInviteSucceeded_profile = {
    @live id: string,
    slug: string,
    title: string,
  }
  @live
  and response_redeemInvite_RedeemInviteSucceeded_user = {
    displayName: string,
    handle: string,
    @live id: string,
  }
  @tag("__typename") and response_redeemInvite = 
    | @live MutationFailed(
      {
        message: string,
      }
    )
    | @live RedeemInviteSucceeded(
      {
        friendConnection: response_redeemInvite_RedeemInviteSucceeded_friendConnection,
        invite: response_redeemInvite_RedeemInviteSucceeded_invite,
        profile: response_redeemInvite_RedeemInviteSucceeded_profile,
        sessionToken: option<string>,
        user: response_redeemInvite_RedeemInviteSucceeded_user,
      }
    )
    | @live @as("__unselected") UnselectedUnionMember(string)

  @live
  type response = {
    redeemInvite: response_redeemInvite,
  }
  @live
  type rawResponse = response
  @live
  type variables = {
    input: redeemInviteInput,
  }
}

@live
let unwrap_response_redeemInvite: Types.response_redeemInvite => Types.response_redeemInvite = RescriptRelay_Internal.unwrapUnion(_, ["MutationFailed", "RedeemInviteSucceeded"])
@live
let wrap_response_redeemInvite: Types.response_redeemInvite => Types.response_redeemInvite = RescriptRelay_Internal.wrapUnion
module Internal = {
  @live
  let variablesConverter: dict<dict<dict<string>>> = %raw(
    json`{"redeemInviteInput":{},"__root":{"input":{"r":"redeemInviteInput"}}}`
  )
  @live
  let variablesConverterMap = ()
  @live
  let convertVariables = v => v->RescriptRelay.convertObj(
    variablesConverter,
    variablesConverterMap,
    None
  )
  @live
  type wrapResponseRaw
  @live
  let wrapResponseConverter: dict<dict<dict<string>>> = %raw(
    json`{"__root":{"redeemInvite":{"u":"response_redeemInvite"}}}`
  )
  @live
  let wrapResponseConverterMap = {
    "response_redeemInvite": wrap_response_redeemInvite,
  }
  @live
  let convertWrapResponse = v => v->RescriptRelay.convertObj(
    wrapResponseConverter,
    wrapResponseConverterMap,
    null
  )
  @live
  type responseRaw
  @live
  let responseConverter: dict<dict<dict<string>>> = %raw(
    json`{"__root":{"redeemInvite":{"u":"response_redeemInvite"}}}`
  )
  @live
  let responseConverterMap = {
    "response_redeemInvite": unwrap_response_redeemInvite,
  }
  @live
  let convertResponse = v => v->RescriptRelay.convertObj(
    responseConverter,
    responseConverterMap,
    None
  )
  type wrapRawResponseRaw = wrapResponseRaw
  @live
  let convertWrapRawResponse = convertWrapResponse
  type rawResponseRaw = responseRaw
  @live
  let convertRawResponse = convertResponse
}
module Utils = {
  @@warning("-33")
  open Types
  @live
  external friendConnectionStatus_toString: RelaySchemaAssets_graphql.enum_FriendConnectionStatus => string = "%identity"
  @live
  external friendConnectionStatus_input_toString: RelaySchemaAssets_graphql.enum_FriendConnectionStatus_input => string = "%identity"
  @live
  let friendConnectionStatus_decode = (enum: RelaySchemaAssets_graphql.enum_FriendConnectionStatus): option<RelaySchemaAssets_graphql.enum_FriendConnectionStatus_input> => {
    switch enum {
      | FutureAddedValue(_) => None
      | valid => Some(Obj.magic(valid))
    }
  }
  @live
  let friendConnectionStatus_fromString = (str: string): option<RelaySchemaAssets_graphql.enum_FriendConnectionStatus_input> => {
    friendConnectionStatus_decode(Obj.magic(str))
  }
  @live
  external inviteStatus_toString: RelaySchemaAssets_graphql.enum_InviteStatus => string = "%identity"
  @live
  external inviteStatus_input_toString: RelaySchemaAssets_graphql.enum_InviteStatus_input => string = "%identity"
  @live
  let inviteStatus_decode = (enum: RelaySchemaAssets_graphql.enum_InviteStatus): option<RelaySchemaAssets_graphql.enum_InviteStatus_input> => {
    switch enum {
      | FutureAddedValue(_) => None
      | valid => Some(Obj.magic(valid))
    }
  }
  @live
  let inviteStatus_fromString = (str: string): option<RelaySchemaAssets_graphql.enum_InviteStatus_input> => {
    inviteStatus_decode(Obj.magic(str))
  }
}

type relayOperationNode
type operationType = RescriptRelay.mutationNode<relayOperationNode>


let node: operationType = %raw(json` (function(){
var v0 = [
  {
    "defaultValue": null,
    "kind": "LocalArgument",
    "name": "input"
  }
],
v1 = {
  "alias": null,
  "args": null,
  "kind": "ScalarField",
  "name": "id",
  "storageKey": null
},
v2 = {
  "alias": null,
  "args": null,
  "kind": "ScalarField",
  "name": "status",
  "storageKey": null
},
v3 = [
  {
    "alias": null,
    "args": [
      {
        "kind": "Variable",
        "name": "input",
        "variableName": "input"
      }
    ],
    "concreteType": null,
    "kind": "LinkedField",
    "name": "redeemInvite",
    "plural": false,
    "selections": [
      {
        "alias": null,
        "args": null,
        "kind": "ScalarField",
        "name": "__typename",
        "storageKey": null
      },
      {
        "kind": "InlineFragment",
        "selections": [
          {
            "alias": null,
            "args": null,
            "kind": "ScalarField",
            "name": "sessionToken",
            "storageKey": null
          },
          {
            "alias": null,
            "args": null,
            "concreteType": "Invite",
            "kind": "LinkedField",
            "name": "invite",
            "plural": false,
            "selections": [
              (v1/*: any*/),
              {
                "alias": null,
                "args": null,
                "kind": "ScalarField",
                "name": "code",
                "storageKey": null
              },
              (v2/*: any*/)
            ],
            "storageKey": null
          },
          {
            "alias": null,
            "args": null,
            "concreteType": "User",
            "kind": "LinkedField",
            "name": "user",
            "plural": false,
            "selections": [
              (v1/*: any*/),
              {
                "alias": null,
                "args": null,
                "kind": "ScalarField",
                "name": "handle",
                "storageKey": null
              },
              {
                "alias": null,
                "args": null,
                "kind": "ScalarField",
                "name": "displayName",
                "storageKey": null
              }
            ],
            "storageKey": null
          },
          {
            "alias": null,
            "args": null,
            "concreteType": "FriendConnection",
            "kind": "LinkedField",
            "name": "friendConnection",
            "plural": false,
            "selections": [
              (v1/*: any*/),
              (v2/*: any*/)
            ],
            "storageKey": null
          },
          {
            "alias": null,
            "args": null,
            "concreteType": "Profile",
            "kind": "LinkedField",
            "name": "profile",
            "plural": false,
            "selections": [
              (v1/*: any*/),
              {
                "alias": null,
                "args": null,
                "kind": "ScalarField",
                "name": "title",
                "storageKey": null
              },
              {
                "alias": null,
                "args": null,
                "kind": "ScalarField",
                "name": "slug",
                "storageKey": null
              }
            ],
            "storageKey": null
          }
        ],
        "type": "RedeemInviteSucceeded",
        "abstractKey": null
      },
      {
        "kind": "InlineFragment",
        "selections": [
          {
            "alias": null,
            "args": null,
            "kind": "ScalarField",
            "name": "message",
            "storageKey": null
          }
        ],
        "type": "MutationFailed",
        "abstractKey": null
      }
    ],
    "storageKey": null
  }
];
return {
  "fragment": {
    "argumentDefinitions": (v0/*: any*/),
    "kind": "Fragment",
    "metadata": null,
    "name": "ProfileVersionMutationsRedeemInviteMutation",
    "selections": (v3/*: any*/),
    "type": "Mutation",
    "abstractKey": null
  },
  "kind": "Request",
  "operation": {
    "argumentDefinitions": (v0/*: any*/),
    "kind": "Operation",
    "name": "ProfileVersionMutationsRedeemInviteMutation",
    "selections": (v3/*: any*/)
  },
  "params": {
    "cacheID": "297891b79af11b5d248a5d9d21a54290",
    "id": null,
    "metadata": {},
    "name": "ProfileVersionMutationsRedeemInviteMutation",
    "operationKind": "mutation",
    "text": "mutation ProfileVersionMutationsRedeemInviteMutation(\n  $input: RedeemInviteInput!\n) {\n  redeemInvite(input: $input) {\n    __typename\n    ... on RedeemInviteSucceeded {\n      sessionToken\n      invite {\n        id\n        code\n        status\n      }\n      user {\n        id\n        handle\n        displayName\n      }\n      friendConnection {\n        id\n        status\n      }\n      profile {\n        id\n        title\n        slug\n      }\n    }\n    ... on MutationFailed {\n      message\n    }\n  }\n}\n"
  }
};
})() `)


