let renderer = Routes.NotFound.Route.makeRenderer(
  ~prepare=_props => {
    ()
  },
  ~render=props => {
    ignore(props)
    <main className="grid min-h-screen place-items-center gap-3 bg-white p-6 text-center text-neutral-950">
      <h1 className="m-0 text-3xl font-black"> {React.string("Profile route not found")} </h1>
      <RelayRouter.Link
        className="font-black text-neutral-950"
        to_={Routes.Editor.Route.makeLink()}
        preloadCode=OnInView
        preloadData=OnIntent
        preloadPriority=High>
        {React.string("Back to vibespace")}
      </RelayRouter.Link>
    </main>
  }
)
