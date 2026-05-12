@val @scope("window") external localStorage: WebStorageTypes.storage = "localStorage"
@get external documentCookie: DomTypes.document => string = "cookie"
@set external setDocumentCookie: (DomTypes.document, string) => unit = "cookie"
@val external encodeURIComponent: string => string = "encodeURIComponent"
@val external decodeURIComponent: string => string = "decodeURIComponent"

let storageKey = "vibespace.viewerSessionToken"
let cookieKey = storageKey
let cookieMaxAgeSeconds = 31536000

let tokenFromString = value => {
  let token = value->String.trim
  token == "" ? None : Some(token)
}

let loadFromLocalStorage = () =>
  try {
    switch Storage.getItem(localStorage, storageKey)->Null.toOption {
    | Some(value) => value->tokenFromString
    | None => None
    }
  } catch {
  | _ => None
  }

let decodeCookieValue = value =>
  try {
    value->decodeURIComponent->tokenFromString
  } catch {
  | _ => value->tokenFromString
  }

let loadFromCookie = () =>
  try {
    documentCookie(DomGlobal.document)
    ->String.split(";")
    ->Array.findMap(segment => {
      let cookie = segment->String.trim
      let prefix = cookieKey ++ "="
      if cookie->String.startsWith(prefix) {
        cookie
        ->String.slice(~start=prefix->String.length, ~end=cookie->String.length)
        ->decodeCookieValue
      } else {
        None
      }
    })
  } catch {
  | _ => None
  }

let saveLocalStorage = token =>
  try {
    Storage.setItem(localStorage, ~key=storageKey, ~value=token)
  } catch {
  | _ => ()
  }

let saveCookie = token =>
  try {
    // TODO(auth-production): Set this as Secure and server-managed once Vibespace
    // has real HTTPS auth. This frontend-readable cookie is local-MVP recovery.
    setDocumentCookie(
      DomGlobal.document,
      cookieKey ++
      "=" ++
      token->encodeURIComponent ++
      "; Path=/; Max-Age=" ++
      cookieMaxAgeSeconds->Int.toString ++
      "; SameSite=Lax",
    )
  } catch {
  | _ => ()
  }

let load = () =>
  switch loadFromLocalStorage() {
  | Some(token) => Some(token)
  | None =>
    switch loadFromCookie() {
    | Some(token) =>
      saveLocalStorage(token)
      Some(token)
    | None => None
    }
  }

let save = token =>
  switch token->tokenFromString {
  | Some(token) =>
    saveLocalStorage(token)
    saveCookie(token)
  | None => ()
  }
