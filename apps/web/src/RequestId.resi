type t

let make: string => option<t>
let unsafeFromString: string => t
let toString: t => string
