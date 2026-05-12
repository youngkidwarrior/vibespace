/* @sourceLoc ProfileVersionMutations.res */
/* @generated */
%%raw("/* @generated */")
module Types = {
  @@warning("-30")

  @live type submitAgentEditInput = RelaySchemaAssets_graphql.input_SubmitAgentEditInput
  @live
  type rec response_startAgentEdit_ProfileEditSessionMutationFailed_failedEditSession_resultVersion_createdBy = {
    displayName: string,
    @live id: string,
  }
  @live
  and response_startAgentEdit_ProfileEditSessionMutationFailed_failedEditSession_resultVersion = {
    createdAt: string,
    createdBy: option<response_startAgentEdit_ProfileEditSessionMutationFailed_failedEditSession_resultVersion_createdBy>,
    css: string,
    html: string,
    @live id: string,
    revisionNumber: int,
    source: RelaySchemaAssets_graphql.enum_ProfileVersionSource,
    summary: string,
    validationErrors: array<string>,
    validationStatus: RelaySchemaAssets_graphql.enum_ValidationStatus,
  }
  @live
  and response_startAgentEdit_ProfileEditSessionMutationFailed_failedEditSession_selectionSnapshot = {
    @live id: string,
    label: string,
  }
  @live
  and response_startAgentEdit_ProfileEditSessionMutationFailed_failedEditSession = {
    createdAt: string,
    error: option<string>,
    @live id: string,
    progressPhase: RelaySchemaAssets_graphql.enum_EditProgressPhase,
    prompt: string,
    resultVersion: option<response_startAgentEdit_ProfileEditSessionMutationFailed_failedEditSession_resultVersion>,
    resultVersionId: option<string>,
    selectionSnapshot: option<response_startAgentEdit_ProfileEditSessionMutationFailed_failedEditSession_selectionSnapshot>,
    status: RelaySchemaAssets_graphql.enum_ProfileEditSessionStatus,
    summary: string,
    updatedAt: string,
    warnings: array<string>,
  }
  @live
  and response_startAgentEdit_ProfileEditSessionMutationSucceeded_succeededEditSession_resultVersion_createdBy = {
    displayName: string,
    @live id: string,
  }
  @live
  and response_startAgentEdit_ProfileEditSessionMutationSucceeded_succeededEditSession_resultVersion = {
    createdAt: string,
    createdBy: option<response_startAgentEdit_ProfileEditSessionMutationSucceeded_succeededEditSession_resultVersion_createdBy>,
    css: string,
    html: string,
    @live id: string,
    revisionNumber: int,
    source: RelaySchemaAssets_graphql.enum_ProfileVersionSource,
    summary: string,
    validationErrors: array<string>,
    validationStatus: RelaySchemaAssets_graphql.enum_ValidationStatus,
  }
  @live
  and response_startAgentEdit_ProfileEditSessionMutationSucceeded_succeededEditSession_selectionSnapshot = {
    @live id: string,
    label: string,
  }
  @live
  and response_startAgentEdit_ProfileEditSessionMutationSucceeded_succeededEditSession = {
    createdAt: string,
    error: option<string>,
    @live id: string,
    progressPhase: RelaySchemaAssets_graphql.enum_EditProgressPhase,
    prompt: string,
    resultVersion: option<response_startAgentEdit_ProfileEditSessionMutationSucceeded_succeededEditSession_resultVersion>,
    resultVersionId: option<string>,
    selectionSnapshot: option<response_startAgentEdit_ProfileEditSessionMutationSucceeded_succeededEditSession_selectionSnapshot>,
    status: RelaySchemaAssets_graphql.enum_ProfileEditSessionStatus,
    summary: string,
    updatedAt: string,
    warnings: array<string>,
  }
  @tag("__typename") and response_startAgentEdit = 
    | @live ProfileEditSessionMutationFailed(
      {
        failedEditSession: option<response_startAgentEdit_ProfileEditSessionMutationFailed_failedEditSession>,
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
        succeededEditSession: response_startAgentEdit_ProfileEditSessionMutationSucceeded_succeededEditSession,
        summary: string,
        validationErrors: array<string>,
        warnings: array<string>,
      }
    )
    | @live @as("__unselected") UnselectedUnionMember(string)

  @live
  type response = {
    startAgentEdit: response_startAgentEdit,
  }
  @live
  type rawResponse = response
  @live
  type variables = {
    input: submitAgentEditInput,
  }
}

@live
let unwrap_response_startAgentEdit: Types.response_startAgentEdit => Types.response_startAgentEdit = RescriptRelay_Internal.unwrapUnion(_, ["ProfileEditSessionMutationFailed", "ProfileEditSessionMutationSucceeded"])
@live
let wrap_response_startAgentEdit: Types.response_startAgentEdit => Types.response_startAgentEdit = RescriptRelay_Internal.wrapUnion
module Internal = {
  @live
  let variablesConverter: dict<dict<dict<string>>> = %raw(
    json`{"submitAgentEditInput":{},"__root":{"input":{"r":"submitAgentEditInput"}}}`
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
    json`{"__root":{"startAgentEdit":{"u":"response_startAgentEdit"}}}`
  )
  @live
  let wrapResponseConverterMap = {
    "response_startAgentEdit": wrap_response_startAgentEdit,
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
    json`{"__root":{"startAgentEdit":{"u":"response_startAgentEdit"}}}`
  )
  @live
  let responseConverterMap = {
    "response_startAgentEdit": unwrap_response_startAgentEdit,
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
  external assistantEditMode_toString: RelaySchemaAssets_graphql.enum_AssistantEditMode => string = "%identity"
  @live
  external assistantEditMode_input_toString: RelaySchemaAssets_graphql.enum_AssistantEditMode_input => string = "%identity"
  @live
  let assistantEditMode_decode = (enum: RelaySchemaAssets_graphql.enum_AssistantEditMode): option<RelaySchemaAssets_graphql.enum_AssistantEditMode_input> => {
    switch enum {
      | FutureAddedValue(_) => None
      | valid => Some(Obj.magic(valid))
    }
  }
  @live
  let assistantEditMode_fromString = (str: string): option<RelaySchemaAssets_graphql.enum_AssistantEditMode_input> => {
    assistantEditMode_decode(Obj.magic(str))
  }
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
v6 = {
  "alias": null,
  "args": null,
  "kind": "ScalarField",
  "name": "id",
  "storageKey": null
},
v7 = {
  "alias": null,
  "args": null,
  "kind": "ScalarField",
  "name": "createdAt",
  "storageKey": null
},
v8 = [
  (v6/*: any*/),
  {
    "alias": null,
    "args": null,
    "kind": "ScalarField",
    "name": "prompt",
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
  (v2/*: any*/),
  {
    "alias": null,
    "args": null,
    "concreteType": "SelectionSnapshot",
    "kind": "LinkedField",
    "name": "selectionSnapshot",
    "plural": false,
    "selections": [
      (v6/*: any*/),
      {
        "alias": null,
        "args": null,
        "kind": "ScalarField",
        "name": "label",
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
    "name": "resultVersion",
    "plural": false,
    "selections": [
      (v6/*: any*/),
      {
        "alias": null,
        "args": null,
        "kind": "ScalarField",
        "name": "revisionNumber",
        "storageKey": null
      },
      {
        "alias": null,
        "args": null,
        "kind": "ScalarField",
        "name": "html",
        "storageKey": null
      },
      {
        "alias": null,
        "args": null,
        "kind": "ScalarField",
        "name": "css",
        "storageKey": null
      },
      {
        "alias": null,
        "args": null,
        "kind": "ScalarField",
        "name": "source",
        "storageKey": null
      },
      (v3/*: any*/),
      {
        "alias": null,
        "args": null,
        "kind": "ScalarField",
        "name": "validationStatus",
        "storageKey": null
      },
      (v5/*: any*/),
      {
        "alias": null,
        "args": null,
        "concreteType": "User",
        "kind": "LinkedField",
        "name": "createdBy",
        "plural": false,
        "selections": [
          (v6/*: any*/),
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
      (v7/*: any*/)
    ],
    "storageKey": null
  },
  (v7/*: any*/),
  {
    "alias": null,
    "args": null,
    "kind": "ScalarField",
    "name": "updatedAt",
    "storageKey": null
  }
],
v9 = [
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
    "name": "startAgentEdit",
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
            "selections": (v8/*: any*/),
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
            "selections": (v8/*: any*/),
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
    "name": "ProfileVersionMutationsStartAgentEditMutation",
    "selections": (v9/*: any*/),
    "type": "Mutation",
    "abstractKey": null
  },
  "kind": "Request",
  "operation": {
    "argumentDefinitions": (v0/*: any*/),
    "kind": "Operation",
    "name": "ProfileVersionMutationsStartAgentEditMutation",
    "selections": (v9/*: any*/)
  },
  "params": {
    "cacheID": "d8d1e955e562550bab062aec1d9e59c8",
    "id": null,
    "metadata": {},
    "name": "ProfileVersionMutationsStartAgentEditMutation",
    "operationKind": "mutation",
    "text": "mutation ProfileVersionMutationsStartAgentEditMutation(\n  $input: SubmitAgentEditInput!\n) {\n  startAgentEdit(input: $input) {\n    __typename\n    ... on ProfileEditSessionMutationSucceeded {\n      providerConversationId\n      resultVersionId\n      summary\n      warnings\n      validationErrors\n      succeededEditSession: editSession {\n        id\n        prompt\n        status\n        progressPhase\n        summary\n        warnings\n        error\n        resultVersionId\n        selectionSnapshot {\n          id\n          label\n        }\n        resultVersion {\n          id\n          revisionNumber\n          html\n          css\n          source\n          summary\n          validationStatus\n          validationErrors\n          createdBy {\n            id\n            displayName\n          }\n          createdAt\n        }\n        createdAt\n        updatedAt\n      }\n    }\n    ... on ProfileEditSessionMutationFailed {\n      message\n      providerConversationId\n      resultVersionId\n      summary\n      warnings\n      validationErrors\n      failedEditSession: editSession {\n        id\n        prompt\n        status\n        progressPhase\n        summary\n        warnings\n        error\n        resultVersionId\n        selectionSnapshot {\n          id\n          label\n        }\n        resultVersion {\n          id\n          revisionNumber\n          html\n          css\n          source\n          summary\n          validationStatus\n          validationErrors\n          createdBy {\n            id\n            displayName\n          }\n          createdAt\n        }\n        createdAt\n        updatedAt\n      }\n    }\n  }\n}\n"
  }
};
})() `)


