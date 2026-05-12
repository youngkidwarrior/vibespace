open RescriptRelay

module DeferredExploreRoute = %relay.deferredComponent(ExploreRoute.make)

let renderer = Routes.Explore.Route.makeRenderer(
  ~prepareCode=_props => [DeferredExploreRoute.preload()],
  ~prepare=props => {
    ExploreRouteQuery_graphql.load(
      ~environment=props.environment,
      ~variables=(),
      ~fetchPolicy=StoreOrNetwork,
    )
  },
  ~render=props => {
    <DeferredExploreRoute queryRef=props.prepared />
  }
)
