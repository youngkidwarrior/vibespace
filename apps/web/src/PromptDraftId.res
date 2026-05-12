type t = string

let make = value => {
  let trimmed = value->String.trim
  trimmed == "" ? None : Some(trimmed)
}

let fromRequestId = requestId => "draft-" ++ RequestId.toString(requestId)
let toString = id => id
let equals = (first, second) => first == second
