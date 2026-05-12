type trustedFrameConfig = {
  origin: string,
  defaultHeight: string,
}

type frameMatch = {
  url: UrlTypes.url,
  origin: string,
  config: trustedFrameConfig,
}

let trustedFrameRegistry = [
  {
    origin: "https://open.spotify.com",
    defaultHeight: "152",
  },
  {
    origin: "https://www.youtube.com",
    defaultHeight: "315",
  },
  {
    origin: "https://www.youtube-nocookie.com",
    defaultHeight: "315",
  },
  {
    origin: "https://w.soundcloud.com",
    defaultHeight: "166",
  },
  {
    origin: "https://player.vimeo.com",
    defaultHeight: "315",
  },
  {
    origin: "https://embed.music.apple.com",
    defaultHeight: "175",
  },
]

let trustedFrameOrigins = trustedFrameRegistry->Array.map(entry => entry.origin)

let trustedImageOrigins = [
  "https://images.unsplash.com",
  "https://plus.unsplash.com",
  "https://upload.wikimedia.org",
]

let trustedFrameCspSourceList = trustedFrameOrigins->Array.join(" ")
let trustedImageCspSourceList = trustedImageOrigins->Array.join(" ")

let dangerousExtensions = RegExp.fromString(
  "\\.(apk|app|bat|cmd|com|dmg|exe|iso|jar|js|msi|pkg|ps1|rar|scr|sh|torrent|vbs|wsf|zip|7z)(?:$|[?#])",
  ~flags="i",
)

let isIpAddress = hostname => {
  RegExp.fromString("^(\\d{1,3}\\.){3}\\d{1,3}$")->RegExp.test(hostname) ||
    hostname->String.includes(":")
}

let isPrivateHostname = hostname => {
  let host = hostname->String.toLowerCase
  if host == "localhost" || host->String.endsWith(".localhost") || host->String.endsWith(".local") {
    true
  } else {
    switch RegExp.fromString("^(\\d{1,3})\\.(\\d{1,3})\\.(\\d{1,3})\\.(\\d{1,3})$")->RegExp.exec(host) {
    | None => host->isIpAddress
    | Some(result) =>
      switch result->RegExp.Result.matches->Array.keepSome {
      | [firstText, secondText, _, _] =>
        let first = firstText->Int.fromString->Option.getOr(-1)
        let second = secondText->Int.fromString->Option.getOr(-1)
        first == 10 ||
          first == 127 ||
          first == 0 ||
          (first == 169 && second == 254) ||
          (first == 172 && second >= 16 && second <= 31) ||
          (first == 192 && second == 168)
      | _ => host->isIpAddress
      }
    }
  }
}

let parseSafeHttpUrlValue = value =>
  try {
    let url = URL.make(~url=value->String.trim)
    if url.protocol != "https:" ||
      url.username != "" ||
      url.password != "" ||
      url.hostname->isPrivateHostname ||
      dangerousExtensions->RegExp.test(url.pathname) {
      None
    } else {
      Some(url)
    }
  } catch {
  | _ => None
  }

let isSafeReferenceUrlValue = value =>
  switch value->parseSafeHttpUrlValue {
  | Some(_) => true
  | None => false
  }

let normalizeTrustedOrigin = value =>
  try {
    let url = URL.make(~url=value->String.trim)
    url.protocol == "https:" ? url.origin : ""
  } catch {
  | _ => ""
  }

let trustedFrameConfigForOrigin = origin => {
  let normalizedOrigin = origin->normalizeTrustedOrigin
  if normalizedOrigin == "" {
    None
  } else {
    trustedFrameRegistry->Array.find(entry => entry.origin == normalizedOrigin)
  }
}

let trustedFrameUrlMatchesProvider = (origin, url: UrlTypes.url) =>
  switch origin {
  | "https://open.spotify.com" => url.pathname->String.startsWith("/embed/")
  | "https://www.youtube.com" | "https://www.youtube-nocookie.com" =>
    url.pathname->String.startsWith("/embed/")
  | "https://w.soundcloud.com" => url.pathname->String.startsWith("/player/")
  | "https://player.vimeo.com" => url.pathname->String.startsWith("/video/")
  | _ => true
  }

let trustedImageOriginMatch = origin => trustedImageOrigins->Array.includes(origin)

let trustedFrameMatchValue = (value, expectedOrigin) =>
  switch value->parseSafeHttpUrlValue {
  | None => None
  | Some(url) =>
    let origin = url.origin
    let expectedOriginText = expectedOrigin->String.trim
    let normalizedExpectedOrigin = expectedOriginText == "" ? "" : expectedOriginText->normalizeTrustedOrigin
    if expectedOriginText != "" && normalizedExpectedOrigin != expectedOriginText {
      None
    } else if expectedOriginText != "" && normalizedExpectedOrigin != origin {
      None
    } else {
      switch origin->trustedFrameConfigForOrigin {
      | Some(config) =>
        origin->trustedFrameUrlMatchesProvider(url) ? Some({url, origin, config}) : None
      | None => None
      }
    }
  }

let trustedImageMatchValue = (value, expectedOrigin) =>
  switch value->parseSafeHttpUrlValue {
  | None => None
  | Some(url) =>
    let origin = url.origin
    let expectedOriginText = expectedOrigin->String.trim
    let normalizedExpectedOrigin = expectedOriginText == "" ? "" : expectedOriginText->normalizeTrustedOrigin
    if expectedOriginText != "" && normalizedExpectedOrigin != expectedOriginText {
      None
    } else if expectedOriginText != "" && normalizedExpectedOrigin != origin {
      None
    } else if origin->trustedImageOriginMatch {
      Some((url, origin))
    } else {
      None
    }
  }
