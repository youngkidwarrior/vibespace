type t = {
  users: UserDataLoaders.t,
  profiles: ProfileDataLoaders.t,
  profileVersions: ProfileVersionDataLoaders.t,
}

let make = (~databaseUrl: option<string>): t => {
  users: UserDataLoaders.make(~databaseUrl),
  profiles: ProfileDataLoaders.make(~databaseUrl),
  profileVersions: ProfileVersionDataLoaders.make(~databaseUrl),
}
