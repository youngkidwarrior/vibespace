type context = {
  currentUserId: option<string>,
  isDevAdmin: bool,
  databaseUrl: option<string>,
  dataLoaders: DataLoaders.t,
}
