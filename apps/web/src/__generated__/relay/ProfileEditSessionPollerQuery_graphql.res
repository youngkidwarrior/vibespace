/* @sourceLoc ProfileEditSessionPoller.res */
/* @generated */
%%raw("/* @generated */")
module Types = {
  @@warning("-30")

  type rec response_profileEditSessionById_resultVersion_createdBy = {
    displayName: string,
    @live id: string,
  }
  and response_profileEditSessionById_resultVersion = {
    createdAt: string,
    createdBy: option<response_profileEditSessionById_resultVersion_createdBy>,
    css: string,
    html: string,
    @live id: string,
    revisionNumber: int,
    source: RelaySchemaAssets_graphql.enum_ProfileVersionSource,
    summary: string,
    validationErrors: array<string>,
    validationStatus: RelaySchemaAssets_graphql.enum_ValidationStatus,
  }
  and response_profileEditSessionById_selectionSnapshot = {
    @live id: string,
    label: string,
  }
  and response_profileEditSessionById = {
    createdAt: string,
    error: option<string>,
    failedCss: option<string>,
    failedHtml: option<string>,
    failedValidationMessage: option<string>,
    failedValidationSpanJson: option<string>,
    @live id: string,
    progressPhase: RelaySchemaAssets_graphql.enum_EditProgressPhase,
    prompt: string,
    resultVersion: option<response_profileEditSessionById_resultVersion>,
    resultVersionId: option<string>,
    selectionSnapshot: option<response_profileEditSessionById_selectionSnapshot>,
    status: RelaySchemaAssets_graphql.enum_ProfileEditSessionStatus,
    summary: string,
    updatedAt: string,
    warnings: array<string>,
  }
  type response = {
    profileEditSessionById: option<response_profileEditSessionById>,
  }
  @live
  type rawResponse = response
  @live
  type variables = {
    @live id: string,
  }
  @live
  type refetchVariables = {
    @live id?: string,
  }
  @live let makeRefetchVariables = (
    ~id=?,
  ): refetchVariables => {
    id: ?id
  }

}


type queryRef

module Internal = {
  @live
  let variablesConverter: dict<dict<dict<string>>> = %raw(
    json`{}`
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
    json`{}`
  )
  @live
  let wrapResponseConverterMap = ()
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
    json`{}`
  )
  @live
  let responseConverterMap = ()
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
  type rawPreloadToken<'response> = {source: Nullable.t<RescriptRelay.Observable.t<'response>>}
  external tokenToRaw: queryRef => rawPreloadToken<Types.response> = "%identity"
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
type operationType = RescriptRelay.queryNode<relayOperationNode>


let node: operationType = %raw(json` (function(){
var v0 = [
  {
    "defaultValue": null,
    "kind": "LocalArgument",
    "name": "id"
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
  "name": "summary",
  "storageKey": null
},
v3 = {
  "alias": null,
  "args": null,
  "kind": "ScalarField",
  "name": "createdAt",
  "storageKey": null
},
v4 = [
  {
    "alias": null,
    "args": [
      {
        "kind": "Variable",
        "name": "id",
        "variableName": "id"
      }
    ],
    "concreteType": "ProfileEditSession",
    "kind": "LinkedField",
    "name": "profileEditSessionById",
    "plural": false,
    "selections": [
      (v1/*: any*/),
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
      (v2/*: any*/),
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
      {
        "alias": null,
        "args": null,
        "kind": "ScalarField",
        "name": "resultVersionId",
        "storageKey": null
      },
      {
        "alias": null,
        "args": null,
        "concreteType": "SelectionSnapshot",
        "kind": "LinkedField",
        "name": "selectionSnapshot",
        "plural": false,
        "selections": [
          (v1/*: any*/),
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
          (v1/*: any*/),
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
          (v2/*: any*/),
          {
            "alias": null,
            "args": null,
            "kind": "ScalarField",
            "name": "validationStatus",
            "storageKey": null
          },
          {
            "alias": null,
            "args": null,
            "kind": "ScalarField",
            "name": "validationErrors",
            "storageKey": null
          },
          {
            "alias": null,
            "args": null,
            "concreteType": "User",
            "kind": "LinkedField",
            "name": "createdBy",
            "plural": false,
            "selections": [
              (v1/*: any*/),
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
          (v3/*: any*/)
        ],
        "storageKey": null
      },
      (v3/*: any*/),
      {
        "alias": null,
        "args": null,
        "kind": "ScalarField",
        "name": "updatedAt",
        "storageKey": null
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
    "name": "ProfileEditSessionPollerQuery",
    "selections": (v4/*: any*/),
    "type": "Query",
    "abstractKey": null
  },
  "kind": "Request",
  "operation": {
    "argumentDefinitions": (v0/*: any*/),
    "kind": "Operation",
    "name": "ProfileEditSessionPollerQuery",
    "selections": (v4/*: any*/)
  },
  "params": {
    "cacheID": "081a4521cb321c6dc79c80e29eb4752c",
    "id": null,
    "metadata": {},
    "name": "ProfileEditSessionPollerQuery",
    "operationKind": "query",
    "text": "query ProfileEditSessionPollerQuery(\n  $id: ID!\n) {\n  profileEditSessionById(id: $id) {\n    id\n    prompt\n    status\n    progressPhase\n    summary\n    warnings\n    error\n    failedHtml\n    failedCss\n    failedValidationMessage\n    failedValidationSpanJson\n    resultVersionId\n    selectionSnapshot {\n      id\n      label\n    }\n    resultVersion {\n      id\n      revisionNumber\n      html\n      css\n      source\n      summary\n      validationStatus\n      validationErrors\n      createdBy {\n        id\n        displayName\n      }\n      createdAt\n    }\n    createdAt\n    updatedAt\n  }\n}\n"
  }
};
})() `)

@live let load: (
  ~environment: RescriptRelay.Environment.t,
  ~variables: Types.variables,
  ~fetchPolicy: RescriptRelay.fetchPolicy=?,
  ~fetchKey: string=?,
  ~networkCacheConfig: RescriptRelay.cacheConfig=?,
) => queryRef = (
  ~environment,
  ~variables,
  ~fetchPolicy=?,
  ~fetchKey=?,
  ~networkCacheConfig=?,
) =>
  RescriptRelayReact.loadQuery(
    environment,
    node,
    variables->Internal.convertVariables,
    {
      fetchKey,
      fetchPolicy,
      networkCacheConfig,
    },
  )

@live
let queryRefToObservable = token => {
  let raw = token->Internal.tokenToRaw
  raw.source->Nullable.toOption
}
  
@live
let queryRefToPromise = token => {
  Promise.make((resolve, _reject) => {
    switch token->queryRefToObservable {
    | None => resolve(Error())
    | Some(o) =>
      open RescriptRelay.Observable
      let _: subscription = o->subscribe(makeObserver(~complete=() => resolve(Ok())))
    }
  })
}
