module ProfileFragment = %relay(`
  fragment ProfileDocumentData_profile on Profile {
    id
    title
    slug
    sendtag
    sendAvatarUrl
    owner {
      id
      handle
      displayName
    }
    currentVersion {
      id
      revisionNumber
      html
      css
      source
      summary
      validationStatus
      validationErrors
      createdBy {
        id
        displayName
      }
      createdAt
    }
    versionHistory(first: 20) {
      edges {
        node {
          id
          revisionNumber
          html
          css
          source
          summary
          validationStatus
          validationErrors
          createdBy {
            id
            displayName
          }
          createdAt
        }
      }
    }
    editSessions(first: 20) {
      edges {
        node {
          id
          prompt
          status
          progressPhase
          summary
          warnings
          error
          resultVersionId
          selectionSnapshot {
            id
            label
          }
          resultVersion {
            id
            revisionNumber
            summary
            createdAt
          }
          createdAt
          updatedAt
        }
      }
    }
    inviteChainFriends(first: 12) {
      edges {
        node {
          id
          displayName
          profileSlug
          profileTitle
          avatarInitials
          avatarColor
          avatarUrl
        }
      }
    }
  }
`)

let documentFromProfile = (profile: ProfileDocumentData_profile_graphql.Types.fragment) =>
  switch profile.currentVersion {
  | Some(version) =>
    ProfileDocument.make(
      ~html=version.html->HtmlSource.make,
      ~css=version.css->CssSource.make,
    )
  | None => ProfileFixture.initialDocument
  }

let editorContextFromProfile = (
  profile: ProfileDocumentData_profile_graphql.Types.fragment,
  ~viewer: option<App.viewerSnapshot>,
  ~availableInvite: option<App.inviteSnapshot>,
  ~viewerUsedInvite: option<App.inviteSnapshot>,
): App.editorContext => {
  let versionHistory = switch profile.versionHistory.edges {
  | Some(edges) =>
    edges->Array.filterMap(edge =>
      switch edge {
      | Some({node: Some(version)}) =>
        Some({
          id: version.id,
          revisionNumber: version.revisionNumber,
          html: version.html->HtmlSource.make,
          css: version.css->CssSource.make,
          summary: version.summary,
          createdAt: version.createdAt,
        }: App.profileVersionSnapshot)
      | Some({node: None}) | None => None
      }
    )
  | None => []
  }

  let editSessions = switch profile.editSessions.edges {
  | Some(edges) =>
    edges->Array.filterMap(edge =>
      switch edge {
      | Some({node: Some(session)}) =>
        Some({
          id: session.id,
          prompt: session.prompt,
          status: session.status->ProfileRelayLabels.profileEditSessionStatus,
          progressPhase: session.progressPhase->ProfileRelayLabels.editProgressPhase,
          summary: session.summary,
          error: session.error,
          selectionLabel: session.selectionSnapshot->Option.map(snapshot => snapshot.label),
          createdAt: session.createdAt,
          updatedAt: session.updatedAt,
        }: App.profileEditSessionSnapshot)
      | Some({node: None}) | None => None
      }
    )
  | None => []
  }
  let inviteChainFriends = switch profile.inviteChainFriends.edges {
  | Some(edges) =>
    edges->Array.filterMap(edge =>
      switch edge {
      | Some({node: Some(friend)}) =>
        Some(({
          id: friend.id,
          displayName: friend.displayName,
          profileSlug: friend.profileSlug,
          profileTitle: friend.profileTitle,
          avatarInitials: friend.avatarInitials,
          avatarColor: friend.avatarColor,
          avatarUrl: friend.avatarUrl,
        }: App.inviteChainFriendSnapshot))
      | Some({node: None}) | None => None
      }
    )
  | None => []
  }

  {
    viewer,
    profileId: Some(profile.id),
    currentVersionId: profile.currentVersion->Option.map(version => version.id),
    initialDocument: profile->documentFromProfile,
    versionHistory,
    editSessions,
    availableInvite,
    viewerUsedInvite,
    inviteChainFriends,
    ownerProfileImage: Some({
      displayName: profile.owner->Option.mapOr(profile.title, owner => owner.displayName),
      avatarUrl: profile.sendAvatarUrl,
    }),
  }
}

@react.component
let make = (
  ~profile,
  ~route: Route.t,
  ~viewer: option<App.viewerSnapshot>,
  ~availableInvite: option<App.inviteSnapshot>,
  ~viewerUsedInvite: option<App.inviteSnapshot>,
) => {
  let profile = ProfileFragment.use(profile)
  <App
    route
    editorContext={profile->editorContextFromProfile(
      ~viewer,
      ~availableInvite,
      ~viewerUsedInvite,
    )}
  />
}
