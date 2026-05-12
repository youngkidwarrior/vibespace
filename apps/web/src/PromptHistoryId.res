type t = string

let make = value => {
  let trimmed = value->String.trim
  trimmed == "" ? None : Some(trimmed)
}

let fromParts = (~createdAt: IsoTimestamp.t, ~promptLength: int) =>
  IsoTimestamp.toString(createdAt) ++ "-" ++ promptLength->Int.toString

let toString = id => id
