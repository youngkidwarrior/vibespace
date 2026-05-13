open GraphQLYoga

@val @scope("process") external env: Dict.t<string> = "env"

module Bun = {
  type server
  type serveConfig = {
    @live port: int,
    @live fetch: Request.t => promise<Fetch.Response.t>,
  }

  @val @scope("Bun") external serve: serveConfig => server = "serve"
}

external serverAsFetch: Server.t => (Request.t => promise<Fetch.Response.t>) = "%identity"

module Url = {
  type t

  @new external make: string => t = "URL"
  @get external pathname: t => string = "pathname"
}

module HealthResponse = {
  @new external make: string => Fetch.Response.t = "Response"
}

module RuntimeLog = {
  @module("./RuntimeLog.js") external now: unit => float = "now"
  @module("./RuntimeLog.js") external logGraphqlRequest: string => unit = "logGraphqlRequest"
  @module("./RuntimeLog.js") external logGraphqlResponse: (
    string,
    float,
    Fetch.Response.t,
  ) => unit = "logGraphqlResponse"
  @module("./RuntimeLog.js") external logGraphqlError: (string, float, exn) => unit =
    "logGraphqlError"
}

module LocalSessionToken = {
  @module("@vibespace/schema/src/LocalSessionToken.js") external verifiedUserIdFromHeaders: (
    string,
    string,
  ) => string = "verifiedUserIdFromHeaders"
}

let optionFromNonBlank = (value: string): option<string> => {
  let trimmed = value->String.trim
  trimmed == "" ? None : Some(trimmed)
}

exception MissingProductionDatabase(string)

let isDevAdminRequest = (request: Request.t): bool => {
  let configuredToken = env->Dict.get("VIBESPACE_DEV_ADMIN_TOKEN")->Option.getOr("")->String.trim
  let requestToken = request
    ->Request.headers
    ->Headers.get("x-vibespace-dev-admin-token")
    ->Option.getOr("")
    ->String.trim

  configuredToken != "" && configuredToken == requestToken
}

let port =
  env
  ->Dict.get("PORT")
  ->Option.flatMap(port => Int.fromString(port))
  ->Option.getOr(4555)

let vibespaceEnv = env->Dict.get("VIBESPACE_ENV")->Option.getOr("")->String.trim->String.toLowerCase
let databaseUrl = env->Dict.get("DATABASE_URL")->Option.flatMap(optionFromNonBlank)
let publicGraphqlUrl = env->Dict.get("VIBESPACE_GRAPHQL_PUBLIC_URL")

let () = switch (vibespaceEnv, databaseUrl) {
| ("production", None) =>
  throw(MissingProductionDatabase(
    "DATABASE_URL is required when VIBESPACE_ENV=production. Refusing to start with fixture-backed data.",
  ))
| _ => ()
}

let yoga = createYoga({
  schema: ResGraphSchema.schema,
  graphqlEndpoint: "/graphql",
  graphiql: Options({title: "Vibespace GraphQL"}),
  maskedErrors: True,
  // TODO(graphql-safety): Add Yoga/Envelope depth or complexity limits before
  // friend/activity/profile graph surfaces are exposed beyond local testing.
  context: async ({request}): ResGraphContext.context => {
    currentUserId: LocalSessionToken.verifiedUserIdFromHeaders(
      request->Request.headers->Headers.get("authorization")->Option.getOr(""),
      request->Request.headers->Headers.get("x-vibespace-session-token")->Option.getOr(""),
    )->optionFromNonBlank,
    isDevAdmin: request->isDevAdminRequest,
    databaseUrl,
    dataLoaders: DataLoaders.make(~databaseUrl),
  },
})

let yogaFetch = yoga->serverAsFetch

let fetch = async (request: Request.t) => {
  let url = request->Request.url
  let pathname = url->Url.make->Url.pathname

  if pathname == "/health" {
    "ok"->HealthResponse.make
  } else {
    let startedAt = RuntimeLog.now()
    RuntimeLog.logGraphqlRequest(url)
    try {
      let response = await yogaFetch(request)
      RuntimeLog.logGraphqlResponse(url, startedAt, response)
      response
    } catch {
    | exception_ =>
      RuntimeLog.logGraphqlError(url, startedAt, exception_)
      throw(exception_)
    }
  }
}

@live
let _server = Bun.serve({
  port,
  fetch,
})

Console.info(`Vibespace GraphQL listening on container port ${port->Int.toString} at /graphql`)

switch publicGraphqlUrl {
| Some(url) => Console.info(`Vibespace GraphQL localnet URL ${url}`)
| None => ()
}
