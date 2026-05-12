type trustedFrameConfig = {
  origin: string,
  defaultHeight: string,
}

type frameMatch = {
  url: UrlTypes.url,
  origin: string,
  config: trustedFrameConfig,
}

let trustedFrameOrigins: array<string>
let trustedImageOrigins: array<string>
let trustedFrameCspSourceList: string
let trustedImageCspSourceList: string
let isSafeReferenceUrlValue: string => bool
let trustedFrameMatchValue: (string, string) => option<frameMatch>
let trustedImageMatchValue: (string, string) => option<(UrlTypes.url, string)>
