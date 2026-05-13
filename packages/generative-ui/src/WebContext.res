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

let validStatuses = ["not_needed", "resolved", "not_found", "blocked"]

let validIntentKinds = [
  "none",
  "media",
  "product",
  "place",
  "person",
  "event",
  "brand",
  "book",
  "movie",
  "artwork",
  "social",
  "reference",
  "unsafe",
]

let nullableString = (value: Nullable.t<string>) => value->Nullable.getOr("")

let nullableStringWithDefault = (value: Nullable.t<string>, defaultValue) => {
  let text = value->nullableString->String.trim
  text == "" ? defaultValue : text
}

let sanitizeTextValue = (~maxLength: int, value) =>
  value
  ->String.replaceAllRegExp(RegExp.fromString("[\\u0000-\\u001f\\u007f]", ~flags="g"), " ")
  ->String.replaceAllRegExp(RegExp.fromString("[<>]", ~flags="g"), "")
  ->String.replaceAllRegExp(RegExp.fromString("\\s+", ~flags="g"), " ")
  ->String.trim
  ->String.slice(~start=0, ~end=maxLength)

let emptyWebContext = (
  statusValue: Nullable.t<string>,
  warningValue: Nullable.t<string>,
): webContext => {
  let status = statusValue->nullableStringWithDefault("not_needed")
  let warning = warningValue->nullableString
  {
    status,
    intentKind: status == "blocked" ? "unsafe" : "none",
    summary: "",
    resolvedItems: [],
    safeFrames: [],
    safeEmbeds: [],
    safeImages: [],
    facts: [],
    warnings: warning == "" ? [] : [warning],
    citations: [],
  }
}

let jsonObject = value => value->JSON.Decode.object
let field = (object, name) => object->Dict.get(name)

let fieldString = (object, name) =>
  object->field(name)->Option.flatMap(JSON.Decode.string)->Option.getOr("")

let fieldBool = (object, name) =>
  object->field(name)->Option.flatMap(JSON.Decode.bool)->Option.getOr(false)

let fieldArray = (object, name) => object->field(name)->Option.flatMap(JSON.Decode.array)

let sanitizeArray = (value, mapItem, maxItems) =>
  switch value {
  | Some(items) => items->Array.filterMap(mapItem)->Array.slice(~start=0, ~end=maxItems)
  | None => []
  }

let fieldStringArray = (object, name, maxItems) =>
  object
  ->fieldArray(name)
  ->sanitizeArray(
    item =>
      item
      ->JSON.Decode.string
      ->Option.map(value => sanitizeTextValue(~maxLength=80, value)),
    maxItems,
  )
  ->Array.filter(value => value != "")

let isSafeReferenceUrlValue = WebCapabilityPolicy.isSafeReferenceUrlValue
let trustedFrameMatchValue = WebCapabilityPolicy.trustedFrameMatchValue
let trustedImageMatchValue = WebCapabilityPolicy.trustedImageMatchValue

let sanitizeSafeFrameItem = item =>
  switch item->jsonObject {
  | None => None
  | Some(object) =>
    let frameUrl = {
      let src = object->fieldString("frameUrl")->String.trim
      src == "" ? object->fieldString("embedUrl")->String.trim : src
    }
    let explicitOrigin = object->fieldString("origin")->String.trim
    switch trustedFrameMatchValue(frameUrl, explicitOrigin) {
    | None => None
    | Some(match) =>
      let canonicalUrl = object->fieldString("canonicalUrl")->String.trim
      Some({
        origin: match.origin,
        title: sanitizeTextValue(~maxLength=160, object->fieldString("title")),
        canonicalUrl: canonicalUrl->isSafeReferenceUrlValue ? canonicalUrl : "",
        frameUrl,
        frameKind: {
          let frameKind = object->fieldString("frameKind")
          let embedKind = object->fieldString("embedKind")
          let rawFrameKind = frameKind != "" ? frameKind : embedKind != "" ? embedKind : "trusted_frame"
          sanitizeTextValue(~maxLength=80, rawFrameKind)
        },
        autoplaySupported: object->fieldBool("autoplaySupported"),
      })
    }
  }

let dedupeSafeFrames = items => {
  let seen = ref([])
  let frames = ref([])

  items->Array.forEach(item => {
    if !(seen.contents->Array.includes(item.frameUrl)) {
      seen.contents = seen.contents->Array.concat([item.frameUrl])
      frames.contents = frames.contents->Array.concat([item])
    }
  })

  frames.contents->Array.slice(~start=0, ~end=5)
}

let sanitizeSafeImageItem = item =>
  switch item->jsonObject {
  | None => None
  | Some(object) =>
    let imageUrl = object->fieldString("imageUrl")->String.trim
    let explicitOrigin = object->fieldString("origin")->String.trim
    switch trustedImageMatchValue(imageUrl, explicitOrigin) {
    | None => None
    | Some((_, origin)) =>
      let canonicalUrl = object->fieldString("canonicalUrl")->String.trim
      let licenseUrl = object->fieldString("licenseUrl")->String.trim
      let altText = sanitizeTextValue(~maxLength=220, object->fieldString("altText"))
      Some({
        origin,
        title: sanitizeTextValue(~maxLength=160, object->fieldString("title")),
        source: sanitizeTextValue(~maxLength=80, object->fieldString("source")),
        creator: sanitizeTextValue(~maxLength=120, object->fieldString("creator")),
        license: sanitizeTextValue(~maxLength=120, object->fieldString("license")),
        licenseUrl: licenseUrl->isSafeReferenceUrlValue ? licenseUrl : "",
        imageUrl,
        canonicalUrl: canonicalUrl->isSafeReferenceUrlValue ? canonicalUrl : "",
        altText,
        subjectTags: object->fieldStringArray("subjectTags", 8),
        visualCues: object->fieldStringArray("visualCues", 10),
      })
    }
  }

let dedupeSafeImages = items => {
  let seen = ref([])
  let images = ref([])

  items->Array.forEach(item => {
    if !(seen.contents->Array.includes(item.imageUrl)) {
      seen.contents = seen.contents->Array.concat([item.imageUrl])
      images.contents = images.contents->Array.concat([item])
    }
  })

  images.contents->Array.slice(~start=0, ~end=6)
}

let sanitizeWebContext = (raw: JSON.t): webContext => {
  let source = raw->jsonObject->Option.getOr(Dict.make())
  let status = ref(
    validStatuses->Array.includes(source->fieldString("status"))
      ? source->fieldString("status")
      : "not_found",
  )
  let intentKind = validIntentKinds->Array.includes(source->fieldString("intentKind"))
    ? source->fieldString("intentKind")
    : "reference"
  let warnings = source->fieldArray("warnings")->sanitizeArray(
    item =>
      item
      ->JSON.Decode.string
      ->Option.map(value => sanitizeTextValue(~maxLength=260, value)),
    8,
  )
  let droppedFrameCount = ref(0)
  let droppedImageCount = ref(0)

  let mapSafeFrameCandidate = item => {
    let candidate = sanitizeSafeFrameItem(item)
    switch candidate {
    | Some(_) => ()
    | None =>
      switch item->jsonObject {
      | Some(object)
        if object->fieldString("frameUrl") != "" ||
          object->fieldString("embedUrl") != "" ||
          object->fieldString("origin") != "" =>
        droppedFrameCount.contents = droppedFrameCount.contents + 1
      | _ => ()
      }
    }
    candidate
  }

  let mapSafeImageCandidate = item => {
    let candidate = sanitizeSafeImageItem(item)
    switch candidate {
    | Some(_) => ()
    | None =>
      switch item->jsonObject {
      | Some(object)
        if object->fieldString("imageUrl") != "" || object->fieldString("origin") != "" =>
        droppedImageCount.contents = droppedImageCount.contents + 1
      | _ => ()
      }
    }
    candidate
  }

  let safeFrames =
    source
    ->fieldArray("safeFrames")
    ->sanitizeArray(mapSafeFrameCandidate, 5)
    ->Array.concat(source->fieldArray("safeEmbeds")->sanitizeArray(mapSafeFrameCandidate, 5))
    ->dedupeSafeFrames

  let safeEmbeds = safeFrames->Array.map(frame => {
    provider: frame.origin,
    title: frame.title,
    canonicalUrl: frame.canonicalUrl,
    embedUrl: frame.frameUrl,
    embedKind: frame.frameKind,
    autoplaySupported: frame.autoplaySupported,
  })

  let safeImages =
    source
    ->fieldArray("safeImages")
    ->sanitizeArray(mapSafeImageCandidate, 8)
    ->dedupeSafeImages

  let resolvedItems =
    source
    ->fieldArray("resolvedItems")
    ->sanitizeArray(item =>
      switch item->jsonObject {
      | None => None
      | Some(object) =>
        let canonicalUrl = object->fieldString("canonicalUrl")->String.trim
        Some({
          title: sanitizeTextValue(~maxLength=160, object->fieldString("title")),
          description: sanitizeTextValue(~maxLength=300, object->fieldString("description")),
          canonicalUrl: canonicalUrl->isSafeReferenceUrlValue ? canonicalUrl : "",
          provider: sanitizeTextValue(~maxLength=80, object->fieldString("provider")),
          itemType: sanitizeTextValue(~maxLength=80, object->fieldString("itemType")),
        })
      },
      8,
    )
    ->Array.filter(item => item.title != "" || item.description != "" || item.canonicalUrl != "")

  let facts =
    source
    ->fieldArray("facts")
    ->sanitizeArray(item =>
      switch item->jsonObject {
      | None => None
      | Some(object) =>
        let sourceUrl = object->fieldString("sourceUrl")->String.trim
        Some({
          label: sanitizeTextValue(~maxLength=80, object->fieldString("label")),
          value: sanitizeTextValue(~maxLength=260, object->fieldString("value")),
          sourceUrl: sourceUrl->isSafeReferenceUrlValue ? sourceUrl : "",
        })
      },
      12,
    )
    ->Array.filter(item => item.label != "" && item.value != "")

  let citations =
    source
    ->fieldArray("citations")
    ->sanitizeArray(item =>
      switch item->jsonObject {
      | None => None
      | Some(object) =>
        let url = object->fieldString("url")->String.trim
        url->isSafeReferenceUrlValue
          ? Some({
              title: sanitizeTextValue(~maxLength=160, object->fieldString("title")),
              url,
            })
          : None
      },
      8,
    )

  if status.contents == "resolved" &&
    safeFrames->Array.length == 0 &&
    safeImages->Array.length == 0 &&
    resolvedItems->Array.length == 0 &&
    facts->Array.length == 0 {
    status.contents = "not_found"
    warnings->Array.push("Web lookup did not produce a safe usable result.")
  }

  if status.contents == "resolved" &&
    intentKind == "media" &&
    safeFrames->Array.length == 0 &&
    safeImages->Array.length == 0 {
    status.contents = "not_found"
    warnings->Array.push("Media lookup did not produce a trusted-origin frame URL.")
  }

  if droppedFrameCount.contents > 0 {
    warnings->Array.push("One or more frames were dropped because they were not HTTPS URLs from a trusted origin.")
  }

  if droppedImageCount.contents > 0 {
    warnings->Array.push("One or more images were dropped because they were not HTTPS URLs from a trusted image origin.")
  }

  {
    status: status.contents,
    intentKind,
    summary: sanitizeTextValue(~maxLength=500, source->fieldString("summary")),
    resolvedItems,
    safeFrames,
    safeEmbeds,
    safeImages,
    facts,
    warnings,
    citations,
  }
}

let capabilityPolicyForPrompt = () =>
  [
    "Raw HTML/CSS is the default. Treat trusted frames as a narrow escape hatch for explicit live external functionality requests.",
    "Use a trusted-frame placeholder only when the request needs playable media or an embedded player and web_context.safeFrames contains a matching trusted frame.",
    "Requests for ambient audio, wave sounds, ocean sounds, soundscapes, or background sounds count as playable media requests. If a matching trusted frame is available, include it as the functional sound component.",
    "For named media without explicit live intent, create a polished static profile block in plain HTML/CSS and do not use data-vibespace-capability.",
    "If the user asks for playable media, ambient audio, or a player and web_context.safeFrames has no relevant match, do not simulate working playback or write copy that says the editor can connect audio later. Add a polished static component and explain the limitation in warnings.",
    "Live frames are limited to HTTPS URLs whose origin exactly matches one of these trusted origins: " ++
    WebCapabilityPolicy.trustedFrameOrigins->Array.join(", ") ++
    ".",
    "Trusted images are limited to direct HTTPS image URLs whose origin exactly matches one of these trusted origins: " ++
    WebCapabilityPolicy.trustedImageOrigins->Array.join(", ") ++
    ".",
    "Inline SVG is allowed only for model-authored decorative/vector UI using Vibespace's safe static SVG subset. Do not fetch, link, embed, or reference remote SVG files.",
    "Do not write raw iframe, script, embed, object, audio src, video src, remote image, form, or arbitrary link markup.",
    "For a live frame, output an inert placeholder element with data-vibespace-capability=\"trusted_frame\", data-vibespace-origin, data-vibespace-src, data-vibespace-name, data-vibespace-description, and friendly fallback text.",
    "Copy data-vibespace-origin and data-vibespace-src exactly from web_context.safeFrames. Do not invent, modify, redirect, shorten, or search for URLs yourself.",
    "For a trusted image, output an inert placeholder element with data-vibespace-capability=\"trusted_image\", data-vibespace-origin, data-vibespace-src, data-vibespace-alt, data-vibespace-name, data-vibespace-description, and friendly fallback text.",
    "Copy trusted image URLs exactly from web_context.safeImages.imageUrl. Do not invent, modify, crop, resize, proxy, redirect, shorten, or search for image URLs yourself.",
    "Trusted image URLs are candidates and can fail to load. Design the surrounding frame and fallback text so the profile still feels intentional if Vibespace shows its broken-image fallback.",
    "When the selected area is a broken trusted image and the user asks to retry, replace that one image candidate and keep the rest of the profile stable unless they ask for a larger redesign.",
    "If web_context.status is blocked or not_found, create a static informative profile block and explain the limitation in warnings.",
  ]->Array.join("\n")
