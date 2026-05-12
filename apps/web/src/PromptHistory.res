type selection = {
  kind: ProfileSelection.kind,
  label: SelectionLabel.t,
  snapshot: SelectionDescription.t,
}

type item = {
  id: PromptHistoryId.t,
  prompt: PromptText.t,
  createdAt: IsoTimestamp.t,
  selection: selection,
  conversationId: option<PromptConversationId.t>,
  revisionId: option<RevisionId.t>,
  documentHtml: HtmlSource.t,
  documentCss: CssSource.t,
}

type storedItem = {
  id: string,
  prompt: string,
  createdAt: string,
  selectionKind: string,
  selectionLabel: string,
  conversationId: string,
  selectionSnapshot: string,
  revisionId: string,
  documentHtml: string,
  documentCss: string,
}

@val @scope("window") external localStorage: WebStorageTypes.storage = "localStorage"

let storageKey = "vibespace.promptHistory.v1"
let maxItems = 30
let maxDocumentLength = 200000

let stringField = (object, name, maxLength) =>
  switch object->Dict.get(name)->Option.flatMap(JSON.Decode.string) {
  | Some(value) => value->String.slice(~start=0, ~end=maxLength)
  | None => ""
  }

let decodeStored = value =>
  switch value->JSON.Decode.object {
  | Some(object) =>
    Some({
      id: stringField(object, "id", 400),
      prompt: stringField(object, "prompt", 4000),
      createdAt: stringField(object, "createdAt", 120),
      selectionKind: stringField(object, "selectionKind", 80),
      selectionLabel: stringField(object, "selectionLabel", 400),
      conversationId: stringField(object, "conversationId", 400),
      selectionSnapshot: stringField(object, "selectionSnapshot", 4000),
      revisionId: stringField(object, "revisionId", 80),
      documentHtml: stringField(object, "documentHtml", maxDocumentLength),
      documentCss: stringField(object, "documentCss", maxDocumentLength),
    })
  | None => None
  }

let loadStored = () =>
  try {
    switch Storage.getItem(localStorage, storageKey)->Null.toOption {
    | Some(raw) =>
      switch JSON.parseOrThrow(raw)->JSON.Decode.array {
      | Some(items) =>
        items
        ->Array.filterMap(decodeStored)
        ->Array.filter(item => item.prompt != "")
      | None => []
      }
    | None => []
    }
  } catch {
  | _ => []
  }

let saveStored = (items: array<storedItem>) =>
  try {
    let safeItems = items->Array.filter(item => item.prompt != "")->Array.slice(
      ~start=0,
      ~end=maxItems,
    )
    switch safeItems->JSON.stringifyAny {
    | Some(serialized) => Storage.setItem(localStorage, ~key=storageKey, ~value=serialized)
    | None => ()
    }
  } catch {
  | _ => ()
  }

let fromStored = (stored: storedItem): option<item> =>
  switch PromptHistoryId.make(stored.id) {
  | Some(id) =>
    let selectionKind = ProfileSelection.kindFromStorage(stored.selectionKind)
    let selectionLabel = ProfileSelection.cleanStoredLabel(
      ~kind=selectionKind,
      stored.selectionLabel,
    )
    let selectionSnapshot = ProfileSelection.cleanStoredAgentContext(
      ~kind=selectionKind,
      ~label=selectionLabel,
      stored.selectionSnapshot,
    )
    Some({
      id,
      prompt: stored.prompt->PromptText.make,
      createdAt: IsoTimestamp.make(stored.createdAt),
      selection: {
        kind: selectionKind,
        label: selectionLabel,
        snapshot: selectionSnapshot,
      },
      conversationId: stored.conversationId->PromptConversationId.make,
      revisionId: stored.revisionId->RevisionId.fromString,
      documentHtml: stored.documentHtml->HtmlSource.make,
      documentCss: stored.documentCss->CssSource.make,
    })
  | None => None
  }

let toStored = (item: item): storedItem => {
  id: item.id->PromptHistoryId.toString,
  prompt: item.prompt->PromptText.toString,
  createdAt: item.createdAt->IsoTimestamp.toString,
  selectionKind: item.selection.kind->ProfileSelection.kindToStorage,
  selectionLabel: item.selection.label->SelectionLabel.toString,
  conversationId: item.conversationId->Option.mapOr("", PromptConversationId.toString),
  selectionSnapshot: item.selection.snapshot->SelectionDescription.toString,
  revisionId: item.revisionId->Option.mapOr("", RevisionId.toString),
  documentHtml: item.documentHtml->HtmlSource.toString,
  documentCss: item.documentCss->CssSource.toString,
}

let isEmptyItem = (item: item) => item.prompt->PromptText.isBlank
let hasSnapshot = (item: item) =>
  item.documentHtml->HtmlSource.toString->String.trim != "" &&
    item.documentCss->CssSource.toString->String.trim != ""
let snapshotHtml = (item: item) => item->hasSnapshot ? Some(item.documentHtml) : None
let snapshotCss = (item: item) => item->hasSnapshot ? Some(item.documentCss) : None
let promptString = (item: item) => item.prompt->PromptText.toString
let selectionKind = (item: item) => item.selection.kind
let selectionLabelString = (item: item) => item.selection.label->SelectionLabel.toString
let revisionLabel = (item: item) =>
  switch item.revisionId {
  | Some(revisionId) => "Version " ++ revisionId->RevisionId.toString
  | None => "Applied"
  }

let pruneEmptyItems = (items: array<item>) => items->Array.filter(item => !(item->isEmptyItem))

let load = () => {
  let decoded: array<item> = []
  loadStored()->Array.forEach(stored =>
    switch stored->fromStored {
    | Some(item) => decoded->Array.push(item)
    | None => ()
    }
  )
  decoded->pruneEmptyItems
}

let save = (items: array<item>) => items->pruneEmptyItems->Array.map(toStored)->saveStored

let makeItem = (
  ~prompt: PromptText.t,
  ~selectionKind: ProfileSelection.kind,
  ~selectionLabel: SelectionLabel.t,
  ~selectionSnapshot: SelectionDescription.t,
  ~revisionId: RevisionId.t,
  ~documentHtml: HtmlSource.t,
  ~documentCss: CssSource.t,
  ~createdAt: IsoTimestamp.t,
): item => {
  let promptLength = prompt->PromptText.toString->String.length
  let selectionLabel = ProfileSelection.cleanStoredLabel(
    ~kind=selectionKind,
    selectionLabel->SelectionLabel.toString,
  )
  let selectionSnapshot = ProfileSelection.cleanStoredAgentContext(
    ~kind=selectionKind,
    ~label=selectionLabel,
    selectionSnapshot->SelectionDescription.toString,
  )
  {
    id: PromptHistoryId.fromParts(~createdAt, ~promptLength),
    prompt,
    createdAt,
    selection: {
      kind: selectionKind,
      label: selectionLabel,
      snapshot: selectionSnapshot,
    },
    conversationId: None,
    revisionId: Some(revisionId),
    documentHtml,
    documentCss,
  }
}
