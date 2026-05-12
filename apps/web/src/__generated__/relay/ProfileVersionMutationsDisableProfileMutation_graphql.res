/* @sourceLoc ProfileVersionMutations.res */
/* @generated */
%%raw("/* @generated */")
module Types = {
  @@warning("-30")

  @live type disableProfileInput = RelaySchemaAssets_graphql.input_DisableProfileInput
  @live
  type rec response_disableProfile_DisableProfileSucceeded_profile = {
    disabledAt: option<string>,
    disabledReason: option<string>,
    @live id: string,
    slug: string,
    title: string,
    visibility: RelaySchemaAssets_graphql.enum_ProfileVisibility,
  }
  @tag("__typename") and response_disableProfile = 
    | @live DisableProfileSucceeded(
      {
        profile: response_disableProfile_DisableProfileSucceeded_profile,
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
    disableProfile: response_disableProfile,
  }
  @live
  type rawResponse = response
  @live
  type variables = {
    input: disableProfileInput,
  }
}

@live
let unwrap_response_disableProfile: Types.response_disableProfile => Types.response_disableProfile = RescriptRelay_Internal.unwrapUnion(_, ["DisableProfileSucceeded", "MutationFailed"])
@live
let wrap_response_disableProfile: Types.response_disableProfile => Types.response_disableProfile = RescriptRelay_Internal.wrapUnion
module Internal = {
  @live
  let variablesConverter: dict<dict<dict<string>>> = %raw(
    json`{"disableProfileInput":{},"__root":{"input":{"r":"disableProfileInput"}}}`
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
    json`{"__root":{"disableProfile":{"u":"response_disableProfile"}}}`
  )
  @live
  let wrapResponseConverterMap = {
    "response_disableProfile": wrap_response_disableProfile,
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
    json`{"__root":{"disableProfile":{"u":"response_disableProfile"}}}`
  )
  @live
  let responseConverterMap = {
    "response_disableProfile": unwrap_response_disableProfile,
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
  external profileVisibility_toString: RelaySchemaAssets_graphql.enum_ProfileVisibility => string = "%identity"
  @live
  external profileVisibility_input_toString: RelaySchemaAssets_graphql.enum_ProfileVisibility_input => string = "%identity"
  @live
  let profileVisibility_decode = (enum: RelaySchemaAssets_graphql.enum_ProfileVisibility): option<RelaySchemaAssets_graphql.enum_ProfileVisibility_input> => {
    switch enum {
      | FutureAddedValue(_) => None
      | valid => Some(Obj.magic(valid))
    }
  }
  @live
  let profileVisibility_fromString = (str: string): option<RelaySchemaAssets_graphql.enum_ProfileVisibility_input> => {
    profileVisibility_decode(Obj.magic(str))
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
    "name": "disableProfile",
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
            "concreteType": "Profile",
            "kind": "LinkedField",
            "name": "profile",
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
                "name": "title",
                "storageKey": null
              },
              {
                "alias": null,
                "args": null,
                "kind": "ScalarField",
                "name": "slug",
                "storageKey": null
              },
              {
                "alias": null,
                "args": null,
                "kind": "ScalarField",
                "name": "visibility",
                "storageKey": null
              },
              {
                "alias": null,
                "args": null,
                "kind": "ScalarField",
                "name": "disabledAt",
                "storageKey": null
              },
              {
                "alias": null,
                "args": null,
                "kind": "ScalarField",
                "name": "disabledReason",
                "storageKey": null
              }
            ],
            "storageKey": null
          }
        ],
        "type": "DisableProfileSucceeded",
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
    "name": "ProfileVersionMutationsDisableProfileMutation",
    "selections": (v1/*: any*/),
    "type": "Mutation",
    "abstractKey": null
  },
  "kind": "Request",
  "operation": {
    "argumentDefinitions": (v0/*: any*/),
    "kind": "Operation",
    "name": "ProfileVersionMutationsDisableProfileMutation",
    "selections": (v1/*: any*/)
  },
  "params": {
    "cacheID": "a0b668cfcda144c900e1b4ef1aa68981",
    "id": null,
    "metadata": {},
    "name": "ProfileVersionMutationsDisableProfileMutation",
    "operationKind": "mutation",
    "text": "mutation ProfileVersionMutationsDisableProfileMutation(\n  $input: DisableProfileInput!\n) {\n  disableProfile(input: $input) {\n    __typename\n    ... on DisableProfileSucceeded {\n      profile {\n        id\n        title\n        slug\n        visibility\n        disabledAt\n        disabledReason\n      }\n    }\n    ... on MutationFailed {\n      message\n    }\n  }\n}\n"
  }
};
})() `)


