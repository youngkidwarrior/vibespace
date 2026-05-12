/* @sourceLoc ProfileDocumentData.res */
/* @generated */
%%raw("/* @generated */")
module Types = {
  @@warning("-30")

  type rec fragment_currentVersion_createdBy = {
    displayName: string,
    @live id: string,
  }
  and fragment_currentVersion = {
    createdAt: string,
    createdBy: option<fragment_currentVersion_createdBy>,
    css: string,
    html: string,
    @live id: string,
    revisionNumber: int,
    source: RelaySchemaAssets_graphql.enum_ProfileVersionSource,
    summary: string,
    validationErrors: array<string>,
    validationStatus: RelaySchemaAssets_graphql.enum_ValidationStatus,
  }
  and fragment_editSessions_edges_node_resultVersion = {
    createdAt: string,
    @live id: string,
    revisionNumber: int,
    summary: string,
  }
  and fragment_editSessions_edges_node_selectionSnapshot = {
    @live id: string,
    label: string,
  }
  and fragment_editSessions_edges_node = {
    createdAt: string,
    error: option<string>,
    @live id: string,
    progressPhase: RelaySchemaAssets_graphql.enum_EditProgressPhase,
    prompt: string,
    resultVersion: option<fragment_editSessions_edges_node_resultVersion>,
    resultVersionId: option<string>,
    selectionSnapshot: option<fragment_editSessions_edges_node_selectionSnapshot>,
    status: RelaySchemaAssets_graphql.enum_ProfileEditSessionStatus,
    summary: string,
    updatedAt: string,
    warnings: array<string>,
  }
  and fragment_editSessions_edges = {
    node: option<fragment_editSessions_edges_node>,
  }
  and fragment_editSessions = {
    edges: option<array<option<fragment_editSessions_edges>>>,
  }
  and fragment_inviteChainFriends_edges_node = {
    avatarColor: string,
    avatarInitials: string,
    avatarUrl: option<string>,
    displayName: string,
    @live id: string,
    profileSlug: string,
    profileTitle: string,
  }
  and fragment_inviteChainFriends_edges = {
    node: option<fragment_inviteChainFriends_edges_node>,
  }
  and fragment_inviteChainFriends = {
    edges: option<array<option<fragment_inviteChainFriends_edges>>>,
  }
  and fragment_owner = {
    displayName: string,
    handle: string,
    @live id: string,
  }
  and fragment_versionHistory_edges_node_createdBy = {
    displayName: string,
    @live id: string,
  }
  and fragment_versionHistory_edges_node = {
    createdAt: string,
    createdBy: option<fragment_versionHistory_edges_node_createdBy>,
    css: string,
    html: string,
    @live id: string,
    revisionNumber: int,
    source: RelaySchemaAssets_graphql.enum_ProfileVersionSource,
    summary: string,
    validationErrors: array<string>,
    validationStatus: RelaySchemaAssets_graphql.enum_ValidationStatus,
  }
  and fragment_versionHistory_edges = {
    node: option<fragment_versionHistory_edges_node>,
  }
  and fragment_versionHistory = {
    edges: option<array<option<fragment_versionHistory_edges>>>,
  }
  type fragment = {
    currentVersion: option<fragment_currentVersion>,
    editSessions: fragment_editSessions,
    @live id: string,
    inviteChainFriends: fragment_inviteChainFriends,
    owner: option<fragment_owner>,
    sendAvatarUrl: option<string>,
    sendtag: option<string>,
    slug: string,
    title: string,
    versionHistory: fragment_versionHistory,
  }
}

module Internal = {
  @live
  type fragmentRaw
  @live
  let fragmentConverter: dict<dict<dict<string>>> = %raw(
    json`{}`
  )
  @live
  let fragmentConverterMap = ()
  @live
  let convertFragment = v => v->RescriptRelay.convertObj(
    fragmentConverter,
    fragmentConverterMap,
    None
  )
}

type t
type fragmentRef
external getFragmentRef:
  RescriptRelay.fragmentRefs<[> | #ProfileDocumentData_profile]> => fragmentRef = "%identity"

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
type operationType = RescriptRelay.fragmentNode<relayOperationNode>


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
  "name": "displayName",
  "storageKey": null
},
v2 = {
  "alias": null,
  "args": null,
  "kind": "ScalarField",
  "name": "revisionNumber",
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
  "name": "createdAt",
  "storageKey": null
},
v5 = [
  (v0/*: any*/),
  (v2/*: any*/),
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
      (v0/*: any*/),
      (v1/*: any*/)
    ],
    "storageKey": null
  },
  (v4/*: any*/)
],
v6 = [
  {
    "kind": "Literal",
    "name": "first",
    "value": 20
  }
];
return {
  "argumentDefinitions": [],
  "kind": "Fragment",
  "metadata": null,
  "name": "ProfileDocumentData_profile",
  "selections": [
    (v0/*: any*/),
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
      "name": "sendtag",
      "storageKey": null
    },
    {
      "alias": null,
      "args": null,
      "kind": "ScalarField",
      "name": "sendAvatarUrl",
      "storageKey": null
    },
    {
      "alias": null,
      "args": null,
      "concreteType": "User",
      "kind": "LinkedField",
      "name": "owner",
      "plural": false,
      "selections": [
        (v0/*: any*/),
        {
          "alias": null,
          "args": null,
          "kind": "ScalarField",
          "name": "handle",
          "storageKey": null
        },
        (v1/*: any*/)
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
      "selections": (v5/*: any*/),
      "storageKey": null
    },
    {
      "alias": null,
      "args": (v6/*: any*/),
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
              "selections": (v5/*: any*/),
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
      "args": (v6/*: any*/),
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
                    (v2/*: any*/),
                    (v3/*: any*/),
                    (v4/*: any*/)
                  ],
                  "storageKey": null
                },
                (v4/*: any*/),
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
    {
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
                (v1/*: any*/),
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
    }
  ],
  "type": "Profile",
  "abstractKey": null
};
})() `)

