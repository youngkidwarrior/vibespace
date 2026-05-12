type t = string

let maxLength = 500
let make = value => value->String.slice(~start=0, ~end=maxLength)
let empty = ""
let toString = value => value
let isBlank = value => value->String.trim == ""
