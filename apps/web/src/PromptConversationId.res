type t = string

let make = value => {
  let trimmed = value->String.trim
  trimmed == "" ? None : Some(trimmed)
}

let toString = id => id
