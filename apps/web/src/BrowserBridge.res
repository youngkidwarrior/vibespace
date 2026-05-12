type frameViewport = {
  scrollX: float,
  scrollY: float,
  viewportWidth: float,
  viewportHeight: float,
}

@module("./BrowserBridge.js") external attachSelectionBridgeRaw: (ReactEvent.Image.t, string, bool, ProfileSelection.payload => unit) => unit = "attachSelectionBridge"
@module("./BrowserBridge.js") external debugPrompt: (string, string) => unit = "debugPrompt"
@module("./BrowserBridge.js") external replaceAddressUrl: string => unit = "replaceAddressUrl"
@module("./BrowserBridge.js") external attachFrameViewportListener: (
  ReactEvent.Image.t,
  frameViewport => unit,
) => unit = "attachFrameViewportListener"

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
