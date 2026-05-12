@genType
type resolvedItem = {
  @live title: string,
  @live description: string,
  @live canonicalUrl: string,
  @live provider: string,
  @live itemType: string,
}

@genType
type safeFrame = {
  @live origin: string,
  @live title: string,
  @live canonicalUrl: string,
  @live frameUrl: string,
  @live frameKind: string,
  @live autoplaySupported: bool,
}

@genType
type safeEmbed = {
  @live provider: string,
  @live title: string,
  @live canonicalUrl: string,
  @live embedUrl: string,
  @live embedKind: string,
  @live autoplaySupported: bool,
}

@genType
type safeImage = {
  @live origin: string,
  @live title: string,
  @live source: string,
  @live creator: string,
  @live license: string,
  @live licenseUrl: string,
  @live imageUrl: string,
  @live canonicalUrl: string,
  @live altText: string,
  @live subjectTags: array<string>,
  @live visualCues: array<string>,
}

@genType
type fact = {
  @live label: string,
  @live value: string,
  @live sourceUrl: string,
}

@genType
type citation = {
  @live title: string,
  @live url: string,
}

@genType
type webContext = {
  @live status: string,
  @live intentKind: string,
  @live summary: string,
  @live resolvedItems: array<resolvedItem>,
  @live safeFrames: array<safeFrame>,
  @live safeEmbeds: array<safeEmbed>,
  @live safeImages: array<safeImage>,
  @live facts: array<fact>,
  @live warnings: array<string>,
  @live citations: array<citation>,
}

let emptyWebContext: (Nullable.t<string>, Nullable.t<string>) => webContext
let sanitizeWebContext: JSON.t => webContext
let capabilityPolicyForPrompt: unit => string
