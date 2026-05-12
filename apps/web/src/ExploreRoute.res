module Query = %relay(`
  query ExploreRouteQuery {
    randomProfile {
      ...PublicProfileViewer_profile
    }
  }
`)

let renderEmpty = () =>
  <main className="grid min-h-screen place-items-center bg-neutral-950 p-6 text-center text-white">
    <section className="w-[min(560px,100%)] rounded-lg border border-white/15 bg-white/10 p-6 shadow-2xl backdrop-blur-xl">
      <p className="m-0 text-xs font-black uppercase tracking-[0.2em] text-amber-200">
        {React.string("Explore")}
      </p>
      <h1 className="mt-3 mb-0 text-3xl font-black leading-none tracking-normal">
        {React.string("No public profiles are ready yet.")}
      </h1>
      <p className="mt-4 mb-0 text-base leading-relaxed text-white/70">
        {React.string("Once someone publishes a profile, this page will open a random Vibespace you can browse while yours is building.")}
      </p>
      <RelayRouter.Link
        className="mt-5 inline-flex h-10 items-center rounded-md border border-white/70 bg-white px-4 text-sm font-black text-neutral-950 no-underline"
        to_={Routes.Editor.Route.makeLink()}
        preloadCode=OnInView
        preloadData=OnIntent>
        {React.string("Back to app")}
      </RelayRouter.Link>
    </section>
  </main>

@react.component
let make = (~queryRef) => {
  let data = Query.usePreloaded(~queryRef)
  switch data.randomProfile {
  | Some(profile) => <PublicProfileViewer profile=profile.fragmentRefs />
  | None => renderEmpty()
  }
}
