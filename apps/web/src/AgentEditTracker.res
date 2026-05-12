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

type onboardingStarterRequest = {
  sessionId: string,
  profileSlug: string,
  inviteCode: string,
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

type trackedOnboardingStarter = {
  sessionId: string,
  profileSlug: string,
  inviteCode: string,
}

type trackedJob =
  | PromptDraft(trackedPromptDraft)
  | SourceLane(trackedSourceLane)
  | OnboardingStarter(trackedOnboardingStarter)

type toastKind =
  | Ready
  | Error

type toast = {
  id: string,
  kind: toastKind,
  title: string,
  message: string,
  actionLabel: string,
  actionLink: string,
}

type context = {
  trackPromptDraft: promptDraftRequest => unit,
  trackSourceLane: sourceLaneRequest => unit,
  trackOnboardingStarter: onboardingStarterRequest => unit,
}

let noopContext = {
  trackPromptDraft: _request => (),
  trackSourceLane: _request => (),
  trackOnboardingStarter: _request => (),
}

let jobKey = job =>
  switch job {
  | PromptDraft(job) => "prompt:" ++ job.sessionId
  | SourceLane(job) => "source:" ++ job.sessionId
  | OnboardingStarter(job) => "onboarding:" ++ job.sessionId
  }

let jobSessionId = job =>
  switch job {
  | PromptDraft(job) => job.sessionId
  | SourceLane(job) => job.sessionId
  | OnboardingStarter(job) => job.sessionId
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

let toastId = (~kind, ~sessionId) => kind ++ ":" ++ sessionId

let enqueueToast = (~setToasts, toast) =>
  setToasts(current => [toast, ...current->Array.filter(item => item.id != toast.id)])

let invalidateRelayStore = () =>
  RescriptRelay.commitLocalUpdate(
    ~environment=RelayEnv.environment,
    ~updater=store => store->RescriptRelay.RecordSourceSelectorProxy.invalidateStore,
  )

let renderToast = (~toast, ~onDismiss) => {
  let toneClass = switch toast.kind {
  | Ready => "border-emerald-200 bg-emerald-50 text-emerald-950"
  | Error => "border-red-200 bg-red-50 text-red-950"
  }
  let actionClass = switch toast.kind {
  | Ready => "bg-emerald-950 text-white hover:bg-emerald-800"
  | Error => "bg-red-950 text-white hover:bg-red-800"
  }

  <aside
    key=toast.id
    className={"pointer-events-auto w-[min(360px,calc(100vw-32px))] rounded-2xl border p-4 shadow-2xl " ++ toneClass}>
    <div className="flex items-start justify-between gap-3">
      <div className="min-w-0">
        <p className="m-0 text-sm font-black leading-tight"> {React.string(toast.title)} </p>
        <p className="mt-1 mb-0 text-sm leading-relaxed opacity-75">
          {React.string(toast.message)}
        </p>
      </div>
      <button
        className="inline-grid size-7 shrink-0 cursor-pointer place-items-center rounded-full border-0 bg-black/5 text-current hover:bg-black/10"
        type_="button"
        ariaLabel="Dismiss notification"
        onClick={_ => onDismiss(toast.id)}>
        <Icons.X size=14 ariaHidden=true />
      </button>
    </div>
    <div className="mt-3 flex justify-end">
      <RelayRouter.Link
        className={"inline-flex h-9 items-center rounded-md px-3 text-sm font-black no-underline " ++ actionClass}
        to_=toast.actionLink
        preloadCode=OnInView
        preloadData=OnIntent>
        {React.string(toast.actionLabel)}
      </RelayRouter.Link>
    </div>
  </aside>
}

let renderPoller = (~job, ~setJobs, ~setToasts) => {
  let key = job->jobKey
  <ProfileEditSessionPoller
    key
    sessionId={job->jobSessionId}
    onSession={session =>
      switch job {
      | PromptDraft(job) => job.onSession(session)
      | SourceLane(job) => job.onSession(session)
      | OnboardingStarter(_) => ()
      }
    }
    onProgress={phase =>
      switch job {
      | PromptDraft(job) =>
        savePromptDraftProgress(job.draftId, phase)
        job.onProgress(phase)
      | SourceLane(_) => ()
      | OnboardingStarter(_) => ()
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
      | OnboardingStarter(job) =>
        invalidateRelayStore()
        enqueueToast(
          ~setToasts,
          {
            id: toastId(~kind="ready", ~sessionId=job.sessionId),
            kind: Ready,
            title: "Your starter Vibespace is ready.",
            message: "Open it when you are ready to edit or share it.",
            actionLabel: "Open profile",
            actionLink: Routes.Profile.Route.makeLink(~handle=job.profileSlug),
          },
        )
      }
    }}
    onFailed={message =>
      switch job {
      | PromptDraft(job) =>
        savePromptDraftFailed(job.draftId, message)
        job.onFailed(message)
      | SourceLane(job) => job.onFailed(message)
      | OnboardingStarter(job) =>
        enqueueToast(
          ~setToasts,
          {
            id: toastId(~kind="error", ~sessionId=job.sessionId),
            kind: Error,
            title: "Starter profile failed.",
            message,
            actionLabel: "Back to onboarding",
            actionLink: Routes.Invite.Route.makeLink(~code=job.inviteCode),
          },
        )
      }
    }
    onFinished={() => setJobs(current => current->Array.filter(job => job->jobKey != key))}
  />
}

module Host = {
  @react.component
  let make = (~dispatchRef: React.ref<context>) => {
    let (jobs, setJobs) = React.useState((): array<trackedJob> => [])
    let (toasts, setToasts) = React.useState((): array<toast> => [])
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
    let trackOnboardingStarter = (request: onboardingStarterRequest) => {
      let nextJob = OnboardingStarter({
        sessionId: request.sessionId,
        profileSlug: request.profileSlug,
        inviteCode: request.inviteCode,
      })
      setJobs(current => current->upsertJob(nextJob))
    }

    React.useEffect1(() => {
      dispatchRef.current = {trackPromptDraft, trackSourceLane, trackOnboardingStarter}
      Some(() => {
        dispatchRef.current = noopContext
      })
    }, ["agent-edit-tracker-host"])

    <>
      {jobs->Array.map(job => renderPoller(~job, ~setJobs, ~setToasts))->React.array}
      {toasts->Array.length > 0
        ? <div className="pointer-events-none fixed bottom-4 right-4 z-50 grid gap-3 max-md:bottom-3 max-md:right-3">
            {toasts
            ->Array.map(toast =>
              renderToast(
                ~toast,
                ~onDismiss=id => setToasts(current => current->Array.filter(item => item.id != id)),
              )
            )
            ->React.array}
          </div>
        : React.null}
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
      trackOnboardingStarter: request => dispatchRef.current.trackOnboardingStarter(request),
    }

    <ContextProvider value>
      {children}
      <Host dispatchRef />
    </ContextProvider>
  }
}
