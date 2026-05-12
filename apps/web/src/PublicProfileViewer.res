module ProfileFragment = %relay(`
  fragment PublicProfileViewer_profile on Profile {
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

let ownerLabel = (profile: PublicProfileViewer_profile_graphql.Types.fragment) =>
  switch profile.owner {
  | Some(owner) => owner.displayName ++ " @" ++ owner.handle
  | None => profile.title
  }

let inviteChainFriendsForPreview = (
  profile: PublicProfileViewer_profile_graphql.Types.fragment,
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

let renderUnavailable = () =>
  <main className="grid min-h-screen place-content-center gap-3 bg-white p-8 text-center text-neutral-950">
    <h1 className="m-0 text-3xl font-black"> {React.string("This profile is not ready yet.")} </h1>
    <p className="m-0 text-neutral-500">
      {React.string("The profile exists, but it does not have a published version to show.")}
    </p>
    <RelayRouter.Link className="font-black text-neutral-950" to_={Routes.Editor.Route.makeLink()}>
      {React.string("Back to vibespace")}
    </RelayRouter.Link>
  </main>

let renderInvitePopup = (~onClose) =>
  <aside className="fixed bottom-4 right-4 z-30 w-[min(360px,calc(100vw-32px))] rounded-lg border border-neutral-200 bg-white p-4 text-neutral-950 shadow-2xl max-md:bottom-3 max-md:right-3 max-md:w-[calc(100vw-24px)]">
    <div className="mb-2.5 flex items-start justify-between gap-3">
      <div>
        <p className="m-0 text-[11px] font-black uppercase tracking-wider text-amber-700">
          {React.string("Invite-only alpha")}
        </p>
        <h2 className="m-0 mt-1 text-xl font-black leading-none tracking-normal">
          {React.string("One invite")}
        </h2>
      </div>
      <button
        className="inline-grid size-8 shrink-0 cursor-pointer place-items-center rounded-full border-0 bg-neutral-100 text-neutral-900 hover:bg-neutral-200"
        type_="button"
        ariaLabel="Close invite note"
        onClick={_ => onClose()}>
        <Icons.X size=15 ariaHidden=true />
      </button>
    </div>
    <p className="m-0 text-sm leading-relaxed text-neutral-600">
      {React.string(
        "Vibespace opens through invite links. Every new profile gets one invite, so the people here decide who gets to make the next profile.",
      )}
    </p>
    <div className="mt-3 flex flex-wrap items-center gap-2">
      <RelayRouter.Link
        className="inline-flex h-9 items-center rounded-md border border-neutral-950 bg-neutral-950 px-3 text-sm font-black text-white no-underline hover:bg-neutral-800"
        to_={Routes.Editor.Route.makeLink()}>
        {React.string("Preview another")}
      </RelayRouter.Link>
      <span className="text-xs font-bold text-neutral-500">
        {React.string("Have an invite? Open that link to start.")}
      </span>
    </div>
  </aside>

@react.component
let make = (~profile, ~showInvitePopup=false, ~canonicalizeRootUrl=false) => {
  let profile = ProfileFragment.use(profile)
  let (invitePopupOpen, setInvitePopupOpen) = React.useState(() => showInvitePopup)
  let location = RelayRouter.Utils.useLocation()
  let router = RelayRouter.Utils.useRouter()
  let canonicalProfileLink = Routes.Profile.Route.makeLink(~handle=profile.slug)
  let canonicalUrlKey =
    (canonicalizeRootUrl ? "1" : "0") ++
    "|" ++ location.pathname ++ "|" ++ location.search ++ "|" ++ location.hash ++ "|" ++ canonicalProfileLink

  React.useEffect1(() => {
    if canonicalizeRootUrl && location.pathname == "/" && location.search == "" && location.hash == "" {
      router.replace(canonicalProfileLink)
    }
    None
  }, [canonicalUrlKey])
  let routeProfileFrameLink = path => router.push(path)

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
          <strong className="overflow-hidden text-ellipsis whitespace-nowrap text-sm font-black text-neutral-950">
            {React.string(profile.title)}
          </strong>
        </div>
      </header>
      <iframe
        className="block h-screen w-screen border-0 bg-white"
        title={profile.title ++ " on Vibespace"}
        sandbox="allow-same-origin allow-scripts allow-popups allow-presentation"
        srcDoc=preview
        onLoad={event => BrowserBridge.attachProfileLinkRouter(event, routeProfileFrameLink)}
      />
      {showInvitePopup && invitePopupOpen
        ? renderInvitePopup(~onClose=() => setInvitePopupOpen(_ => false))
        : React.null}
    </main>
  | None => renderUnavailable()
  }
}
