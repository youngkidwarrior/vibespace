type runState =
  | Running(RelaySchemaAssets_graphql.enum_EditProgressPhase)
  | Applied(string)
  | Failed(string)

type promptDraftRequest = {
  sessionId: string,
  prompt: string,
  draftId: PromptDraftId.t,
  mode: AssistantEstimate.mode,
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
  prompt: string,
  mode: AssistantEstimate.mode,
  onSession: ProfileEditSessionPoller.polledProfileEditSession => unit,
  onApplied: (
    ProfileEditSessionPoller.polledProfileEditSession,
    ProfileEditSessionPoller.polledProfileVersion,
  ) => unit,
  onFailed: string => unit,
}

type trackedPromptDraft = {
  sessionId: string,
  prompt: string,
  draftId: PromptDraftId.t,
  mode: AssistantEstimate.mode,
  state: runState,
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
  prompt: string,
  mode: AssistantEstimate.mode,
  state: runState,
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

let jobPrompt = job =>
  switch job {
  | PromptDraft(job) => job.prompt
  | SourceLane(job) => job.prompt
  }

let jobMode = job =>
  switch job {
  | PromptDraft(job) => job.mode
  | SourceLane(job) => job.mode
  }

let jobState = job =>
  switch job {
  | PromptDraft(job) => job.state
  | SourceLane(job) => job.state
  }

let setJobState = (job, state) =>
  switch job {
  | PromptDraft(job) => PromptDraft({...job, state})
  | SourceLane(job) => SourceLane({...job, state})
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

let terminalSummary = job =>
  switch job->jobState {
  | Applied(summary) => Some(summary)
  | Running(_) | Failed(_) => None
  }

let runningPhaseLabel = job =>
  switch job->jobState {
  | Running(phase) => phase->ProfileRelayLabels.editProgressPhase
  | Applied(_) => "Ready"
  | Failed(_) => "Needs attention"
  }

let updateJob = (jobs, key, update) =>
  jobs->Array.map(job => job->jobKey == key ? update(job) : job)

let upsertJob = (jobs, nextJob) => [
  nextJob,
  ...jobs->Array.filter(job => job->jobKey != nextJob->jobKey),
]

let compactText = value => AppHelpers.shortText(value->String.trim)

let renderOpenProfileLink = () =>
  <RelayRouter.Link
    className="inline-flex h-8 shrink-0 items-center justify-center rounded-lg border border-neutral-950 bg-neutral-950 px-3 text-sm font-bold text-white shadow-sm transition hover:-translate-y-px hover:bg-neutral-800"
    to_={Routes.Editor.Route.makeLink()}>
    {React.string("Open profile")}
  </RelayRouter.Link>

let renderJobCard = (~job, ~dismiss) => {
  let key = job->jobKey
  let mode = job->jobMode
  let prompt = job->jobPrompt->compactText
  <Card className="w-[min(420px,calc(100vw-24px))] border border-neutral-950/10 bg-white/95 shadow-2xl backdrop-blur-xl">
    <Card.Header className="grid grid-cols-[1fr_auto] gap-3">
      <div className="min-w-0">
        <p className="m-0 mb-1 text-[11px] font-black uppercase tracking-wider text-neutral-500">
          {React.string(job->runningPhaseLabel)}
        </p>
        <Card.Title className="text-base font-black">
          {switch job->jobState {
          | Running(_) => React.string("Building your page")
          | Applied(_) => React.string("Your page is ready")
          | Failed(_) => React.string("Assistant request failed")
          }}
        </Card.Title>
      </div>
      <Card.Action>
        {switch job->jobState {
        | Running(_) =>
          <span className="inline-grid size-8 place-items-center rounded-full bg-blue-50 text-blue-700">
            <Icons.Loader2 className="animate-spin" size=16 ariaHidden=true />
          </span>
        | Applied(_) =>
          <span className="inline-grid size-8 place-items-center rounded-full bg-green-50 text-green-700">
            <Icons.Check size=16 ariaHidden=true />
          </span>
        | Failed(_) =>
          <Button
            variant=Ghost
            size=IconSm
            type_="button"
            title="Dismiss"
            onClick={_ => dismiss(key)}>
            <Icons.X size=16 ariaHidden=true />
          </Button>
        }}
      </Card.Action>
    </Card.Header>
    <Card.Content className="grid gap-3">
      <p className="m-0 text-sm font-semibold leading-snug text-neutral-950">
        {React.string(prompt == "" ? "Profile update" : prompt)}
      </p>
      {switch job->jobState {
      | Running(_) =>
        <p className="m-0 text-sm leading-snug text-neutral-500">
          {React.string(mode->AssistantEstimate.waitingCopy)}
        </p>
      | Applied(_) =>
        <p className="m-0 text-sm leading-snug text-neutral-500">
          {React.string("The update finished in the background. Open your profile to see the latest version.")}
        </p>
      | Failed(message) =>
        <p className="m-0 text-sm leading-snug text-red-700"> {React.string(message)} </p>
      }}
      {switch job->terminalSummary {
      | Some(summary) if summary != "" =>
        <p className="m-0 rounded-lg bg-neutral-50 p-2.5 text-xs font-bold leading-snug text-neutral-600">
          {React.string(summary)}
        </p>
      | Some(_) | None => React.null
      }}
      <div className="flex flex-wrap items-center justify-between gap-2">
        <span className="text-xs font-bold text-neutral-500">
          {React.string("ETA " ++ mode->AssistantEstimate.label)}
        </span>
        {switch job->jobState {
        | Applied(_) => renderOpenProfileLink()
        | Running(_) =>
          <span className="text-xs font-bold text-neutral-500">
            {React.string("Safe to navigate")}
          </span>
        | Failed(_) => React.null
        }}
      </div>
    </Card.Content>
  </Card>
}

let renderTracker = (~jobs, ~dismiss) => {
  switch jobs->Array.get(0) {
  | None => React.null
  | Some(job) =>
    <aside className="fixed bottom-4 right-4 z-[120] grid gap-3 max-md:bottom-3 max-md:right-3 max-md:left-3">
      {renderJobCard(~job, ~dismiss)}
      {jobs->Array.length > 1
        ? <p className="m-0 justify-self-end rounded-full bg-neutral-950 px-2.5 py-1 text-xs font-bold text-white shadow-lg">
            {React.string("+" ++ (jobs->Array.length - 1)->Int.toString ++ " more")}
          </p>
        : React.null}
    </aside>
  }
}

let renderPoller = (~job, ~setJobs) => {
  let key = job->jobKey
  switch job->jobState {
  | Running(_) =>
    <ProfileEditSessionPoller
      key
      sessionId={job->jobSessionId}
      onSession={session => {
        setJobs(current => current->updateJob(key, job => job->setJobState(Running(session.progressPhase))))
        switch job {
        | PromptDraft(job) => job.onSession(session)
        | SourceLane(job) => job.onSession(session)
        }
      }}
      onProgress={phase => {
        setJobs(current => current->updateJob(key, job => job->setJobState(Running(phase))))
        switch job {
        | PromptDraft(job) =>
          savePromptDraftProgress(job.draftId, phase)
          job.onProgress(phase)
        | SourceLane(_) => ()
        }
      }}
      onApplied={(session, version) => {
        let summary = session.summary->String.trim == ""
          ? "Applied assistant changes."
          : session.summary
        setJobs(current => current->updateJob(key, job => job->setJobState(Applied(summary))))
        switch job {
        | PromptDraft(job) =>
          savePromptDraftApplied(job.draftId, summary)
          job.onApplied(session, version)
        | SourceLane(job) => job.onApplied(session, version)
        }
      }}
      onFailed={message => {
        setJobs(current => current->updateJob(key, job => job->setJobState(Failed(message))))
        switch job {
        | PromptDraft(job) =>
          savePromptDraftFailed(job.draftId, message)
          job.onFailed(message)
        | SourceLane(job) => job.onFailed(message)
        }
      }}
      onFinished={() => ()}
    />
  | Applied(_) | Failed(_) => React.null
  }
}

module Host = {
  @react.component
  let make = (~dispatchRef: React.ref<context>) => {
    let (jobs, setJobs) = React.useState((): array<trackedJob> => [])
    let dismiss = key => setJobs(current => current->Array.filter(job => job->jobKey != key))
    let trackPromptDraft = (request: promptDraftRequest) => {
      let nextJob = PromptDraft({
        sessionId: request.sessionId,
        prompt: request.prompt,
        draftId: request.draftId,
        mode: request.mode,
        state: Running(PREPARING),
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
        prompt: request.prompt,
        mode: request.mode,
        state: Running(PREPARING),
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
      {renderTracker(~jobs, ~dismiss)}
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
