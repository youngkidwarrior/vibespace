type t

let make: string => option<t>
let fromRequestId: RequestId.t => t
let toString: t => string
let equals: (t, t) => bool
