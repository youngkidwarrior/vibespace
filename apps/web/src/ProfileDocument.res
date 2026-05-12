type t = {
  html: HtmlSource.t,
  css: CssSource.t,
  revisionId: RevisionId.t,
}

let make = (~html: HtmlSource.t, ~css: CssSource.t): t => {
  html,
  css,
  revisionId: RevisionId.initial,
}

let html = document => document.html
let css = document => document.css
let htmlString = document => document.html->HtmlSource.toString
let cssString = document => document.css->CssSource.toString
let revisionString = document => document.revisionId->RevisionId.toString

let updateHtml = (document: t, html: HtmlSource.t): t => {
  ...document,
  html,
  revisionId: document.revisionId->RevisionId.next,
}

let updateHtmlFromString = (document: t, html: string): t =>
  updateHtml(document, HtmlSource.make(html))

let updateCss = (document: t, css: CssSource.t): t => {
  ...document,
  css,
  revisionId: document.revisionId->RevisionId.next,
}

let updateCssFromString = (document: t, css: string): t =>
  updateCss(document, CssSource.make(css))

let replace = (document: t, html: HtmlSource.t, css: CssSource.t): t => {
  html,
  css,
  revisionId: document.revisionId->RevisionId.next,
}
