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
    randomProfile {
      ...PublicProfileViewer_profile
    }
  }
`)

let makeNoPublicProfilesLanding = () =>
  <main className="grid min-h-screen place-items-center bg-neutral-950 p-6 text-center text-white">
    <section className="w-[min(560px,100%)] rounded-lg border border-white/15 bg-white/10 p-6 shadow-2xl backdrop-blur-xl">
      <p className="m-0 text-xs font-black uppercase tracking-[0.2em] text-amber-200">
        {React.string("Invite-only alpha")}
      </p>
      <h1 className="mt-3 mb-0 text-3xl font-black leading-none tracking-normal">
        {React.string("No profiles are ready yet.")}
      </h1>
      <p className="mt-4 mb-0 text-base leading-relaxed text-white/70">
        {React.string(
          "Vibespace opens through invite links. Once someone publishes a profile, this page will open directly to a random public profile.",
        )}
      </p>
    </section>
  </main>

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
    />
  | None =>
    switch data.viewer {
    | Some(_) => <App route />
    | None =>
      switch data.randomProfile {
      | Some(profile) =>
        <PublicProfileViewer
          profile=profile.fragmentRefs
          showInvitePopup=true
          canonicalizeRootUrl=true
        />
      | None => makeNoPublicProfilesLanding()
      }
    }
  }
}
