type bounds = ProfileGeometry.bounds
type viewport = ProfileGeometry.viewport
type anchor = ProfileGeometry.anchor

type kind =
  | NoSelectionKind
  | ElementKind
  | AreaKind

type elementContext = {
  requestId: option<RequestId.t>,
  id: ProfileElementId.t,
  friendlyName: option<SelectionLabel.t>,
  friendlyDescription: option<SelectionDescription.t>,
  tagName: string,
  text: string,
  className: option<string>,
  selector: CssSelector.t,
  bounds: bounds,
  viewport: viewport,
}

type areaContext = {
  requestId: RequestId.t,
  bounds: bounds,
  viewport: viewport,
  screenshotDataUrl: option<DataUrl.t>,
  // Future model input should include a full-page before screenshot alongside this crop.
  // Keep both images tied to the same requestId so the agent sees the page and selection state together.
  nearest: option<elementContext>,
  selectedElements: array<elementContext>,
}

type t =
  | NoSelection
  | Element(elementContext)
  | Area(areaContext)

type payload = {
  requestId: string,
  kind: string,
  id: string,
  friendlyName: string,
  friendlyDescription: string,
  tagName: string,
  text: string,
  className: string,
  selector: string,
  x: float,
  y: float,
  width: float,
  height: float,
  documentX: float,
  documentY: float,
  viewportWidth: float,
  viewportHeight: float,
  screenshotDataUrl: string,
  nearestId: string,
  nearestFriendlyName: string,
  nearestFriendlyDescription: string,
  nearestTagName: string,
  nearestText: string,
  nearestClassName: string,
  nearestSelector: string,
  nearestX: float,
  nearestY: float,
  nearestWidth: float,
  nearestHeight: float,
  nearestDocumentX: float,
  nearestDocumentY: float,
  selectedElements: array<elementContext>,
}

@send external stringIncludes: (string, string) => bool = "includes"
@send external stringReplaceAll: (string, string, string) => string = "replaceAll"

let empty = NoSelection

let nonBlank = value => {
  let trimmed = value->String.trim
  trimmed == "" ? None : Some(trimmed)
}

let kindToStorage = kind =>
  switch kind {
  | NoSelectionKind => "none"
  | ElementKind => "element"
  | AreaKind => "area"
  }

let kindFromStorage = value =>
  switch value {
  | "element" => ElementKind
  | "area" => AreaKind
  | _ => NoSelectionKind
  }

let kindLabel = kind =>
  switch kind {
  | NoSelectionKind => "Whole profile"
  | ElementKind => "Section"
  | AreaKind => "Area"
  }

let looksTechnical = value => {
  let lower = value->String.toLowerCase
  lower->stringIncludes("data-vibespace") ||
    lower->stringIncludes("selector") ||
    lower->stringIncludes("tag:") ||
    lower->stringIncludes("class:") ||
    lower->stringIncludes("text:") ||
    lower->stringIncludes("<") ||
    lower->stringIncludes(">")
}

let shortLabel = value => {
  let trimmed = value->String.trim
  if trimmed->String.length > 64 {
    trimmed->String.slice(~start=0, ~end=64) ++ "..."
  } else {
    trimmed
  }
}

let cleanStoredLabel = (~kind, labelValue): SelectionLabel.t => {
  let trimmed = labelValue->String.trim
  if trimmed == "" ||
    trimmed == "No selection" ||
    trimmed == "No selection yet" ||
    trimmed->looksTechnical {
    kind->kindLabel->SelectionLabel.make
  } else {
    trimmed->shortLabel->SelectionLabel.make
  }
}

let cleanStoredAgentContext = (~kind, ~label, contextValue): SelectionDescription.t => {
  let trimmed = contextValue->String.trim
  let label = label->SelectionLabel.toString
  if trimmed == "" || trimmed->looksTechnical {
    ("Selected profile context\nname: " ++ label ++ "\nscope: " ++ kind->kindLabel)
    ->SelectionDescription.make
  } else {
    trimmed->SelectionDescription.make
  }
}

let boundsFromPayload = (payload: payload): bounds => {
  ProfileGeometry.bounds(
    ~x=payload.x,
    ~y=payload.y,
    ~width=payload.width,
    ~height=payload.height,
    ~documentX=payload.documentX,
    ~documentY=payload.documentY,
  )
}

let viewportFromPayload = (payload: payload): viewport => {
  ProfileGeometry.viewport(~width=payload.viewportWidth, ~height=payload.viewportHeight)
}

let selectorFromPayload = (selector, id) =>
  switch nonBlank(selector) {
  | Some(selector) => CssSelector.make(selector)
  | None => CssSelector.forElementId(id)
  }

let elementFromRaw = (
  ~requestId: option<RequestId.t>,
  ~id,
  ~friendlyName,
  ~friendlyDescription,
  ~tagName,
  ~text,
  ~className,
  ~selector,
  ~bounds,
  ~viewport,
): option<elementContext> =>
  switch ProfileElementId.make(id) {
  | Some(id) =>
    Some({
      requestId,
      id,
      friendlyName: nonBlank(friendlyName)->Option.map(SelectionLabel.make),
      friendlyDescription: nonBlank(friendlyDescription)->Option.map(SelectionDescription.make),
      tagName,
      text,
      className: nonBlank(className),
      selector: selectorFromPayload(selector, id),
      bounds,
      viewport,
    })
  | None => None
  }

let elementFromPayload = (payload: payload): option<elementContext> =>
  elementFromRaw(
    ~requestId=RequestId.make(payload.requestId),
    ~id=payload.id,
    ~friendlyName=payload.friendlyName,
    ~friendlyDescription=payload.friendlyDescription,
    ~tagName=payload.tagName,
    ~text=payload.text,
    ~className=payload.className,
    ~selector=payload.selector,
    ~bounds=boundsFromPayload(payload),
    ~viewport=viewportFromPayload(payload),
  )

let nearestFromPayload = (payload: payload): option<elementContext> =>
  switch nonBlank(payload.nearestId) {
  | None => None
  | Some(_) =>
    elementFromRaw(
      ~requestId=RequestId.make(payload.requestId),
      ~id=payload.nearestId,
      ~friendlyName=payload.nearestFriendlyName,
      ~friendlyDescription=payload.nearestFriendlyDescription,
      ~tagName=payload.nearestTagName,
      ~text=payload.nearestText,
      ~className=payload.nearestClassName,
      ~selector=payload.nearestSelector,
      ~bounds=ProfileGeometry.bounds(
        ~x=payload.nearestX,
        ~y=payload.nearestY,
        ~width=payload.nearestWidth,
        ~height=payload.nearestHeight,
        ~documentX=payload.nearestDocumentX,
        ~documentY=payload.nearestDocumentY,
      ),
      ~viewport=viewportFromPayload(payload),
    )
  }

let withRequestId = (requestId, context: elementContext): elementContext => {
  ...context,
  requestId: Some(requestId),
}

let elementsFromPayload = (payload: payload): array<elementContext> =>
  payload.selectedElements

let fromPayload = (payload: payload): t =>
  switch payload.kind {
  | "element" =>
    switch elementFromPayload(payload) {
    | Some(element) => Element(element)
    | None => NoSelection
    }
  | "area" =>
    switch RequestId.make(payload.requestId) {
    | Some(requestId) =>
      Area({
        requestId,
        bounds: boundsFromPayload(payload),
        viewport: viewportFromPayload(payload),
        screenshotDataUrl: DataUrl.make(payload.screenshotDataUrl),
        nearest: nearestFromPayload(payload),
        selectedElements: elementsFromPayload(payload),
      })
    | None => NoSelection
    }
  | _ => NoSelection
  }

let kind = selection =>
  switch selection {
  | NoSelection => NoSelectionKind
  | Element(_) => ElementKind
  | Area(_) => AreaKind
  }

let hasSelection = selection =>
  switch selection {
  | NoSelection => false
  | Element(_) | Area(_) => true
  }

let selectedId = selection =>
  switch selection {
  | Element(element) => Some(element.id)
  | Area(area) =>
    switch area.nearest {
    | Some(element) => Some(element.id)
    | None => None
    }
  | NoSelection => None
  }

let requestId = selection =>
  switch selection {
  | Element(element) => element.requestId
  | Area(area) => Some(area.requestId)
  | NoSelection => None
  }

let selectionKindLabel = selection => selection->kind->kindLabel

let fallbackLabel = (element: elementContext) =>
  switch element.id->ProfileElementId.toString->nonBlank {
  | Some(id) =>
    if id->stringIncludes("auto-") {
      "Selected section"
    } else {
      let readable = id->stringReplaceAll("-", " ")->stringReplaceAll("_", " ")
      readable->shortLabel
    }
  | None => "Selected section"
  }

let isRootElement = (element: elementContext) =>
  element.id->ProfileElementId.toString == "profile-root"

let elementFriendlyLabel = (element: elementContext) =>
  if element->isRootElement {
    "Profile background"
  } else {
    switch element.friendlyName {
    | Some(name) => name->SelectionLabel.toString
    | None =>
      switch element.friendlyDescription {
      | Some(description) => description->SelectionDescription.toString
      | None => fallbackLabel(element)
      }
    }
  }

let label = selection =>
  switch selection {
  | NoSelection => "Whole profile"->SelectionLabel.make
  | Element(element) => element->elementFriendlyLabel->SelectionLabel.make
  | Area(area) =>
    switch area.nearest {
    | Some(element) => ("Area around " ++ element->elementFriendlyLabel)->SelectionLabel.make
    | None => "Selected profile area"->SelectionLabel.make
    }
  }

let descriptionLabel = friendlyDescription =>
  friendlyDescription
  ->Option.mapOr("No description provided yet.", SelectionDescription.toString)

let anchorLabel = (element: elementContext) => element.id->ProfileElementId.toString

let visibleTextSummary = (element: elementContext) =>
  switch element.text->nonBlank {
  | Some(text) => "\nvisible text: " ++ text->shortLabel
  | None => ""
  }

let elementSummary = (element: elementContext, index: int) =>
  (index + 1)->Int.toString ++ ". " ++ element->elementFriendlyLabel ++
  "\ndescription: " ++ element.friendlyDescription->descriptionLabel ++
  "\nprofile anchor: " ++ element->anchorLabel ++
  "\nvisual bounds: " ++ ProfileGeometry.boundsSummary(element.bounds) ++
  element->visibleTextSummary

let agentContext = selection =>
  switch selection {
  | NoSelection =>
    "Whole profile\nscope: apply the request across the full profile."->SelectionDescription.make
  | Element(element) =>
    (if element->isRootElement {
      "Clicked profile background/root\nname: " ++ element->elementFriendlyLabel ++
      "\ndescription: page-level background/root surface for the profile" ++
      "\nprofile anchor: " ++ element->anchorLabel ++
      "\nselection confidence: weak placement context" ++
      "\nscope guidance: use this as page-level placement context, not permission to redesign the whole profile. For additive requests, insert a new component and preserve the current page design unless the user explicitly asks for a broad redesign." ++
      "\nvisual bounds: " ++ ProfileGeometry.boundsSummary(element.bounds)
    } else {
      "Selected profile part\nname: " ++ element->elementFriendlyLabel ++
      "\ndescription: " ++ element.friendlyDescription->descriptionLabel ++
      "\nprofile anchor: " ++ element->anchorLabel ++
      "\nselection confidence: focused component context" ++
      "\nvisual bounds: " ++ ProfileGeometry.boundsSummary(element.bounds)
    })->SelectionDescription.make
  | Area(area) =>
    let nearest = switch area.nearest {
    | Some(element) =>
      "\nnearest name: " ++ element->elementFriendlyLabel ++
      "\nnearest description: " ++ element.friendlyDescription->descriptionLabel ++
      "\nnearest profile anchor: " ++ element->anchorLabel
    | None => "\nnearest profile part: none"
    }
    let selectedElements = area.selectedElements->Array.length == 0
      ? "\nselected profile parts: none"
      : "\nselected profile parts count: " ++ area.selectedElements->Array.length->Int.toString ++
        "\n" ++
        area.selectedElements
        ->Array.mapWithIndex((element, index) => elementSummary(element, index))
        ->Array.join("\n")
    let screenshot = switch area.screenshotDataUrl {
    | Some(_) => "yes"
    | None => "no"
    }
    ("Area selection\nbounds: " ++ ProfileGeometry.boundsSummary(area.bounds) ++
    "\nviewport: width=" ++ area.viewport.width->Float.toString ++
    ", height=" ++ area.viewport.height->Float.toString ++
    "\nscreenshot captured: " ++ screenshot ++
    nearest ++
    selectedElements)->SelectionDescription.make
  }

let anchor = selection =>
  switch selection {
  | Element(element) =>
    Some(ProfileGeometry.anchorFromBounds(~bounds=element.bounds, ~viewport=element.viewport))
  | Area(area) =>
    Some(ProfileGeometry.anchorFromBounds(~bounds=area.bounds, ~viewport=area.viewport))
  | NoSelection => None
  }

let screenshotDataUrl = selection =>
  switch selection {
  | Area(area) => area.screenshotDataUrl
  | Element(_) | NoSelection => None
  }
