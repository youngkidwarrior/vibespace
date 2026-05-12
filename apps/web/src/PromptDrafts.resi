type progressPhase =
  | Preparing
  | Planning
  | CheckingWebContext
  | ExtractingAssets
  | Generating
  | Validating
  | Repairing
  | Applying

type status =
  | Draft
  | Submitting(progressPhase)
  | Error(ValidationMessage.t)
  | Applied(PatchSummary.t)

type selection = {
  kind: ProfileSelection.kind,
  label: SelectionLabel.t,
  snapshot: SelectionDescription.t,
  selectedRegionScreenshotDataUrl: option<DataUrl.t>,
}

type failedPatch = DocumentEditTypes.failedPatch

type item = {
  id: PromptDraftId.t,
  prompt: PromptText.t,
  createdAt: IsoTimestamp.t,
  updatedAt: IsoTimestamp.t,
  selection: selection,
  status: status,
  notice: DraftNotice.t,
  failedPatch: option<failedPatch>,
  minimized: bool,
  anchor: ProfileGeometry.anchor,
}

let statusLabel: status => string
let isSubmitting: status => bool
let isEmptyDraft: item => bool
let errorMessage: status => option<string>
let appliedSummary: status => option<string>
let hasFailedPatch: item => bool
let pruneEmptyDrafts: array<item> => array<item>
let load: unit => array<item>
let save: array<item> => unit
let findById: (array<item>, PromptDraftId.t) => option<item>
let removeById: (array<item>, PromptDraftId.t) => array<item>
let upsertSelection: (
  array<item>,
  ~id: PromptDraftId.t,
  ~selectionKind: ProfileSelection.kind,
  ~selectionLabel: SelectionLabel.t,
  ~selectionSnapshot: SelectionDescription.t,
  ~selectedRegionScreenshotDataUrl: option<DataUrl.t>,
  ~anchor: ProfileGeometry.anchor,
  ~now: IsoTimestamp.t,
) => array<item>
let updatePrompt: (array<item>, PromptDraftId.t, string, IsoTimestamp.t) => array<item>
let setMinimized: (array<item>, PromptDraftId.t, bool, IsoTimestamp.t) => array<item>
let markTouched: (array<item>, PromptDraftId.t, IsoTimestamp.t) => array<item>
let markSubmitting: (array<item>, PromptDraftId.t, IsoTimestamp.t) => array<item>
let markSubmittingPhase: (
  array<item>,
  PromptDraftId.t,
  progressPhase,
  IsoTimestamp.t,
) => array<item>
let markError: (array<item>, PromptDraftId.t, string, IsoTimestamp.t) => array<item>
let markApplied: (array<item>, PromptDraftId.t, string, IsoTimestamp.t) => array<item>
