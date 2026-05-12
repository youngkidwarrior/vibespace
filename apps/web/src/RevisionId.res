type t = int

let initial = 1
let next = revision => revision + 1
let fromString = value =>
  switch value->String.trim->Int.fromString {
  | Some(revision) if revision > 0 => Some(revision)
  | _ => None
  }
let toString = revision => revision->Int.toString
