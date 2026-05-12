@module("./TamboChat.jsx") @react.component
external make: (
  ~enabled: bool,
  ~documentHtml: string,
  ~documentCss: string,
  ~selectedId: string,
  ~selectedSelector: string,
  ~selectedText: string,
) => React.element = "default"
