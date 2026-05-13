/* @sourceLoc ProfileVersionMutations.res */
/* @generated */
%%raw("/* @generated */")
module Types = {
  @@warning("-30")

  @live type requestTargetedAgentEditRepairInput = RelaySchemaAssets_graphql.input_RequestTargetedAgentEditRepairInput
  @live
  type rec response_requestTargetedAgentEditRepair_ProfileEditSessionMutationFailed_failedEditSession = {
    createdAt: string,
    error: option<string>,
    failedCss: option<string>,
    failedHtml: option<string>,
    failedValidationMessage: option<string>,
    failedValidationSpanJson: option<string>,
    @live id: string,
    progressPhase: RelaySchemaAssets_graphql.enum_EditProgressPhase,
    resultVersionId: option<string>,
    status: RelaySchemaAssets_graphql.enum_ProfileEditSessionStatus,
    summary: string,
    updatedAt: string,
    warnings: array<string>,
  }
  @live
  and response_requestTargetedAgentEditRepair_ProfileEditSessionMutationSucceeded_succeededEditSession = {
    createdAt: string,
    error: option<string>,
    failedCss: option<string>,
    failedHtml: option<string>,
    failedValidationMessage: option<string>,
    failedValidationSpanJson: option<string>,
    @live id: string,
    progressPhase: RelaySchemaAssets_graphql.enum_EditProgressPhase,
    resultVersionId: option<string>,
    status: RelaySchemaAssets_graphql.enum_ProfileEditSessionStatus,
    summary: string,
    updatedAt: string,
    warnings: array<string>,
  }
  @tag("__typename") and response_requestTargetedAgentEditRepair = 
    | @live ProfileEditSessionMutationFailed(
      {
        failedEditSession: option<response_requestTargetedAgentEditRepair_ProfileEditSessionMutationFailed_failedEditSession>,
        message: string,
        providerConversationId: option<string>,
        resultVersionId: option<string>,
        summary: string,
        validationErrors: array<string>,
        warnings: array<string>,
      }
    )
    | @live ProfileEditSessionMutationSucceeded(
      {
        providerConversationId: option<string>,
        resultVersionId: option<string>,
        succeededEditSession: response_requestTargetedAgentEditRepair_ProfileEditSessionMutationSucceeded_succeededEditSession,
        summary: string,
        validationErrors: array<string>,
        warnings: array<string>,
      }
    )
    | @live @as("__unselected") UnselectedUnionMember(string)

  @live
  type response = {
    requestTargetedAgentEditRepair: response_requestTargetedAgentEditRepair,
  }
  @live
  type rawResponse = response
  @live
  type variables = {
    input: requestTargetedAgentEditRepairInput,
  }
}

@live
let unwrap_response_requestTargetedAgentEditRepair: Types.response_requestTargetedAgentEditRepair => Types.response_requestTargetedAgentEditRepair = RescriptRelay_Internal.unwrapUnion(_, ["ProfileEditSessionMutationFailed", "ProfileEditSessionMutationSucceeded"])
@live
let wrap_response_requestTargetedAgentEditRepair: Types.response_requestTargetedAgentEditRepair => Types.response_requestTargetedAgentEditRepair = RescriptRelay_Internal.wrapUnion
module Internal = {
  @live
  let variablesConverter: dict<dict<dict<string>>> = %raw(
    json`{"requestTargetedAgentEditRepairInput":{},"__root":{"input":{"r":"requestTargetedAgentEditRepairInput"}}}`
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
    json`{"__root":{"requestTargetedAgentEditRepair":{"u":"response_requestTargetedAgentEditRepair"}}}`
  )
  @live
  let wrapResponseConverterMap = {
    "response_requestTargetedAgentEditRepair": wrap_response_requestTargetedAgentEditRepair,
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
    json`{"__root":{"requestTargetedAgentEditRepair":{"u":"response_requestTargetedAgentEditRepair"}}}`
  )
  @live
  let responseConverterMap = {
    "response_requestTargetedAgentEditRepair": unwrap_response_requestTargetedAgentEditRepair,
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
  external editProgressPhase_toString: RelaySchemaAssets_graphql.enum_EditProgressPhase => string = "%identity"
  @live
  external editProgressPhase_input_toString: RelaySchemaAssets_graphql.enum_EditProgressPhase_input => string = "%identity"
  @live
  let editProgressPhase_decode = (enum: RelaySchemaAssets_graphql.enum_EditProgressPhase): option<RelaySchemaAssets_graphql.enum_EditProgressPhase_input> => {
    switch enum {
      | FutureAddedValue(_) => None
      | valid => Some(Obj.magic(valid))
    }
  }
  @live
  let editProgressPhase_fromString = (str: string): option<RelaySchemaAssets_graphql.enum_EditProgressPhase_input> => {
    editProgressPhase_decode(Obj.magic(str))
  }
  @live
  external profileEditSessionStatus_toString: RelaySchemaAssets_graphql.enum_ProfileEditSessionStatus => string = "%identity"
  @live
  external profileEditSessionStatus_input_toString: RelaySchemaAssets_graphql.enum_ProfileEditSessionStatus_input => string = "%identity"
  @live
  let profileEditSessionStatus_decode = (enum: RelaySchemaAssets_graphql.enum_ProfileEditSessionStatus): option<RelaySchemaAssets_graphql.enum_ProfileEditSessionStatus_input> => {
    switch enum {
      | FutureAddedValue(_) => None
      | valid => Some(Obj.magic(valid))
    }
  }
  @live
  let profileEditSessionStatus_fromString = (str: string): option<RelaySchemaAssets_graphql.enum_ProfileEditSessionStatus_input> => {
    profileEditSessionStatus_decode(Obj.magic(str))
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
  "name": "providerConversationId",
  "storageKey": null
},
v2 = {
  "alias": null,
  "args": null,
  "kind": "ScalarField",
  "name": "resultVersionId",
  "storageKey": null
},
v3 = {
  "alias": null,
  "args": null,
  "kind": "ScalarField",
  "name": "summary",
  "storageKey": null
},
v4 = {
  "alias": null,
  "args": null,
  "kind": "ScalarField",
  "name": "warnings",
  "storageKey": null
},
v5 = {
  "alias": null,
  "args": null,
  "kind": "ScalarField",
  "name": "validationErrors",
  "storageKey": null
},
v6 = [
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
    "name": "status",
    "storageKey": null
  },
  {
    "alias": null,
    "args": null,
    "kind": "ScalarField",
    "name": "progressPhase",
    "storageKey": null
  },
  (v3/*: any*/),
  (v4/*: any*/),
  {
    "alias": null,
    "args": null,
    "kind": "ScalarField",
    "name": "error",
    "storageKey": null
  },
  {
    "alias": null,
    "args": null,
    "kind": "ScalarField",
    "name": "failedHtml",
    "storageKey": null
  },
  {
    "alias": null,
    "args": null,
    "kind": "ScalarField",
    "name": "failedCss",
    "storageKey": null
  },
  {
    "alias": null,
    "args": null,
    "kind": "ScalarField",
    "name": "failedValidationMessage",
    "storageKey": null
  },
  {
    "alias": null,
    "args": null,
    "kind": "ScalarField",
    "name": "failedValidationSpanJson",
    "storageKey": null
  },
  (v2/*: any*/),
  {
    "alias": null,
    "args": null,
    "kind": "ScalarField",
    "name": "createdAt",
    "storageKey": null
  },
  {
    "alias": null,
    "args": null,
    "kind": "ScalarField",
    "name": "updatedAt",
    "storageKey": null
  }
],
v7 = [
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
    "name": "requestTargetedAgentEditRepair",
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
          (v2/*: any*/),
          (v3/*: any*/),
          (v4/*: any*/),
          (v5/*: any*/),
          {
            "alias": "succeededEditSession",
            "args": null,
            "concreteType": "ProfileEditSession",
            "kind": "LinkedField",
            "name": "editSession",
            "plural": false,
            "selections": (v6/*: any*/),
            "storageKey": null
          }
        ],
        "type": "ProfileEditSessionMutationSucceeded",
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
          (v2/*: any*/),
          (v3/*: any*/),
          (v4/*: any*/),
          (v5/*: any*/),
          {
            "alias": "failedEditSession",
            "args": null,
            "concreteType": "ProfileEditSession",
            "kind": "LinkedField",
            "name": "editSession",
            "plural": false,
            "selections": (v6/*: any*/),
            "storageKey": null
          }
        ],
        "type": "ProfileEditSessionMutationFailed",
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
    "name": "ProfileVersionMutationsRequestTargetedAgentEditRepairMutation",
    "selections": (v7/*: any*/),
    "type": "Mutation",
    "abstractKey": null
  },
  "kind": "Request",
  "operation": {
    "argumentDefinitions": (v0/*: any*/),
    "kind": "Operation",
    "name": "ProfileVersionMutationsRequestTargetedAgentEditRepairMutation",
    "selections": (v7/*: any*/)
  },
  "params": {
    "cacheID": "ff185387f355f589cf3b0d580ebc9bd8",
    "id": null,
    "metadata": {},
    "name": "ProfileVersionMutationsRequestTargetedAgentEditRepairMutation",
    "operationKind": "mutation",
    "text": "mutation ProfileVersionMutationsRequestTargetedAgentEditRepairMutation(\n  $input: RequestTargetedAgentEditRepairInput!\n) {\n  requestTargetedAgentEditRepair(input: $input) {\n    __typename\n    ... on ProfileEditSessionMutationSucceeded {\n      providerConversationId\n      resultVersionId\n      summary\n      warnings\n      validationErrors\n      succeededEditSession: editSession {\n        id\n        status\n        progressPhase\n        summary\n        warnings\n        error\n        failedHtml\n        failedCss\n        failedValidationMessage\n        failedValidationSpanJson\n        resultVersionId\n        createdAt\n        updatedAt\n      }\n    }\n    ... on ProfileEditSessionMutationFailed {\n      message\n      providerConversationId\n      resultVersionId\n      summary\n      warnings\n      validationErrors\n      failedEditSession: editSession {\n        id\n        status\n        progressPhase\n        summary\n        warnings\n        error\n        failedHtml\n        failedCss\n        failedValidationMessage\n        failedValidationSpanJson\n        resultVersionId\n        createdAt\n        updatedAt\n      }\n    }\n  }\n}\n"
  }
};
})() `)


