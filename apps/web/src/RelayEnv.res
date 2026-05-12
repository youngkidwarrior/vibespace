@module("./ViteEnv.js") external graphqlEndpoint: string = "graphqlEndpoint"

@throws(JsExn)
let fetchGraphql = async (
  operation: RescriptRelay.Network.operation,
  variables: JSON.t,
  _cacheConfig: RescriptRelay.cacheConfig,
  _uploadables: Nullable.t<RescriptRelay.uploadables>,
): JSON.t => {
  let query = operation.text->Nullable.toOption->Option.getOr("")
  let body = {
    "query": query,
    "variables": variables,
  }
  let serialized = body->JSON.stringifyAny->Option.getOr("{\"query\":\"\",\"variables\":{}}")
  let headers = dict{
    "accept": "application/json",
    "content-type": "application/json",
  }
  switch LocalViewerSession.load() {
  | Some(sessionToken) => Dict.set(headers, "authorization", "Bearer " ++ sessionToken)
  | None => ()
  }

  let response = await Fetch.fetch(graphqlEndpoint, ~init={
    method: "POST",
    headers: HeadersInit.fromDict(headers),
    body: BodyInit.fromString(serialized),
    credentials: SameOrigin,
  })

  await response->Response.json
}

@throws(JsExn)
let network = RescriptRelay.Network.makePromiseBased(~fetchFunction=fetchGraphql)

let store = RescriptRelay.Store.make(~source=RescriptRelay.RecordSource.make())

@throws(JsExn)
let environment = RescriptRelay.Environment.make(~network, ~store)
