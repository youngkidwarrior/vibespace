type validationError

type result =
  | Valid
  | Invalid(validationError)

let validate: (HtmlSource.t, CssSource.t) => promise<result>
let repairHtml: HtmlSource.t => promise<HtmlSource.t>
let message: validationError => string
let blockedHtml: string => HtmlSource.t
let blockedCss: CssSource.t
