/* @sourceLoc ProfileVersionMutations.res */
/* @generated */
%%raw("/* @generated */")
module Types = {
  @@warning("-30")

  @live type restoreProfileVersionInput = RelaySchemaAssets_graphql.input_RestoreProfileVersionInput
  @live
  type rec response_restoreProfileVersion_ProfileVersionMutationFailed_profile = {
    @live id: string,
  }
  @live
  and response_restoreProfileVersion_ProfileVersionMutationSucceeded_profile_currentVersion = {
    createdAt: string,
    css: string,
    html: string,
    @live id: string,
    revisionNumber: int,
    summary: string,
  }
  @live
  and response_restoreProfileVersion_ProfileVersionMutationSucceeded_profile = {
    currentVersion: option<response_restoreProfileVersion_ProfileVersionMutationSucceeded_profile_currentVersion>,
    @live id: string,
  }
  @live
  and response_restoreProfileVersion_ProfileVersionMutationSucceeded_profileVersion_createdBy = {
    displayName: string,
    @live id: string,
  }
  @live
  and response_restoreProfileVersion_ProfileVersionMutationSucceeded_profileVersion = {
    createdAt: string,
    createdBy: option<response_restoreProfileVersion_ProfileVersionMutationSucceeded_profileVersion_createdBy>,
    css: string,
    html: string,
    @live id: string,
    revisionNumber: int,
    source: RelaySchemaAssets_graphql.enum_ProfileVersionSource,
    summary: string,
    validationErrors: array<string>,
    validationStatus: RelaySchemaAssets_graphql.enum_ValidationStatus,
  }
  @tag("__typename") and response_restoreProfileVersion = 
    | @live ProfileVersionMutationFailed(
      {
        message: string,
        profile: option<response_restoreProfileVersion_ProfileVersionMutationFailed_profile>,
        summary: string,
        validationErrors: array<string>,
      }
    )
    | @live ProfileVersionMutationSucceeded(
      {
        profile: option<response_restoreProfileVersion_ProfileVersionMutationSucceeded_profile>,
        profileVersion: response_restoreProfileVersion_ProfileVersionMutationSucceeded_profileVersion,
        summary: string,
        warnings: array<string>,
      }
    )
    | @live @as("__unselected") UnselectedUnionMember(string)

  @live
  type response = {
    restoreProfileVersion: response_restoreProfileVersion,
  }
  @live
  type rawResponse = response
  @live
  type variables = {
    input: restoreProfileVersionInput,
  }
}

@live
let unwrap_response_restoreProfileVersion: Types.response_restoreProfileVersion => Types.response_restoreProfileVersion = RescriptRelay_Internal.unwrapUnion(_, ["ProfileVersionMutationFailed", "ProfileVersionMutationSucceeded"])
@live
let wrap_response_restoreProfileVersion: Types.response_restoreProfileVersion => Types.response_restoreProfileVersion = RescriptRelay_Internal.wrapUnion
module Internal = {
  @live
  let variablesConverter: dict<dict<dict<string>>> = %raw(
    json`{"restoreProfileVersionInput":{},"__root":{"input":{"r":"restoreProfileVersionInput"}}}`
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
    json`{"__root":{"restoreProfileVersion":{"u":"response_restoreProfileVersion"}}}`
  )
  @live
  let wrapResponseConverterMap = {
    "response_restoreProfileVersion": wrap_response_restoreProfileVersion,
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
    json`{"__root":{"restoreProfileVersion":{"u":"response_restoreProfileVersion"}}}`
  )
  @live
  let responseConverterMap = {
    "response_restoreProfileVersion": unwrap_response_restoreProfileVersion,
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
  external profileVersionSource_toString: RelaySchemaAssets_graphql.enum_ProfileVersionSource => string = "%identity"
  @live
  external profileVersionSource_input_toString: RelaySchemaAssets_graphql.enum_ProfileVersionSource_input => string = "%identity"
  @live
  let profileVersionSource_decode = (enum: RelaySchemaAssets_graphql.enum_ProfileVersionSource): option<RelaySchemaAssets_graphql.enum_ProfileVersionSource_input> => {
    switch enum {
      | FutureAddedValue(_) => None
      | valid => Some(Obj.magic(valid))
    }
  }
  @live
  let profileVersionSource_fromString = (str: string): option<RelaySchemaAssets_graphql.enum_ProfileVersionSource_input> => {
    profileVersionSource_decode(Obj.magic(str))
  }
  @live
  external validationStatus_toString: RelaySchemaAssets_graphql.enum_ValidationStatus => string = "%identity"
  @live
  external validationStatus_input_toString: RelaySchemaAssets_graphql.enum_ValidationStatus_input => string = "%identity"
  @live
  let validationStatus_decode = (enum: RelaySchemaAssets_graphql.enum_ValidationStatus): option<RelaySchemaAssets_graphql.enum_ValidationStatus_input> => {
    switch enum {
      | FutureAddedValue(_) => None
      | valid => Some(Obj.magic(valid))
    }
  }
  @live
  let validationStatus_fromString = (str: string): option<RelaySchemaAssets_graphql.enum_ValidationStatus_input> => {
    validationStatus_decode(Obj.magic(str))
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
  "name": "summary",
  "storageKey": null
},
v2 = {
  "alias": null,
  "args": null,
  "kind": "ScalarField",
  "name": "id",
  "storageKey": null
},
v3 = {
  "alias": null,
  "args": null,
  "kind": "ScalarField",
  "name": "revisionNumber",
  "storageKey": null
},
v4 = {
  "alias": null,
  "args": null,
  "kind": "ScalarField",
  "name": "html",
  "storageKey": null
},
v5 = {
  "alias": null,
  "args": null,
  "kind": "ScalarField",
  "name": "css",
  "storageKey": null
},
v6 = {
  "alias": null,
  "args": null,
  "kind": "ScalarField",
  "name": "createdAt",
  "storageKey": null
},
v7 = {
  "alias": null,
  "args": null,
  "kind": "ScalarField",
  "name": "validationErrors",
  "storageKey": null
},
v8 = [
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
    "name": "restoreProfileVersion",
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
          (v1/*: any*/),
          {
            "alias": null,
            "args": null,
            "kind": "ScalarField",
            "name": "warnings",
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
              (v2/*: any*/),
              {
                "alias": null,
                "args": null,
                "concreteType": "ProfileVersion",
                "kind": "LinkedField",
                "name": "currentVersion",
                "plural": false,
                "selections": [
                  (v2/*: any*/),
                  (v3/*: any*/),
                  (v4/*: any*/),
                  (v5/*: any*/),
                  (v1/*: any*/),
                  (v6/*: any*/)
                ],
                "storageKey": null
              }
            ],
            "storageKey": null
          },
          {
            "alias": null,
            "args": null,
            "concreteType": "ProfileVersion",
            "kind": "LinkedField",
            "name": "profileVersion",
            "plural": false,
            "selections": [
              (v2/*: any*/),
              (v3/*: any*/),
              (v4/*: any*/),
              (v5/*: any*/),
              {
                "alias": null,
                "args": null,
                "kind": "ScalarField",
                "name": "source",
                "storageKey": null
              },
              (v1/*: any*/),
              {
                "alias": null,
                "args": null,
                "kind": "ScalarField",
                "name": "validationStatus",
                "storageKey": null
              },
              (v7/*: any*/),
              {
                "alias": null,
                "args": null,
                "concreteType": "User",
                "kind": "LinkedField",
                "name": "createdBy",
                "plural": false,
                "selections": [
                  (v2/*: any*/),
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
              (v6/*: any*/)
            ],
            "storageKey": null
          }
        ],
        "type": "ProfileVersionMutationSucceeded",
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
          },
          (v1/*: any*/),
          (v7/*: any*/),
          {
            "alias": null,
            "args": null,
            "concreteType": "Profile",
            "kind": "LinkedField",
            "name": "profile",
            "plural": false,
            "selections": [
              (v2/*: any*/)
            ],
            "storageKey": null
          }
        ],
        "type": "ProfileVersionMutationFailed",
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
    "name": "ProfileVersionMutationsRestoreProfileVersionMutation",
    "selections": (v8/*: any*/),
    "type": "Mutation",
    "abstractKey": null
  },
  "kind": "Request",
  "operation": {
    "argumentDefinitions": (v0/*: any*/),
    "kind": "Operation",
    "name": "ProfileVersionMutationsRestoreProfileVersionMutation",
    "selections": (v8/*: any*/)
  },
  "params": {
    "cacheID": "c245836cbc9a25966aac5354201329be",
    "id": null,
    "metadata": {},
    "name": "ProfileVersionMutationsRestoreProfileVersionMutation",
    "operationKind": "mutation",
    "text": "mutation ProfileVersionMutationsRestoreProfileVersionMutation(\n  $input: RestoreProfileVersionInput!\n) {\n  restoreProfileVersion(input: $input) {\n    __typename\n    ... on ProfileVersionMutationSucceeded {\n      summary\n      warnings\n      profile {\n        id\n        currentVersion {\n          id\n          revisionNumber\n          html\n          css\n          summary\n          createdAt\n        }\n      }\n      profileVersion {\n        id\n        revisionNumber\n        html\n        css\n        source\n        summary\n        validationStatus\n        validationErrors\n        createdBy {\n          id\n          displayName\n        }\n        createdAt\n      }\n    }\n    ... on ProfileVersionMutationFailed {\n      message\n      summary\n      validationErrors\n      profile {\n        id\n      }\n    }\n  }\n}\n"
  }
};
})() `)


