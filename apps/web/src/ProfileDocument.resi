type t

let make: (~html: HtmlSource.t, ~css: CssSource.t) => t
let html: t => HtmlSource.t
let css: t => CssSource.t
let htmlString: t => string
let cssString: t => string
let revisionString: t => string
let updateHtmlFromString: (t, string) => t
let updateCssFromString: (t, string) => t
let replace: (t, HtmlSource.t, CssSource.t) => t
