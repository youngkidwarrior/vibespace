type t = string

let maxLength = 2000
let make = value => value->String.slice(~start=0, ~end=maxLength)
let toString = value => value
