export function buildPreviewDocument(html, css, selectedId) {
  const escapedSelectedId = JSON.stringify(selectedId || "");
  return `<!doctype html>
<html>
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <style>
    ${css}
    [data-vibespace-hover="true"] { outline: 3px dashed rgba(255, 0, 110, .75) !important; outline-offset: 3px; cursor: crosshair; }
  </style>
</head>
<body>
${html}
<script>
(function () {
  var selectedId = ${escapedSelectedId};
  function describeElement(element) {
    if (!element) return null;
    var id = element.getAttribute("data-vibespace-id") || "";
    if (!id) {
      id = "auto-" + Math.random().toString(36).slice(2, 9);
      element.setAttribute("data-vibespace-id", id);
    }
    return {
      id: id,
      tagName: element.tagName.toLowerCase(),
      text: (element.textContent || "").trim().slice(0, 160),
      className: element.getAttribute("class") || "",
      selector: '[data-vibespace-id="' + id.replace(/"/g, '\\"') + '"]'
    };
  }
  function clearHover() {
    document.querySelectorAll('[data-vibespace-hover="true"]').forEach(function (node) {
      node.removeAttribute("data-vibespace-hover");
    });
  }
  function paintSelected() {
    document.querySelectorAll('[data-vibespace-selected="true"]').forEach(function (node) {
      node.removeAttribute("data-vibespace-selected");
    });
    if (!selectedId) return;
    var selected = document.querySelector('[data-vibespace-id="' + selectedId.replace(/"/g, '\\"') + '"]');
    if (selected) selected.setAttribute("data-vibespace-selected", "true");
  }
  document.addEventListener("mouseover", function (event) {
    clearHover();
    var target = event.target && event.target.closest("[data-vibespace-id]");
    if (target) target.setAttribute("data-vibespace-hover", "true");
  });
  document.addEventListener("mouseout", clearHover);
  document.addEventListener("click", function (event) {
    event.preventDefault();
    event.stopPropagation();
    var target = event.target && event.target.closest("[data-vibespace-id]");
    var detail = describeElement(target || event.target);
    window.parent.postMessage({ type: "vibespace:selected", payload: detail }, "*");
  }, true);
  paintSelected();
})();
</script>
</body>
</html>`;
}
