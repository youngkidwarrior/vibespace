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

let viewport: (~width: float, ~height: float) => viewport
let bounds: (
  ~x: float,
  ~y: float,
  ~width: float,
  ~height: float,
  ~documentX: float,
  ~documentY: float,
) => bounds
let anchor: (
  ~x: float,
  ~y: float,
  ~documentX: float,
  ~documentY: float,
  ~width: float,
  ~height: float,
  ~viewport: viewport,
) => anchor
let anchorFromBounds: (~bounds: bounds, ~viewport: viewport) => anchor
let boundsSummary: bounds => string
