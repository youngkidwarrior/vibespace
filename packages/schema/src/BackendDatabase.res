module Client = {
  type t = PgTyped.Pg.Client.t
  type config = {@live connectionString: string}
  type queryResult

  @module("pg") @new external make: config => t = "Client"
  @send external connect: t => promise<unit> = "connect"
  @send external end_: t => promise<unit> = "end"
  @send external query: (t, string) => promise<queryResult> = "query"
}

let quietlyEnd = async (client: Client.t): unit => {
  try {
    await client->Client.end_
  } catch {
  | _ => ()
  }
}

let withClient = async (
  databaseUrl: option<string>,
  operation: Client.t => promise<'result>,
): option<'result> =>
  switch databaseUrl {
  | None => None
  | Some(connectionString) =>
    let client = Client.make({connectionString: connectionString})

    try {
      await client->Client.connect
      let result = await operation(client)
      await client->quietlyEnd
      Some(result)
    } catch {
    | _ =>
      await client->quietlyEnd
      None
    }
  }

let withTransaction = async (
  databaseUrl: option<string>,
  operation: Client.t => promise<'result>,
): option<'result> =>
  switch databaseUrl {
  | None => None
  | Some(connectionString) =>
    let client = Client.make({connectionString: connectionString})

    try {
      await client->Client.connect
      let _ = await client->Client.query("BEGIN")

      try {
        let result = await operation(client)
        let _ = await client->Client.query("COMMIT")
        await client->quietlyEnd
        Some(result)
      } catch {
      | _ =>
        let _ = await client->Client.query("ROLLBACK")
        await client->quietlyEnd
        None
      }
    } catch {
    | _ =>
      await client->quietlyEnd
      None
    }
  }
