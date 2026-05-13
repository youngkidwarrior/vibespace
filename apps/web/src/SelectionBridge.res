type webRect = {
  x: float,
  y: float,
  width: float,
  height: float,
  documentX: float,
  documentY: float,
}

type draftStart = {
  x: float,
  y: float,
  target: DomTypes.element,
}

type selectionEntry = {
  context: ProfileSelection.elementContext,
  overlapArea: float,
}

let metadataEdgeBufferPx = 20.0
let maxSelectedMetadataElements = 60
let selectionCounter = ref(0)

@send external elementFromPoint: (DomTypes.document, float, float) => Null.t<DomTypes.element> = "elementFromPoint"
external eventTargetToElement: EventTypes.eventTarget => DomTypes.element = "%identity"
external elementToHtmlElement: DomTypes.element => DomTypes.htmlElement = "%identity"
@val @scope("Date") external now: unit => float = "now"
@val @scope("Math") external random: unit => float = "random"

let nextRequestId = () => {
  selectionCounter.contents = selectionCounter.contents + 1
  RequestId.unsafeFromString(
    "selection-" ++ now()->Float.toString ++ "-" ++ selectionCounter.contents->Int.toString,
  )
}

let nullString = value =>
  switch value->Null.toOption {
  | Some(value) => value
  | None => ""
  }

let minFloat = (first, second) => first < second ? first : second
let maxFloat = (first, second) => first > second ? first : second
let absFloat = value => value < 0.0 ? 0.0 -. value : value

let viewport = (frameWindow: DomTypes.window): ProfileSelection.viewport => {
  ProfileGeometry.viewport(
    ~width=frameWindow->Window.innerWidth->Int.toFloat,
    ~height=frameWindow->Window.innerHeight->Int.toFloat,
  )
}

let rectForElement = (frameWindow: DomTypes.window, element: DomTypes.element): ProfileSelection.bounds => {
  let rect = Element.getBoundingClientRect(element)
  ProfileGeometry.bounds(
    ~x=rect.left,
    ~y=rect.top,
    ~width=rect.width,
    ~height=rect.height,
    ~documentX=rect.left + frameWindow->Window.scrollX,
    ~documentY=rect.top + frameWindow->Window.scrollY,
  )
}

let textForElement = (element: DomTypes.element) => {
  let text = element->Element.asNode
  text.textContent->nullString->String.trim
}

let closestVibespaceElement = (element: DomTypes.element): option<DomTypes.element> =>
  try {
    Element.closest(element, "[data-vibespace-id]")->Null.toOption
  } catch {
  | _ => None
  }

let describeElement = (
  frameWindow: DomTypes.window,
  element: DomTypes.element,
  ~autoId,
): option<ProfileSelection.elementContext> => {
  let rawId = Element.getAttribute(element, "data-vibespace-id")->nullString
  let maybeId = switch ProfileElementId.make(rawId) {
  | Some(id) => Some(id)
  | None =>
    if autoId {
      let generatedId = ProfileElementId.unsafeFromString("auto-" ++ random()->Float.toString)
      Element.setAttribute(
        element,
        ~qualifiedName="data-vibespace-id",
        ~value=generatedId->ProfileElementId.toString,
      )
      Some(generatedId)
    } else {
      None
    }
  }

  switch maybeId {
  | Some(id) =>
    let className = Element.getAttribute(element, "class")->nullString
    let friendlyName = Element.getAttribute(element, "data-vibespace-name")->nullString
    let friendlyDescription = Element.getAttribute(
      element,
      "data-vibespace-description",
    )->nullString
    Some({
      requestId: None,
      id,
      friendlyName: friendlyName->String.trim == "" ? None : Some(friendlyName->SelectionLabel.make),
      friendlyDescription: friendlyDescription->String.trim == ""
        ? None
        : Some(friendlyDescription->SelectionDescription.make),
      tagName: element.tagName->String.toLowerCase,
      text: textForElement(element)->String.slice(~start=0, ~end=220),
      className: className->String.trim == "" ? None : Some(className),
      selector: CssSelector.forElementId(id),
      bounds: rectForElement(frameWindow, element),
      viewport: viewport(frameWindow),
    })
  | None => None
  }
}

let elementContextWithRequestId = (context: ProfileSelection.elementContext, requestId) => {
  ProfileSelection.withRequestId(requestId, context)
}

let clearAttribute = (frameDocument: DomTypes.document, selector, attribute) => {
  let nodes = try {
    Some(Document.querySelectorAll(frameDocument, selector))
  } catch {
  | _ => None
  }

  switch nodes {
  | Some(nodes) =>
    for index in 0 to nodes.length - 1 {
      Element.removeAttribute(NodeList.item(nodes, index), attribute)
    }
  | None => ()
  }
}

let clearHover = frameDocument =>
  clearAttribute(frameDocument, "[data-vibespace-hover=\"true\"]", "data-vibespace-hover")

let paintSelected = (frameDocument, selectedId, _editMode) => {
  clearAttribute(frameDocument, "[data-vibespace-selected=\"true\"]", "data-vibespace-selected")
  if selectedId != "" {
    let nodes = try {
      Some(Document.querySelectorAll(frameDocument, "[data-vibespace-id]"))
    } catch {
    | _ => None
    }
    switch nodes {
    | Some(nodes) =>
      for index in 0 to nodes.length - 1 {
        let node = NodeList.item(nodes, index)
        if Element.getAttribute(node, "data-vibespace-id")->nullString == selectedId {
          Element.setAttribute(node, ~qualifiedName="data-vibespace-selected", ~value="true")
        }
      }
    | None => ()
    }
  }
}

let normalizedRect = (frameWindow, first, secondX, secondY): webRect => {
  let x = minFloat(first.x, secondX)
  let y = minFloat(first.y, secondY)
  let width = absFloat(secondX -. first.x)
  let height = absFloat(secondY -. first.y)
  {
    x,
    y,
    width,
    height,
    documentX: x + frameWindow->Window.scrollX,
    documentY: y + frameWindow->Window.scrollY,
  }
}

let intersectRects = (first: ProfileSelection.bounds, second: webRect): webRect => {
  let left = maxFloat(first.x, second.x)
  let top = maxFloat(first.y, second.y)
  let right = minFloat(first.x + first.width, second.x + second.width)
  let bottom = minFloat(first.y + first.height, second.y + second.height)
  let width = maxFloat(0.0, right -. left)
  let height = maxFloat(0.0, bottom -. top)
  {x: left, y: top, width, height, documentX: 0.0, documentY: 0.0}
}

let insetRect = (rect: webRect, inset) =>
  if rect.width <= inset *. 2.0 || rect.height <= inset *. 2.0 {
    rect
  } else {
    {
      x: rect.x + inset,
      y: rect.y + inset,
      width: rect.width -. inset *. 2.0,
      height: rect.height -. inset *. 2.0,
      documentX: rect.documentX + inset,
      documentY: rect.documentY + inset,
    }
  }

let setStyle = (element: DomTypes.element, property, value) => {
  let htmlElement = elementToHtmlElement(element)
  CSSStyleDeclaration.setProperty(htmlElement.style, ~property, ~value)
}

let ensureOverlay = (frameDocument: DomTypes.document, overlayRef: ref<option<DomTypes.element>>) =>
  switch overlayRef.contents {
  | Some(overlay) => overlay
  | None =>
    let overlay = Document.createElement(frameDocument, "div")
    Element.setAttribute(overlay, ~qualifiedName="data-vibespace-area-draft", ~value="true")
    setStyle(overlay, "position", "fixed")
    setStyle(overlay, "z-index", "2147483647")
    setStyle(overlay, "pointer-events", "none")
    setStyle(overlay, "border", "2px solid #38f8ff")
    setStyle(overlay, "background", "rgba(56, 248, 255, 0.14)")
    setStyle(
      overlay,
      "box-shadow",
      "0 0 0 2px rgba(0, 0, 0, 0.92), 0 0 0 5px rgba(255, 255, 255, 0.94), 0 0 28px rgba(56, 248, 255, 0.82), 0 0 0 9999px rgba(0, 0, 0, 0.16)",
    )
    ignore(Node.appendChild(frameDocument.body->HTMLElement.asNode, overlay->Element.asNode))
    overlayRef.contents = Some(overlay)
    overlay
  }

let removeOverlay = (overlayRef: ref<option<DomTypes.element>>) => {
  switch overlayRef.contents {
  | Some(overlay) =>
    switch overlay.parentNode->Null.toOption {
    | Some(parent) => ignore(Node.removeChild(parent, overlay->Element.asNode))
    | None => ()
    }
  | None => ()
  }
  overlayRef.contents = None
}

let updateOverlay = (frameDocument, overlayRef, rect: webRect) => {
  let node = ensureOverlay(frameDocument, overlayRef)
  setStyle(node, "left", rect.x->Float.toString ++ "px")
  setStyle(node, "top", rect.y->Float.toString ++ "px")
  setStyle(node, "width", rect.width->Float.toString ++ "px")
  setStyle(node, "height", rect.height->Float.toString ++ "px")
}

let elementAtCenter = (frameDocument, rect: webRect): option<DomTypes.element> => {
  let x = rect.x +. rect.width /. 2.0
  let y = rect.y +. rect.height /. 2.0
  switch elementFromPoint(frameDocument, x, y)->Null.toOption {
  | Some(node) =>
    switch closestVibespaceElement(node) {
    | Some(element) => Some(element)
    | None => Some(node)
    }
  | None => None
  }
}

let collectElementsInSelection = (frameDocument, frameWindow, rect: webRect) => {
  let bufferedRect = insetRect(rect, metadataEdgeBufferPx)
  let entries: array<selectionEntry> = []
  let seen: dict<bool> = Dict.make()
  let nodes = try {
    Some(Document.querySelectorAll(frameDocument, "[data-vibespace-id]"))
  } catch {
  | _ => None
  }

  switch nodes {
  | Some(nodes) =>
    for index in 0 to nodes.length - 1 {
      let element = NodeList.item(nodes, index)
      if !Element.hasAttribute(element, "data-vibespace-area-draft") {
        let id = Element.getAttribute(element, "data-vibespace-id")->nullString
        if id != "" && Dict.get(seen, id)->Option.isNone {
          let bounds = rectForElement(frameWindow, element)
          if bounds.width > 0.0 && bounds.height > 0.0 {
            let overlap = intersectRects(bounds, bufferedRect)
            if overlap.width > 0.0 && overlap.height > 0.0 {
              Dict.set(seen, id, true)
              switch describeElement(frameWindow, element, ~autoId=false) {
              | Some(context) =>
                entries->Array.push({context, overlapArea: overlap.width *. overlap.height})
              | None => ()
              }
            }
          }
        }
      }
    }
  | None => ()
  }

  entries->Array.sort((first, second) => Float.compare(second.overlapArea, first.overlapArea))
  entries
  ->Array.slice(~start=0, ~end=maxSelectedMetadataElements)
  ->Array.map(entry => entry.context)
}

let payloadFromElement = (requestId, context: ProfileSelection.elementContext): ProfileSelection.payload => {
  let context = elementContextWithRequestId(context, requestId)
  let requestIdString = requestId->RequestId.toString
  {
    requestId: requestIdString,
    kind: "element",
    id: context.id->ProfileElementId.toString,
    friendlyName: context.friendlyName->Option.mapOr("", SelectionLabel.toString),
    friendlyDescription: context.friendlyDescription->Option.mapOr("", SelectionDescription.toString),
    tagName: context.tagName,
    text: context.text,
    className: context.className->Option.getOr(""),
    selector: context.selector->CssSelector.toString,
    x: context.bounds.x,
    y: context.bounds.y,
    width: context.bounds.width,
    height: context.bounds.height,
    documentX: context.bounds.documentX,
    documentY: context.bounds.documentY,
    viewportWidth: context.viewport.width,
    viewportHeight: context.viewport.height,
    screenshotDataUrl: "",
    nearestId: "",
    nearestFriendlyName: "",
    nearestFriendlyDescription: "",
    nearestTagName: "",
    nearestText: "",
    nearestClassName: "",
    nearestSelector: "",
    nearestX: 0.0,
    nearestY: 0.0,
    nearestWidth: 0.0,
    nearestHeight: 0.0,
    nearestDocumentX: 0.0,
    nearestDocumentY: 0.0,
    selectedElements: [],
  }
}

let payloadFromArea = (
  requestId,
  frameWindow,
  rect: webRect,
  nearest: option<ProfileSelection.elementContext>,
  selectedElements,
): ProfileSelection.payload => {
  let nearest = nearest->Option.map(context => elementContextWithRequestId(context, requestId))
  let selectedElements = selectedElements->Array.map(context =>
    elementContextWithRequestId(context, requestId)
  )
  let frameViewport = viewport(frameWindow)
  let requestIdString = requestId->RequestId.toString
  {
    requestId: requestIdString,
    kind: "area",
    id: "",
    friendlyName: "",
    friendlyDescription: "",
    tagName: "",
    text: "",
    className: "",
    selector: "",
    x: rect.x,
    y: rect.y,
    width: rect.width,
    height: rect.height,
    documentX: rect.documentX,
    documentY: rect.documentY,
    viewportWidth: frameViewport.width,
    viewportHeight: frameViewport.height,
    screenshotDataUrl: "",
    nearestId: nearest->Option.mapOr("", context => context.id->ProfileElementId.toString),
    nearestFriendlyName: nearest->Option.mapOr(
      "",
      context => context.friendlyName->Option.mapOr("", SelectionLabel.toString),
    ),
    nearestFriendlyDescription: nearest->Option.mapOr(
      "",
      context => context.friendlyDescription->Option.mapOr("", SelectionDescription.toString),
    ),
    nearestTagName: nearest->Option.mapOr("", context => context.tagName),
    nearestText: nearest->Option.mapOr("", context => context.text),
    nearestClassName: nearest->Option.mapOr("", context => context.className->Option.getOr("")),
    nearestSelector: nearest->Option.mapOr("", context => context.selector->CssSelector.toString),
    nearestX: nearest->Option.mapOr(0.0, context => context.bounds.x),
    nearestY: nearest->Option.mapOr(0.0, context => context.bounds.y),
    nearestWidth: nearest->Option.mapOr(0.0, context => context.bounds.width),
    nearestHeight: nearest->Option.mapOr(0.0, context => context.bounds.height),
    nearestDocumentX: nearest->Option.mapOr(0.0, context => context.bounds.documentX),
    nearestDocumentY: nearest->Option.mapOr(0.0, context => context.bounds.documentY),
    selectedElements,
  }
}

@live
let attachToIframe = (
  iframe: DomTypes.htmliFrameElement,
  selectedId,
  editMode,
  callback: ProfileSelection.payload => unit,
) => {
  let frameDocument = iframe.contentDocument->Null.toOption
  let frameWindow = iframe.contentWindow->Null.toOption

  switch (frameDocument, frameWindow) {
  | (Some(frameDocument), Some(frameWindow)) =>
    paintSelected(frameDocument, selectedId, editMode)
    if editMode {
      let startRef: ref<option<draftStart>> = ref(None)
      let overlayRef: ref<option<DomTypes.element>> = ref(None)
      let movedRef = ref(false)

      let cancelDraft = () => {
        startRef.contents = None
        movedRef.contents = false
        removeOverlay(overlayRef)
      }

      let highlightAt = (target: option<DomTypes.element>) => {
        if startRef.contents->Option.isNone {
          clearHover(frameDocument)
          switch target {
          | Some(target) =>
            switch closestVibespaceElement(target) {
            | Some(target) =>
              Element.setAttribute(target, ~qualifiedName="data-vibespace-hover", ~value="true")
            | None => ()
            }
          | None => ()
          }
        }
      }

      let mouseOver = (event: UiEventsTypes.mouseEvent) =>
        highlightAt(event.target->Null.toOption->Option.map(eventTargetToElement))

      let pointerHover = (event: UiEventsTypes.pointerEvent) =>
        highlightAt(event.target->Null.toOption->Option.map(eventTargetToElement))

      let pointerDown = (event: UiEventsTypes.pointerEvent) => {
        if event.button == 0 {
          switch event.target->Null.toOption->Option.map(eventTargetToElement) {
          | Some(target) =>
            startRef.contents = Some({
              x: event.clientX->Int.toFloat,
              y: event.clientY->Int.toFloat,
              target,
            })
            movedRef.contents = false
            switch closestVibespaceElement(target) {
            | Some(hoverTarget) =>
              clearHover(frameDocument)
              Element.setAttribute(
                hoverTarget,
                ~qualifiedName="data-vibespace-hover",
                ~value="true",
              )
            | None => clearHover(frameDocument)
            }
            // Do not preventDefault here. On touch this would suppress the
            // platform long-press text-selection gesture before we know whether
            // the user is dragging or holding. preventDefault moves to
            // pointerMove once we detect real movement.
          | None => ()
          }
        }
      }

      let pointerMove = (event: UiEventsTypes.pointerEvent) => {
        switch startRef.contents {
        | Some(start) =>
          let rect = normalizedRect(
            frameWindow,
            start,
            event.clientX->Int.toFloat,
            event.clientY->Int.toFloat,
          )
          if rect.width > 4.0 || rect.height > 4.0 {
            if !movedRef.contents {
              movedRef.contents = true
              try {
                Element.setPointerCapture(start.target, event.pointerId)
              } catch {
              | _ => ()
              }
            }
            updateOverlay(frameDocument, overlayRef, rect)
            // Only block default behavior once we are confidently dragging an
            // area. This keeps the OS long-press text-selection gesture alive
            // for stationary touches.
            PointerEvent.preventDefault(event)
            PointerEvent.stopPropagation(event)
          }
        | None => ()
        }
      }

      let pickedRef = ref(false)

      let pointerUp = (event: UiEventsTypes.pointerEvent) => {
        switch startRef.contents {
        | Some(start) =>
          let rect = normalizedRect(
            frameWindow,
            start,
            event.clientX->Int.toFloat,
            event.clientY->Int.toFloat,
          )
          startRef.contents = None
          removeOverlay(overlayRef)
          pickedRef.contents = false

          if movedRef.contents && rect.width > 6.0 && rect.height > 6.0 {
            let requestId = nextRequestId()
            let selectedElements = collectElementsInSelection(frameDocument, frameWindow, rect)
            let nearest = switch elementAtCenter(frameDocument, rect) {
            | Some(element) => describeElement(frameWindow, element, ~autoId=false)
            | None => None
            }
            let selectedElements = if selectedElements->Array.length == 0 {
              switch nearest {
              | Some(nearest) => [nearest]
              | None => selectedElements
              }
            } else {
              selectedElements
            }
            callback(payloadFromArea(requestId, frameWindow, rect, nearest, selectedElements))
            pickedRef.contents = true
            PointerEvent.preventDefault(event)
            PointerEvent.stopPropagation(event)
          } else {
            let target = switch closestVibespaceElement(start.target) {
            | Some(target) => target
            | None => start.target
            }
            switch describeElement(frameWindow, target, ~autoId=true) {
            | Some(context) =>
              Element.setAttribute(target, ~qualifiedName="data-vibespace-selected", ~value="true")
              callback(payloadFromElement(nextRequestId(), context))
              pickedRef.contents = true
              PointerEvent.preventDefault(event)
              PointerEvent.stopPropagation(event)
            | None => ()
            }
          }

          movedRef.contents = false
        | None => ()
        }
      }

      let pointerCancel = (_event: UiEventsTypes.pointerEvent) => {
        cancelDraft()
        clearHover(frameDocument)
      }

      let click = (event: EventTypes.event) => {
        // Only suppress the synthesized click when we just handled a selection
        // gesture; let unrelated clicks (e.g. the OS dismissing the
        // text-selection magnifier) pass through.
        if pickedRef.contents {
          pickedRef.contents = false
          Event.preventDefault(event)
          Event.stopPropagation(event)
        }
      }

      Document.addEventListener(frameDocument, Mouseover, mouseOver)
      Document.addEventListener(frameDocument, Mouseout, _event => clearHover(frameDocument))
      Document.addEventListener(frameDocument, Pointerover, pointerHover)
      let captureOptions: EventTypes.addEventListenerOptions = {capture: true}
      Document.addEventListener(frameDocument, Pointerdown, pointerDown, ~options=captureOptions)
      Document.addEventListener(frameDocument, Pointermove, pointerMove, ~options=captureOptions)
      Document.addEventListener(frameDocument, Pointerup, pointerUp, ~options=captureOptions)
      Document.addEventListener(frameDocument, Pointercancel, pointerCancel, ~options=captureOptions)
      Document.addEventListener(frameDocument, Click, click, ~options=captureOptions)
      Window.addEventListener(frameWindow, Blur, _event => cancelDraft())
    }
  | _ => ()
  }
}
