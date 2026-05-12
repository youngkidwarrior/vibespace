@module("./BrowserBridge.js") external eventTargetValue: ReactEvent.Form.t => string = "eventTargetValue"
@module("./BrowserBridge.js") external addSelectionListener: (Selection.t => unit) => unit => unit = "addSelectionListener"
