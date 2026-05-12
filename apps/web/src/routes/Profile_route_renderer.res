open RescriptRelay

module DeferredPublicProfileRoute = %relay.deferredComponent(PublicProfileRoute.make)

let renderer = Routes.Profile.Route.makeRenderer(
  ~prepareCode=_props => [DeferredPublicProfileRoute.preload()],
  ~prepare=props => {
    PublicProfileRouteQuery_graphql.load(
      ~environment=props.environment,
      ~variables={handle: props.handle},
      ~fetchPolicy=StoreOrNetwork,
    )
  },
  ~render=props => {
    <DeferredPublicProfileRoute queryRef=props.prepared />
  }
)
