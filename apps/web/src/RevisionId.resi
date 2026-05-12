type t

let initial: t
let next: t => t
let fromString: string => option<t>
let toString: t => string
