type validationError = UnsafeProfileSource(string)

type svgTrustSummary = {
  knownCount: int,
  unknownCount: int,
}

type result =
  | Valid
  | Invalid(validationError)

@module("./ProfileValidationCompiler.js")
external validateHtmlSource: string => promise<string> = "validateHtmlSource"

@module("./ProfileValidationCompiler.js")
external validateCssSource: string => promise<string> = "validateCssSource"

@module("./ProfileValidationCompiler.js")
external repairHtmlSource: string => promise<string> = "repairHtmlSource"

@module("./ProfileValidationCompiler.js")
external inspectSvgTrust: string => svgTrustSummary = "inspectSvgTrust"

let maxDocumentLength = 200000

let validateStrings = async (html, css) => {
  let nextHtml = html
  let nextCss = css

  if nextHtml->String.trim == "" {
    Invalid(UnsafeProfileSource("Profile content cannot be empty."))
  } else if nextCss->String.trim == "" {
    Invalid(UnsafeProfileSource("Profile look cannot be empty."))
  } else if nextHtml->String.length > maxDocumentLength || nextCss->String.length > maxDocumentLength {
    Invalid(UnsafeProfileSource("This profile is too large for the local prototype."))
  } else {
    switch await nextHtml->validateHtmlSource {
    | message if message != "" => Invalid(UnsafeProfileSource(message))
    | _ =>
      switch WebCapabilities.validateWebCapabilityPlaceholders(nextHtml) {
      | "" =>
        switch await nextCss->validateCssSource {
        | message if message != "" => Invalid(UnsafeProfileSource(message))
        | _ => Valid
        }
      | message => Invalid(UnsafeProfileSource(message))
      }
    }
  }
}

let validate = (html: HtmlSource.t, css: CssSource.t) =>
  validateStrings(html->HtmlSource.toString, css->CssSource.toString)

let repairHtml = async (html: HtmlSource.t) => {
  let repairedHtml = await html->HtmlSource.toString->repairHtmlSource
  repairedHtml->HtmlSource.make
}

let svgTrust = (html: HtmlSource.t) => html->HtmlSource.toString->inspectSvgTrust

let message = error =>
  switch error {
  | UnsafeProfileSource(message) => message
  }

let escapeHtml = value =>
  value
  ->String.replaceAll("&", "&amp;")
  ->String.replaceAll("<", "&lt;")
  ->String.replaceAll(">", "&gt;")
  ->String.replaceAll("\"", "&quot;")
  ->String.replaceAll("'", "&#39;")

let blockedHtml = message =>
  HtmlSource.make("<main class=\"blocked-profile-preview\" data-vibespace-id=\"profile-root\">\n" ++
  "  <section class=\"blocked-profile-card\" data-vibespace-id=\"validation-message\">\n" ++
  "    <p>Profile paused</p>\n" ++
  "    <h1>This profile needs a quick fix</h1>\n" ++
  "    <p>" ++ message->escapeHtml ++ "</p>\n" ++
  "  </section>\n" ++
  "</main>")

let blockedCss =
  CssSource.make(":root { color-scheme: light; }\n" ++
  "body { margin: 0; font-family: Inter, ui-sans-serif, system-ui, sans-serif; background: #f7f3ea; color: #161616; }\n" ++
  ".blocked-profile-preview { min-height: 100vh; display: grid; place-items: center; padding: 32px; }\n" ++
  ".blocked-profile-card { max-width: 520px; border: 1px solid #161616; background: white; padding: 24px; box-shadow: 8px 8px 0 #d8d0c3; }\n" ++
  ".blocked-profile-card p { margin: 0 0 10px; line-height: 1.5; }\n" ++
  ".blocked-profile-card h1 { margin: 0 0 12px; font-size: 32px; letter-spacing: 0; }\n")
