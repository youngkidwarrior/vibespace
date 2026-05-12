type documentValidationState =
  | ValidationChecking
  | ValidationValid
  | ValidationInvalid(string)

type profileVersionSnapshot = {
  id: string,
  revisionNumber: int,
  html: HtmlSource.t,
  css: CssSource.t,
  summary: string,
  createdAt: string,
}

type viewerSnapshot = {
  id: string,
  status: string,
}

type profileEditSessionSnapshot = {
  id: string,
  prompt: string,
  status: string,
  progressPhase: string,
  summary: string,
  error: option<string>,
  selectionLabel: option<string>,
  createdAt: string,
  updatedAt: string,
}

type inviteSnapshot = {
  id: string,
  code: option<string>,
  status: string,
  redeemedAt: option<string>,
}

type inviteChainFriendSnapshot = PreviewBridge.inviteChainFriend
type ownerProfileImageSnapshot = PreviewBridge.ownerProfileImage

@val external encodeURIComponent: string => string = "encodeURIComponent"

type editorContext = {
  viewer: option<viewerSnapshot>,
  profileId: option<string>,
  currentVersionId: option<string>,
  initialDocument: ProfileDocument.t,
  versionHistory: array<profileVersionSnapshot>,
  editSessions: array<profileEditSessionSnapshot>,
  availableInvite: option<inviteSnapshot>,
  viewerUsedInvite: option<inviteSnapshot>,
  inviteChainFriends: array<inviteChainFriendSnapshot>,
  ownerProfileImage: option<ownerProfileImageSnapshot>,
}

type historyEntry =
  | DraftEntry(PromptDrafts.item)
  | BackendRequestEntry(profileEditSessionSnapshot)
  | SavedVersionEntry(profileVersionSnapshot)
  | LocalAppliedEntry(PromptHistory.item)

type promptDraftPollJob = {
  sessionId: string,
  fallbackSelectionLabel: string,
  draftId: PromptDraftId.t,
  instruction: string,
  selectionKind: ProfileSelection.kind,
  selectionLabel: SelectionLabel.t,
  selectionSnapshot: SelectionDescription.t,
}

type codexChatPollJob = {
  sessionId: string,
  fallbackSelectionLabel: string,
  onSuccess: CodexChat.codexPatch => unit,
  onError: string => unit,
}

type activeAgentPoll =
  | PromptDraftPoll(promptDraftPollJob)
  | CodexChatPoll(codexChatPollJob)

let fixtureEditorContext = {
  viewer: None,
  profileId: None,
  currentVersionId: None,
  initialDocument: ProfileFixture.initialDocument,
  versionHistory: [],
  editSessions: [],
  availableInvite: None,
  viewerUsedInvite: None,
  inviteChainFriends: [],
  ownerProfileImage: None,
}

let inviteLinkForCode = code => DomGlobal.origin ++ "/invite/" ++ encodeURIComponent(code)

@react.component
let make = (~route=Route.Canvas, ~editorContext=fixtureEditorContext) => {
  let initialDocument = editorContext.initialDocument
  let router = RelayRouter.Utils.useRouter()
  let editorRouteParams = Routes.Editor.Route.useQueryParams()
  let editorQueryParams = editorRouteParams.queryParams
  let editorRouteLink = Routes.Editor.Route.makeLink()
  let sourceRouteLink = Routes.Editor.Source.Route.makeLink()
  let preloadEditorRoute = () => router.preload(~priority=High, editorRouteLink)
  let preloadSourceRoute = () => router.preload(~priority=High, sourceRouteLink)
  let (inviteCopyStatus, setInviteCopyStatus) = React.useState((): option<string> => None)
  let inviteModalOpen = switch editorQueryParams.invite {
  | Some(true) => true
  | Some(false) | None => false
  }
  let setInviteModalOpen = open_ => {
    if open_ {
      setInviteCopyStatus(_ => None)
    }
    editorRouteParams.setParams(
      ~setter=_params => {invite: open_ ? Some(true) : None},
      ~removeNotControlledParams=false,
    )
  }
  let openInviteModal = () => setInviteModalOpen(true)
  let (
    restoreProfileVersion,
    _restoreProfileVersionInFlight,
  ) = ProfileVersionMutations.RestoreProfileVersionMutation.use()
  let (
    startAgentEdit,
    _startAgentEditInFlight,
  ) = ProfileVersionMutations.StartAgentEditMutation.use()
  let (
    reactivateUsedInvite,
    reactivateUsedInviteInFlight,
  ) = ProfileVersionMutations.ReactivateUsedInviteMutation.use()
  let initialDocumentKey =
    ProfileDocument.htmlString(initialDocument) ++ "\n/* vibespace css */\n" ++ ProfileDocument.cssString(initialDocument)
  let editorContextKey =
    (switch editorContext.profileId {
    | Some(profileId) => profileId
    | None => "fixture"
    }) ++
    "\n" ++
    (switch editorContext.currentVersionId {
    | Some(versionId) => versionId
    | None => "none"
    }) ++
    "\n" ++
    initialDocumentKey ++
    "\n" ++
    editorContext.versionHistory
    ->Array.map(version => version.id ++ ":" ++ version.revisionNumber->Int.toString)
    ->Array.join("|") ++
    "\n" ++
    editorContext.editSessions
    ->Array.map(session => session.id ++ ":" ++ session.status ++ ":" ++ session.updatedAt)
    ->Array.join("|") ++
    "\n" ++
    (switch editorContext.availableInvite {
    | Some(invite) => invite.id ++ ":" ++ invite.status
    | None => "no-available-invite"
    }) ++
    "\n" ++
    (switch editorContext.viewerUsedInvite {
    | Some(invite) => invite.id ++ ":" ++ invite.status
    | None => "no-used-invite"
    }) ++
    "\n" ++
    (switch editorContext.viewer {
    | Some(viewer) => viewer.id ++ ":" ++ viewer.status
    | None => "no-viewer"
    })
  let debugBool = value => value ? "true" : "false"

  let exceptionMessage = caught =>
    switch caught {
    | JsExn(error) => error->JsExn.message->Option.getOr("Profile validation failed.")
    | _ => "Profile validation failed."
    }

  let debugRawId = value => value == "" ? "none" : value

  let debugPromptDraftId = id => id->PromptDraftId.toString

  let debugOptionalPromptDraftId = id =>
    switch id {
    | Some(id) => id->debugPromptDraftId
    | None => "none"
    }

  let debugOptionalRequestId = id =>
    switch id {
    | Some(id) => id->RequestId.toString
    | None => "none"
    }

  let debugOptionalProfileElementId = id =>
    switch id {
    | Some(id) => id->ProfileElementId.toString
    | None => "none"
    }

  let debugSelectionAnchor = selection =>
    switch ProfileSelection.anchor(selection) {
    | Some(anchor) =>
      "anchor=" ++
      anchor.x->Float.toInt->Int.toString ++
      "," ++
      anchor.y->Float.toInt->Int.toString ++
      " " ++
      anchor.width->Float.toInt->Int.toString ++
      "x" ++
      anchor.height->Float.toInt->Int.toString
    | None => "anchor=none"
    }

  let debugSelection = selection =>
    "kind=" ++
    selection->ProfileSelection.selectionKindLabel ++
    " requestId=" ++
    selection->ProfileSelection.requestId->debugOptionalRequestId ++
    " hasSelection=" ++
    selection->ProfileSelection.hasSelection->debugBool ++
    " " ++
    selection->debugSelectionAnchor

  let debugPayload = (payload: ProfileSelection.payload) =>
    "kind=" ++
    payload.kind ++
    " requestId=" ++
    payload.requestId->debugRawId ++
    " id=" ++
    payload.id->debugRawId ++
    " nearestId=" ++
    payload.nearestId->debugRawId ++
    " selectedCount=" ++
    payload.selectedElements->Array.length->Int.toString ++
    " hasScreenshot=" ++
    (payload.screenshotDataUrl != "")->debugBool ++
    " bounds=" ++
    payload.width->Float.toInt->Int.toString ++
    "x" ++
    payload.height->Float.toInt->Int.toString

  let debugDraft = (draft: PromptDrafts.item) =>
    "id=" ++
    draft.id->debugPromptDraftId ++
    " status=" ++
    (draft.status->PromptDrafts.statusLabel) ++
    " minimized=" ++
    draft.minimized->debugBool ++
    " empty=" ++
    draft->PromptDrafts.isEmptyDraft->debugBool ++
    " anchor=" ++
    draft.anchor.client.x->Float.toInt->Int.toString ++
    "," ++
    draft.anchor.client.y->Float.toInt->Int.toString ++
    " " ++
    draft.anchor.size.width->Float.toInt->Int.toString ++
    "x" ++
    draft.anchor.size.height->Float.toInt->Int.toString

  let debugOptionalDraft = draft =>
    switch draft {
    | Some(draft) => draft->debugDraft
    | None => "none"
    }

  let (document, setDocument) = React.useState(() => initialDocument)
  let (lastValidDocument, setLastValidDocument) = React.useState(() => initialDocument)
  let (documentValidation, setDocumentValidation) = React.useState(() => ValidationValid)
  let (selection, setSelection) = React.useState(() => ProfileSelection.empty)
  let (frameViewport, setFrameViewport) = React.useState((): BrowserBridge.frameViewport => {
    scrollX: 0.0,
    scrollY: 0.0,
    viewportWidth: 0.0,
    viewportHeight: 0.0,
  })
  let (isEditing, setIsEditing) = React.useState(() => false)
  let (historyOpen, setHistoryOpen) = React.useState(() => false)
  let (promptHistory, setPromptHistory) = React.useState(() => PromptHistory.load())
  let (currentProfileVersionId, setCurrentProfileVersionId) = React.useState(() => editorContext.currentVersionId)
  let (profileVersionHistory, setProfileVersionHistory) = React.useState(() => editorContext.versionHistory)
  let (profileEditSessionHistory, setProfileEditSessionHistory) = React.useState(() => editorContext.editSessions)
  let (viewerSnapshot, setViewerSnapshot) = React.useState(() => editorContext.viewer)
  let (availableInvite, setAvailableInvite) = React.useState(() => editorContext.availableInvite)
  let (viewerUsedInvite, setViewerUsedInvite) = React.useState(() => editorContext.viewerUsedInvite)
  let (reactivateInviteConfirmOpen, setReactivateInviteConfirmOpen) = React.useState(() => false)
  let (activeAgentPolls, setActiveAgentPolls) = React.useState((): array<activeAgentPoll> => [])
  // TODO: Support multiple simultaneous prompt bubbles anchored to different selections.
  // TODO: Promote activePromptDraft into an array of open prompt drafts with independent minimized/focused state.
  let (promptDrafts, setPromptDrafts) = React.useState(() => PromptDrafts.load())
  let (activePromptId, setActivePromptId) = React.useState(() => None)
  let (documentNotice, setDocumentNotice) = React.useState(() => None)
  let latestValidationRevision = React.useRef(ProfileDocument.revisionString(initialDocument))
  let knownValidRevision = React.useRef(ProfileDocument.revisionString(initialDocument))
  let skippedInitialValidation = React.useRef(false)

  React.useEffect1(() => {
    let revision = ProfileDocument.revisionString(initialDocument)
    latestValidationRevision.current = revision
    knownValidRevision.current = revision
    setDocument(_ => initialDocument)
    setLastValidDocument(_ => initialDocument)
    setDocumentValidation(_ => ValidationValid)
    setDocumentNotice(_ => None)
    setCurrentProfileVersionId(_ => editorContext.currentVersionId)
    setProfileVersionHistory(_ => editorContext.versionHistory)
    setProfileEditSessionHistory(_ => editorContext.editSessions)
    setViewerSnapshot(_ => editorContext.viewer)
    setAvailableInvite(_ => editorContext.availableInvite)
    setViewerUsedInvite(_ => editorContext.viewerUsedInvite)
    setReactivateInviteConfirmOpen(_ => false)
    setActiveAgentPolls(_ => [])
    setIsEditing(_ => false)
    setSelection(_ => ProfileSelection.empty)
    setHistoryOpen(_ => false)
    setActivePromptId(_ => None)
    None
  }, [editorContextKey])

  let clearEditMode = () => {
    setIsEditing(_ => false)
    setSelection(_ => ProfileSelection.empty)
    setHistoryOpen(_ => false)
  }

  let activeAgentPollKey = poll =>
    switch poll {
    | PromptDraftPoll(job) => "draft:" ++ job.sessionId
    | CodexChatPoll(job) => "codex:" ++ job.sessionId
    }

  let upsertActiveAgentPoll = poll => {
    let key = poll->activeAgentPollKey
    setActiveAgentPolls(current => [
      poll,
      ...current->Array.filter(existing => existing->activeAgentPollKey != key),
    ])
  }

  let removeActiveAgentPoll = key =>
    setActiveAgentPolls(current =>
      current->Array.filter(existing => existing->activeAgentPollKey != key)
    )

  let profileVersionSnapshot = (
    ~id: string,
    ~revisionNumber: int,
    ~html: string,
    ~css: string,
    ~summary: string,
    ~createdAt: string,
  ): profileVersionSnapshot => {
    id,
    revisionNumber,
    html: html->HtmlSource.make,
    css: css->CssSource.make,
    summary,
    createdAt,
  }

  let profileEditSessionSnapshot = (
    ~id: string,
    ~prompt: string,
    ~status: string,
    ~progressPhase: string,
    ~summary: string,
    ~error: option<string>,
    ~selectionLabel: option<string>,
    ~createdAt: string,
    ~updatedAt: string,
  ): profileEditSessionSnapshot => {
    id,
    prompt,
    status,
    progressPhase,
    summary,
    error,
    selectionLabel,
    createdAt,
    updatedAt,
  }

  let upsertProfileVersionSnapshot = (
    history: array<profileVersionSnapshot>,
    snapshot: profileVersionSnapshot,
  ): array<profileVersionSnapshot> => [
    snapshot,
    ...history->Array.filter(version => version.id != snapshot.id),
  ]

  let upsertProfileEditSessionSnapshot = (
    history: array<profileEditSessionSnapshot>,
    snapshot: profileEditSessionSnapshot,
  ): array<profileEditSessionSnapshot> => [
    snapshot,
    ...history->Array.filter(session => session.id != snapshot.id),
  ]

  let applyProfileVersionSnapshot = (snapshot: profileVersionSnapshot, ~notice: string) => {
    let nextDocument = ProfileDocument.replace(document, snapshot.html, snapshot.css)
    let nextRevision = ProfileDocument.revisionString(nextDocument)
    latestValidationRevision.current = nextRevision
    knownValidRevision.current = nextRevision
    setDocument(_ => nextDocument)
    setLastValidDocument(_ => nextDocument)
    setDocumentValidation(_ => ValidationValid)
    setSelection(_ => ProfileSelection.empty)
    setActivePromptId(_ => None)
    setCurrentProfileVersionId(_ => Some(snapshot.id))
    setProfileVersionHistory(current => current->upsertProfileVersionSnapshot(snapshot))
    setDocumentNotice(_ => Some(notice))
  }

  let restoreBackendVersion = (snapshot: profileVersionSnapshot) => {
    switch editorContext.profileId {
    | None =>
      setDocumentNotice(_ => Some("Backend history is unavailable for this local-only profile."))
    | Some(profileId) =>
      setDocumentNotice(_ => Some("Restoring Version " ++ snapshot.revisionNumber->Int.toString ++ "..."))
      restoreProfileVersion(
        ~variables={
          input: {
            profileId,
            versionId: snapshot.id,
          },
        },
        ~onCompleted=(response, errors) => {
          switch errors {
          | Some(errors) =>
            switch errors->Array.get(0) {
            | Some(error) => setDocumentNotice(_ => Some("Version restore warning: " ++ error.message))
            | None => ()
            }
          | None => ()
          }

          switch response.restoreProfileVersion {
          | ProfileVersionMutationFailed(payload) =>
            switch payload.validationErrors->Array.get(0) {
            | Some(error) => setDocumentNotice(_ => Some("Version restore validation warning: " ++ error))
            | None => setDocumentNotice(_ => Some("Version restore failed: " ++ payload.message))
            }
          | ProfileVersionMutationSucceeded(payload) =>
            let version = payload.profileVersion
            let restoredSnapshot = profileVersionSnapshot(
              ~id=version.id,
              ~revisionNumber=version.revisionNumber,
              ~html=version.html,
              ~css=version.css,
              ~summary=version.summary,
              ~createdAt=version.createdAt,
            )
            applyProfileVersionSnapshot(
              restoredSnapshot,
              ~notice=switch payload.warnings->Array.get(0) {
              | Some(warning) => "Restored Version " ++ restoredSnapshot.revisionNumber->Int.toString ++ " with warning: " ++ warning
              | None => "Restored Version " ++ restoredSnapshot.revisionNumber->Int.toString ++ "."
              },
            )
          | UnselectedUnionMember(_) =>
            setDocumentNotice(_ => Some("Version restore returned an unknown result."))
          }
        },
        ~onError=error => setDocumentNotice(_ => Some("Version restore failed: " ++ error.message)),
      )->ignore
    }
  }

  let promptProgressPhaseFromRelay = (
    phase: RelaySchemaAssets_graphql.enum_EditProgressPhase,
  ): PromptDrafts.progressPhase =>
    switch phase {
    | PREPARING => Preparing
    | PLANNING => Planning
    | CHECKING_WEB_CONTEXT => CheckingWebContext
    | EXTRACTING_ASSETS => ExtractingAssets
    | GENERATING => Generating
    | VALIDATING => Validating
    | REPAIRING => Repairing
    | APPLYING => Applying
    | FutureAddedValue(_) => Preparing
    }

  let sessionSnapshotFromPolled = (
    session: ProfileEditSessionPoller.polledProfileEditSession,
    ~fallbackSelectionLabel,
  ) =>
    profileEditSessionSnapshot(
      ~id=session.id,
      ~prompt=session.prompt,
      ~status=session.status->ProfileRelayLabels.profileEditSessionStatus,
      ~progressPhase=session.progressPhase->ProfileRelayLabels.editProgressPhase,
      ~summary=session.summary,
      ~error=session.error,
      ~selectionLabel=switch session.selectionSnapshot {
      | Some(snapshot) => Some(snapshot.label)
      | None => Some(fallbackSelectionLabel)
      },
      ~createdAt=session.createdAt,
      ~updatedAt=session.updatedAt,
    )

  React.useEffect1(() => {
    PromptHistory.save(promptHistory)
    None
  }, [promptHistory])

  React.useEffect1(() => {
    PromptDrafts.save(promptDrafts)
    None
  }, [promptDrafts])

  React.useEffect1(() => {
    if !skippedInitialValidation.current {
      skippedInitialValidation.current = true
    } else {
      let revision = ProfileDocument.revisionString(document)
      let html = ProfileDocument.html(document)
      let css = ProfileDocument.css(document)
      latestValidationRevision.current = revision
      if knownValidRevision.current == revision {
        setDocumentValidation(_ => ValidationValid)
        setLastValidDocument(_ => document)
      } else {
        setDocumentValidation(_ => ValidationChecking)

        let run = async () => {
          try {
            let validation = await ProfileValidation.validate(html, css)
            if latestValidationRevision.current == revision {
              switch validation {
              | ProfileValidation.Valid =>
                knownValidRevision.current = revision
                setDocumentValidation(_ => ValidationValid)
                setLastValidDocument(_ => document)
              | ProfileValidation.Invalid(error) =>
                setDocumentValidation(_ => ValidationInvalid(ProfileValidation.message(error)))
              }
            }
          } catch {
          | caught =>
            if latestValidationRevision.current == revision {
              setDocumentValidation(_ => ValidationInvalid(caught->exceptionMessage))
            }
          }
        }

        run()->Promise.ignore
      }
    }
    None
  }, [ProfileDocument.revisionString(document)])

  let selectedId = ProfileSelection.selectedId(selection)
  let assistantAvailable = editorContext.profileId->Option.isSome
  let documentIsValid = switch documentValidation {
  | ValidationValid => true
  | ValidationChecking | ValidationInvalid(_) => false
  }
  let activeDraft = switch activePromptId {
  | Some(id) => PromptDrafts.findById(promptDrafts, id)
  | None => None
  }
  let promptIsOpen = switch activeDraft {
  | Some(draft) => !draft.minimized
  | None => false
  }
  let selectionInteractionEnabled = isEditing && documentIsValid
  let latestPromptGate = React.useRef((activePromptId, promptIsOpen, selectionInteractionEnabled))
  latestPromptGate.current = (activePromptId, promptIsOpen, selectionInteractionEnabled)
  let activeDocumentNotice = switch documentNotice {
  | Some(message) => Some(message)
  | None =>
    switch documentValidation {
    | ValidationValid => None
    | ValidationChecking => Some("Checking profile changes...")
    | ValidationInvalid(message) => Some("Profile paused: " ++ message)
    }
  }
  let previewHtml = switch documentValidation {
  | ValidationValid => ProfileDocument.html(document)
  | ValidationChecking => ProfileDocument.html(lastValidDocument)
  | ValidationInvalid(message) => ProfileValidation.blockedHtml(message)
  }
  let previewCss = switch documentValidation {
  | ValidationValid => ProfileDocument.css(document)
  | ValidationChecking => ProfileDocument.css(lastValidDocument)
  | ValidationInvalid(_) => ProfileValidation.blockedCss
  }
  let canvasPreview = PreviewBridge.buildPreviewDocument(
    previewHtml,
    previewCss,
    selectedId,
    isEditing && documentIsValid,
    Some({friends: editorContext.inviteChainFriends}),
    editorContext.ownerProfileImage,
  )
  let sourcePreview = PreviewBridge.buildPreviewDocument(
    previewHtml,
    previewCss,
    None,
    false,
    Some({friends: editorContext.inviteChainFriends}),
    editorContext.ownerProfileImage,
  )
  let codexDisabledReason = if !assistantAvailable {
    "Assistant changes require a saved profile."
  } else if !documentIsValid {
    "Fix the profile issue before asking the assistant to update it."
  } else {
    ""
  }

  let repairCurrentDocument = () => {
    setDocumentNotice(_ => Some("Checking quick fix..."))
    let run = async () => {
      try {
        let repairedHtml = await ProfileDocument.html(document)->ProfileValidation.repairHtml
        let currentCss = ProfileDocument.css(document)
        switch await ProfileValidation.validate(repairedHtml, currentCss) {
        | ProfileValidation.Valid =>
          let nextDocument = ProfileDocument.replace(document, repairedHtml, currentCss)
          let nextRevision = ProfileDocument.revisionString(nextDocument)
          latestValidationRevision.current = nextRevision
          knownValidRevision.current = nextRevision
          setDocument(_ => nextDocument)
          setLastValidDocument(_ => nextDocument)
          setDocumentValidation(_ => ValidationValid)
          setSelection(_ => ProfileSelection.empty)
          setActivePromptId(_ => None)
          setDocumentNotice(_ => None)
        | ProfileValidation.Invalid(error) =>
          setDocumentNotice(_ =>
            Some("Quick fix could not repair this yet: " ++ ProfileValidation.message(error))
          )
        }
      } catch {
      | caught => setDocumentNotice(_ => Some("Quick fix could not repair this yet: " ++ caught->exceptionMessage))
      }
    }

    run()->Promise.ignore
  }

  let visiblePromptDrafts = promptDrafts->PromptDrafts.pruneEmptyDrafts
  let visiblePromptHistory = promptHistory->PromptHistory.pruneEmptyItems
  let visibleProfileVersionHistory = profileVersionHistory->Array.filter(version =>
    version.html->HtmlSource.toString->String.trim != "" &&
      version.css->CssSource.toString->String.trim != ""
  )
  let visibleProfileEditSessions = profileEditSessionHistory->Array.filter(session =>
    session.prompt->String.trim != "" || session.summary->String.trim != ""
  )
  let historyEntryCreatedAt = entry =>
    switch entry {
    | DraftEntry(draft) => draft.createdAt->IsoTimestamp.toString
    | BackendRequestEntry(session) => session.createdAt
    | SavedVersionEntry(version) => version.createdAt
    | LocalAppliedEntry(item) => item.createdAt->IsoTimestamp.toString
    }
  let visibleHistoryEntries = [
    ...visiblePromptDrafts->Array.map(draft => DraftEntry(draft)),
    ...visibleProfileEditSessions->Array.map(session => BackendRequestEntry(session)),
    ...visibleProfileVersionHistory->Array.map(version => SavedVersionEntry(version)),
    ...visiblePromptHistory->Array.map(item => LocalAppliedEntry(item)),
  ]
  visibleHistoryEntries->Array.sort((first, second) => {
    let firstCreatedAt = first->historyEntryCreatedAt
    let secondCreatedAt = second->historyEntryCreatedAt
    if firstCreatedAt == secondCreatedAt {
      0.0
    } else if firstCreatedAt < secondCreatedAt {
      1.0
    } else {
      -1.0
    }
  })
  let minimizedPromptDrafts = promptDrafts->Array.filter(draft =>
    draft.minimized &&
      switch draft.status->PromptDrafts.appliedSummary {
      | Some(_) => false
      | None => true
      }
  )
  let promptDebugSnapshot =
    "activePromptId=" ++
    activePromptId->debugOptionalPromptDraftId ++
    " activeDraft=" ++
    activeDraft->debugOptionalDraft ++
    " drafts=" ++
    promptDrafts->Array.length->Int.toString ++
    " visibleDrafts=" ++
    visiblePromptDrafts->Array.length->Int.toString ++
    " selection=" ++
    selection->debugSelection ++
    " selectedId=" ++
    selectedId->debugOptionalProfileElementId ++
    " historyOpen=" ++
    historyOpen->debugBool ++
    " documentIsValid=" ++
    documentIsValid->debugBool ++
    " promptIsOpen=" ++
    promptIsOpen->debugBool ++
    " selectionInteractionEnabled=" ++
    selectionInteractionEnabled->debugBool

  React.useEffect1(() => {
    BrowserBridge.debugPrompt("state", promptDebugSnapshot)
    switch (activePromptId, activeDraft) {
    | (Some(id), None) =>
      BrowserBridge.debugPrompt(
        "stale-active-prompt-id",
        "activePromptId=" ++ id->debugPromptDraftId ++ " activeDraft=none",
      )
    | (None, _) | (Some(_), Some(_)) => ()
    }
    None
  }, [promptDebugSnapshot])

  let visibleAnchor = (anchor: ProfileGeometry.anchor): ProfileGeometry.anchor => {
    let viewportWidth = frameViewport.viewportWidth > 0.0 ? frameViewport.viewportWidth : anchor.viewport.width
    let viewportHeight = frameViewport.viewportHeight > 0.0 ? frameViewport.viewportHeight : anchor.viewport.height
    ProfileGeometry.anchor(
      ~x=anchor.document.x -. frameViewport.scrollX,
      ~y=anchor.document.y -. frameViewport.scrollY,
      ~documentX=anchor.document.x,
      ~documentY=anchor.document.y,
      ~width=anchor.size.width,
      ~height=anchor.size.height,
      ~viewport=ProfileGeometry.viewport(~width=viewportWidth, ~height=viewportHeight),
    )
  }

  let handleSelectionPayload = payload => {
    let nextSelection = ProfileSelection.fromPayload(payload)
    BrowserBridge.debugPrompt("selection-payload", payload->debugPayload)
    switch (ProfileSelection.requestId(nextSelection), ProfileSelection.anchor(nextSelection)) {
    | (Some(requestId), Some(anchor)) =>
      let draftId = PromptDraftId.fromRequestId(requestId)
      let (
        latestActivePromptId,
        latestPromptIsOpen,
        latestSelectionInteractionEnabled,
      ) = latestPromptGate.current
      let shouldAccept = latestSelectionInteractionEnabled
      let replacingActiveDraft = switch latestActivePromptId {
      | Some(activeId) => !PromptDraftId.equals(activeId, draftId)
      | None => false
      }
      BrowserBridge.debugPrompt(
        shouldAccept ? "selection-accepted" : "selection-rejected",
        "draftId=" ++
        draftId->debugPromptDraftId ++
        " activePromptId=" ++
        latestActivePromptId->debugOptionalPromptDraftId ++
        " promptIsOpen=" ++
        latestPromptIsOpen->debugBool ++
        " selectionInteractionEnabled=" ++
        latestSelectionInteractionEnabled->debugBool ++
        " replacingActiveDraft=" ++
        replacingActiveDraft->debugBool,
      )
      if shouldAccept {
        let now = Now.nowIso()
        setSelection(_ => nextSelection)
        setActivePromptId(_ => Some(draftId))
        setPromptDrafts(current =>
          {
            let current = switch latestActivePromptId {
            | Some(activeId) if !PromptDraftId.equals(activeId, draftId) =>
              switch PromptDrafts.findById(current, activeId) {
              | Some(activeDraft) if activeDraft->PromptDrafts.isEmptyDraft =>
                PromptDrafts.removeById(current, activeId)
              | Some(_) | None => PromptDrafts.setMinimized(current, activeId, true, now)
              }
            | Some(_) | None => current
            }
            let current = PromptDrafts.upsertSelection(
              current,
              ~id=draftId,
              ~selectionKind=ProfileSelection.kind(nextSelection),
              ~selectionLabel=ProfileSelection.label(nextSelection),
              ~selectionSnapshot=ProfileSelection.agentContext(nextSelection),
              ~selectedRegionScreenshotDataUrl=ProfileSelection.screenshotDataUrl(nextSelection),
              ~anchor,
              ~now,
            )
            PromptDrafts.setMinimized(current, draftId, false, now)
          }
        )
      }
    | (None, _) | (_, None) =>
      BrowserBridge.debugPrompt(
        "selection-ignored",
        "reason=missing-request-or-anchor " ++ nextSelection->debugSelection,
      )
    }
  }

  let updateDraftPrompt = (draftId, nextPrompt) => {
    setPromptDrafts(current => PromptDrafts.updatePrompt(current, draftId, nextPrompt, Now.nowIso()))
  }

  let setDraftMinimized = (draftId, minimized) => {
    setPromptDrafts(current => PromptDrafts.setMinimized(current, draftId, minimized, Now.nowIso()))
  }

  let activateDraft = draftId => {
    let now = Now.nowIso()
    setPromptDrafts(current =>
      {
        let current = switch activePromptId {
        | Some(activeId) if !PromptDraftId.equals(activeId, draftId) =>
          switch PromptDrafts.findById(current, activeId) {
          | Some(activeDraft) if activeDraft->PromptDrafts.isEmptyDraft =>
            PromptDrafts.removeById(current, activeId)
          | Some(_) | None => PromptDrafts.setMinimized(current, activeId, true, now)
          }
        | Some(_) | None => current
        }
        PromptDrafts.setMinimized(current, draftId, false, now)
      }
    )
    setActivePromptId(_ => Some(draftId))
    setHistoryOpen(_ => false)
  }

  let minimizeDraft = draftId => {
    setDraftMinimized(draftId, true)
    switch activePromptId {
    | Some(activeId) if PromptDraftId.equals(activeId, draftId) => setActivePromptId(_ => None)
    | Some(_) | None => ()
    }
  }

  let assistantModeInput = (mode: CodexChat.mode): RelaySchemaAssets_graphql.enum_AssistantEditMode_input =>
    switch mode {
    | CodexChat.Fast => FAST
    | CodexChat.Reasoning => REASONING
    }

  let firstPayloadError = (~error: option<string>, ~validationErrors: array<string>) =>
    switch error {
    | Some(message) => Some(message)
    | None => validationErrors->Array.get(0)
    }

  let failedPatchFields = (failedPatch: option<PromptDrafts.failedPatch>) =>
    switch failedPatch {
    | Some(patch) => (
        patch.html->HtmlSource.toString,
        patch.css->CssSource.toString,
        patch.summary->PatchSummary.toString,
        patch.warnings->PatchWarnings.toString,
        patch.validationMessage->ValidationMessage.toString,
      )
    | None => ("", "", "", "", "")
    }

  let closeDraft = draftId => {
    let existingDraft = promptDrafts->PromptDrafts.findById(draftId)
    let draftWasEmpty = switch existingDraft {
    | Some(draft) => draft->PromptDrafts.isEmptyDraft
    | None => true
    }
    BrowserBridge.debugPrompt(
      "close-draft",
      "draftId=" ++
      draftId->debugPromptDraftId ++
      " exists=" ++
      existingDraft->Option.isSome->debugBool ++
      " empty=" ++
      draftWasEmpty->debugBool ++
      " activeBefore=" ++
      activePromptId->debugOptionalPromptDraftId ++
      " draftsBefore=" ++
      promptDrafts->Array.length->Int.toString ++
      " historyAfter=" ++
      (!draftWasEmpty)->debugBool,
    )
    setPromptDrafts(current =>
      if draftWasEmpty {
        current->PromptDrafts.removeById(draftId)
      } else {
        PromptDrafts.markTouched(current, draftId, Now.nowIso())
      }
    )
    setActivePromptId(_ => None)
    setHistoryOpen(_ => !draftWasEmpty)
    BrowserBridge.debugPrompt(
      "close-draft-dispatched",
      "draftId=" ++ draftId->debugPromptDraftId ++ " activeAfter=none",
    )
  }

  let deleteDraft = draftId => {
    BrowserBridge.debugPrompt("history-delete-draft", "draftId=" ++ draftId->debugPromptDraftId)
    setPromptDrafts(current => current->PromptDrafts.removeById(draftId))
    switch activePromptId {
    | Some(activeId) if PromptDraftId.equals(activeId, draftId) => setActivePromptId(_ => None)
    | Some(_) | None => ()
    }
  }

  let submitDraftToAssistant = (draft: PromptDrafts.item) => {
    let instruction = draft.prompt->PromptText.trim
    if instruction != "" {
      let submittedAt = Now.nowIso()
      let failDraft = message =>
        setPromptDrafts(current => PromptDrafts.markError(current, draft.id, message, Now.nowIso()))
      setPromptDrafts(current => PromptDrafts.markSubmitting(current, draft.id, submittedAt))
      switch editorContext.profileId {
      | Some(profileId) =>
        let (
          previousFailedHtml,
          previousFailedCss,
          previousFailedSummary,
          previousFailedWarnings,
          previousFailedValidationMessage,
        ) = draft.failedPatch->failedPatchFields
        let inputWithCurrentVersion = (currentVersionId): RelaySchemaAssets_graphql.input_SubmitAgentEditInput => {
          profileId,
          currentVersionId,
          prompt: instruction,
          selectionLabel: draft.selection.label->SelectionLabel.toString,
          selectionAgentContext: draft.selection.snapshot->SelectionDescription.toString,
          selectedRegionScreenshotDataUrl: draft.selection.selectedRegionScreenshotDataUrl->Option.mapOr(
            "",
            DataUrl.toString,
          ),
          fullPageScreenshotDataUrl: "",
          previousFailedHtml,
          previousFailedCss,
          previousFailedSummary,
          previousFailedWarnings,
          previousFailedValidationMessage,
          mode: FAST,
        }
        let inputWithoutCurrentVersion: RelaySchemaAssets_graphql.input_SubmitAgentEditInput = {
          profileId,
          prompt: instruction,
          selectionLabel: draft.selection.label->SelectionLabel.toString,
          selectionAgentContext: draft.selection.snapshot->SelectionDescription.toString,
          selectedRegionScreenshotDataUrl: draft.selection.selectedRegionScreenshotDataUrl->Option.mapOr(
            "",
            DataUrl.toString,
          ),
          fullPageScreenshotDataUrl: "",
          previousFailedHtml,
          previousFailedCss,
          previousFailedSummary,
          previousFailedWarnings,
          previousFailedValidationMessage,
          mode: FAST,
        }
        let input = switch currentProfileVersionId {
        | Some(currentVersionId) => inputWithCurrentVersion(currentVersionId)
        | None => inputWithoutCurrentVersion
        }
        startAgentEdit(
          ~variables={input: input},
          ~onCompleted=(response, errors) => {
            let graphQLError = switch errors {
            | Some(errors) => errors->Array.get(0)->Option.map(error => error.message)
            | None => None
            }

            switch graphQLError {
            | Some(message) =>
              setDocumentNotice(_ => Some("Assistant request failed: " ++ message))
              failDraft(message)
            | None =>
              switch response.startAgentEdit {
              | ProfileEditSessionMutationSucceeded(payload) =>
                let session = payload.succeededEditSession
                let sessionSnapshot = profileEditSessionSnapshot(
                  ~id=session.id,
                  ~prompt=session.prompt,
                  ~status=session.status->ProfileRelayLabels.profileEditSessionStatus,
                  ~progressPhase=session.progressPhase->ProfileRelayLabels.editProgressPhase,
                  ~summary=session.summary,
                  ~error=session.error,
                  ~selectionLabel=switch session.selectionSnapshot {
                  | Some(snapshot) => Some(snapshot.label)
                  | None => Some(draft.selection.label->SelectionLabel.toString)
                  },
                  ~createdAt=session.createdAt,
                  ~updatedAt=session.updatedAt,
                )
                setProfileEditSessionHistory(current =>
                  current->upsertProfileEditSessionSnapshot(sessionSnapshot)
                )
                setHistoryOpen(_ => true)

                switch firstPayloadError(
                  ~error=None,
                  ~validationErrors=payload.validationErrors,
                ) {
                | Some(message) =>
                  setDocumentNotice(_ => Some("Assistant request failed: " ++ message))
                  failDraft(message)
                | None =>
                  upsertActiveAgentPoll(
                    PromptDraftPoll({
                      sessionId: session.id,
                      fallbackSelectionLabel: draft.selection.label->SelectionLabel.toString,
                      draftId: draft.id,
                      instruction,
                      selectionKind: draft.selection.kind,
                      selectionLabel: draft.selection.label,
                      selectionSnapshot: draft.selection.snapshot,
                    }),
                  )
                }
              | ProfileEditSessionMutationFailed(payload) =>
                payload.failedEditSession->Option.forEach(session => {
                  let sessionSnapshot = profileEditSessionSnapshot(
                    ~id=session.id,
                    ~prompt=session.prompt,
                    ~status=session.status->ProfileRelayLabels.profileEditSessionStatus,
                    ~progressPhase=session.progressPhase->ProfileRelayLabels.editProgressPhase,
                    ~summary=session.summary,
                    ~error=session.error,
                    ~selectionLabel=switch session.selectionSnapshot {
                    | Some(snapshot) => Some(snapshot.label)
                    | None => Some(draft.selection.label->SelectionLabel.toString)
                    },
                    ~createdAt=session.createdAt,
                    ~updatedAt=session.updatedAt,
                  )
                  setProfileEditSessionHistory(current =>
                    current->upsertProfileEditSessionSnapshot(sessionSnapshot)
                  )
                })
                let message = firstPayloadError(
                  ~error=Some(payload.message),
                  ~validationErrors=payload.validationErrors,
                )->Option.getOr(payload.message)
                setDocumentNotice(_ => Some("Assistant request failed: " ++ message))
                failDraft(message)
              | UnselectedUnionMember(_) =>
                let message = "Assistant request returned an unknown result."
                setDocumentNotice(_ => Some(message))
                failDraft(message)
              }
            }
          },
          ~onError=error => {
            setDocumentNotice(_ => Some("Assistant request failed: " ++ error.message))
            failDraft(error.message)
          },
        )->ignore
      | None =>
        let message = "Assistant changes require a saved profile."
        setDocumentNotice(_ => Some(message))
        failDraft(message)
      }
    }
  }

  let restoreHistoryItem = (item: PromptHistory.item) => {
    switch (item->PromptHistory.snapshotHtml, item->PromptHistory.snapshotCss) {
    | (Some(html), Some(css)) =>
      setDocumentNotice(_ => Some("Checking history item..."))
      let run = async () => {
        try {
          switch await ProfileValidation.validate(html, css) {
          | ProfileValidation.Valid =>
            let nextDocument = ProfileDocument.replace(document, html, css)
            let nextRevision = ProfileDocument.revisionString(nextDocument)
            latestValidationRevision.current = nextRevision
            knownValidRevision.current = nextRevision
            setDocument(_ => nextDocument)
            setLastValidDocument(_ => nextDocument)
            setDocumentValidation(_ => ValidationValid)
            setSelection(_ => ProfileSelection.empty)
            setActivePromptId(_ => None)
            setDocumentNotice(_ => Some("Restored profile from history."))
          | ProfileValidation.Invalid(error) =>
            setDocumentNotice(_ =>
              Some("History restore failed: " ++ ProfileValidation.message(error))
            )
          }
        } catch {
        | caught => setDocumentNotice(_ => Some("History restore failed: " ++ caught->exceptionMessage))
        }
      }
      run()->Promise.ignore
    | _ =>
      setDocumentNotice(_ =>
        Some(
          "This history item cannot be restored because it was saved before profile snapshots existed.",
        )
      )
    }
  }

  let kickerClass = "m-0 mb-1 text-[11px] font-black uppercase tracking-wider text-neutral-500"
  let mutedClass = "m-0 text-sm leading-snug text-neutral-500"
  let historySidebarClass = "absolute bottom-[18px] right-[18px] top-[72px] z-[34] flex w-[min(340px,calc(100vw-36px))] flex-col overflow-hidden rounded-lg border border-neutral-200 bg-white/95 shadow-2xl backdrop-blur-md max-md:bottom-2.5 max-md:right-2.5 max-md:top-[58px]"
  let historyHeaderClass = "flex items-center justify-between gap-3 border-b border-neutral-200 px-3.5 py-3"
  let historyItemClass = "grid w-full gap-2 rounded-lg border border-neutral-200 bg-white p-3 text-left text-inherit shadow-sm"
  let historyButtonItemClass = historyItemClass ++ " cursor-pointer transition hover:-translate-y-px hover:border-neutral-950 hover:shadow-[4px_4px_0_rgb(23_23_23_/_0.14)] focus-visible:border-neutral-950 focus-visible:shadow-[4px_4px_0_rgb(23_23_23_/_0.14)] focus-visible:outline-none"
  let historyDraftButtonClass = historyButtonItemClass ++ " pr-10"
  let historyDeleteButtonClass = "absolute right-2 top-2"
  let historyToplineClass = "flex items-start justify-between gap-2"
  let historyTitleClass = "min-w-0 break-words text-sm font-bold leading-snug text-neutral-950"
  let historyStatusClass = "shrink-0 rounded-full bg-neutral-100 px-2 py-0.5 text-[11px] font-bold leading-tight text-neutral-700"
  let historyAppliedStatusClass = "shrink-0 rounded-full bg-green-100 px-2 py-0.5 text-[11px] font-bold leading-tight text-green-800"
  let historyContextClass = "break-words text-xs leading-snug text-neutral-500"
  let historyActionsClass = "flex justify-end"

  let renderHistorySidebar = () =>
    if historyOpen {
      <aside className=historySidebarClass>
        <header className=historyHeaderClass>
          <div>
            <p className=kickerClass> {React.string("History")} </p>
            <h2 className="m-0 text-lg font-bold leading-tight text-neutral-950"> {React.string("Requests")} </h2>
          </div>
          <Button variant=Ghost size=IconSm type_="button" title="Close history" onClick={_ => setHistoryOpen(_ => false)}>
            <Icons.X size=16 ariaHidden=true />
          </Button>
        </header>
        <ScrollArea className="min-h-0 flex-1">
          <div className="grid content-start gap-4 p-3">
            {visibleHistoryEntries->Array.length == 0
              ? <p className=mutedClass> {React.string("Drafts and applied changes will appear here.")} </p>
              : React.null}
            {visibleHistoryEntries
            ->Array.map(entry =>
              switch entry {
              | DraftEntry(draft) =>
                let key = "draft-" ++ draft.id->PromptDraftId.toString
                <article className="relative" key>
                    <button
                      className=historyDraftButtonClass
                      type_="button"
                      onClick={_ => {
                        BrowserBridge.debugPrompt("history-reopen-draft", draft->debugDraft)
                        activateDraft(draft.id)
                      }}>
                      <span className=historyToplineClass>
                        <span className=historyTitleClass>
                          {React.string(AppHelpers.shortText(draft.prompt->PromptText.toString))}
                        </span>
                        <span className=historyStatusClass>
                          {React.string(draft.status->PromptDrafts.statusLabel)}
                        </span>
                      </span>
                      <span className=historyContextClass>
                        {React.string(
                          draft.selection.kind->ProfileSelection.kindLabel ++
                          " - " ++
                          draft.selection.label->SelectionLabel.toString,
                        )}
                      </span>
                    </button>
                    <Button
                      className=historyDeleteButtonClass
                      variant=Ghost
                      size=IconXs
                      type_="button"
                      title="Delete draft"
                      onClick={(event: ReactEvent.Mouse.t) => {
                        ReactEvent.Mouse.stopPropagation(event)
                        deleteDraft(draft.id)
                      }}>
                      <Icons.X size=14 ariaHidden=true />
                    </Button>
                  </article>
              | BackendRequestEntry(session) =>
                let key = "backend-session-" ++ session.id
                <article className=historyItemClass key>
                  <span className=historyToplineClass>
                    <span className=historyTitleClass>
                      {React.string(AppHelpers.shortText(session.prompt))}
                    </span>
                    <span className=historyStatusClass>
                      {React.string(session.status)}
                    </span>
                  </span>
                  <span className=historyContextClass>
                    {React.string(
                      session.progressPhase ++
                      " - " ++
                      session.selectionLabel->Option.getOr("Profile request"),
                    )}
                  </span>
                  {session.error->Option.mapOr(React.null, error =>
                    <span className=historyContextClass>
                      {React.string(error)}
                    </span>
                  )}
                </article>
              | SavedVersionEntry(version) =>
                let key = "backend-version-" ++ version.id
                let isCurrent = switch currentProfileVersionId {
                | Some(versionId) => versionId == version.id
                | None => false
                }
                <article className={historyItemClass ++ " opacity-90"} key>
                  <span className=historyToplineClass>
                    <span className=historyTitleClass>
                      {React.string(version.summary)}
                    </span>
                    <span className=historyAppliedStatusClass>
                      {React.string("Version " ++ version.revisionNumber->Int.toString)}
                    </span>
                  </span>
                  <span className=historyContextClass>
                    {React.string(version.createdAt)}
                  </span>
                  <div className=historyActionsClass>
                    <Button
                      variant={isCurrent ? Secondary : Outline}
                      size=Sm
                      type_="button"
                      disabled=isCurrent
                      onClick={_ => restoreBackendVersion(version)}>
                      {React.string(isCurrent ? "Current" : "Revert")}
                    </Button>
                  </div>
                </article>
              | LocalAppliedEntry(item) =>
                let key = "history-" ++ item.id->PromptHistoryId.toString
                <article className={historyItemClass ++ " opacity-90"} key>
                  <span className=historyToplineClass>
                    <span className=historyTitleClass>
                      {React.string(item->PromptHistory.promptString)}
                    </span>
                    <span className=historyAppliedStatusClass>
                      {React.string(item->PromptHistory.revisionLabel)}
                    </span>
                  </span>
                  <span className=historyContextClass>
                    {React.string(
                      item->PromptHistory.selectionKind->ProfileSelection.kindLabel ++
                      " - " ++
                      item->PromptHistory.selectionLabelString,
                    )}
                  </span>
                  <div className=historyActionsClass>
                    <Button
                      variant=Outline
                      size=Sm
                      type_="button"
                      onClick={_ => restoreHistoryItem(item)}>
                      {React.string("Revert")}
                    </Button>
                  </div>
                </article>
              }
            )
            ->React.array}
          </div>
        </ScrollArea>
      </aside>
    } else {
      React.null
    }

  let copyInviteLink = inviteLink => {
    setInviteCopyStatus(_ => Some("Copying..."))
    let run = async () => {
      try {
        await Clipboard.writeText(DomGlobal.navigator->Navigator.clipboard, inviteLink)
        setInviteCopyStatus(_ => Some("Copied."))
      } catch {
      | _ => setInviteCopyStatus(_ => Some("Copy failed. Select the link and copy it manually."))
      }
    }

    run()->Promise.ignore
  }

  let viewerIsDisabled = switch viewerSnapshot {
  | Some(viewer) => viewer.status == "Disabled"
  | None => false
  }

  let inviteIsAvailable = invite => invite.status == "Available"
  let inviteIsRedeemed = invite => invite.status == "Redeemed"

  let shareableInvite = switch availableInvite {
  | Some(invite) if !viewerIsDisabled && invite->inviteIsAvailable =>
    switch invite.code {
    | Some(code) => Some((invite, code->inviteLinkForCode))
    | None => None
    }
  | Some(_) | None => None
  }

  let renderActiveInviteGiftButton = () =>
    switch shareableInvite {
    | Some(_) =>
      <Button
        className="relative size-11 overflow-visible rounded-2xl border-amber-200 bg-amber-300 text-neutral-950 shadow-xl shadow-amber-500/25 hover:bg-amber-200"
        variant=Outline
        size=IconLg
        type_="button"
        title="Open invite"
        onClick={_ => openInviteModal()}>
        <span
          className="absolute inset-0 rounded-2xl bg-amber-300/45 animate-ping motion-reduce:animate-none"
          ariaHidden=true
        />
        <span
          className="relative inline-grid size-full place-items-center animate-[bounce_2.6s_ease-in-out_infinite] motion-reduce:animate-none"
          ariaHidden=true>
          <Icons.Gift size=20 ariaHidden=true />
        </span>
        <span className="sr-only"> {React.string("Open invite")} </span>
      </Button>
    | None => React.null
    }

  let reactivateUsedInviteCode = () => {
    setDocumentNotice(_ => Some("Reactivating the invite code..."))
    reactivateUsedInvite(
      ~variables={input: {confirmDisable: true}},
      ~onCompleted=(response, errors) => {
        let graphQLError = switch errors {
        | Some(errors) => errors->Array.get(0)->Option.map(error => error.message)
        | None => None
        }

        switch graphQLError {
        | Some(message) => setDocumentNotice(_ => Some("Invite reactivation failed: " ++ message))
        | None =>
          switch response.reactivateUsedInvite {
          | MutationFailed({message}) =>
            setDocumentNotice(_ => Some("Invite reactivation failed: " ++ message))
          | ReactivateUsedInviteSucceeded(payload) =>
            let user = payload.user
            let invite = payload.invite
            setViewerSnapshot(_ =>
              Some({
                id: user.id,
                status: user.status->ProfileRelayLabels.userStatus,
              })
            )
            setAvailableInvite(_ => None)
            setViewerUsedInvite(_ =>
              Some({
                id: invite.id,
                code: invite.code,
                status: invite.status->ProfileRelayLabels.inviteStatus,
                redeemedAt: invite.redeemedAt,
              })
            )
            setReactivateInviteConfirmOpen(_ => false)
            setInviteModalOpen(false)
            setDocumentNotice(_ =>
              Some("Your account is disabled. The invite code you used is available again.")
            )
          | UnselectedUnionMember(_) =>
            setDocumentNotice(_ => Some("Invite reactivation returned an unknown result."))
          }
        }
      },
      ~onError=error => setDocumentNotice(_ => Some("Invite reactivation failed: " ++ error.message)),
    )->ignore
  }

  let renderInviteModal = () => {
    <BaseUi.Dialog.Root
      open_=inviteModalOpen
      modal={BaseUi.Types.Modal.Bool(false)}
      onOpenChange={(open_, _details) => setInviteModalOpen(open_)}>
      <BaseUi.Dialog.Portal>
        <BaseUi.Dialog.Popup className="fixed bottom-4 right-4 z-[91] w-[min(380px,calc(100vw-32px))] rounded-lg border border-white/70 bg-white p-4 text-neutral-950 shadow-2xl max-md:bottom-3 max-md:right-3 max-md:w-[calc(100vw-24px)]">
          <div className="mb-3 flex items-start justify-between gap-2.5">
            <span className="inline-grid size-9 place-items-center rounded-lg bg-neutral-950 text-amber-200 shadow-lg" ariaHidden=true>
              <Icons.Gift size=18 ariaHidden=true />
            </span>
            <BaseUi.Dialog.Close className="inline-grid size-8 cursor-pointer place-items-center rounded-full border-0 bg-neutral-100 text-neutral-900 hover:bg-neutral-200" ariaLabel="Close invite">
              <Icons.X size=16 ariaHidden=true />
            </BaseUi.Dialog.Close>
          </div>
          <BaseUi.Dialog.Title className="m-0 text-2xl font-black leading-none tracking-normal">
            {React.string("One invite")}
          </BaseUi.Dialog.Title>
          <BaseUi.Dialog.Description className="mt-3 text-sm leading-relaxed text-neutral-600">
            {React.string(
              "Every new Vibespace user gets one invite. Once it is used, it is gone. Pick someone who will make something worth visiting, because it is on you to make sure the vibe does not die.",
            )}
          </BaseUi.Dialog.Description>
          {switch shareableInvite {
          | Some((invite, inviteLink)) =>
            <div className="mt-4 rounded-lg border border-neutral-200 bg-neutral-50 p-3.5">
              <span className="block text-[11px] font-black uppercase tracking-wider text-amber-700">
                {React.string("Invite " ++ invite.status->String.toLowerCase)}
              </span>
              <p className="mt-2 break-all text-sm leading-snug text-neutral-950"> {React.string(inviteLink)} </p>
              <div className="mt-3.5 flex flex-wrap items-center gap-2.5">
                <Button
                  className="shadow-md"
                  type_="button"
                  onClick={_ => copyInviteLink(inviteLink)}>
                  <Icons.Copy size=14 ariaHidden=true />
                  {React.string("Copy link")}
                </Button>
                {inviteCopyStatus->Option.mapOr(React.null, status =>
                  <span className="text-xs font-bold text-neutral-500"> {React.string(status)} </span>
                )}
              </div>
            </div>
          | None =>
            <div className="mt-4 rounded-lg border border-neutral-200 bg-neutral-50/70 p-3.5">
              <span className="block text-[11px] font-black uppercase tracking-wider text-amber-700"> {React.string("No invite available")} </span>
              <p className="mt-2 break-words text-sm leading-snug text-neutral-950">
                {React.string("Your invite is not available yet, it has already been used, or this account is disabled.")}
              </p>
            </div>
          }}
        </BaseUi.Dialog.Popup>
      </BaseUi.Dialog.Portal>
    </BaseUi.Dialog.Root>
  }

  let renderReactivateInviteDialog = () =>
    <BaseUi.Dialog.Root
      open_=reactivateInviteConfirmOpen
      modal={BaseUi.Types.Modal.Bool(true)}
      onOpenChange={(open_, _details) => setReactivateInviteConfirmOpen(_ => open_)}>
      <BaseUi.Dialog.Portal>
        <BaseUi.Dialog.Backdrop className="fixed inset-0 z-[90] bg-neutral-950/50 backdrop-blur-md" />
        <BaseUi.Dialog.Popup className="fixed left-1/2 top-1/2 z-[91] w-[min(460px,calc(100vw-32px))] -translate-x-1/2 -translate-y-1/2 rounded-3xl border border-red-200 bg-white p-6 text-neutral-950 shadow-2xl">
          <div className="mb-3.5 flex items-center justify-between gap-2.5">
            <span className="inline-grid size-10 place-items-center rounded-2xl bg-red-50 text-red-700 shadow-lg" ariaHidden=true>
              <Icons.ShieldAlert size=18 ariaHidden=true />
            </span>
            <BaseUi.Dialog.Close className="inline-grid size-8 cursor-pointer place-items-center rounded-full border-0 bg-neutral-100 text-neutral-900 hover:bg-neutral-200" ariaLabel="Cancel invite reactivation">
              <Icons.X size=16 ariaHidden=true />
            </BaseUi.Dialog.Close>
          </div>
          <BaseUi.Dialog.Title className="m-0 text-3xl font-black leading-none tracking-normal">
            {React.string("Disable this account?")}
          </BaseUi.Dialog.Title>
          <BaseUi.Dialog.Description className="mt-3 text-sm leading-relaxed text-neutral-600">
            {React.string(
              "This reactivates the invite link you used, but disables your account and hides it from the invite chain. Your profile data stays in the database, but this account will no longer be an active Vibespace account.",
            )}
          </BaseUi.Dialog.Description>
          <div className="mt-5 flex flex-wrap justify-end gap-2.5">
            <Button
              variant=Outline
              type_="button"
              disabled=reactivateUsedInviteInFlight
              onClick={_ => setReactivateInviteConfirmOpen(_ => false)}>
              {React.string("Cancel")}
            </Button>
            <Button
              className="border-red-200 bg-red-600 text-white hover:bg-red-700"
              variant=Destructive
              type_="button"
              disabled=reactivateUsedInviteInFlight
              onClick={_ => reactivateUsedInviteCode()}>
              {reactivateUsedInviteInFlight
                ? React.string("Disabling...")
                : React.string("Disable account")}
            </Button>
          </div>
        </BaseUi.Dialog.Popup>
      </BaseUi.Dialog.Portal>
    </BaseUi.Dialog.Root>

  let renderAdvancedInviteControls = () => {
    let canReactivateUsedInvite = switch viewerUsedInvite {
    | Some(invite) => !viewerIsDisabled && invite->inviteIsRedeemed
    | None => false
    }
    let activeInviteIsShareable = switch shareableInvite {
    | Some(_) => true
    | None => false
    }
    let showClaimedInviteControls = !activeInviteIsShareable && canReactivateUsedInvite

    if !showClaimedInviteControls {
      React.null
    } else {
      <section className="mx-auto mt-4 grid w-[min(760px,100%)] gap-4">
        <Card className="border-red-200 bg-white">
          <Card.Header className="flex items-center justify-between gap-3">
            <div>
              <p className="m-0 mb-1 text-[11px] font-black uppercase tracking-wider text-red-700">
                {React.string("Claimed invite")}
              </p>
              <Card.Title> {React.string("Reactivate your invite link")} </Card.Title>
              <Card.Description>
                {React.string("Give back the invite code you used by disabling this account.")}
              </Card.Description>
            </div>
            <Card.Action>
              <span className="inline-grid size-10 place-items-center rounded-2xl bg-red-50 text-red-700" ariaHidden=true>
                <Icons.RefreshCcw size=18 ariaHidden=true />
              </span>
            </Card.Action>
          </Card.Header>
          <Card.Content className="grid gap-3">
            {switch viewerUsedInvite {
            | Some(invite) =>
              <div className="rounded-2xl border border-neutral-200 bg-neutral-50 p-3.5">
                <div className="flex flex-wrap items-center justify-between gap-2">
                  <span className="text-[11px] font-black uppercase tracking-wider text-neutral-500">
                    {React.string("Used invite " ++ invite.status->String.toLowerCase)}
                  </span>
                  {invite.redeemedAt->Option.mapOr(React.null, redeemedAt =>
                    <span className="text-xs font-bold text-neutral-500"> {React.string(redeemedAt)} </span>
                  )}
                </div>
                <p className="mt-2 mb-0 text-sm leading-relaxed text-neutral-600">
                  {React.string("Reactivation makes this invite usable again and disables this account.")}
                </p>
              </div>
            | None => React.null
            }}
            <div className="flex justify-end">
              <Button
                className="border-red-200"
                variant=Destructive
                type_="button"
                disabled={!canReactivateUsedInvite || reactivateUsedInviteInFlight}
                onClick={_ => setReactivateInviteConfirmOpen(_ => true)}>
                {React.string("Reactivate invite code")}
              </Button>
            </div>
          </Card.Content>
        </Card>
      </section>
    }
  }

  let renderSelectionOverlay = () =>
    switch ProfileSelection.anchor(selection) {
    | Some(anchor) =>
      switch selection {
        | ProfileSelection.Area(_) =>
        let anchor = anchor->visibleAnchor
        <div
          className="pointer-events-none absolute z-[18] border-2 border-blue-500/90 bg-blue-500/10 shadow-[0_0_0_1px_rgb(255_255_255_/_0.9),0_12px_34px_rgb(30_64_175_/_0.18),0_0_0_9999px_rgb(0_0_0_/_0.10)]"
          style={{
            left: anchor.x->Float.toString ++ "px",
            top: anchor.y->Float.toString ++ "px",
            width: anchor.width->Float.toString ++ "px",
            height: anchor.height->Float.toString ++ "px",
          }}
        />
      | ProfileSelection.Element(_) | ProfileSelection.NoSelection => React.null
      }
    | None => React.null
    }

  let renderMinimizedPromptTray = () =>
    if minimizedPromptDrafts->Array.length == 0 {
      React.null
    } else {
      <div className="pointer-events-none absolute bottom-4 left-4 z-[31] flex flex-col-reverse gap-2.5 max-md:bottom-3 max-md:left-3 max-md:max-w-[calc(100vw-24px)] max-md:flex-row max-md:overflow-x-auto max-md:p-1" ariaLabel="Minimized edit requests">
        {minimizedPromptDrafts
        ->Array.mapWithIndex((draft, _index) => {
          let key = "minimized-" ++ draft.id->PromptDraftId.toString
          let draftIsSubmitting = draft.status->PromptDrafts.isSubmitting
          let title = if draftIsSubmitting {
            draft.status->PromptDrafts.statusLabel
          } else {
            AppHelpers.shortText(draft.prompt->PromptText.toString)
          }
          <Button
            className="pointer-events-auto relative size-11 rounded-full border-white/70 bg-blue-500 text-white shadow-xl shadow-blue-900/25 hover:-translate-y-px hover:shadow-2xl focus-visible:ring-blue-300"
            key
            variant=Default
            size=IconLg
            type_="button"
            title={"Open edit request: " ++ title}
            onClick={_ => activateDraft(draft.id)}>
            <Icons.Sparkles size=20 ariaHidden=true />
            {draftIsSubmitting ? <span className="absolute right-1.5 top-1.5 size-2 rounded-full bg-white shadow-[0_0_0_3px_rgb(255_255_255_/_0.28)] animate-pulse" /> : React.null}
          </Button>
        })
        ->React.array}
      </div>
    }

  let renderPromptBubble = () =>
    switch activeDraft {
    | Some(draft) if !draft.minimized =>
      let draftAnchor = switch (ProfileSelection.requestId(selection), ProfileSelection.anchor(selection)) {
      | (Some(requestId), Some(anchor)) if PromptDraftId.equals(
          draft.id,
          PromptDraftId.fromRequestId(requestId),
        ) => Some(anchor)
      | _ => AppHelpers.anchorFromDraft(draft)
      }
      switch draftAnchor {
      | None => React.null
      | Some(anchor) =>
      let anchor = anchor->visibleAnchor
      let position = AppHelpers.positionForAnchor(anchor)
      let draftIsSubmitting = draft.status->PromptDrafts.isSubmitting
      let draftStatusLabel = draft.status->PromptDrafts.statusLabel
      let composerNotice = draft.notice->DraftNotice.isBlank
        ? React.null
        : <p className="m-0 max-w-[36ch] min-w-0 break-words text-xs font-bold leading-snug text-amber-800">
            {React.string(draft.notice->DraftNotice.toString)}
          </p>
      let failedPatchNotice = draft->PromptDrafts.hasFailedPatch
        ? <p className="m-0 max-w-[36ch] min-w-0 break-words text-xs font-bold leading-snug text-amber-800">
            {React.string("Saved failed output is attached to the next update for repair.")}
          </p>
        : React.null
      let composerStatus = if draftIsSubmitting {
        <div className="inline-flex w-fit min-w-0 items-center gap-2 rounded-full text-xs font-bold leading-tight text-neutral-500" role="status">
          <span className="size-2 rounded-full bg-blue-500 shadow-[0_0_0_4px_rgb(59_130_246_/_0.14)] animate-pulse" />
          <span> {React.string(draftStatusLabel)} </span>
        </div>
      } else {
        switch draft.status->PromptDrafts.errorMessage {
        | Some(message) => <p className="m-0 min-w-0 break-words text-xs font-bold leading-snug text-red-700"> {React.string(message)} </p>
        | None =>
          !assistantAvailable && codexDisabledReason != ""
            ? <p className="m-0 min-w-0 break-words text-xs leading-snug text-neutral-500"> {React.string(codexDisabledReason)} </p>
            : React.null
        }
      }
      <section
        className="absolute z-30 w-[min(420px,calc(100vw-24px))] max-h-[calc(100vh-88px)] overflow-visible max-md:!bottom-3 max-md:!left-3 max-md:!right-3 max-md:!top-auto max-md:!w-auto max-md:max-h-[calc(100vh-24px)]"
        style={{
          left: position.left->Float.toString ++ "px",
          top: position.top->Float.toString ++ "px",
        }}>
        <Card className="gap-0 rounded-xl border border-neutral-200 bg-white/95 p-0 shadow-2xl backdrop-blur-xl">
          <Card.Header className="flex items-center justify-between gap-3 px-3 py-2">
            <div className="flex min-w-0 items-center">
              <span className="inline-flex min-h-7 max-w-full items-center overflow-hidden text-ellipsis whitespace-nowrap rounded-full border border-neutral-200 bg-neutral-100 px-2.5 py-1 text-xs font-bold leading-tight text-neutral-900">
                {React.string(draft.selection.label->SelectionLabel.toString)}
              </span>
            </div>
            <Card.Action>
              <div className="flex items-center gap-2">
                <Button variant=Ghost size=IconSm type_="button" title="Minimize request" onClick={_ => minimizeDraft(draft.id)}>
                  <Icons.Minus size=16 ariaHidden=true />
                </Button>
                <Button variant=Ghost size=IconSm type_="button" title="Close request" onClick={_ => closeDraft(draft.id)}>
                  <Icons.X size=16 ariaHidden=true />
                </Button>
              </div>
            </Card.Action>
          </Card.Header>
          <Card.Content className="px-3 pb-3">
            <Textarea
              className="min-h-32 max-h-[min(280px,calc(100vh-230px))] resize-y rounded-lg border-neutral-200 bg-white/80 p-3 text-[15px] leading-snug shadow-inner max-md:min-h-28 max-md:max-h-[calc(100vh-220px)]"
              placeholder="What should change?"
              value={draft.prompt->PromptText.toString}
              disabled=draftIsSubmitting
              onChange={event => updateDraftPrompt(draft.id, BrowserBridge.eventTargetValue(event))}
            />
          </Card.Content>
          <Card.Footer className="flex min-h-12 items-center justify-between gap-2 border-t border-neutral-200 bg-transparent px-3 py-3 max-md:flex-col max-md:items-start">
            <div className="flex min-w-0 flex-1 items-center">
              <div className="grid min-w-0 gap-1.5">
                {composerNotice}
                {failedPatchNotice}
                {composerStatus}
              </div>
            </div>
            <div className="flex shrink-0 items-center gap-2 max-md:w-full max-md:justify-end">
              <Button
                size=Sm
                type_="button"
                disabled={draft.prompt->PromptText.isBlank ||
                draftIsSubmitting ||
                !documentIsValid ||
                !assistantAvailable}
                onClick={_ => submitDraftToAssistant(draft)}>
                <Icons.Sparkles size=14 ariaHidden=true />
                {React.string(draftIsSubmitting ? draftStatusLabel : "Update")}
              </Button>
            </div>
          </Card.Footer>
        </Card>
      </section>
      }
    | Some(_) | None => React.null
    }

  let renderAgentPoller = poll => {
    let key = poll->activeAgentPollKey

    switch poll {
    | PromptDraftPoll(job) =>
      <ProfileEditSessionPoller
        key
        sessionId=job.sessionId
        onSession={session =>
          setProfileEditSessionHistory(current =>
            current->upsertProfileEditSessionSnapshot(
              session->sessionSnapshotFromPolled(~fallbackSelectionLabel=job.fallbackSelectionLabel),
            )
          )
        }
        onProgress={phase =>
          setPromptDrafts(current =>
            PromptDrafts.markSubmittingPhase(
              current,
              job.draftId,
              phase->promptProgressPhaseFromRelay,
              Now.nowIso(),
            )
          )
        }
        onApplied={(session, version) => {
          let snapshot = profileVersionSnapshot(
            ~id=version.id,
            ~revisionNumber=version.revisionNumber,
            ~html=version.html,
            ~css=version.css,
            ~summary=version.summary,
            ~createdAt=version.createdAt,
          )
          applyProfileVersionSnapshot(snapshot, ~notice="Applied assistant changes.")
          let completedAt = Now.nowIso()
          let appliedSummary = session.summary->String.trim == ""
            ? "Applied assistant changes."
            : session.summary
          setPromptDrafts(current =>
            PromptDrafts.markApplied(current, job.draftId, appliedSummary, completedAt)
          )
          setPromptHistory(current => [
            PromptHistory.makeItem(
              ~prompt=job.instruction->PromptText.make,
              ~selectionKind=job.selectionKind,
              ~selectionLabel=job.selectionLabel,
              ~selectionSnapshot=job.selectionSnapshot,
              ~revisionId=snapshot.revisionNumber->Int.toString->RevisionId.fromString->Option.getOr(
                RevisionId.initial,
              ),
              ~documentHtml=snapshot.html,
              ~documentCss=snapshot.css,
              ~createdAt=completedAt,
            ),
            ...current,
          ])
          setHistoryOpen(_ => true)
        }}
        onFailed={message => {
          setDocumentNotice(_ => Some("Assistant request failed: " ++ message))
          setPromptDrafts(current =>
            PromptDrafts.markError(current, job.draftId, message, Now.nowIso())
          )
        }}
        onFinished={() => removeActiveAgentPoll(key)}
      />
    | CodexChatPoll(job) =>
      <ProfileEditSessionPoller
        key
        sessionId=job.sessionId
        onSession={session =>
          setProfileEditSessionHistory(current =>
            current->upsertProfileEditSessionSnapshot(
              session->sessionSnapshotFromPolled(~fallbackSelectionLabel=job.fallbackSelectionLabel),
            )
          )
        }
        onProgress={_phase => ()}
        onApplied={(session, version) => {
          let snapshot = profileVersionSnapshot(
            ~id=version.id,
            ~revisionNumber=version.revisionNumber,
            ~html=version.html,
            ~css=version.css,
            ~summary=version.summary,
            ~createdAt=version.createdAt,
          )
          applyProfileVersionSnapshot(snapshot, ~notice="Applied assistant changes.")
          let summary = session.summary->String.trim == ""
            ? "Applied assistant changes."
            : session.summary
          job.onSuccess({
            summary: summary->PatchSummary.make,
            warnings: session.warnings->Array.join("\n")->PatchWarnings.make,
          })
        }}
        onFailed={message => job.onError(message)}
        onFinished={() => removeActiveAgentPoll(key)}
      />
    }
  }

  let renderAgentPollers = () =>
    activeAgentPolls->Array.map(renderAgentPoller)->React.array

  let renderCanvasRoute = () => {
    let headerButtonClass = "h-10 rounded-xl px-3.5 text-sm font-black shadow-sm"
    <main className="relative min-h-screen overflow-hidden bg-neutral-100">
      // TODO(friends-list): Add the hideable, movable friends-list profile
      // component once invite-chain friendships are visible in the editor.
      <header className="pointer-events-none fixed left-4 right-4 top-4 z-40 flex items-center justify-between gap-3 max-md:left-2.5 max-md:right-2.5 max-md:top-2.5">
        <div className="pointer-events-auto inline-flex items-center gap-2">
          {renderActiveInviteGiftButton()}
          <Button
            className={headerButtonClass ++ " bg-white/85 backdrop-blur-md max-md:hidden"}
            variant=Secondary
            size=Lg
            type_="button"
            onMouseEnter={_ => preloadEditorRoute()}
            onMouseDown={_ => preloadEditorRoute()}
            onTouchStart={_ => preloadEditorRoute()}
            onFocus={_ => preloadEditorRoute()}
            onClick={_ => router.push(editorRouteLink)}>
            {React.string("vibespace")}
          </Button>
        </div>
        <div className="pointer-events-auto flex items-center gap-2">
          <Button
            className=headerButtonClass
            variant=Outline
            size=Lg
            type_="button"
            onMouseEnter={_ => preloadSourceRoute()}
            onMouseDown={_ => preloadSourceRoute()}
            onTouchStart={_ => preloadSourceRoute()}
            onFocus={_ => preloadSourceRoute()}
            onClick={_ => {
              preloadSourceRoute()
              clearEditMode()
              router.push(sourceRouteLink)
            }}>
            {React.string("Advanced")}
          </Button>
          {isEditing
            ? <Button
                className=headerButtonClass
                variant={historyOpen ? Secondary : Outline}
                size=Lg
                type_="button"
                title={historyOpen ? "Hide history" : "View history"}
                onClick={_ => setHistoryOpen(current => !current)}>
                {React.string("History")}
              </Button>
            : React.null}
          {isEditing
            ? <Button className=headerButtonClass size=Lg type_="button" onClick={_ => clearEditMode()}>
                {React.string("Done")}
              </Button>
            : <Button className=headerButtonClass size=Lg type_="button" onClick={_ => setIsEditing(_ => true)}>
                {React.string("Edit")}
              </Button>}
        </div>
      </header>
      <section className="relative h-screen w-screen overflow-hidden">
        {switch activeDocumentNotice {
        | Some(message) =>
          <Alert className="absolute left-1/2 top-[72px] z-32 w-[min(560px,calc(100vw-32px))] -translate-x-1/2 text-center" variant=Destructive>
            <Alert.Description> {React.string(message)} </Alert.Description>
            {!documentIsValid
              ? <Alert.Action>
                  <Button variant=Destructive size=Sm type_="button" onClick={_ => repairCurrentDocument()}>
                    {React.string("Quick fix")}
                  </Button>
                </Alert.Action>
              : React.null}
          </Alert>
        | None => React.null
        }}
        <iframe
          id="vibespace-profile-frame"
          title="Vibespace generated profile preview"
          className={selectionInteractionEnabled
            ? "block h-full w-full cursor-crosshair border-0 bg-white"
            : "block h-full w-full border-0 bg-white"}
          sandbox="allow-same-origin allow-scripts allow-popups allow-presentation allow-top-navigation-by-user-activation"
          srcDoc=canvasPreview
          onLoad={event => {
            let bridgeEditMode = isEditing && documentIsValid
            BrowserBridge.debugPrompt(
              "iframe-load",
              "selectedId=" ++
              selectedId->debugOptionalProfileElementId ++
              " bridgeEditMode=" ++
              bridgeEditMode->debugBool ++
              " promptIsOpen=" ++
              promptIsOpen->debugBool ++
              " selectionInteractionEnabled=" ++
              selectionInteractionEnabled->debugBool,
            )
            BrowserBridge.attachFrameViewportListener(event, nextViewport =>
              setFrameViewport(_ => nextViewport)
            )
            BrowserBridge.attachSelectionBridge(
              event,
              selectedId,
              bridgeEditMode,
              handleSelectionPayload,
            )
          }}
        />
        {selectionInteractionEnabled && !ProfileSelection.hasSelection(selection)
          ? <Alert className="absolute bottom-6 left-1/2 z-20 w-[min(520px,calc(100vw-32px))] -translate-x-1/2 text-center">
              <Alert.Description>
                {React.string("Drag an area to describe a visual edit, or click a profile section.")}
              </Alert.Description>
            </Alert>
          : React.null}
        {isEditing ? renderSelectionOverlay() : React.null}
        {renderPromptBubble()}
        {renderMinimizedPromptTray()}
        {renderHistorySidebar()}
        {renderInviteModal()}
      </section>
    </main>
  }

  let renderSourceRoute = () =>
    <main className="min-h-screen bg-neutral-100 p-6 max-md:p-3.5">
      <header className="mx-auto flex w-[min(1500px,100%)] items-center justify-between gap-3 pb-4 pt-1 max-md:flex-col max-md:items-start">
        <div>
          <p className=kickerClass> {React.string("Advanced")} </p>
          <h1 className="m-0 text-5xl font-black leading-none tracking-normal text-neutral-950 max-md:text-3xl"> {React.string("Profile blueprint")} </h1>
        </div>
        <div className="flex items-center gap-2">
          <Badge variant={assistantAvailable ? Badge.Variant.Default : Badge.Variant.Secondary}>
            {React.string(assistantAvailable ? "Assistant ready" : "Saved profile required")}
          </Badge>
          <Button
            variant=Outline
            type_="button"
            onMouseEnter={_ => preloadEditorRoute()}
            onMouseDown={_ => preloadEditorRoute()}
            onTouchStart={_ => preloadEditorRoute()}
            onFocus={_ => preloadEditorRoute()}
            onClick={_ => router.push(editorRouteLink)}>
            {React.string("Back to profile")}
          </Button>
        </div>
      </header>
      {renderAdvancedInviteControls()}
      <section className="mx-auto grid w-[min(1500px,100%)] grid-cols-[420px_minmax(0,1fr)] items-start gap-4 max-[1100px]:grid-cols-1">
        <Card>
          <Card.Header className="flex items-center justify-between gap-3">
            <div>
              <p className=kickerClass> {React.string("Preview")} </p>
              <Card.Title> {React.string("Current profile")} </Card.Title>
            </div>
            <Card.Action>
              <Badge variant=Outline> {React.string("Version " ++ ProfileDocument.revisionString(document))} </Badge>
            </Card.Action>
          </Card.Header>
          <Card.Content className="px-3 pb-3">
            <iframe
              title="Vibespace profile preview"
              className="block h-[520px] w-full border border-neutral-300 bg-white max-[1100px]:h-[420px]"
              sandbox="allow-scripts allow-popups allow-presentation allow-top-navigation-by-user-activation"
              srcDoc=sourcePreview
            />
          </Card.Content>
        </Card>
        <section className="grid grid-cols-2 gap-4 max-[1100px]:grid-cols-1">
          <Card>
            <Card.Header>
              <Label> {React.string("Profile content")} </Label>
            </Card.Header>
            <Card.Content>
              <Textarea
              className="min-h-[520px] font-mono text-xs leading-normal max-[1100px]:min-h-[420px]"
              value={ProfileDocument.htmlString(document)}
              spellCheck=false
              onChange={event => {
                latestValidationRevision.current = "pending-source-edit"
                setDocumentValidation(_ => ValidationChecking)
                setDocument(current =>
                  ProfileDocument.updateHtmlFromString(current, BrowserBridge.eventTargetValue(event))
                )
                setDocumentNotice(_ => None)
              }}
            />
            </Card.Content>
          </Card>
          <Card>
            <Card.Header>
              <Label> {React.string("Profile look")} </Label>
            </Card.Header>
            <Card.Content>
              <Textarea
              className="min-h-[520px] font-mono text-xs leading-normal max-[1100px]:min-h-[420px]"
              value={ProfileDocument.cssString(document)}
              spellCheck=false
              onChange={event => {
                latestValidationRevision.current = "pending-source-edit"
                setDocumentValidation(_ => ValidationChecking)
                setDocument(current =>
                  ProfileDocument.updateCssFromString(current, BrowserBridge.eventTargetValue(event))
                )
                setDocumentNotice(_ => None)
              }}
            />
            </Card.Content>
          </Card>
        </section>
      </section>
      {switch documentValidation {
      | ValidationInvalid(message) =>
        <Alert className="mx-auto mt-4 w-[min(1500px,100%)]" variant=Destructive>
            <Alert.Title> {React.string("Needs attention")} </Alert.Title>
            <Alert.Description> {React.string(message)} </Alert.Description>
            <Alert.Action>
              <Button variant=Destructive size=Sm type_="button" onClick={_ => repairCurrentDocument()}>
                {React.string("Quick fix")}
              </Button>
            </Alert.Action>
          </Alert>
      | ValidationChecking =>
        <Alert className="mx-auto mt-4 w-[min(1500px,100%)]">
          <Alert.Description> {React.string("Checking profile changes...")} </Alert.Description>
        </Alert>
      | ValidationValid => React.null
      }}
      <Card className="mx-auto mt-4 w-[min(1500px,100%)]">
        <Card.Header>
          <Card.Title> {React.string("Assistant test lane")} </Card.Title>
          <Card.Description>
            {React.string("The profile prompt is the main experience. This panel is a quieter place to test assistant changes.")}
          </Card.Description>
        </Card.Header>
        <Card.Content>
          <CodexChat
            enabled={assistantAvailable && documentIsValid}
            disabledReason=codexDisabledReason
            onSubmit={(instruction, mode, onSuccess, onError) => {
              switch editorContext.profileId {
              | None => onError("Assistant changes require a saved profile.")
              | Some(profileId) =>
                let selectionLabel = selection->ProfileSelection.label->SelectionLabel.toString
                let inputWithCurrentVersion = (currentVersionId): RelaySchemaAssets_graphql.input_SubmitAgentEditInput => {
                  profileId,
                  currentVersionId,
                  prompt: instruction,
                  selectionLabel,
                  selectionAgentContext: ProfileSelection.agentContext(selection)->SelectionDescription.toString,
                  selectedRegionScreenshotDataUrl: ProfileSelection.screenshotDataUrl(selection)->Option.mapOr(
                    "",
                    DataUrl.toString,
                  ),
                  fullPageScreenshotDataUrl: "",
                  previousFailedHtml: "",
                  previousFailedCss: "",
                  previousFailedSummary: "",
                  previousFailedWarnings: "",
                  previousFailedValidationMessage: "",
                  mode: mode->assistantModeInput,
                }
                let inputWithoutCurrentVersion: RelaySchemaAssets_graphql.input_SubmitAgentEditInput = {
                  profileId,
                  prompt: instruction,
                  selectionLabel,
                  selectionAgentContext: ProfileSelection.agentContext(selection)->SelectionDescription.toString,
                  selectedRegionScreenshotDataUrl: ProfileSelection.screenshotDataUrl(selection)->Option.mapOr(
                    "",
                    DataUrl.toString,
                  ),
                  fullPageScreenshotDataUrl: "",
                  previousFailedHtml: "",
                  previousFailedCss: "",
                  previousFailedSummary: "",
                  previousFailedWarnings: "",
                  previousFailedValidationMessage: "",
                  mode: mode->assistantModeInput,
                }
                let input = switch currentProfileVersionId {
                | Some(currentVersionId) => inputWithCurrentVersion(currentVersionId)
                | None => inputWithoutCurrentVersion
                }
                startAgentEdit(
                  ~variables={input: input},
                  ~onCompleted=(response, errors) => {
                    let graphQLError = switch errors {
                    | Some(errors) => errors->Array.get(0)->Option.map(error => error.message)
                    | None => None
                    }

                    switch graphQLError {
                    | Some(message) => onError(message)
                    | None =>
                      switch response.startAgentEdit {
                      | ProfileEditSessionMutationSucceeded(payload) =>
                        let session = payload.succeededEditSession
                        let sessionSnapshot = profileEditSessionSnapshot(
                          ~id=session.id,
                          ~prompt=session.prompt,
                          ~status=session.status->ProfileRelayLabels.profileEditSessionStatus,
                          ~progressPhase=session.progressPhase->ProfileRelayLabels.editProgressPhase,
                          ~summary=session.summary,
                          ~error=session.error,
                          ~selectionLabel=switch session.selectionSnapshot {
                          | Some(snapshot) => Some(snapshot.label)
                          | None => Some(selectionLabel)
                          },
                          ~createdAt=session.createdAt,
                          ~updatedAt=session.updatedAt,
                        )
                        setProfileEditSessionHistory(current =>
                          current->upsertProfileEditSessionSnapshot(sessionSnapshot)
                        )

                        switch firstPayloadError(
                          ~error=None,
                          ~validationErrors=payload.validationErrors,
                        ) {
                        | Some(message) => onError(message)
                        | None =>
                          upsertActiveAgentPoll(
                            CodexChatPoll({
                              sessionId: session.id,
                              fallbackSelectionLabel: selectionLabel,
                              onSuccess,
                              onError,
                            }),
                          )
                        }
                      | ProfileEditSessionMutationFailed(payload) =>
                        payload.failedEditSession->Option.forEach(session => {
                          let sessionSnapshot = profileEditSessionSnapshot(
                            ~id=session.id,
                            ~prompt=session.prompt,
                            ~status=session.status->ProfileRelayLabels.profileEditSessionStatus,
                            ~progressPhase=session.progressPhase->ProfileRelayLabels.editProgressPhase,
                            ~summary=session.summary,
                            ~error=session.error,
                            ~selectionLabel=switch session.selectionSnapshot {
                            | Some(snapshot) => Some(snapshot.label)
                            | None => Some(selectionLabel)
                            },
                            ~createdAt=session.createdAt,
                            ~updatedAt=session.updatedAt,
                          )
                          setProfileEditSessionHistory(current =>
                            current->upsertProfileEditSessionSnapshot(sessionSnapshot)
                          )
                        })
                        let message = firstPayloadError(
                          ~error=Some(payload.message),
                          ~validationErrors=payload.validationErrors,
                        )->Option.getOr(payload.message)
                        onError(message)
                      | UnselectedUnionMember(_) =>
                        onError("Assistant request returned an unknown result.")
                      }
                    }
                  },
                  ~onError=error => onError(error.message),
                )->ignore
              }
            }}
          />
        </Card.Content>
      </Card>
      {renderInviteModal()}
      {renderReactivateInviteDialog()}
    </main>

  <>
    {switch route {
    | Route.Source => renderSourceRoute()
    | Route.Canvas => renderCanvasRoute()
    }}
    {renderAgentPollers()}
  </>
}
