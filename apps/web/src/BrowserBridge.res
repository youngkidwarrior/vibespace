type frameViewport = {
  scrollX: float,
  scrollY: float,
  viewportWidth: float,
  viewportHeight: float,
}

type trustedPlayerFrame = {
  key: string,
  source: string,
  title: string,
  x: float,
  y: float,
  width: float,
  height: float,
}

@module("./BrowserBridge.js") external attachSelectionBridgeRaw: (ReactEvent.Image.t, string, bool, ProfileSelection.payload => unit) => unit = "attachSelectionBridge"
@module("./BrowserBridge.js") external debugPrompt: (string, string) => unit = "debugPrompt"
@module("./BrowserBridge.js") external attachProfileLinkRouter: (
  ReactEvent.Image.t,
  string => unit,
) => unit = "attachProfileLinkRouter"
@module("./BrowserBridge.js") external attachFrameViewportListener: (
  ReactEvent.Image.t,
  frameViewport => unit,
) => unit = "attachFrameViewportListener"
@module("./BrowserBridge.js") external attachTrustedPlayerLayer: (
  ReactEvent.Image.t,
  array<trustedPlayerFrame> => unit,
) => unit = "attachTrustedPlayerLayer"

@get external eventTarget: ReactEvent.Form.t => {..} = "target"
@get external targetValue: {..} => string = "value"

let eventTargetValue = event => event->eventTarget->targetValue

let selectedIdToString = selectedId =>
  switch selectedId {
  | Some(id) => id->ProfileElementId.toString
  | None => ""
  }

let attachSelectionBridge = (event, selectedId, editMode, callback) =>
  attachSelectionBridgeRaw(event, selectedId->selectedIdToString, editMode, callback)
