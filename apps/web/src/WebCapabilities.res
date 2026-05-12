type trustedFrameConfig = WebCapabilityPolicy.trustedFrameConfig
type frameMatch = WebCapabilityPolicy.frameMatch

type frameAttributes = {
  source: string,
  origin: string,
  legacy: bool,
}

type imageAttributes = {
  source: string,
  origin: string,
  altText: string,
}

type domParser

@new external makeDomParser: unit => domParser = "DOMParser"
@send external parseFromString: (domParser, string, string) => DomTypes.document = "parseFromString"
@get external innerHTML: DomTypes.element => string = "innerHTML"
@set external setInnerHTML: (DomTypes.element, string) => unit = "innerHTML"
@get external templateContent: DomTypes.element => DomTypes.documentFragment = "content"

type permissionsPolicy
type featureList = unit => array<string>

@get external permissionsPolicy: DomTypes.document => Nullable.t<permissionsPolicy> = "permissionsPolicy"
@get external featurePolicy: DomTypes.document => Nullable.t<permissionsPolicy> = "featurePolicy"
@get external featuresFunction: permissionsPolicy => Nullable.t<featureList> = "features"
@get external allowedFeaturesFunction: permissionsPolicy => Nullable.t<featureList> = "allowedFeatures"

let trustedFrameCspSourceList = WebCapabilityPolicy.trustedFrameCspSourceList
let trustedImageCspSourceList = WebCapabilityPolicy.trustedImageCspSourceList
let trustedFrameMatchValue = WebCapabilityPolicy.trustedFrameMatchValue
let trustedImageMatchValue = WebCapabilityPolicy.trustedImageMatchValue

let sanitizeTextValue = (~maxLength: int, value) =>
  value
  ->String.replaceAllRegExp(RegExp.fromString("[\\u0000-\\u001f\\u007f]", ~flags="g"), " ")
  ->String.replaceAllRegExp(RegExp.fromString("[<>]", ~flags="g"), "")
  ->String.replaceAllRegExp(RegExp.fromString("\\s+", ~flags="g"), " ")
  ->String.trim
  ->String.slice(~start=0, ~end=maxLength)

let nullString = value =>
  switch value->Null.toOption {
  | Some(value) => value
  | None => ""
  }

let capabilityFrameAttributes = (node, capability) =>
  switch capability {
  | "trusted_frame" =>
    Some({
      source: Element.getAttribute(node, "data-vibespace-src")->nullString,
      origin: Element.getAttribute(node, "data-vibespace-origin")->nullString,
      legacy: false,
    })
  | "web_embed" =>
    Some({
      source: Element.getAttribute(node, "data-vibespace-embed-src")->nullString,
      origin: "",
      legacy: true,
    })
  | _ => None
  }

let capabilityImageAttributes = (node, capability) =>
  switch capability {
  | "trusted_image" =>
    Some({
      source: Element.getAttribute(node, "data-vibespace-src")->nullString,
      origin: Element.getAttribute(node, "data-vibespace-origin")->nullString,
      altText: Element.getAttribute(node, "data-vibespace-alt")->nullString,
    })
  | _ => None
  }

let validateWebCapabilityPlaceholders = html =>
  try {
    let parsed = makeDomParser()->parseFromString(html, "text/html")
    let nodes = Document.querySelectorAll(parsed, "[data-vibespace-capability]")
    let message = ref("")

    for index in 0 to nodes.length - 1 {
      if message.contents == "" {
        let node = NodeList.item(nodes, index)
        let capability = Element.getAttribute(node, "data-vibespace-capability")->nullString

        switch capabilityFrameAttributes(node, capability) {
        | None =>
          switch capabilityImageAttributes(node, capability) {
          | None => message.contents = "Unsupported web capability \"" ++ capability ++ "\"."
          | Some(imageAttributes) =>
            let friendlyName = Element.getAttribute(node, "data-vibespace-name")
              ->nullString
              ->sanitizeTextValue(~maxLength=120)
            let friendlyDescription = Element.getAttribute(node, "data-vibespace-description")
              ->nullString
              ->sanitizeTextValue(~maxLength=220)
            let altText = imageAttributes.altText->sanitizeTextValue(~maxLength=220)

            if imageAttributes.origin->String.trim == "" {
              message.contents = "Trusted image placeholders must include data-vibespace-origin."
            } else if imageAttributes.source->String.trim == "" {
              message.contents = "Trusted image placeholders must include data-vibespace-src."
            } else if !(
              switch trustedImageMatchValue(imageAttributes.source, imageAttributes.origin) {
              | Some(_) => true
              | None => false
              }
            ) {
              message.contents = "Profile content includes an unsupported or unsafe trusted image URL."
            } else if friendlyName == "" || friendlyDescription == "" {
              message.contents = "Trusted image placeholders must include data-vibespace-name and data-vibespace-description."
            } else if altText == "" {
              message.contents = "Trusted image placeholders must include data-vibespace-alt."
            }
          }
        | Some(frameAttributes) =>
          let friendlyName = Element.getAttribute(node, "data-vibespace-name")
            ->nullString
            ->sanitizeTextValue(~maxLength=120)
          let friendlyDescription = Element.getAttribute(node, "data-vibespace-description")
            ->nullString
            ->sanitizeTextValue(~maxLength=220)

          if !frameAttributes.legacy && frameAttributes.origin->String.trim == "" {
            message.contents = "Trusted frame placeholders must include data-vibespace-origin."
          } else if frameAttributes.source->String.trim == "" {
            message.contents = frameAttributes.legacy
              ? "Legacy web embed placeholders must include data-vibespace-embed-src."
              : "Trusted frame placeholders must include data-vibespace-src."
          } else if !(
            switch trustedFrameMatchValue(frameAttributes.source, frameAttributes.origin) {
            | Some(_) => true
            | None => false
            }
          ) {
            message.contents = "Profile content includes an unsupported or unsafe trusted frame URL."
          } else if friendlyName == "" || friendlyDescription == "" {
            message.contents = "Trusted frame placeholders must include data-vibespace-name and data-vibespace-description."
          }
        }
      }
    }

    message.contents
  } catch {
  | _ => ""
  }

let classSlug = value => {
  let slug =
    value
    ->String.toLowerCase
    ->String.replaceAllRegExp(RegExp.fromString("[^a-z0-9]+", ~flags="g"), "-")
    ->String.replaceRegExp(RegExp.fromString("^-+"), "")
    ->String.replaceRegExp(RegExp.fromString("-+$"), "")
    ->String.slice(~start=0, ~end=60)
  slug == "" ? "trusted-frame" : slug
}

let supportedIframeAllowValue = features => {
  let maybePolicy = switch DomGlobal.document->permissionsPolicy->Nullable.toOption {
  | Some(policy) => Some(policy)
  | None => DomGlobal.document->featurePolicy->Nullable.toOption
  }

  let supportedFeatures = switch maybePolicy {
  | None => []
  | Some(policy) =>
    switch policy->featuresFunction->Nullable.toOption {
    | Some(listFeatures) => listFeatures()
    | None =>
      switch policy->allowedFeaturesFunction->Nullable.toOption {
      | Some(listAllowedFeatures) => listAllowedFeatures()
      | None => []
      }
    }
  }

  supportedFeatures->Array.length == 0
    ? ""
    : features->Array.filter(feature => supportedFeatures->Array.includes(feature))->Array.join("; ")
}

let webCapabilityCss = () => "
    .vibespace-trusted-frame,
    .vibespace-web-embed,
    .vibespace-trusted-image {
      display: grid;
      gap: 10px;
      max-width: 100%;
    }

    .vibespace-trusted-frame-frame,
    .vibespace-web-embed-frame {
      display: block;
      width: 100%;
      max-width: 100%;
      border: 0;
      border-radius: inherit;
      background: transparent;
    }

    .vibespace-trusted-image {
      min-width: 0;
    }

    .vibespace-trusted-image-frame {
      position: relative;
      display: grid;
      width: 100%;
      height: 100%;
      min-height: 180px;
      overflow: hidden;
      isolation: isolate;
      border-radius: inherit;
      background:
        linear-gradient(135deg, rgba(255, 255, 255, .14), rgba(255, 255, 255, .03)),
        repeating-linear-gradient(45deg, rgba(255, 255, 255, .08) 0 12px, rgba(255, 255, 255, .02) 12px 24px),
        #151515;
      color: #f8f8f2;
    }

    .vibespace-trusted-image-img,
    .vibespace-trusted-image-fallback {
      grid-area: 1 / 1;
    }

    .vibespace-trusted-image-img {
      position: relative;
      z-index: 2;
      display: block;
      width: 100%;
      max-width: 100%;
      height: 100%;
      min-height: inherit;
      object-fit: cover;
      border-radius: inherit;
      transition: opacity .16s ease;
    }

    .vibespace-trusted-image-fallback {
      z-index: 1;
      display: grid;
      align-content: center;
      gap: 8px;
      min-height: inherit;
      padding: 18px;
      background:
        radial-gradient(circle at 20% 10%, rgba(255, 255, 255, .16), transparent 34%),
        linear-gradient(135deg, rgba(22, 22, 22, .94), rgba(45, 37, 26, .92));
      color: #f8f8f2;
      text-shadow: 0 1px 1px rgba(0, 0, 0, .45);
    }

    .vibespace-trusted-image-fallback-kicker {
      width: max-content;
      max-width: 100%;
      border: 1px solid rgba(255, 255, 255, .24);
      border-radius: 999px;
      padding: 5px 9px;
      background: rgba(255, 255, 255, .08);
      font: 700 10px/1.2 ui-sans-serif, system-ui, sans-serif;
      letter-spacing: .08em;
      text-transform: uppercase;
    }

    .vibespace-trusted-image-fallback-title {
      margin: 0;
      font: 800 clamp(18px, 4vw, 28px)/1.05 ui-sans-serif, system-ui, sans-serif;
      letter-spacing: 0;
    }

    .vibespace-trusted-image-fallback-copy,
    .vibespace-trusted-image-fallback-alt,
    .vibespace-trusted-image-fallback-hint {
      max-width: 46ch;
      margin: 0;
      font: 500 13px/1.45 ui-sans-serif, system-ui, sans-serif;
      color: rgba(248, 248, 242, .78);
    }

    .vibespace-trusted-image-fallback-alt {
      color: rgba(248, 248, 242, .66);
    }

    .vibespace-trusted-image-fallback-hint {
      margin-top: 4px;
      color: rgba(255, 224, 138, .86);
    }

    .vibespace-trusted-image[data-vibespace-image-state=\"loaded\"] .vibespace-trusted-image-fallback {
      opacity: 0;
      pointer-events: none;
    }

    .vibespace-trusted-image[data-vibespace-image-state=\"broken\"] .vibespace-trusted-image-img {
      opacity: 0;
      pointer-events: none;
    }

    .vibespace-trusted-image[data-vibespace-image-state=\"broken\"] .vibespace-trusted-image-fallback,
    .vibespace-trusted-image[data-vibespace-image-state=\"loading\"] .vibespace-trusted-image-fallback {
      opacity: 1;
    }
  "

let appendClass = (node, nextClass) => {
  let existingClass = Element.getAttribute(node, "class")->nullString->String.trim
  Element.setAttribute(
    node,
    ~qualifiedName="class",
    ~value=existingClass == "" ? nextClass : existingClass ++ " " ++ nextClass,
  )
}

let expandWebCapabilityPlaceholders = html =>
  try {
    let template = Document.createElement(DomGlobal.document, "template")
    template->setInnerHTML(html)

    let nodes = DocumentFragment.querySelectorAll(
      template->templateContent,
      "[data-vibespace-capability=\"trusted_frame\"], [data-vibespace-capability=\"web_embed\"], [data-vibespace-capability=\"trusted_image\"]",
    )

    for index in 0 to nodes.length - 1 {
      let node = NodeList.item(nodes, index)
      let capability = Element.getAttribute(node, "data-vibespace-capability")->nullString

      switch capabilityFrameAttributes(node, capability) {
      | None =>
        switch capabilityImageAttributes(node, capability) {
        | None => ()
        | Some(imageAttributes) =>
          switch trustedImageMatchValue(imageAttributes.source, imageAttributes.origin) {
          | None => ()
          | Some((url, origin)) =>
            let friendlyName = Element.getAttribute(node, "data-vibespace-name")
              ->nullString
              ->sanitizeTextValue(~maxLength=120)
            let friendlyDescription = Element.getAttribute(node, "data-vibespace-description")
              ->nullString
              ->sanitizeTextValue(~maxLength=220)
            let altText = imageAttributes.altText->sanitizeTextValue(~maxLength=220)

            if friendlyName != "" && friendlyDescription != "" && altText != "" {
              let frame = Document.createElement(DomGlobal.document, "div")
              Element.setAttribute(
                frame,
                ~qualifiedName="class",
                ~value="vibespace-trusted-image-frame",
              )

              let image = Document.createElement(DomGlobal.document, "img")
              Element.setAttribute(image, ~qualifiedName="class", ~value="vibespace-trusted-image-img")
              Element.setAttribute(
                image,
                ~qualifiedName="data-vibespace-trusted-image-img",
                ~value="true",
              )
              Element.setAttribute(image, ~qualifiedName="src", ~value=url.href)
              Element.setAttribute(image, ~qualifiedName="alt", ~value=altText)
              Element.setAttribute(image, ~qualifiedName="loading", ~value="lazy")
              Element.setAttribute(image, ~qualifiedName="decoding", ~value="async")
              Element.setAttribute(image, ~qualifiedName="referrerpolicy", ~value="no-referrer")

              let fallback = Document.createElement(DomGlobal.document, "div")
              Element.setAttribute(
                fallback,
                ~qualifiedName="class",
                ~value="vibespace-trusted-image-fallback",
              )

              let fallbackKicker = Document.createElement(DomGlobal.document, "span")
              Element.setAttribute(
                fallbackKicker,
                ~qualifiedName="class",
                ~value="vibespace-trusted-image-fallback-kicker",
              )
              Element.append2(fallbackKicker, "Vibespace image")

              let fallbackTitle = Document.createElement(DomGlobal.document, "strong")
              Element.setAttribute(
                fallbackTitle,
                ~qualifiedName="class",
                ~value="vibespace-trusted-image-fallback-title",
              )
              Element.append2(fallbackTitle, friendlyName)

              let fallbackCopy = Document.createElement(DomGlobal.document, "p")
              Element.setAttribute(
                fallbackCopy,
                ~qualifiedName="class",
                ~value="vibespace-trusted-image-fallback-copy",
              )
              Element.append2(fallbackCopy, friendlyDescription)

              let fallbackAlt = Document.createElement(DomGlobal.document, "p")
              Element.setAttribute(
                fallbackAlt,
                ~qualifiedName="class",
                ~value="vibespace-trusted-image-fallback-alt",
              )
              Element.append2(fallbackAlt, altText)

              let fallbackHint = Document.createElement(DomGlobal.document, "p")
              Element.setAttribute(
                fallbackHint,
                ~qualifiedName="class",
                ~value="vibespace-trusted-image-fallback-hint",
              )
              Element.append2(fallbackHint, "Select this image and ask Vibespace to try again.")

              Element.append(fallback, fallbackKicker->Element.asNode)
              Element.append(fallback, fallbackTitle->Element.asNode)
              Element.append(fallback, fallbackCopy->Element.asNode)
              Element.append(fallback, fallbackAlt->Element.asNode)
              Element.append(fallback, fallbackHint->Element.asNode)

              Element.append(frame, fallback->Element.asNode)
              Element.append(frame, image->Element.asNode)

              appendClass(
                node,
                "vibespace-trusted-image vibespace-trusted-image--" ++ origin->classSlug,
              )
              Element.setAttribute(node, ~qualifiedName="data-vibespace-image-state", ~value="loading")
              Element.replaceChildren(node, frame->Element.asNode)
            }
          }
        }
      | Some(frameAttributes) =>
        switch trustedFrameMatchValue(frameAttributes.source, frameAttributes.origin) {
        | None => ()
        | Some(match) =>
          let friendlyName = Element.getAttribute(node, "data-vibespace-name")
            ->nullString
            ->sanitizeTextValue(~maxLength=120)
          let friendlyDescription = Element.getAttribute(node, "data-vibespace-description")
            ->nullString
            ->sanitizeTextValue(~maxLength=220)

          if friendlyName != "" && friendlyDescription != "" {
            let iframe = Document.createElement(DomGlobal.document, "iframe")
            Element.setAttribute(
              iframe,
              ~qualifiedName="class",
              ~value="vibespace-trusted-frame-frame vibespace-web-embed-frame",
            )
            Element.setAttribute(iframe, ~qualifiedName="src", ~value=match.url.href)
            Element.setAttribute(iframe, ~qualifiedName="title", ~value=friendlyName)
            Element.setAttribute(iframe, ~qualifiedName="height", ~value=match.config.defaultHeight)
            Element.setAttribute(iframe, ~qualifiedName="loading", ~value="lazy")
            Element.setAttribute(
              iframe,
              ~qualifiedName="referrerpolicy",
              ~value="strict-origin-when-cross-origin",
            )
            Element.setAttribute(iframe, ~qualifiedName="allowfullscreen", ~value="")

            let allowValue = supportedIframeAllowValue([
              "autoplay",
              "encrypted-media",
              "fullscreen",
              "picture-in-picture",
            ])
            if allowValue != "" {
              Element.setAttribute(iframe, ~qualifiedName="allow", ~value=allowValue)
            }

            appendClass(
              node,
              "vibespace-trusted-frame vibespace-web-embed vibespace-trusted-frame--" ++
              match.origin->classSlug,
            )
            Element.replaceChildren(node, iframe->Element.asNode)
          }
        }
      }
    }

    template->innerHTML
  } catch {
  | _ => html
  }
