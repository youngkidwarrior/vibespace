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

type storedItem = {
  id: string,
  prompt: string,
  createdAt: string,
  updatedAt: string,
  selectionKind: string,
  selectionLabel: string,
  selectionSnapshot: string,
  selectedRegionScreenshotDataUrl: string,
  status: string,
  progress: string,
  error: string,
  summary: string,
  notice: string,
  failedHtml: string,
  failedCss: string,
  failedSummary: string,
  failedWarnings: string,
  failedValidationMessage: string,
  minimized: bool,
  anchorX: float,
  anchorY: float,
  anchorWidth: float,
  anchorHeight: float,
  viewportWidth: float,
  viewportHeight: float,
}

@val @scope("window") external localStorage: WebStorageTypes.storage = "localStorage"

let storageKey = "vibespace.promptDrafts.v1"
let maxDrafts = 50
let maxFailedSourceLength = 200000

let jsonObject = value => value->JSON.Decode.object

let stringField = (object, name, maxLength) =>
  switch object->Dict.get(name)->Option.flatMap(JSON.Decode.string) {
  | Some(value) => value->String.slice(~start=0, ~end=maxLength)
  | None => ""
  }

let boolField = (object, name) =>
  object->Dict.get(name)->Option.flatMap(JSON.Decode.bool)->Option.getOr(false)

let floatField = (object, name) =>
  object->Dict.get(name)->Option.flatMap(JSON.Decode.float)->Option.getOr(0.0)

let decodeStored = value =>
  switch value->jsonObject {
  | Some(object) =>
    Some({
      id: stringField(object, "id", 400),
      prompt: stringField(object, "prompt", 8000),
      createdAt: stringField(object, "createdAt", 120),
      updatedAt: stringField(object, "updatedAt", 120),
      selectionKind: stringField(object, "selectionKind", 80),
      selectionLabel: stringField(object, "selectionLabel", 400),
      selectionSnapshot: stringField(object, "selectionSnapshot", 8000),
      selectedRegionScreenshotDataUrl: stringField(object, "selectedRegionScreenshotDataUrl", 400000),
      status: stringField(object, "status", 80),
      progress: stringField(object, "progress", 80),
      error: stringField(object, "error", 800),
      summary: stringField(object, "summary", 800),
      notice: stringField(object, "notice", 500),
      failedHtml: stringField(object, "failedHtml", maxFailedSourceLength),
      failedCss: stringField(object, "failedCss", maxFailedSourceLength),
      failedSummary: stringField(object, "failedSummary", 1200),
      failedWarnings: stringField(object, "failedWarnings", 2000),
      failedValidationMessage: stringField(object, "failedValidationMessage", 2000),
      minimized: boolField(object, "minimized"),
      anchorX: floatField(object, "anchorX"),
      anchorY: floatField(object, "anchorY"),
      anchorWidth: floatField(object, "anchorWidth"),
      anchorHeight: floatField(object, "anchorHeight"),
      viewportWidth: floatField(object, "viewportWidth"),
      viewportHeight: floatField(object, "viewportHeight"),
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
        ->Array.filter(item => item.id != "")
      | None => []
      }
    | None => []
    }
  } catch {
  | _ => []
  }

let saveStored = (items: array<storedItem>) =>
  try {
    let safeItems = items->Array.filter(item => item.id != "")->Array.slice(~start=0, ~end=maxDrafts)
    switch safeItems->JSON.stringifyAny {
    | Some(serialized) => Storage.setItem(localStorage, ~key=storageKey, ~value=serialized)
    | None => ()
    }
  } catch {
  | _ => ()
  }

let progressFromStorage = value =>
  switch value {
  | "planning" => Planning
  | "checking_web_context" => CheckingWebContext
  | "extracting_assets" => ExtractingAssets
  | "generating" => Generating
  | "validating" => Validating
  | "repairing" => Repairing
  | "applying" => Applying
  | "preparing" | _ => Preparing
  }

let progressToStorage = phase =>
  switch phase {
  | Preparing => "preparing"
  | Planning => "planning"
  | CheckingWebContext => "checking_web_context"
  | ExtractingAssets => "extracting_assets"
  | Generating => "generating"
  | Validating => "validating"
  | Repairing => "repairing"
  | Applying => "applying"
  }

let progressLabel = phase =>
  switch phase {
  | Preparing => "Preparing"
  | Planning => "Understanding request"
  | CheckingWebContext => "Checking web context"
  | ExtractingAssets => "Finding safe images"
  | Generating => "Generating changes"
  | Validating => "Validating"
  | Repairing => "Repairing markup"
  | Applying => "Applying"
  }

let statusFromStored = (status, progress, error, summary) =>
  switch status {
  | "submitting" => Submitting(progress->progressFromStorage)
  | "error" => Error(error->ValidationMessage.make)
  | "applied" => Applied(summary->PatchSummary.make)
  | _ => Draft
  }

let statusToStored = status =>
  switch status {
  | Draft => ("draft", "", "", "")
  | Submitting(phase) => ("submitting", phase->progressToStorage, "", "")
  | Error(message) => ("error", "", message->ValidationMessage.toString, "")
  | Applied(summary) => ("applied", "", "", summary->PatchSummary.toString)
  }

let statusLabel = status =>
  switch status {
  | Draft => "Draft"
  | Submitting(phase) => phase->progressLabel
  | Error(_) => "Needs attention"
  | Applied(_) => "Applied"
  }

let isSubmitting = status =>
  switch status {
  | Submitting(_) => true
  | Draft | Error(_) | Applied(_) => false
  }

let errorMessage = status =>
  switch status {
  | Error(message) => Some(message->ValidationMessage.toString)
  | Draft | Submitting(_) | Applied(_) => None
  }

let appliedSummary = status =>
  switch status {
  | Applied(summary) => Some(summary->PatchSummary.toString)
  | Draft | Submitting(_) | Error(_) => None
  }

let failedPatchFromStored = (stored: storedItem): option<failedPatch> => {
  if stored.failedHtml->String.trim == "" && stored.failedCss->String.trim == "" {
    None
  } else {
    Some({
      html: stored.failedHtml->HtmlSource.make,
      css: stored.failedCss->CssSource.make,
      summary: stored.failedSummary->PatchSummary.make,
      warnings: stored.failedWarnings->PatchWarnings.make,
      validationMessage: stored.failedValidationMessage->ValidationMessage.make,
    })
  }
}

let hasFailedPatch = (draft: item) => draft.failedPatch->Option.isSome

let isEmptyDraft = (draft: item) =>
  draft.prompt->PromptText.isBlank &&
  switch draft.status {
  | Draft => true
  | Submitting(_) | Error(_) | Applied(_) => false
  }

let fromStored = (stored: storedItem): option<item> =>
  switch PromptDraftId.make(stored.id) {
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
      updatedAt: IsoTimestamp.make(stored.updatedAt),
      selection: {
        kind: selectionKind,
        label: selectionLabel,
        snapshot: selectionSnapshot,
        selectedRegionScreenshotDataUrl: DataUrl.make(stored.selectedRegionScreenshotDataUrl),
      },
      status: statusFromStored(stored.status, stored.progress, stored.error, stored.summary),
      notice: stored.notice->DraftNotice.make,
      failedPatch: stored->failedPatchFromStored,
      minimized: stored.minimized,
      anchor: ProfileGeometry.anchor(
        ~x=stored.anchorX,
        ~y=stored.anchorY,
        ~documentX=stored.anchorX,
        ~documentY=stored.anchorY,
        ~width=stored.anchorWidth,
        ~height=stored.anchorHeight,
        ~viewport=ProfileGeometry.viewport(
          ~width=stored.viewportWidth,
          ~height=stored.viewportHeight,
        ),
      ),
    })
  | None => None
  }

let toStored = (item: item): storedItem => {
  let (status, progress, error, summary) = item.status->statusToStored
  let failedPatch = item.failedPatch
  {
    id: item.id->PromptDraftId.toString,
    prompt: item.prompt->PromptText.toString,
    createdAt: item.createdAt->IsoTimestamp.toString,
    updatedAt: item.updatedAt->IsoTimestamp.toString,
    selectionKind: item.selection.kind->ProfileSelection.kindToStorage,
    selectionLabel: item.selection.label->SelectionLabel.toString,
    selectionSnapshot: item.selection.snapshot->SelectionDescription.toString,
    selectedRegionScreenshotDataUrl: item.selection.selectedRegionScreenshotDataUrl->Option.mapOr(
      "",
      DataUrl.toString,
    ),
    status,
    progress,
    error,
    summary,
    notice: item.notice->DraftNotice.toString,
    failedHtml: failedPatch->Option.mapOr("", patch => patch.html->HtmlSource.toString),
    failedCss: failedPatch->Option.mapOr("", patch => patch.css->CssSource.toString),
    failedSummary: failedPatch->Option.mapOr("", patch => patch.summary->PatchSummary.toString),
    failedWarnings: failedPatch->Option.mapOr("", patch => patch.warnings->PatchWarnings.toString),
    failedValidationMessage: failedPatch->Option.mapOr(
      "",
      patch => patch.validationMessage->ValidationMessage.toString,
    ),
    minimized: item.minimized,
    anchorX: item.anchor.client.x,
    anchorY: item.anchor.client.y,
    anchorWidth: item.anchor.size.width,
    anchorHeight: item.anchor.size.height,
    viewportWidth: item.anchor.viewport.width,
    viewportHeight: item.anchor.viewport.height,
  }
}

let pruneEmptyDrafts = (drafts: array<item>) => drafts->Array.filter(draft => !isEmptyDraft(draft))

let load = () => {
  let decoded: array<item> = []
  loadStored()->Array.forEach(stored =>
    switch stored->fromStored {
    | Some(item) => decoded->Array.push(item)
    | None => ()
    }
  )
  decoded->pruneEmptyDrafts
}

let save = (items: array<item>) => items->pruneEmptyDrafts->Array.map(toStored)->saveStored

let findById = (drafts: array<item>, id: PromptDraftId.t): option<item> =>
  drafts->Array.findMap(draft => draft.id->PromptDraftId.equals(id) ? Some(draft) : None)

let removeById = (drafts: array<item>, id: PromptDraftId.t): array<item> =>
  drafts->Array.filter(draft => !PromptDraftId.equals(draft.id, id))

let replace = (drafts: array<item>, next: item): array<item> =>
  drafts->Array.map(draft => draft.id->PromptDraftId.equals(next.id) ? next : draft)

let upsert = (drafts: array<item>, next: item): array<item> =>
  switch drafts->findById(next.id) {
  | Some(_) => drafts->replace(next)
  | None => [next, ...drafts]
  }

let makeSelection = (
  ~kind: ProfileSelection.kind,
  ~label: SelectionLabel.t,
  ~snapshot: SelectionDescription.t,
  ~selectedRegionScreenshotDataUrl,
) => {
  let label = ProfileSelection.cleanStoredLabel(~kind, label->SelectionLabel.toString)
  let snapshot = ProfileSelection.cleanStoredAgentContext(
    ~kind,
    ~label,
    snapshot->SelectionDescription.toString,
  )
  {kind, label, snapshot, selectedRegionScreenshotDataUrl}
}

let makeSelectionDraft = (
  ~id: PromptDraftId.t,
  ~selection: selection,
  ~anchor: ProfileGeometry.anchor,
  ~createdAt: IsoTimestamp.t,
): item => {
  {
    id,
    prompt: PromptText.empty,
    createdAt,
    updatedAt: createdAt,
    selection,
    status: Draft,
    notice: DraftNotice.empty,
    failedPatch: None,
    minimized: false,
    anchor,
  }
}

let upsertSelection = (
  drafts: array<item>,
  ~id: PromptDraftId.t,
  ~selectionKind: ProfileSelection.kind,
  ~selectionLabel: SelectionLabel.t,
  ~selectionSnapshot: SelectionDescription.t,
  ~selectedRegionScreenshotDataUrl: option<DataUrl.t>,
  ~anchor: ProfileGeometry.anchor,
  ~now: IsoTimestamp.t,
): array<item> => {
  let selection = makeSelection(
    ~kind=selectionKind,
    ~label=selectionLabel,
    ~snapshot=selectionSnapshot,
    ~selectedRegionScreenshotDataUrl,
  )
  let next = switch drafts->findById(id) {
  | Some(existing) => {
      ...existing,
      updatedAt: now,
      selection,
      anchor,
    }
  | None => makeSelectionDraft(~id, ~selection, ~anchor, ~createdAt=now)
  }
  drafts->upsert(next)
}

let updatePrompt = (
  drafts: array<item>,
  id: PromptDraftId.t,
  prompt: string,
  now: IsoTimestamp.t,
): array<item> =>
  drafts->Array.map(draft =>
    draft.id->PromptDraftId.equals(id)
      ? {
          ...draft,
          prompt: prompt->PromptText.make,
          updatedAt: now,
          status: Draft,
          notice: DraftNotice.empty,
        }
      : draft
  )

let setMinimized = (
  drafts: array<item>,
  id: PromptDraftId.t,
  minimized: bool,
  now: IsoTimestamp.t,
): array<item> =>
  drafts->Array.map(draft => draft.id->PromptDraftId.equals(id) ? {...draft, minimized, updatedAt: now} : draft)

let markTouched = (drafts: array<item>, id: PromptDraftId.t, now: IsoTimestamp.t): array<item> =>
  drafts->Array.map(draft => draft.id->PromptDraftId.equals(id) ? {...draft, updatedAt: now} : draft)

let markSubmitting = (drafts: array<item>, id: PromptDraftId.t, now: IsoTimestamp.t): array<item> =>
  drafts->Array.map(draft =>
    draft.id->PromptDraftId.equals(id)
      ? {...draft, status: Submitting(Preparing), notice: DraftNotice.empty, minimized: false, updatedAt: now}
      : draft
  )

let markSubmittingPhase = (
  drafts: array<item>,
  id: PromptDraftId.t,
  phase: progressPhase,
  now: IsoTimestamp.t,
): array<item> =>
  drafts->Array.map(draft =>
    draft.id->PromptDraftId.equals(id)
      ? {...draft, status: Submitting(phase), notice: DraftNotice.empty, minimized: false, updatedAt: now}
      : draft
  )

let markError = (
  drafts: array<item>,
  id: PromptDraftId.t,
  message: string,
  now: IsoTimestamp.t,
): array<item> =>
  drafts->Array.map(draft =>
    draft.id->PromptDraftId.equals(id)
      ? {...draft, status: Error(message->ValidationMessage.make), minimized: false, updatedAt: now}
      : draft
  )

let markApplied = (
  drafts: array<item>,
  id: PromptDraftId.t,
  summary: string,
  now: IsoTimestamp.t,
): array<item> =>
  drafts->Array.map(draft =>
    draft.id->PromptDraftId.equals(id)
      ? {
          ...draft,
          status: Applied(summary->PatchSummary.make),
          notice: DraftNotice.empty,
          failedPatch: None,
          minimized: true,
          updatedAt: now,
        }
      : draft
  )
