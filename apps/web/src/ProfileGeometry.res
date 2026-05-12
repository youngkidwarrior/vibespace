type size = {
  width: float,
  height: float,
}

type viewport = size

type clientPoint = {
  x: float,
  y: float,
}

type documentPoint = {
  x: float,
  y: float,
}

type bounds = {
  client: clientPoint,
  document: documentPoint,
  size: size,
  x: float,
  y: float,
  width: float,
  height: float,
  documentX: float,
  documentY: float,
}

type anchor = {
  client: clientPoint,
  document: documentPoint,
  size: size,
  x: float,
  y: float,
  width: float,
  height: float,
  viewport: viewport,
}

let nonNegative = value => value < 0.0 ? 0.0 : value

let size = (~width, ~height): size => {
  width: width->nonNegative,
  height: height->nonNegative,
}

let viewport = size

let clientPoint = (~x, ~y): clientPoint => {x, y}
let documentPoint = (~x, ~y): documentPoint => {x, y}

let bounds = (~x, ~y, ~width, ~height, ~documentX, ~documentY) => {
  let size = size(~width, ~height)
  let client = clientPoint(~x, ~y)
  let document = documentPoint(~x=documentX, ~y=documentY)
  {
    client,
    document,
    size,
    x: client.x,
    y: client.y,
    width: size.width,
    height: size.height,
    documentX: document.x,
    documentY: document.y,
  }
}

let anchor = (~x, ~y, ~documentX, ~documentY, ~width, ~height, ~viewport) => {
  let size = size(~width, ~height)
  let client = clientPoint(~x, ~y)
  let document = documentPoint(~x=documentX, ~y=documentY)
  {
    client,
    document,
    size,
    x: client.x,
    y: client.y,
    width: size.width,
    height: size.height,
    viewport,
  }
}

let anchorFromBounds = (~bounds: bounds, ~viewport) =>
  anchor(
    ~x=bounds.client.x,
    ~y=bounds.client.y,
    ~documentX=bounds.document.x,
    ~documentY=bounds.document.y,
    ~width=bounds.size.width,
    ~height=bounds.size.height,
    ~viewport,
  )

let boundsSummary = (bounds: bounds) =>
  "x=" ++ bounds.client.x->Float.toString ++
  ", y=" ++ bounds.client.y->Float.toString ++
  ", width=" ++ bounds.size.width->Float.toString ++
  ", height=" ++ bounds.size.height->Float.toString
