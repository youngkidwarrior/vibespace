module Query = %relay(`
  query PublicProfileRouteQuery($handle: String!) {
    profileByHandle(handle: $handle) {
      ...PublicProfileViewer_profile
    }
  }
`)

@react.component
let make = (~queryRef) => {
  let data = Query.usePreloaded(~queryRef)
  switch data.profileByHandle {
  | Some(profileRef) => <PublicProfileViewer profile=profileRef.fragmentRefs />
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
