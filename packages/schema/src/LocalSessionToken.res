@module("./LocalSessionToken.js") external issueForUserIdUnsafe: string => string = "issueForUserId"

let issueForUserId = (userId: string): option<string> => {
  let token = userId->issueForUserIdUnsafe
  token == "" ? None : Some(token)
}
