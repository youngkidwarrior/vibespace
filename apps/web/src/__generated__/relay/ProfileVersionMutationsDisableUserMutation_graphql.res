/* @sourceLoc ProfileVersionMutations.res */
/* @generated */
%%raw("/* @generated */")
module Types = {
  @@warning("-30")

  @live type disableUserInput = RelaySchemaAssets_graphql.input_DisableUserInput
  @live
  type rec response_disableUser_DisableUserSucceeded_user = {
    displayName: string,
    handle: string,
    @live id: string,
    status: RelaySchemaAssets_graphql.enum_UserStatus,
  }
  @tag("__typename") and response_disableUser = 
    | @live DisableUserSucceeded(
      {
        user: response_disableUser_DisableUserSucceeded_user,
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
    disableUser: response_disableUser,
  }
  @live
  type rawResponse = response
  @live
  type variables = {
    input: disableUserInput,
  }
}

@live
let unwrap_response_disableUser: Types.response_disableUser => Types.response_disableUser = RescriptRelay_Internal.unwrapUnion(_, ["DisableUserSucceeded", "MutationFailed"])
@live
let wrap_response_disableUser: Types.response_disableUser => Types.response_disableUser = RescriptRelay_Internal.wrapUnion
module Internal = {
  @live
  let variablesConverter: dict<dict<dict<string>>> = %raw(
    json`{"disableUserInput":{},"__root":{"input":{"r":"disableUserInput"}}}`
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
    json`{"__root":{"disableUser":{"u":"response_disableUser"}}}`
  )
  @live
  let wrapResponseConverterMap = {
    "response_disableUser": wrap_response_disableUser,
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
    json`{"__root":{"disableUser":{"u":"response_disableUser"}}}`
  )
  @live
  let responseConverterMap = {
    "response_disableUser": unwrap_response_disableUser,
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
    "name": "disableUser",
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
            "concreteType": "User",
            "kind": "LinkedField",
            "name": "user",
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
        "type": "DisableUserSucceeded",
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
    "name": "ProfileVersionMutationsDisableUserMutation",
    "selections": (v1/*: any*/),
    "type": "Mutation",
    "abstractKey": null
  },
  "kind": "Request",
  "operation": {
    "argumentDefinitions": (v0/*: any*/),
    "kind": "Operation",
    "name": "ProfileVersionMutationsDisableUserMutation",
    "selections": (v1/*: any*/)
  },
  "params": {
    "cacheID": "f61f4c347365089f3e56cc5c59a5b363",
    "id": null,
    "metadata": {},
    "name": "ProfileVersionMutationsDisableUserMutation",
    "operationKind": "mutation",
    "text": "mutation ProfileVersionMutationsDisableUserMutation(\n  $input: DisableUserInput!\n) {\n  disableUser(input: $input) {\n    __typename\n    ... on DisableUserSucceeded {\n      user {\n        id\n        handle\n        displayName\n        status\n      }\n    }\n    ... on MutationFailed {\n      message\n    }\n  }\n}\n"
  }
};
})() `)


