type t = string

@val @scope("JSON") external stringify: string => string = "stringify"

let quote = value => {
  stringify(value)
}

let forElementId = id => "[data-vibespace-id=" ++ quote(ProfileElementId.toString(id)) ++ "]"
let make = value => value
let toString = selector => selector
