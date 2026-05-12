/* @sourceLoc ProfileVersionMutations.res */
/* @generated */
%%raw("/* @generated */")
module Types = {
  @@warning("-30")

  @live type adminCreateSeedUserInput = RelaySchemaAssets_graphql.input_AdminCreateSeedUserInput
  @live
  type rec response_adminCreateSeedUser_AdminCreateSeedUserSucceeded_invite = {
    code: option<string>,
    @live id: string,
    status: RelaySchemaAssets_graphql.enum_InviteStatus,
  }
  @live
  and response_adminCreateSeedUser_AdminCreateSeedUserSucceeded_user = {
    displayName: string,
    handle: string,
    @live id: string,
  }
  @tag("__typename") and response_adminCreateSeedUser = 
    | @live AdminCreateSeedUserSucceeded(
      {
        invite: response_adminCreateSeedUser_AdminCreateSeedUserSucceeded_invite,
        sessionToken: string,
        user: response_adminCreateSeedUser_AdminCreateSeedUserSucceeded_user,
        warnings: array<string>,
      }
    )
    | @live AdminCreateSeedUserUnavailable(
      {
        message: string,
      }
    )
    | @live AdminCreateSeedUserValidationFailed(
      {
        fields: array<string>,
        message: string,
      }
    )
    | @live @as("__unselected") UnselectedUnionMember(string)

  @live
  type response = {
    adminCreateSeedUser: response_adminCreateSeedUser,
  }
  @live
  type rawResponse = response
  @live
  type variables = {
    input: adminCreateSeedUserInput,
  }
}

@live
let unwrap_response_adminCreateSeedUser: Types.response_adminCreateSeedUser => Types.response_adminCreateSeedUser = RescriptRelay_Internal.unwrapUnion(_, ["AdminCreateSeedUserSucceeded", "AdminCreateSeedUserUnavailable", "AdminCreateSeedUserValidationFailed"])
@live
let wrap_response_adminCreateSeedUser: Types.response_adminCreateSeedUser => Types.response_adminCreateSeedUser = RescriptRelay_Internal.wrapUnion
module Internal = {
  @live
  let variablesConverter: dict<dict<dict<string>>> = %raw(
    json`{"adminCreateSeedUserInput":{},"__root":{"input":{"r":"adminCreateSeedUserInput"}}}`
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
    json`{"__root":{"adminCreateSeedUser":{"u":"response_adminCreateSeedUser"}}}`
  )
  @live
  let wrapResponseConverterMap = {
    "response_adminCreateSeedUser": wrap_response_adminCreateSeedUser,
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
    json`{"__root":{"adminCreateSeedUser":{"u":"response_adminCreateSeedUser"}}}`
  )
  @live
  let responseConverterMap = {
    "response_adminCreateSeedUser": unwrap_response_adminCreateSeedUser,
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
  external userRole_toString: RelaySchemaAssets_graphql.enum_UserRole => string = "%identity"
  @live
  external userRole_input_toString: RelaySchemaAssets_graphql.enum_UserRole_input => string = "%identity"
  @live
  let userRole_decode = (enum: RelaySchemaAssets_graphql.enum_UserRole): option<RelaySchemaAssets_graphql.enum_UserRole_input> => {
    switch enum {
      | FutureAddedValue(_) => None
      | valid => Some(Obj.magic(valid))
    }
  }
  @live
  let userRole_fromString = (str: string): option<RelaySchemaAssets_graphql.enum_UserRole_input> => {
    userRole_decode(Obj.magic(str))
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
  "name": "message",
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
    "name": "adminCreateSeedUser",
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
                "name": "status",
                "storageKey": null
              }
            ],
            "storageKey": null
          },
          {
            "alias": null,
            "args": null,
            "kind": "ScalarField",
            "name": "warnings",
            "storageKey": null
          }
        ],
        "type": "AdminCreateSeedUserSucceeded",
        "abstractKey": null
      },
      {
        "kind": "InlineFragment",
        "selections": [
          (v2/*: any*/),
          {
            "alias": null,
            "args": null,
            "kind": "ScalarField",
            "name": "fields",
            "storageKey": null
          }
        ],
        "type": "AdminCreateSeedUserValidationFailed",
        "abstractKey": null
      },
      {
        "kind": "InlineFragment",
        "selections": [
          (v2/*: any*/)
        ],
        "type": "AdminCreateSeedUserUnavailable",
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
    "name": "ProfileVersionMutationsAdminCreateSeedUserMutation",
    "selections": (v3/*: any*/),
    "type": "Mutation",
    "abstractKey": null
  },
  "kind": "Request",
  "operation": {
    "argumentDefinitions": (v0/*: any*/),
    "kind": "Operation",
    "name": "ProfileVersionMutationsAdminCreateSeedUserMutation",
    "selections": (v3/*: any*/)
  },
  "params": {
    "cacheID": "cacac5d7e53ab50840c9e8039c5248f2",
    "id": null,
    "metadata": {},
    "name": "ProfileVersionMutationsAdminCreateSeedUserMutation",
    "operationKind": "mutation",
    "text": "mutation ProfileVersionMutationsAdminCreateSeedUserMutation(\n  $input: AdminCreateSeedUserInput!\n) {\n  adminCreateSeedUser(input: $input) {\n    __typename\n    ... on AdminCreateSeedUserSucceeded {\n      sessionToken\n      user {\n        id\n        handle\n        displayName\n      }\n      invite {\n        id\n        code\n        status\n      }\n      warnings\n    }\n    ... on AdminCreateSeedUserValidationFailed {\n      message\n      fields\n    }\n    ... on AdminCreateSeedUserUnavailable {\n      message\n    }\n  }\n}\n"
  }
};
})() `)


