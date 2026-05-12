type promptDraftRequest = {
  sessionId: string,
  draftId: PromptDraftId.t,
  onSession: ProfileEditSessionPoller.polledProfileEditSession => unit,
  onProgress: RelaySchemaAssets_graphql.enum_EditProgressPhase => unit,
  onApplied: (
    ProfileEditSessionPoller.polledProfileEditSession,
    ProfileEditSessionPoller.polledProfileVersion,
  ) => unit,
  onFailed: string => unit,
}

type sourceLaneRequest = {
  sessionId: string,
  onSession: ProfileEditSessionPoller.polledProfileEditSession => unit,
  onApplied: (
    ProfileEditSessionPoller.polledProfileEditSession,
    ProfileEditSessionPoller.polledProfileVersion,
  ) => unit,
  onFailed: string => unit,
}

type trackedPromptDraft = {
  sessionId: string,
  draftId: PromptDraftId.t,
  onSession: ProfileEditSessionPoller.polledProfileEditSession => unit,
  onProgress: RelaySchemaAssets_graphql.enum_EditProgressPhase => unit,
  onApplied: (
    ProfileEditSessionPoller.polledProfileEditSession,
    ProfileEditSessionPoller.polledProfileVersion,
  ) => unit,
  onFailed: string => unit,
}

type trackedSourceLane = {
  sessionId: string,
  onSession: ProfileEditSessionPoller.polledProfileEditSession => unit,
  onApplied: (
    ProfileEditSessionPoller.polledProfileEditSession,
    ProfileEditSessionPoller.polledProfileVersion,
  ) => unit,
  onFailed: string => unit,
}

type trackedJob =
  | PromptDraft(trackedPromptDraft)
  | SourceLane(trackedSourceLane)

type context = {
  trackPromptDraft: promptDraftRequest => unit,
  trackSourceLane: sourceLaneRequest => unit,
}

let noopContext = {
  trackPromptDraft: _request => (),
  trackSourceLane: _request => (),
}

let jobKey = job =>
  switch job {
  | PromptDraft(job) => "prompt:" ++ job.sessionId
  | SourceLane(job) => "source:" ++ job.sessionId
  }

let jobSessionId = job =>
  switch job {
  | PromptDraft(job) => job.sessionId
  | SourceLane(job) => job.sessionId
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

let savePromptDraftProgress = (draftId, phase) =>
  PromptDrafts.load()
  ->PromptDrafts.markSubmittingPhase(draftId, phase->promptProgressPhaseFromRelay, Now.nowIso())
  ->PromptDrafts.save

let savePromptDraftApplied = (draftId, summary) =>
  PromptDrafts.load()
  ->PromptDrafts.markApplied(draftId, summary, Now.nowIso())
  ->PromptDrafts.save

let savePromptDraftFailed = (draftId, message) =>
  PromptDrafts.load()
  ->PromptDrafts.markError(draftId, message, Now.nowIso())
  ->PromptDrafts.save

let trackerContext = React.createContext(noopContext)

let use = () => React.useContext(trackerContext)

module ContextProvider = {
  let make = React.Context.provider(trackerContext)
}

let upsertJob = (jobs, nextJob) => [
  nextJob,
  ...jobs->Array.filter(job => job->jobKey != nextJob->jobKey),
]

let renderPoller = (~job, ~setJobs) => {
  let key = job->jobKey
  <ProfileEditSessionPoller
    key
    sessionId={job->jobSessionId}
    onSession={session =>
      switch job {
      | PromptDraft(job) => job.onSession(session)
      | SourceLane(job) => job.onSession(session)
      }
    }
    onProgress={phase =>
      switch job {
      | PromptDraft(job) =>
        savePromptDraftProgress(job.draftId, phase)
        job.onProgress(phase)
      | SourceLane(_) => ()
      }
    }
    onApplied={(session, version) => {
      let summary = session.summary->String.trim == ""
        ? "Applied assistant changes."
        : session.summary
      switch job {
      | PromptDraft(job) =>
        savePromptDraftApplied(job.draftId, summary)
        job.onApplied(session, version)
      | SourceLane(job) => job.onApplied(session, version)
      }
    }}
    onFailed={message =>
      switch job {
      | PromptDraft(job) =>
        savePromptDraftFailed(job.draftId, message)
        job.onFailed(message)
      | SourceLane(job) => job.onFailed(message)
      }
    }
    onFinished={() => setJobs(current => current->Array.filter(job => job->jobKey != key))}
  />
}

module Host = {
  @react.component
  let make = (~dispatchRef: React.ref<context>) => {
    let (jobs, setJobs) = React.useState((): array<trackedJob> => [])
    let trackPromptDraft = (request: promptDraftRequest) => {
      let nextJob = PromptDraft({
        sessionId: request.sessionId,
        draftId: request.draftId,
        onSession: request.onSession,
        onProgress: request.onProgress,
        onApplied: request.onApplied,
        onFailed: request.onFailed,
      })
      setJobs(current => current->upsertJob(nextJob))
    }
    let trackSourceLane = (request: sourceLaneRequest) => {
      let nextJob = SourceLane({
        sessionId: request.sessionId,
        onSession: request.onSession,
        onApplied: request.onApplied,
        onFailed: request.onFailed,
      })
      setJobs(current => current->upsertJob(nextJob))
    }

    React.useEffect1(() => {
      dispatchRef.current = {trackPromptDraft, trackSourceLane}
      Some(() => {
        dispatchRef.current = noopContext
      })
    }, ["agent-edit-tracker-host"])

    <>
      {jobs->Array.map(job => renderPoller(~job, ~setJobs))->React.array}
    </>
  }
}

module Provider = {
  @react.component
  let make = (~children) => {
    let dispatchRef = React.useRef(noopContext)
    let value = {
      trackPromptDraft: request => dispatchRef.current.trackPromptDraft(request),
      trackSourceLane: request => dispatchRef.current.trackSourceLane(request),
    }

    <ContextProvider value>
      {children}
      <Host dispatchRef />
    </ContextProvider>
  }
}
