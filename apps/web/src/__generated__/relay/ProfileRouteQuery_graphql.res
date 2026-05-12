/* @sourceLoc ProfileRoute.res */
/* @generated */
%%raw("/* @generated */")
module Types = {
  @@warning("-30")

  type rec response_availableInvite = {
    code: option<string>,
    @live id: string,
    inviteeUserId: option<string>,
    inviterUserId: string,
    redeemedAt: option<string>,
    status: RelaySchemaAssets_graphql.enum_InviteStatus,
  }
  and response_friendActivity_edges_node_actor = {
    displayName: string,
    @live id: string,
  }
  and response_friendActivity_edges_node_eventProfile = {
    @live id: string,
    title: string,
  }
  and response_friendActivity_edges_node = {
    actor: option<response_friendActivity_edges_node_actor>,
    createdAt: string,
    eventProfile: option<response_friendActivity_edges_node_eventProfile>,
    @live id: string,
    kind: RelaySchemaAssets_graphql.enum_ProfileUpdateEventKind,
    summary: string,
    title: string,
  }
  and response_friendActivity_edges = {
    node: option<response_friendActivity_edges_node>,
  }
  and response_friendActivity = {
    edges: option<array<option<response_friendActivity_edges>>>,
  }
  and response_randomProfile = {
    fragmentRefs: RescriptRelay.fragmentRefs<[ | #PublicProfileViewer_profile]>,
  }
  and response_viewer = {
    displayName: string,
    handle: string,
    @live id: string,
    status: RelaySchemaAssets_graphql.enum_UserStatus,
  }
  and response_viewerProfile = {
    fragmentRefs: RescriptRelay.fragmentRefs<[ | #ProfileDocumentData_profile]>,
  }
  and response_viewerUsedInvite = {
    code: option<string>,
    @live id: string,
    inviteeUserId: option<string>,
    inviterUserId: string,
    redeemedAt: option<string>,
    status: RelaySchemaAssets_graphql.enum_InviteStatus,
  }
  type response = {
    availableInvite: option<response_availableInvite>,
    friendActivity: response_friendActivity,
    randomProfile: option<response_randomProfile>,
    viewer: option<response_viewer>,
    viewerProfile: option<response_viewerProfile>,
    viewerUsedInvite: option<response_viewerUsedInvite>,
  }
  @live
  type rawResponse = response
  @live
  type variables = unit
  @live
  type refetchVariables = unit
  @live let makeRefetchVariables = () => ()
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
    json`{"__root":{"viewerProfile":{"f":""},"randomProfile":{"f":""}}}`
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
    json`{"__root":{"viewerProfile":{"f":""},"randomProfile":{"f":""}}}`
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
  external profileUpdateEventKind_toString: RelaySchemaAssets_graphql.enum_ProfileUpdateEventKind => string = "%identity"
  @live
  external profileUpdateEventKind_input_toString: RelaySchemaAssets_graphql.enum_ProfileUpdateEventKind_input => string = "%identity"
  @live
  let profileUpdateEventKind_decode = (enum: RelaySchemaAssets_graphql.enum_ProfileUpdateEventKind): option<RelaySchemaAssets_graphql.enum_ProfileUpdateEventKind_input> => {
    switch enum {
      | FutureAddedValue(_) => None
      | valid => Some(Obj.magic(valid))
    }
  }
  @live
  let profileUpdateEventKind_fromString = (str: string): option<RelaySchemaAssets_graphql.enum_ProfileUpdateEventKind_input> => {
    profileUpdateEventKind_decode(Obj.magic(str))
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
type operationType = RescriptRelay.queryNode<relayOperationNode>


let node: operationType = %raw(json` (function(){
var v0 = {
  "alias": null,
  "args": null,
  "kind": "ScalarField",
  "name": "id",
  "storageKey": null
},
v1 = {
  "alias": null,
  "args": null,
  "kind": "ScalarField",
  "name": "handle",
  "storageKey": null
},
v2 = {
  "alias": null,
  "args": null,
  "kind": "ScalarField",
  "name": "displayName",
  "storageKey": null
},
v3 = {
  "alias": null,
  "args": null,
  "kind": "ScalarField",
  "name": "status",
  "storageKey": null
},
v4 = {
  "alias": null,
  "args": null,
  "concreteType": "User",
  "kind": "LinkedField",
  "name": "viewer",
  "plural": false,
  "selections": [
    (v0/*: any*/),
    (v1/*: any*/),
    (v2/*: any*/),
    (v3/*: any*/)
  ],
  "storageKey": null
},
v5 = [
  (v0/*: any*/),
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
  (v3/*: any*/),
  {
    "alias": null,
    "args": null,
    "kind": "ScalarField",
    "name": "redeemedAt",
    "storageKey": null
  }
],
v6 = {
  "alias": null,
  "args": null,
  "concreteType": "Invite",
  "kind": "LinkedField",
  "name": "availableInvite",
  "plural": false,
  "selections": (v5/*: any*/),
  "storageKey": null
},
v7 = {
  "alias": null,
  "args": null,
  "concreteType": "Invite",
  "kind": "LinkedField",
  "name": "viewerUsedInvite",
  "plural": false,
  "selections": (v5/*: any*/),
  "storageKey": null
},
v8 = {
  "alias": null,
  "args": null,
  "kind": "ScalarField",
  "name": "title",
  "storageKey": null
},
v9 = {
  "alias": null,
  "args": null,
  "kind": "ScalarField",
  "name": "summary",
  "storageKey": null
},
v10 = {
  "alias": null,
  "args": null,
  "kind": "ScalarField",
  "name": "createdAt",
  "storageKey": null
},
v11 = [
  (v0/*: any*/),
  (v2/*: any*/)
],
v12 = {
  "alias": null,
  "args": [
    {
      "kind": "Literal",
      "name": "first",
      "value": 10
    }
  ],
  "concreteType": "ProfileUpdateEventConnection",
  "kind": "LinkedField",
  "name": "friendActivity",
  "plural": false,
  "selections": [
    {
      "alias": null,
      "args": null,
      "concreteType": "ProfileUpdateEventEdge",
      "kind": "LinkedField",
      "name": "edges",
      "plural": true,
      "selections": [
        {
          "alias": null,
          "args": null,
          "concreteType": "ProfileUpdateEvent",
          "kind": "LinkedField",
          "name": "node",
          "plural": false,
          "selections": [
            (v0/*: any*/),
            {
              "alias": null,
              "args": null,
              "kind": "ScalarField",
              "name": "kind",
              "storageKey": null
            },
            (v8/*: any*/),
            (v9/*: any*/),
            (v10/*: any*/),
            {
              "alias": null,
              "args": null,
              "concreteType": "User",
              "kind": "LinkedField",
              "name": "actor",
              "plural": false,
              "selections": (v11/*: any*/),
              "storageKey": null
            },
            {
              "alias": null,
              "args": null,
              "concreteType": "Profile",
              "kind": "LinkedField",
              "name": "eventProfile",
              "plural": false,
              "selections": [
                (v0/*: any*/),
                (v8/*: any*/)
              ],
              "storageKey": null
            }
          ],
          "storageKey": null
        }
      ],
      "storageKey": null
    }
  ],
  "storageKey": "friendActivity(first:10)"
},
v13 = {
  "alias": null,
  "args": null,
  "kind": "ScalarField",
  "name": "slug",
  "storageKey": null
},
v14 = {
  "alias": null,
  "args": null,
  "kind": "ScalarField",
  "name": "sendtag",
  "storageKey": null
},
v15 = {
  "alias": null,
  "args": null,
  "kind": "ScalarField",
  "name": "sendAvatarUrl",
  "storageKey": null
},
v16 = {
  "alias": null,
  "args": null,
  "kind": "ScalarField",
  "name": "revisionNumber",
  "storageKey": null
},
v17 = {
  "alias": null,
  "args": null,
  "kind": "ScalarField",
  "name": "html",
  "storageKey": null
},
v18 = {
  "alias": null,
  "args": null,
  "kind": "ScalarField",
  "name": "css",
  "storageKey": null
},
v19 = [
  (v0/*: any*/),
  (v16/*: any*/),
  (v17/*: any*/),
  (v18/*: any*/),
  {
    "alias": null,
    "args": null,
    "kind": "ScalarField",
    "name": "source",
    "storageKey": null
  },
  (v9/*: any*/),
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
    "selections": (v11/*: any*/),
    "storageKey": null
  },
  (v10/*: any*/)
],
v20 = [
  {
    "kind": "Literal",
    "name": "first",
    "value": 20
  }
],
v21 = {
  "alias": null,
  "args": [
    {
      "kind": "Literal",
      "name": "first",
      "value": 12
    }
  ],
  "concreteType": "InviteChainFriendConnection",
  "kind": "LinkedField",
  "name": "inviteChainFriends",
  "plural": false,
  "selections": [
    {
      "alias": null,
      "args": null,
      "concreteType": "InviteChainFriendEdge",
      "kind": "LinkedField",
      "name": "edges",
      "plural": true,
      "selections": [
        {
          "alias": null,
          "args": null,
          "concreteType": "InviteChainFriend",
          "kind": "LinkedField",
          "name": "node",
          "plural": false,
          "selections": [
            (v0/*: any*/),
            (v2/*: any*/),
            {
              "alias": null,
              "args": null,
              "kind": "ScalarField",
              "name": "profileSlug",
              "storageKey": null
            },
            {
              "alias": null,
              "args": null,
              "kind": "ScalarField",
              "name": "profileTitle",
              "storageKey": null
            },
            {
              "alias": null,
              "args": null,
              "kind": "ScalarField",
              "name": "avatarInitials",
              "storageKey": null
            },
            {
              "alias": null,
              "args": null,
              "kind": "ScalarField",
              "name": "avatarColor",
              "storageKey": null
            },
            {
              "alias": null,
              "args": null,
              "kind": "ScalarField",
              "name": "avatarUrl",
              "storageKey": null
            }
          ],
          "storageKey": null
        }
      ],
      "storageKey": null
    }
  ],
  "storageKey": "inviteChainFriends(first:12)"
};
return {
  "fragment": {
    "argumentDefinitions": [],
    "kind": "Fragment",
    "metadata": null,
    "name": "ProfileRouteQuery",
    "selections": [
      (v4/*: any*/),
      (v6/*: any*/),
      (v7/*: any*/),
      (v12/*: any*/),
      {
        "alias": null,
        "args": null,
        "concreteType": "Profile",
        "kind": "LinkedField",
        "name": "viewerProfile",
        "plural": false,
        "selections": [
          {
            "args": null,
            "kind": "FragmentSpread",
            "name": "ProfileDocumentData_profile"
          }
        ],
        "storageKey": null
      },
      {
        "alias": null,
        "args": null,
        "concreteType": "Profile",
        "kind": "LinkedField",
        "name": "randomProfile",
        "plural": false,
        "selections": [
          {
            "args": null,
            "kind": "FragmentSpread",
            "name": "PublicProfileViewer_profile"
          }
        ],
        "storageKey": null
      }
    ],
    "type": "Query",
    "abstractKey": null
  },
  "kind": "Request",
  "operation": {
    "argumentDefinitions": [],
    "kind": "Operation",
    "name": "ProfileRouteQuery",
    "selections": [
      (v4/*: any*/),
      (v6/*: any*/),
      (v7/*: any*/),
      (v12/*: any*/),
      {
        "alias": null,
        "args": null,
        "concreteType": "Profile",
        "kind": "LinkedField",
        "name": "viewerProfile",
        "plural": false,
        "selections": [
          (v0/*: any*/),
          (v8/*: any*/),
          (v13/*: any*/),
          (v14/*: any*/),
          (v15/*: any*/),
          {
            "alias": null,
            "args": null,
            "concreteType": "User",
            "kind": "LinkedField",
            "name": "owner",
            "plural": false,
            "selections": [
              (v0/*: any*/),
              (v1/*: any*/),
              (v2/*: any*/)
            ],
            "storageKey": null
          },
          {
            "alias": null,
            "args": null,
            "concreteType": "ProfileVersion",
            "kind": "LinkedField",
            "name": "currentVersion",
            "plural": false,
            "selections": (v19/*: any*/),
            "storageKey": null
          },
          {
            "alias": null,
            "args": (v20/*: any*/),
            "concreteType": "ProfileVersionConnection",
            "kind": "LinkedField",
            "name": "versionHistory",
            "plural": false,
            "selections": [
              {
                "alias": null,
                "args": null,
                "concreteType": "ProfileVersionEdge",
                "kind": "LinkedField",
                "name": "edges",
                "plural": true,
                "selections": [
                  {
                    "alias": null,
                    "args": null,
                    "concreteType": "ProfileVersion",
                    "kind": "LinkedField",
                    "name": "node",
                    "plural": false,
                    "selections": (v19/*: any*/),
                    "storageKey": null
                  }
                ],
                "storageKey": null
              }
            ],
            "storageKey": "versionHistory(first:20)"
          },
          {
            "alias": null,
            "args": (v20/*: any*/),
            "concreteType": "ProfileEditSessionConnection",
            "kind": "LinkedField",
            "name": "editSessions",
            "plural": false,
            "selections": [
              {
                "alias": null,
                "args": null,
                "concreteType": "ProfileEditSessionEdge",
                "kind": "LinkedField",
                "name": "edges",
                "plural": true,
                "selections": [
                  {
                    "alias": null,
                    "args": null,
                    "concreteType": "ProfileEditSession",
                    "kind": "LinkedField",
                    "name": "node",
                    "plural": false,
                    "selections": [
                      (v0/*: any*/),
                      {
                        "alias": null,
                        "args": null,
                        "kind": "ScalarField",
                        "name": "prompt",
                        "storageKey": null
                      },
                      (v3/*: any*/),
                      {
                        "alias": null,
                        "args": null,
                        "kind": "ScalarField",
                        "name": "progressPhase",
                        "storageKey": null
                      },
                      (v9/*: any*/),
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
                          (v0/*: any*/),
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
                          (v0/*: any*/),
                          (v16/*: any*/),
                          (v9/*: any*/),
                          (v10/*: any*/)
                        ],
                        "storageKey": null
                      },
                      (v10/*: any*/),
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
                ],
                "storageKey": null
              }
            ],
            "storageKey": "editSessions(first:20)"
          },
          (v21/*: any*/)
        ],
        "storageKey": null
      },
      {
        "alias": null,
        "args": null,
        "concreteType": "Profile",
        "kind": "LinkedField",
        "name": "randomProfile",
        "plural": false,
        "selections": [
          (v8/*: any*/),
          (v13/*: any*/),
          (v14/*: any*/),
          (v15/*: any*/),
          {
            "alias": null,
            "args": null,
            "concreteType": "User",
            "kind": "LinkedField",
            "name": "owner",
            "plural": false,
            "selections": [
              (v1/*: any*/),
              (v2/*: any*/),
              (v0/*: any*/)
            ],
            "storageKey": null
          },
          {
            "alias": null,
            "args": null,
            "concreteType": "ProfileVersion",
            "kind": "LinkedField",
            "name": "currentVersion",
            "plural": false,
            "selections": [
              (v17/*: any*/),
              (v18/*: any*/),
              (v9/*: any*/),
              (v10/*: any*/),
              (v0/*: any*/)
            ],
            "storageKey": null
          },
          (v21/*: any*/),
          (v0/*: any*/)
        ],
        "storageKey": null
      }
    ]
  },
  "params": {
    "cacheID": "7758f3f20979293e171bb9fd97d8bf56",
    "id": null,
    "metadata": {},
    "name": "ProfileRouteQuery",
    "operationKind": "query",
    "text": "query ProfileRouteQuery {\n  viewer {\n    id\n    handle\n    displayName\n    status\n  }\n  availableInvite {\n    id\n    code\n    inviterUserId\n    inviteeUserId\n    status\n    redeemedAt\n  }\n  viewerUsedInvite {\n    id\n    code\n    inviterUserId\n    inviteeUserId\n    status\n    redeemedAt\n  }\n  friendActivity(first: 10) {\n    edges {\n      node {\n        id\n        kind\n        title\n        summary\n        createdAt\n        actor {\n          id\n          displayName\n        }\n        eventProfile {\n          id\n          title\n        }\n      }\n    }\n  }\n  viewerProfile {\n    ...ProfileDocumentData_profile\n    id\n  }\n  randomProfile {\n    ...PublicProfileViewer_profile\n    id\n  }\n}\n\nfragment ProfileDocumentData_profile on Profile {\n  id\n  title\n  slug\n  sendtag\n  sendAvatarUrl\n  owner {\n    id\n    handle\n    displayName\n  }\n  currentVersion {\n    id\n    revisionNumber\n    html\n    css\n    source\n    summary\n    validationStatus\n    validationErrors\n    createdBy {\n      id\n      displayName\n    }\n    createdAt\n  }\n  versionHistory(first: 20) {\n    edges {\n      node {\n        id\n        revisionNumber\n        html\n        css\n        source\n        summary\n        validationStatus\n        validationErrors\n        createdBy {\n          id\n          displayName\n        }\n        createdAt\n      }\n    }\n  }\n  editSessions(first: 20) {\n    edges {\n      node {\n        id\n        prompt\n        status\n        progressPhase\n        summary\n        warnings\n        error\n        resultVersionId\n        selectionSnapshot {\n          id\n          label\n        }\n        resultVersion {\n          id\n          revisionNumber\n          summary\n          createdAt\n        }\n        createdAt\n        updatedAt\n      }\n    }\n  }\n  inviteChainFriends(first: 12) {\n    edges {\n      node {\n        id\n        displayName\n        profileSlug\n        profileTitle\n        avatarInitials\n        avatarColor\n        avatarUrl\n      }\n    }\n  }\n}\n\nfragment PublicProfileViewer_profile on Profile {\n  title\n  slug\n  sendtag\n  sendAvatarUrl\n  owner {\n    handle\n    displayName\n    id\n  }\n  currentVersion {\n    html\n    css\n    summary\n    createdAt\n    id\n  }\n  inviteChainFriends(first: 12) {\n    edges {\n      node {\n        id\n        displayName\n        profileSlug\n        profileTitle\n        avatarInitials\n        avatarColor\n        avatarUrl\n      }\n    }\n  }\n}\n"
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
