type reactRoot

@module("react-dom/client") external createRoot: DomTypes.element => reactRoot = "createRoot"
@send external render: (reactRoot, React.element) => unit = "render"

@throws(JsExn)
switch Document.getElementById(DomGlobal.document, "root")->Null.toOption {
| Some(root) =>
  root
  ->createRoot
  ->render(
    <React.StrictMode>
      <RescriptRelayReact.Context.Provider environment=RelayEnv.environment>
        <RelayRouter.Provider value={Router.routerContext}>
          <React.Suspense fallback={<div className="grid min-h-screen place-items-center bg-white p-6 text-neutral-950"> {React.string("Loading profile...")} </div>}>
            <RelayRouter.RouteRenderer renderPending={pending =>
              pending
                ? <div className="fixed inset-0 z-20 grid place-items-center bg-white/70 p-6 text-neutral-950 backdrop-blur-md"> {React.string("Loading...")} </div>
                : React.null
            } />
          </React.Suspense>
        </RelayRouter.Provider>
      </RescriptRelayReact.Context.Provider>
    </React.StrictMode>,
  )
| None => Console.error("Vibespace root element was not found.")
}
