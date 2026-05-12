module Query = %relay(`
  query PublicProfileRouteQuery($handle: String!) {
    profileByHandle(handle: $handle) {
      ...PublicProfileRoute_profile
    }
  }
`)

module ProfileFragment = %relay(`
  fragment PublicProfileRoute_profile on Profile {
    title
    slug
    sendtag
    sendAvatarUrl
    owner {
      handle
      displayName
    }
    currentVersion {
      html
      css
      summary
      createdAt
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

let ownerLabel = (profile: PublicProfileRoute_profile_graphql.Types.fragment) =>
  switch profile.owner {
  | Some(owner) => owner.displayName ++ " @" ++ owner.handle
  | None => profile.title
  }

let inviteChainFriendsForPreview = (
  profile: PublicProfileRoute_profile_graphql.Types.fragment,
): PreviewBridge.inviteChainFriends => {
  let friends = switch profile.inviteChainFriends.edges {
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
        }: PreviewBridge.inviteChainFriend))
      | Some({node: None}) | None => None
      }
    )
  | None => []
  }

  {friends: friends}
}

@react.component
let make = (~queryRef) => {
  let data = Query.usePreloaded(~queryRef)
  switch data.profileByHandle {
  | Some(profileRef) =>
    let profile = ProfileFragment.use(profileRef.fragmentRefs)
    switch profile.currentVersion {
    | Some(version) =>
      let preview = PreviewBridge.buildPreviewDocument(
        version.html->HtmlSource.make,
        version.css->CssSource.make,
        None,
        false,
        Some(profile->inviteChainFriendsForPreview),
        Some({
          displayName: profile.owner->Option.mapOr(profile.title, owner => owner.displayName),
          avatarUrl: profile.sendAvatarUrl,
        }),
      )
      <main className="min-h-screen bg-neutral-950">
        <header className="pointer-events-none fixed left-4 right-4 top-4 z-20 flex items-center justify-between gap-3">
          <RelayRouter.Link
            className="pointer-events-auto inline-flex min-h-8 items-center rounded-xl border border-white/20 bg-white/85 px-3 text-sm font-black text-neutral-950 no-underline shadow-lg backdrop-blur-md"
            to_={Routes.Editor.Route.makeLink()}
            preloadCode=OnInView
            preloadData=OnIntent>
            {React.string("vibespace")}
          </RelayRouter.Link>
          <div className="pointer-events-auto grid max-w-[min(420px,58vw)] rounded-2xl border border-white/20 bg-white/85 px-3 py-2 text-right text-neutral-950 shadow-lg backdrop-blur-md">
            <span className="text-[11px] font-bold text-neutral-500"> {React.string(profile->ownerLabel)} </span>
            <strong className="overflow-hidden text-ellipsis whitespace-nowrap text-sm font-black text-neutral-950"> {React.string(profile.title)} </strong>
          </div>
        </header>
        <iframe
          className="block h-screen w-screen border-0 bg-white"
          title={profile.title ++ " on Vibespace"}
          sandbox="allow-same-origin allow-scripts allow-popups allow-presentation allow-top-navigation-by-user-activation"
          srcDoc=preview
        />
      </main>
    | None =>
      <main className="grid min-h-screen place-content-center gap-3 bg-white p-8 text-center text-neutral-950">
        <h1 className="m-0 text-3xl font-black"> {React.string("This profile is not ready yet.")} </h1>
        <p className="m-0 text-neutral-500"> {React.string("The profile exists, but it does not have a published version to show.")} </p>
        <RelayRouter.Link className="font-black text-neutral-950" to_={Routes.Editor.Route.makeLink()}>
          {React.string("Back to vibespace")}
        </RelayRouter.Link>
      </main>
    }
  | None =>
    <main className="grid min-h-screen place-content-center gap-3 bg-white p-8 text-center text-neutral-950">
      <h1 className="m-0 text-3xl font-black"> {React.string("Profile not found")} </h1>
      <p className="m-0 text-neutral-500"> {React.string("That Vibespace profile is unavailable or not visible to you.")} </p>
      <RelayRouter.Link className="font-black text-neutral-950" to_={Routes.Editor.Route.makeLink()}>
        {React.string("Back to vibespace")}
      </RelayRouter.Link>
    </main>
  }
}
