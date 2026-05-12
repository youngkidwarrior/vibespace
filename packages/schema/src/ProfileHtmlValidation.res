@module("./ProfileHtmlValidation.js")
external validateProfileDocument: (string, string) => promise<string> = "validateProfileDocument"

type result =
  | Valid
  | Invalid(string)

let validateDocument = async (~html, ~css) => {
  switch await validateProfileDocument(html, css) {
  | "" => Valid
  | message => Invalid(message)
  }
}
