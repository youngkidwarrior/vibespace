module DbQueries = Profile_versions__sql

type t = {
  byId: DataLoader.t<string, option<DbQueries.getProfilesByIdsResult>>,
  byOwnerId: DataLoader.t<string, option<DbQueries.getProfilesByOwnerIdsResult>>,
}

let emptyResults = ids => ids->Array.map(_id => None)

let profilesById = async (
  ~databaseUrl: option<string>,
  ids: array<string>,
): array<option<DbQueries.getProfilesByIdsResult>> => {
  switch await BackendDatabase.withClient(databaseUrl, async client =>
    await DbQueries.GetProfilesByIds.many(client, {ids: ids})
  ) {
  | None => ids->emptyResults
  | Some(rows) => ids->Array.map(id => rows->Array.find(row => row.id == id))
  }
}

let profilesByOwnerId = async (
  ~databaseUrl: option<string>,
  ownerUserIds: array<string>,
): array<option<DbQueries.getProfilesByOwnerIdsResult>> => {
  switch await BackendDatabase.withClient(databaseUrl, async client =>
    await DbQueries.GetProfilesByOwnerIds.many(client, {ownerUserIds: ownerUserIds})
  ) {
  | None => ownerUserIds->emptyResults
  | Some(rows) =>
    ownerUserIds->Array.map(ownerUserId => rows->Array.find(row => row.ownerUserId == ownerUserId))
  }
}

let make = (~databaseUrl: option<string>): t => {
  byId: DataLoader.makeBatched(ids => profilesById(~databaseUrl, ids), ~options={name: "profileById"}),
  byOwnerId: DataLoader.makeBatched(
    ownerUserIds => profilesByOwnerId(~databaseUrl, ownerUserIds),
    ~options={name: "profileByOwnerId"},
  ),
}
