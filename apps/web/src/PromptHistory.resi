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

let load: unit => array<item>
let save: array<item> => unit
let pruneEmptyItems: array<item> => array<item>
let snapshotHtml: item => option<HtmlSource.t>
let snapshotCss: item => option<CssSource.t>
let promptString: item => string
let selectionKind: item => ProfileSelection.kind
let selectionLabelString: item => string
let revisionLabel: item => string
let makeItem: (
  ~prompt: PromptText.t,
  ~selectionKind: ProfileSelection.kind,
  ~selectionLabel: SelectionLabel.t,
  ~selectionSnapshot: SelectionDescription.t,
  ~revisionId: RevisionId.t,
  ~documentHtml: HtmlSource.t,
  ~documentCss: CssSource.t,
  ~createdAt: IsoTimestamp.t,
) => item
