let preparedAssetsMap = Dict.make()

@live
@throws(JsExn)
let routerResources = RelayRouter.Router.make(
  ~routes=RouteDeclarations.make(~prepareDisposeTimeout=5 * 60 * 1000),
  ~environment=RelayEnv.environment,
  ~routerEnvironment=RelayRouter.RouterEnvironment.makeBrowserEnvironment(),
  ~preloadAsset=RelayRouter.AssetPreloader.makeClientAssetPreloader(preparedAssetsMap),
)

@live
@throws(JsExn)
let cleanup = switch routerResources {
| (cleanup, _) => cleanup
}

@throws(JsExn)
let routerContext = switch routerResources {
| (_, routerContext) => routerContext
}
