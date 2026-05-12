type t = {
  html: string,
  css: string,
  revisionId: int,
  updatedAt: string,
}

let make = (~html: string, ~css: string, ~updatedAt: string): t => {
  html,
  css,
  revisionId: 1,
  updatedAt,
}

let updateHtml = (document: t, html: string, updatedAt: string): t => {
  ...document,
  html,
  revisionId: document.revisionId + 1,
  updatedAt,
}

let updateCss = (document: t, css: string, updatedAt: string): t => {
  ...document,
  css,
  revisionId: document.revisionId + 1,
  updatedAt,
}

let replace = (document: t, html: string, css: string, updatedAt: string): t => {
  html,
  css,
  revisionId: document.revisionId + 1,
  updatedAt,
}
