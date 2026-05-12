type t = string

let maxLength = 400
let make = value => value->String.trim->String.slice(~start=0, ~end=maxLength)
let toString = value => value
