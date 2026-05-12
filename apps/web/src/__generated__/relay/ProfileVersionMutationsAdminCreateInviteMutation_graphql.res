/* @sourceLoc ProfileVersionMutations.res */
/* @generated */
%%raw("/* @generated */")
module Types = {
  @@warning("-30")

  @live type adminCreateInviteInput = RelaySchemaAssets_graphql.input_AdminCreateInviteInput
  @live
  type rec response_adminCreateInvite_AdminCreateInviteSucceeded_invite = {
    code: option<string>,
    @live id: string,
    status: RelaySchemaAssets_graphql.enum_InviteStatus,
  }
  @tag("__typename") and response_adminCreateInvite = 
    | @live AdminCreateInviteSucceeded(
      {
        invite: response_adminCreateInvite_AdminCreateInviteSucceeded_invite,
      }
    )
    | @live MutationFailed(
      {
        message: string,
      }
    )
    | @live @as("__unselected") UnselectedUnionMember(string)

  @live
  type response = {
    adminCreateInvite: response_adminCreateInvite,
  }
  @live
  type rawResponse = response
  @live
  type variables = {
    input: adminCreateInviteInput,
  }
}

@live
let unwrap_response_adminCreateInvite: Types.response_adminCreateInvite => Types.response_adminCreateInvite = RescriptRelay_Internal.unwrapUnion(_, ["AdminCreateInviteSucceeded", "MutationFailed"])
@live
let wrap_response_adminCreateInvite: Types.response_adminCreateInvite => Types.response_adminCreateInvite = RescriptRelay_Internal.wrapUnion
module Internal = {
  @live
  let variablesConverter: dict<dict<dict<string>>> = %raw(
    json`{"adminCreateInviteInput":{},"__root":{"input":{"r":"adminCreateInviteInput"}}}`
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
    json`{"__root":{"adminCreateInvite":{"u":"response_adminCreateInvite"}}}`
  )
  @live
  let wrapResponseConverterMap = {
    "response_adminCreateInvite": wrap_response_adminCreateInvite,
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
    json`{"__root":{"adminCreateInvite":{"u":"response_adminCreateInvite"}}}`
  )
  @live
  let responseConverterMap = {
    "response_adminCreateInvite": unwrap_response_adminCreateInvite,
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
v1 = [
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
    "name": "adminCreateInvite",
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
              {
                "alias": null,
                "args": null,
                "kind": "ScalarField",
                "name": "id",
                "storageKey": null
              },
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
                "name": "status",
                "storageKey": null
              }
            ],
            "storageKey": null
          }
        ],
        "type": "AdminCreateInviteSucceeded",
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
    "name": "ProfileVersionMutationsAdminCreateInviteMutation",
    "selections": (v1/*: any*/),
    "type": "Mutation",
    "abstractKey": null
  },
  "kind": "Request",
  "operation": {
    "argumentDefinitions": (v0/*: any*/),
    "kind": "Operation",
    "name": "ProfileVersionMutationsAdminCreateInviteMutation",
    "selections": (v1/*: any*/)
  },
  "params": {
    "cacheID": "d30dba9bce2b7490180cf182871a6a51",
    "id": null,
    "metadata": {},
    "name": "ProfileVersionMutationsAdminCreateInviteMutation",
    "operationKind": "mutation",
    "text": "mutation ProfileVersionMutationsAdminCreateInviteMutation(\n  $input: AdminCreateInviteInput!\n) {\n  adminCreateInvite(input: $input) {\n    __typename\n    ... on AdminCreateInviteSucceeded {\n      invite {\n        id\n        code\n        status\n      }\n    }\n    ... on MutationFailed {\n      message\n    }\n  }\n}\n"
  }
};
})() `)


