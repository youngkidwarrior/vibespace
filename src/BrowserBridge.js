export function eventTargetValue(event) {
  return event?.target?.value ?? "";
}

export function addSelectionListener(callback) {
  function handler(event) {
    if (event?.data?.type !== "vibespace:selected") return;
    const payload = event.data.payload || {};
    callback({
      id: String(payload.id || ""),
      tagName: String(payload.tagName || ""),
      text: String(payload.text || ""),
      className: String(payload.className || ""),
      selector: String(payload.selector || ""),
    });
  }

  window.addEventListener("message", handler);
  return () => window.removeEventListener("message", handler);
}
