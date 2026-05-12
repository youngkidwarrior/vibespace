type t = string

let startsWith = (value, prefix) =>
  value->String.slice(~start=0, ~end=prefix->String.length) == prefix

let make = value => {
  let trimmed = value->String.trim
  if trimmed == "" {
    None
  } else if startsWith(trimmed, "data:image/") {
    Some(trimmed)
  } else {
    None
  }
}

let toString = dataUrl => dataUrl
