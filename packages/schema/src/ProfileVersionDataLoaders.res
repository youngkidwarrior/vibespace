module DbQueries = Profile_versions__sql

type t = {
  byId: DataLoader.t<string, option<DbQueries.getProfileVersionsByIdsResult>>,
  currentByProfileId: DataLoader.t<
    string,
    option<DbQueries.getCurrentProfileVersionsByProfileIdsResult>,
  >,
}

let emptyResults = ids => ids->Array.map(_id => None)

let profileVersionsById = async (
  ~databaseUrl: option<string>,
  ids: array<string>,
): array<option<DbQueries.getProfileVersionsByIdsResult>> => {
  switch await BackendDatabase.withClient(databaseUrl, async client =>
    await DbQueries.GetProfileVersionsByIds.many(client, {ids: ids})
  ) {
  | None => ids->emptyResults
  | Some(rows) => ids->Array.map(id => rows->Array.find(row => row.id == id))
  }
}

let currentProfileVersionsByProfileId = async (
  ~databaseUrl: option<string>,
  profileIds: array<string>,
): array<option<DbQueries.getCurrentProfileVersionsByProfileIdsResult>> => {
  switch await BackendDatabase.withClient(databaseUrl, async client =>
    await DbQueries.GetCurrentProfileVersionsByProfileIds.many(client, {profileIds: profileIds})
  ) {
  | None => profileIds->emptyResults
  | Some(rows) => profileIds->Array.map(profileId => rows->Array.find(row => row.profileId == profileId))
  }
}

let make = (~databaseUrl: option<string>): t => {
  byId: DataLoader.makeBatched(
    ids => profileVersionsById(~databaseUrl, ids),
    ~options={name: "profileVersionById"},
  ),
  currentByProfileId: DataLoader.makeBatched(
    profileIds => currentProfileVersionsByProfileId(~databaseUrl, profileIds),
    ~options={name: "currentProfileVersionByProfileId"},
  ),
}
