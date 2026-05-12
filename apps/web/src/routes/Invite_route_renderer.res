open RescriptRelay

module DeferredInviteRoute = %relay.deferredComponent(InviteRoute.make)

let renderer = Routes.Invite.Route.makeRenderer(
  ~prepareCode=_props => [DeferredInviteRoute.preload()],
  ~prepare=props => {
    InviteRouteQuery_graphql.load(
      ~environment=props.environment,
      ~variables={code: props.code},
      ~fetchPolicy=StoreOrNetwork,
    )
  },
  ~render=props => {
    <DeferredInviteRoute queryRef=props.prepared code=props.code />
  },
)
