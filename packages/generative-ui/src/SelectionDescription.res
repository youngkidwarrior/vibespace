type t = string

let maxLength = 8000
let make = value => value->String.trim->String.slice(~start=0, ~end=maxLength)
let toString = value => value
let isBlank = value => value->String.trim == ""
