type validationError

type svgTrustSummary = {
  knownCount: int,
  unknownCount: int,
}

type result =
  | Valid
  | Invalid(validationError)

let validate: (HtmlSource.t, CssSource.t) => promise<result>
let repairHtml: HtmlSource.t => promise<HtmlSource.t>
let svgTrust: HtmlSource.t => svgTrustSummary
let message: validationError => string
let blockedHtml: string => HtmlSource.t
let blockedCss: CssSource.t
