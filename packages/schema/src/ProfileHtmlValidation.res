@module("./ProfileHtmlValidation.js")
external validateProfileDocument: (string, string) => promise<string> = "validateProfileDocument"

@module("./ProfileHtmlValidation.js")
external validateManualProfileDocument: (string, string) => promise<string> = "validateManualProfileDocument"

type result =
  | Valid
  | Invalid(string)

let validateDocument = async (~html, ~css) => {
  switch await validateProfileDocument(html, css) {
  | "" => Valid
  | message => Invalid(message)
  }
}

let validateManualDocument = async (~html, ~css) => {
  switch await validateManualProfileDocument(html, css) {
  | "" => Valid
  | message => Invalid(message)
  }
}
