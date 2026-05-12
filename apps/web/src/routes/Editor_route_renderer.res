open RescriptRelay

module DeferredProfileRoute = %relay.deferredComponent(ProfileRoute.make)

let renderer = Routes.Editor.Route.makeRenderer(
  ~prepareCode=_props => [DeferredProfileRoute.preload()],
  ~prepare=props => {
    ProfileRouteQuery_graphql.load(
      ~environment=props.environment,
      ~variables=(),
      ~fetchPolicy=StoreOrNetwork,
    )
  },
  ~render=props => {
    let route = switch Routes.Editor.Route.getActiveSubRoute(props.location) {
    | Some(#Source) => Route.Source
    | None => Route.Canvas
    }

    <DeferredProfileRoute queryRef=props.prepared route />
  }
)
