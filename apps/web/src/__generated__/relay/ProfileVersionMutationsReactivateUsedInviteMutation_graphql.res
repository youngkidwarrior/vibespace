/* @sourceLoc ProfileVersionMutations.res */
/* @generated */
%%raw("/* @generated */")
module Types = {
  @@warning("-30")

  @live type reactivateUsedInviteInput = RelaySchemaAssets_graphql.input_ReactivateUsedInviteInput
  @live
  type rec response_reactivateUsedInvite_ReactivateUsedInviteSucceeded_invite = {
    code: option<string>,
    @live id: string,
    inviteeUserId: option<string>,
    inviterUserId: string,
    redeemedAt: option<string>,
    status: RelaySchemaAssets_graphql.enum_InviteStatus,
  }
  @live
  and response_reactivateUsedInvite_ReactivateUsedInviteSucceeded_user = {
    displayName: string,
    handle: string,
    @live id: string,
    status: RelaySchemaAssets_graphql.enum_UserStatus,
  }
  @tag("__typename") and response_reactivateUsedInvite = 
    | @live MutationFailed(
      {
        message: string,
      }
    )
    | @live ReactivateUsedInviteSucceeded(
      {
        invite: response_reactivateUsedInvite_ReactivateUsedInviteSucceeded_invite,
        user: response_reactivateUsedInvite_ReactivateUsedInviteSucceeded_user,
      }
    )
    | @live @as("__unselected") UnselectedUnionMember(string)

  @live
  type response = {
    reactivateUsedInvite: response_reactivateUsedInvite,
  }
  @live
  type rawResponse = response
  @live
  type variables = {
    input: reactivateUsedInviteInput,
  }
}

@live
let unwrap_response_reactivateUsedInvite: Types.response_reactivateUsedInvite => Types.response_reactivateUsedInvite = RescriptRelay_Internal.unwrapUnion(_, ["MutationFailed", "ReactivateUsedInviteSucceeded"])
@live
let wrap_response_reactivateUsedInvite: Types.response_reactivateUsedInvite => Types.response_reactivateUsedInvite = RescriptRelay_Internal.wrapUnion
module Internal = {
  @live
  let variablesConverter: dict<dict<dict<string>>> = %raw(
    json`{"reactivateUsedInviteInput":{},"__root":{"input":{"r":"reactivateUsedInviteInput"}}}`
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
    json`{"__root":{"reactivateUsedInvite":{"u":"response_reactivateUsedInvite"}}}`
  )
  @live
  let wrapResponseConverterMap = {
    "response_reactivateUsedInvite": wrap_response_reactivateUsedInvite,
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
    json`{"__root":{"reactivateUsedInvite":{"u":"response_reactivateUsedInvite"}}}`
  )
  @live
  let responseConverterMap = {
    "response_reactivateUsedInvite": unwrap_response_reactivateUsedInvite,
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
  @live
  external userStatus_toString: RelaySchemaAssets_graphql.enum_UserStatus => string = "%identity"
  @live
  external userStatus_input_toString: RelaySchemaAssets_graphql.enum_UserStatus_input => string = "%identity"
  @live
  let userStatus_decode = (enum: RelaySchemaAssets_graphql.enum_UserStatus): option<RelaySchemaAssets_graphql.enum_UserStatus_input> => {
    switch enum {
      | FutureAddedValue(_) => None
      | valid => Some(Obj.magic(valid))
    }
  }
  @live
  let userStatus_fromString = (str: string): option<RelaySchemaAssets_graphql.enum_UserStatus_input> => {
    userStatus_decode(Obj.magic(str))
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
    "name": "reactivateUsedInvite",
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
              {
                "alias": null,
                "args": null,
                "kind": "ScalarField",
                "name": "inviterUserId",
                "storageKey": null
              },
              {
                "alias": null,
                "args": null,
                "kind": "ScalarField",
                "name": "inviteeUserId",
                "storageKey": null
              },
              (v2/*: any*/),
              {
                "alias": null,
                "args": null,
                "kind": "ScalarField",
                "name": "redeemedAt",
                "storageKey": null
              }
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
              },
              (v2/*: any*/)
            ],
            "storageKey": null
          }
        ],
        "type": "ReactivateUsedInviteSucceeded",
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
    "name": "ProfileVersionMutationsReactivateUsedInviteMutation",
    "selections": (v3/*: any*/),
    "type": "Mutation",
    "abstractKey": null
  },
  "kind": "Request",
  "operation": {
    "argumentDefinitions": (v0/*: any*/),
    "kind": "Operation",
    "name": "ProfileVersionMutationsReactivateUsedInviteMutation",
    "selections": (v3/*: any*/)
  },
  "params": {
    "cacheID": "eb0245c35c7ad77945763f7247e2e738",
    "id": null,
    "metadata": {},
    "name": "ProfileVersionMutationsReactivateUsedInviteMutation",
    "operationKind": "mutation",
    "text": "mutation ProfileVersionMutationsReactivateUsedInviteMutation(\n  $input: ReactivateUsedInviteInput!\n) {\n  reactivateUsedInvite(input: $input) {\n    __typename\n    ... on ReactivateUsedInviteSucceeded {\n      invite {\n        id\n        code\n        inviterUserId\n        inviteeUserId\n        status\n        redeemedAt\n      }\n      user {\n        id\n        handle\n        displayName\n        status\n      }\n    }\n    ... on MutationFailed {\n      message\n    }\n  }\n}\n"
  }
};
})() `)


