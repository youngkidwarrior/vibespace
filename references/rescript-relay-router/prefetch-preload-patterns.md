# Prefetch And Preload Patterns

Use RescriptRelayRouter's route preloading instead of ad hoc fetching.

## Route Renderers

- Wrap route-owned screen components with `%relay.deferredComponent`.
- Add `prepareCode` and return the deferred component's `preload()` asset.
- Add `prepare` for data-owning routes and return Relay query refs from
  `SomeRouteQuery_graphql.load`.
- Render the deferred component with `props.prepared`.

```rescript
module DeferredProfileRoute = %relay.deferredComponent(ProfileRoute.make)

let renderer = Routes.Editor.Route.makeRenderer(
  ~prepareCode=_props => [DeferredProfileRoute.preload()],
  ~prepare=props =>
    ProfileRouteQuery_graphql.load(
      ~environment=props.environment,
      ~variables=(),
      ~fetchPolicy=StoreOrNetwork,
    ),
  ~render=props => <DeferredProfileRoute queryRef=props.prepared route=Route.Canvas />,
)
```

## Links

Use generated route links. For visible navigation, make preloading explicit when
the destination is important.

```rescript
<RelayRouter.Link
  to_={Routes.Editor.Route.makeLink()}
  preloadCode=OnInView
  preloadData=OnIntent
  preloadPriority=High>
  {React.string("Back")}
</RelayRouter.Link>
```

## App-Native Buttons

Shadcn/BaseUI buttons do not get `RelayRouter.Link` intent behavior. Use
`RelayRouter.Utils.useRouter()` and call `preload` before `push`.

```rescript
let router = RelayRouter.Utils.useRouter()
let sourceRouteLink = Routes.Editor.Source.Route.makeLink()
let preloadSourceRoute = () => router.preload(~priority=High, sourceRouteLink)

<Button
  onMouseEnter={_ => preloadSourceRoute()}
  onMouseDown={_ => preloadSourceRoute()}
  onTouchStart={_ => preloadSourceRoute()}
  onFocus={_ => preloadSourceRoute()}
  onClick={_ => {
    preloadSourceRoute()
    router.push(sourceRouteLink)
  }}>
  {React.string("Advanced")}
</Button>
```

Prefer `router.preload` for code plus data. Use `router.preloadCode` only when
the route has no data or when data fetching would be wasteful.
