module Query = %relay(`
  query ProfileRouteQuery {
    viewer {
      id
      handle
      displayName
      status
    }
    availableInvite {
      id
      code
      inviterUserId
      inviteeUserId
      status
      redeemedAt
    }
    viewerUsedInvite {
      id
      code
      inviterUserId
      inviteeUserId
      status
      redeemedAt
    }
    friendActivity(first: 10) {
      edges {
        node {
          id
          kind
          title
          summary
          createdAt
          actor {
            id
            displayName
          }
          eventProfile {
            id
            title
          }
        }
      }
    }
    viewerProfile {
      ...ProfileDocumentData_profile
    }
  }
`)

let makeUnauthenticatedLanding = () => {
  // TODO(random-profile-discovery): Replace this placeholder with a random
  // friend-visible profile query for visitors who do not have an invite or
  // local account yet.
  <main className="grid min-h-screen place-items-center bg-neutral-950 p-6 text-center text-white">
    <section className="w-[min(620px,100%)] rounded-3xl border border-white/15 bg-white/10 p-8 shadow-2xl backdrop-blur-xl">
      <p className="m-0 text-xs font-black uppercase tracking-[0.2em] text-amber-200">
        {React.string("Invite-only alpha")}
      </p>
      <h1 className="mt-3 mb-0 text-5xl font-black leading-none tracking-normal max-md:text-4xl">
        {React.string("Vibespace opens through a link.")}
      </h1>
      <p className="mt-4 mb-0 text-base leading-relaxed text-white/70">
        {React.string("If you have an invite, open that link to create your profile. Otherwise this page will become a random profile discovery surface.")}
      </p>
      <div className="mt-6">
        <RelayRouter.Link
          className="inline-flex h-9 items-center rounded-xl border border-white/20 bg-white px-3 text-sm font-black text-neutral-950 no-underline shadow-lg"
          to_={Routes.Profile.Route.makeLink(~handle="vic")}
          preloadCode=OnInView
          preloadData=OnIntent>
          {React.string("Preview a profile")}
        </RelayRouter.Link>
      </div>
    </section>
  </main>
}

@react.component
let make = (~queryRef, ~route: Route.t) => {
  let data = Query.usePreloaded(~queryRef)
  let viewer: option<App.viewerSnapshot> = data.viewer->Option.map(viewer => ({
    id: viewer.id,
    status: viewer.status->ProfileRelayLabels.userStatus,
  }: App.viewerSnapshot))
  let availableInvite: option<App.inviteSnapshot> = data.availableInvite->Option.map(invite => ({
    id: invite.id,
    code: invite.code,
    status: invite.status->ProfileRelayLabels.inviteStatus,
    redeemedAt: invite.redeemedAt,
  }: App.inviteSnapshot))
  let viewerUsedInvite: option<App.inviteSnapshot> = data.viewerUsedInvite->Option.map(invite => ({
    id: invite.id,
    code: invite.code,
    status: invite.status->ProfileRelayLabels.inviteStatus,
    redeemedAt: invite.redeemedAt,
  }: App.inviteSnapshot))
  switch data.viewerProfile {
  | Some(profile) =>
    <ProfileDocumentData
      route
      profile=profile.fragmentRefs
      viewer
      availableInvite
      viewerUsedInvite
      canonicalizeRootUrl=true
    />
  | None =>
    switch data.viewer {
    | Some(_) => <App route />
    | None => makeUnauthenticatedLanding()
    }
  }
}
