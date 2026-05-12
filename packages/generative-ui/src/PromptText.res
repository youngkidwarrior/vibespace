type t = string

let make = value => value
let empty = ""
let toString = value => value
let trim = value => value->String.trim
let isBlank = value => value->trim == ""
