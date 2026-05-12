type t

let make: string => option<t>
let fromParts: (~createdAt: IsoTimestamp.t, ~promptLength: int) => t
let toString: t => string
