module DbQueries = Profile_versions__sql

type t = {
  byId: DataLoader.t<string, option<DbQueries.getUsersByIdsResult>>,
}

let emptyResults = ids => ids->Array.map(_id => None)

let usersById = async (
  ~databaseUrl: option<string>,
  ids: array<string>,
): array<option<DbQueries.getUsersByIdsResult>> => {
  switch await BackendDatabase.withClient(databaseUrl, async client =>
    await DbQueries.GetUsersByIds.many(client, {ids: ids})
  ) {
  | None => ids->emptyResults
  | Some(rows) => ids->Array.map(id => rows->Array.find(row => row.id == id))
  }
}

let make = (~databaseUrl: option<string>): t => {
  byId: DataLoader.makeBatched(ids => usersById(~databaseUrl, ids), ~options={name: "userById"}),
}
