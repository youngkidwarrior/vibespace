module Query = %relay(`
  query InviteRouteQuery($code: String!) {
    viewer {
      id
      handle
      displayName
    }
    viewerProfile {
      id
      slug
    }
    inviteByCode(code: $code) {
      id
      code
      status
      invitee {
        id
      }
      inviter {
        id
        handle
        displayName
      }
    }
  }
`)

module SendtagLookupQuery = %relay(`
  query InviteRouteSendtagLookupQuery($sendtag: String!) {
    sendtagLookup(sendtag: $sendtag) {
      ok
      sendtag
      message
    }
  }
`)

@module("./OnboardingFileReader.js")
external readFirstImageFromEvent: ReactEvent.Synthetic.t => promise<Nullable.t<string>> =
  "readFirstImageFromEvent"

let validateSendtag = async rawSendtag => {
  let variables: InviteRouteSendtagLookupQuery_graphql.Types.variables = {sendtag: rawSendtag}
  let data: InviteRouteSendtagLookupQuery_graphql.Types.response = await RescriptRelay_QueryNonReact.fetchPromised(
    ~node=InviteRouteSendtagLookupQuery_graphql.node,
    ~convertResponse=InviteRouteSendtagLookupQuery_graphql.Internal.convertResponse,
    ~convertVariables=InviteRouteSendtagLookupQuery_graphql.Internal.convertVariables,
  )(
    ~environment=RelayEnv.environment,
    ~variables,
    ~fetchPolicy=NetworkOnly,
  )
  data.sendtagLookup
}

type onboardingMode =
  | People
  | Nature

type onboardingStep =
  | ConfirmInvite
  | ChooseVibe
  | Questions
  | Generating

type redeemedAccount = {
  sessionToken: string,
  profileId: string,
  profileSlug: string,
}

type onboardingAnswers = {
  favoriteSong: string,
  likes: string,
  dislikes: string,
  vibeNote: string,
  profileName: string,
  sendtag: string,
}

let defaultAnswers = {
  favoriteSong: "",
  likes: "",
  dislikes: "",
  vibeNote: "",
  profileName: "",
  sendtag: "",
}

let inviteStatusLabel = status => status->ProfileRelayLabels.inviteStatus

let modeTitle = mode =>
  switch mode {
  | People => "Show off a picture of you"
  | Nature => "Show a picture of a beautiful place"
  }

let placeholderGlyph = mode =>
  switch mode {
  | People => "🎭"
  | Nature => "🍃"
  }

let onboardingContext = mode =>
  switch mode {
  | People =>
    "The user chose the people path. Treat the uploaded image as emotional and social context."
  | Nature =>
    "The user chose the nature path. Treat the uploaded image as atmosphere, palette, place, light, and energy context."
  }

let normalizeSendtag = value => {
  let trimmed = value->String.trim
  let withoutOneSlash = trimmed->String.startsWith("/")
    ? trimmed->String.slice(~start=1, ~end=trimmed->String.length)
    : trimmed

  withoutOneSlash->String.trim
}

let sendtagPromptContext = answers => {
  let sendtag = answers.sendtag->normalizeSendtag
  if sendtag == "" {
    ""
  } else {
    "\nSendtag: /" ++
    sendtag ++
    "\nBecause a Sendtag was provided, include one profile-picture placeholder where the owner photo should appear: <div data-vibespace-system-component=\"owner-profile-image\" data-vibespace-id=\"owner-profile-image\" data-vibespace-name=\"Profile picture\" data-vibespace-description=\"System-rendered owner profile image\"></div>. Vibespace will render the live Send profile image there. Do not write a remote avatar URL or raw image source for the Send avatar."
  }
}

let peoplePrompt = (~answers: onboardingAnswers) =>
  [
    "Create my first Vibespace profile from onboarding.",
    "",
    "The attached image is the people-path reference photo. Analyze it as emotional and social context for a first Vibespace profile. Capture expression, energy, confidence, color, pose, setting, and social vibe. Build a starter page that feels like the person's online room, not a generic social profile. Prioritize warmth, identity, emotional truth, and tasteful Myspace-inspired personality. Do not claim facts not visible in the image or provided answers.",
    "",
    "Profile name: " ++ answers.profileName,
    "Favorite song: " ++ answers.favoriteSong,
    "Likes: " ++ answers.likes,
    "Dislikes: " ++ answers.dislikes,
    "Extra vibe note: " ++ answers.vibeNote,
    answers->sendtagPromptContext,
    "",
    "Return a complete starter profile that feels personal, polished, and ready to edit.",
  ]->Array.join("\n")

let naturePrompt = (~answers: onboardingAnswers) =>
  [
    "Create my first Vibespace profile from onboarding.",
    "",
    "The attached image is the nature-path reference photo. Analyze it as atmosphere, palette, place, weather, light, and energy. Match the profile's colors, texture, rhythm, and mood to the scene. Build a starter page that feels like entering that place. Prioritize color harmony, ambient feeling, composition, and environmental details. Do not invent exact location unless the user provided it.",
    "",
    "Profile name: " ++ answers.profileName,
    "Favorite song: " ++ answers.favoriteSong,
    "Likes: " ++ answers.likes,
    "Dislikes: " ++ answers.dislikes,
    "Extra vibe note: " ++ answers.vibeNote,
    answers->sendtagPromptContext,
    "",
    "Return a complete starter profile that feels personal, polished, and ready to edit.",
  ]->Array.join("\n")

let promptForMode = (~mode, ~answers) =>
  switch mode {
  | People => peoplePrompt(~answers)
  | Nature => naturePrompt(~answers)
  }

let answerIsReady = answers => answers.profileName->String.trim != ""

let inputClass =
  "h-11 w-full rounded-xl border border-neutral-200 bg-white px-3 text-base font-semibold text-neutral-950 outline-none transition focus:border-neutral-500 focus:ring-4 focus:ring-neutral-200"

let textareaClass =
  "min-h-24 w-full resize-y rounded-xl border border-neutral-200 bg-white px-3 py-2.5 text-base font-semibold leading-relaxed text-neutral-950 outline-none transition focus:border-neutral-500 focus:ring-4 focus:ring-neutral-200"

type onboardingState = {
  step: onboardingStep,
  selectedMode: option<onboardingMode>,
  imageDataUrl: option<string>,
  answers: onboardingAnswers,
  message: option<string>,
  sendtagValidationInFlight: bool,
  accountKeyCopyStatus: option<string>,
  manualSessionToken: string,
  manualSessionMessage: option<string>,
  redeemedAccount: option<redeemedAccount>,
  locallyRedeemedInviteId: option<string>,
}

type answerField =
  | FavoriteSong
  | Likes
  | Dislikes
  | VibeNote
  | ProfileName
  | Sendtag

type onboardingAction =
  | ModeSelected(onboardingMode)
  | ImageSelected(string)
  | ImageReadFailed(string)
  | AnswerChanged(answerField, string)
  | AccountKeyCopyStarted
  | AccountKeyCopySucceeded
  | AccountKeyCopyFailed
  | ManualSessionTokenChanged(string)
  | ManualSessionMessageSet(option<string>)
  | RedeemStarted
  | RedeemSucceeded({
      account: redeemedAccount,
      inviteId: string,
      displayName: string,
    })
  | RedeemFailed(string)
  | ContinueRequested
  | BackToChooseVibe
  | SendtagCheckStarted(string)
  | SendtagCheckFailed(string)
  | StarterGenerationStarted
  | StarterGenerationQueued
  | StarterGenerationFailed(string)

let initialOnboardingState = initialRedeemedAccount => {
  step: switch initialRedeemedAccount {
  | Some(_) => ChooseVibe
  | None => ConfirmInvite
  },
  selectedMode: None,
  imageDataUrl: None,
  answers: defaultAnswers,
  message: None,
  sendtagValidationInFlight: false,
  accountKeyCopyStatus: None,
  manualSessionToken: "",
  manualSessionMessage: None,
  redeemedAccount: initialRedeemedAccount,
  locallyRedeemedInviteId: None,
}

let updateAnswer = (answers, field, value) =>
  switch field {
  | FavoriteSong => {...answers, favoriteSong: value}
  | Likes => {...answers, likes: value}
  | Dislikes => {...answers, dislikes: value}
  | VibeNote => {...answers, vibeNote: value}
  | ProfileName => {...answers, profileName: value}
  | Sendtag => {...answers, sendtag: value}
  }

let onboardingReducer = (state, action) =>
  switch action {
  | ModeSelected(mode) => {...state, selectedMode: Some(mode), message: None}
  | ImageSelected(dataUrl) => {...state, imageDataUrl: Some(dataUrl), message: None}
  | ImageReadFailed(message) => {...state, message: Some(message)}
  | AnswerChanged(field, value) => {...state, answers: state.answers->updateAnswer(field, value)}
  | AccountKeyCopyStarted => {...state, accountKeyCopyStatus: Some("Copying...")}
  | AccountKeyCopySucceeded => {...state, accountKeyCopyStatus: Some("Copied.")}
  | AccountKeyCopyFailed => {
      ...state,
      accountKeyCopyStatus: Some("Copy failed. Copy the key manually."),
    }
  | ManualSessionTokenChanged(token) => {
      ...state,
      manualSessionToken: token,
      manualSessionMessage: None,
    }
  | ManualSessionMessageSet(message) => {...state, manualSessionMessage: message}
  | RedeemStarted => {...state, message: Some("Redeeming invite...")}
  | RedeemSucceeded({account, inviteId, displayName}) => {
      ...state,
      redeemedAccount: Some(account),
      locallyRedeemedInviteId: Some(inviteId),
      answers: {...state.answers, profileName: displayName},
      message: None,
      step: ChooseVibe,
    }
  | RedeemFailed(message) => {...state, message: Some(message)}
  | ContinueRequested =>
    switch (state.selectedMode, state.imageDataUrl) {
    | (Some(_), Some(_)) => {...state, message: None, step: Questions}
    | (None, _) => {...state, message: Some("Choose people or nature first.")}
    | (_, None) => {...state, message: Some("Upload a photo first.")}
    }
  | BackToChooseVibe => {...state, step: ChooseVibe}
  | SendtagCheckStarted(normalizedSendtag) => {
      ...state,
      sendtagValidationInFlight: true,
      message: Some(
        normalizedSendtag == ""
          ? "Designing your starter profile..."
          : "Checking /" ++ normalizedSendtag ++ "...",
      ),
    }
  | SendtagCheckFailed(message) => {
      ...state,
      sendtagValidationInFlight: false,
      message: Some(message),
    }
  | StarterGenerationStarted => {
      ...state,
      sendtagValidationInFlight: false,
      message: Some("Designing your starter profile..."),
      step: Generating,
    }
  | StarterGenerationQueued => {
      ...state,
      message: Some("We are building your starter Vibespace in the background."),
      step: Generating,
    }
  | StarterGenerationFailed(message) => {
      ...state,
      sendtagValidationInFlight: false,
      message: Some(message),
      step: Questions,
    }
  }

@react.component
let make = (~queryRef, ~code: string) => {
  let data = Query.usePreloaded(~queryRef)
  let router = RelayRouter.Utils.useRouter()
  let agentTracker = AgentEditTracker.use()
  let editorLink = Routes.Editor.Route.makeLink()
  let exploreLink = Routes.Explore.Route.makeLink()
  let inviteBelongsToViewer = switch data.inviteByCode {
  | Some(invite) =>
    switch (data.viewer, invite.invitee) {
    | (Some(viewer), Some(invitee)) => viewer.id == invitee.id
    | _ => false
    }
  | None => false
  }
  let initialRedeemedAccount = switch (
    inviteBelongsToViewer,
    LocalViewerSession.load(),
    data.viewer,
    data.viewerProfile,
  ) {
  | (true, Some(sessionToken), Some(_viewer), Some(profile)) =>
    Some({
      sessionToken,
      profileId: profile.id,
      profileSlug: profile.slug,
    })
  | _ => None
  }
  let (state, dispatch) = React.useReducer(
    onboardingReducer,
    initialOnboardingState(initialRedeemedAccount),
  )
  let step = state.step
  let selectedMode = state.selectedMode
  let imageDataUrl = state.imageDataUrl
  let answers = state.answers
  let message = state.message
  let sendtagValidationInFlight = state.sendtagValidationInFlight
  let accountKeyCopyStatus = state.accountKeyCopyStatus
  let manualSessionToken = state.manualSessionToken
  let manualSessionMessage = state.manualSessionMessage
  let redeemedAccount = state.redeemedAccount
  let locallyRedeemedInviteId = state.locallyRedeemedInviteId
  let (redeemInvite, redeemInviteInFlight) = ProfileVersionMutations.RedeemInviteMutation.use()
  let (submitAgentEdit, submitAgentEditInFlight) = ProfileVersionMutations.SubmitAgentEditMutation.use()

  let goHome = () => router.push(editorLink)
  let invalidateRelayStore = () =>
    RescriptRelay.commitLocalUpdate(
      ~environment=RelayEnv.environment,
      ~updater=store => store->RescriptRelay.RecordSourceSelectorProxy.invalidateStore,
    )
  let openSavedSession = () => {
    invalidateRelayStore()
    router.replace(editorLink)
  }

  let updateAnswer = (field, value) => dispatch(AnswerChanged(field, value))

  let copyAccountKey = token => {
    dispatch(AccountKeyCopyStarted)
    let run = async () => {
      try {
        await Clipboard.writeText(DomGlobal.navigator->Navigator.clipboard, token)
        dispatch(AccountKeyCopySucceeded)
      } catch {
      | _ => dispatch(AccountKeyCopyFailed)
      }
    }
    run()->Promise.ignore
  }

  let restoreManualSession = () => {
    let token = manualSessionToken->String.trim
    if token == "" {
      dispatch(ManualSessionMessageSet(Some("Paste your account key first.")))
    } else {
      LocalViewerSession.save(token)
      dispatch(ManualSessionMessageSet(Some("Account key saved. Opening your Vibespace...")))
      openSavedSession()
    }
  }

  let readImage = event => {
    ReactEvent.Synthetic.preventDefault(event)
    ReactEvent.Synthetic.stopPropagation(event)
    let run = async () => {
      try {
        let dataUrl = await readFirstImageFromEvent(event)
        switch dataUrl->Nullable.toOption {
        | Some(value) => dispatch(ImageSelected(value))
        | None => dispatch(ImageReadFailed("Choose an image file to keep building your vibe."))
        }
      } catch {
      | _ => dispatch(ImageReadFailed("That image could not be read. Try a different photo."))
      }
    }
    run()->Promise.ignore
  }

  let confirmRedeem = () => {
    if !redeemInviteInFlight {
      dispatch(RedeemStarted)
      redeemInvite(
        ~variables={input: {code, displayName: "New Vibespace"}},
        ~onCompleted=(response, errors) => {
          switch errors {
          | Some(errors) =>
            switch errors->Array.get(0) {
            | Some(error) => dispatch(RedeemFailed(error.message))
            | None => dispatch(RedeemFailed("Invite redemption failed."))
            }
          | None =>
            switch response.redeemInvite {
            | RedeemInviteSucceeded(payload) =>
              switch payload.sessionToken {
              | Some(token) =>
                LocalViewerSession.save(token)
                copyAccountKey(token)
                dispatch(RedeemSucceeded({
                  account: {
                    sessionToken: token,
                    profileId: payload.profile.id,
                    profileSlug: payload.profile.slug,
                  },
                  inviteId: payload.invite.id,
                  displayName: payload.user.displayName,
                }))
              | None =>
                dispatch(RedeemFailed("Profile was created, but the server did not return a session token."))
              }
            | MutationFailed({message}) => dispatch(RedeemFailed(message))
            | UnselectedUnionMember(_) => dispatch(RedeemFailed("Invite redemption returned an unknown result."))
            }
          }
        },
        ~onError=error => dispatch(RedeemFailed(error.message)),
      )->ignore
    }
  }

  let startQuestions = () => dispatch(ContinueRequested)

  let generateStarterProfile = () => {
    switch (redeemedAccount, selectedMode, imageDataUrl) {
    | (Some(account), Some(mode), Some(referenceImageDataUrl)) if answers->answerIsReady =>
      if sendtagValidationInFlight || submitAgentEditInFlight {
        ()
      } else {
      let run = async () => {
        let rawSendtag = answers.sendtag
        let normalizedSendtag = rawSendtag->normalizeSendtag
        dispatch(SendtagCheckStarted(normalizedSendtag))

        try {
          let sendtagValidation = await validateSendtag(rawSendtag)
          if !sendtagValidation.ok {
            dispatch(SendtagCheckFailed(sendtagValidation.message))
          } else {
            dispatch(StarterGenerationStarted)
            submitAgentEdit(
              ~variables={
                input: {
                  profileId: account.profileId,
                  prompt: promptForMode(~mode, ~answers),
                  selectionLabel: "Onboarding starter profile",
                  selectionAgentContext: onboardingContext(mode),
                  selectedRegionScreenshotDataUrl: "",
                  fullPageScreenshotDataUrl: "",
                  referenceImageDataUrl,
                  previousFailedHtml: "",
                  previousFailedCss: "",
                  previousFailedSummary: "",
                  previousFailedWarnings: "",
                  previousFailedValidationMessage: "",
                  profileName: answers.profileName,
                  sendtag: sendtagValidation.sendtag,
                  mode: REASONING,
                },
              },
              ~onCompleted=(response, errors) => {
                switch errors {
                | Some(errors) =>
                  switch errors->Array.get(0) {
                  | Some(error) =>
                    dispatch(StarterGenerationFailed(error.message))
                  | None =>
                    dispatch(StarterGenerationFailed("Starter profile generation failed."))
                  }
                | None =>
                  switch response.submitAgentEdit {
                  | ProfileEditSessionMutationSucceeded(payload) =>
                    agentTracker.trackOnboardingStarter({
                      sessionId: payload.succeededEditSession.id,
                      profileSlug: account.profileSlug,
                      inviteCode: code,
                    })
                    invalidateRelayStore()
                    dispatch(StarterGenerationQueued)
                  | ProfileEditSessionMutationFailed({message}) =>
                    dispatch(StarterGenerationFailed(message))
                  | UnselectedUnionMember(_) =>
                    dispatch(StarterGenerationFailed("Starter profile generation returned an unknown result."))
                  }
                }
              },
              ~onError=error => {
                dispatch(StarterGenerationFailed(error.message))
              },
            )->ignore
          }
        } catch {
        | _ =>
          dispatch(SendtagCheckFailed("We could not check that Sendtag. Check the tag or leave it blank."))
        }
      }
      run()->Promise.ignore
      }
    | (None, _, _) => dispatch(StarterGenerationFailed("Redeem the invite before generating a starter profile."))
    | (_, None, _) => dispatch(StarterGenerationFailed("Choose people or nature first."))
    | (_, _, None) => dispatch(StarterGenerationFailed("Upload a photo first."))
    | (_, _, _) => dispatch(StarterGenerationFailed("Give your profile a name first."))
    }
  }

  let welcomeLetters = ["W", "e", "l", "c", "o", "m", "e", " ", "t", "o", " ", "v", "i", "b", "e", "s", "p", "a", "c", "e", "."]

  let renderWelcome = () =>
    <h1 className="m-0 flex flex-wrap justify-center gap-[0.02em] text-center font-serif text-6xl font-black leading-none tracking-normal text-neutral-950 max-md:text-4xl">
      {welcomeLetters
      ->Array.mapWithIndex((letter, index) => {
        let key = "welcome-" ++ index->Int.toString
        <span
          key
          className={letter == " "
            ? "inline-block w-3"
            : "inline-block animate-[bounce_3.8s_ease-in-out_infinite] motion-reduce:animate-none"}
          style={{animationDelay: (index * 90)->Int.toString ++ "ms"}}>
          {React.string(letter)}
        </span>
      })
      ->React.array}
    </h1>

  let renderShell = children =>
    <main className="min-h-screen bg-[radial-gradient(circle_at_12%_8%,rgba(125,211,252,0.22),transparent_28%),radial-gradient(circle_at_82%_14%,rgba(253,186,116,0.24),transparent_30%),linear-gradient(135deg,#fafafa,#e7e5e4)] p-5 text-neutral-950">
      <header className="mx-auto flex w-[min(1100px,100%)] items-center justify-between py-3">
        <RelayRouter.Link
          className="inline-flex min-h-8 items-center rounded-xl border border-white/70 bg-white/80 px-3 text-sm font-black text-neutral-950 no-underline shadow-sm backdrop-blur-md"
          to_=editorLink
          preloadCode=OnInView
          preloadData=OnIntent>
          {React.string("vibespace")}
        </RelayRouter.Link>
      </header>
      <section className="mx-auto grid min-h-[calc(100vh-96px)] w-[min(1100px,100%)] place-items-center py-8">
        {children}
      </section>
    </main>

  let renderAccountKey = () =>
    redeemedAccount->Option.mapOr(React.null, account =>
      <aside className="mx-auto w-[min(760px,100%)] rounded-2xl border border-neutral-200 bg-white/85 p-4 text-left shadow-lg backdrop-blur-md">
        <div className="flex flex-wrap items-start justify-between gap-3">
          <div className="min-w-0">
            <p className="m-0 text-[11px] font-black uppercase tracking-[0.16em] text-neutral-500">
              {React.string("Account key")}
            </p>
            <p className="mt-1 mb-0 text-sm leading-snug text-neutral-600">
              {React.string("This temporary key is your way back into this MVP account. It is saved in this browser and copied when possible.")}
            </p>
          </div>
          <Button variant=Outline type_="button" onClick={_ => copyAccountKey(account.sessionToken)}>
            {React.string("Copy key")}
          </Button>
        </div>
        <code className="mt-3 block max-h-28 overflow-auto rounded-xl border border-neutral-200 bg-neutral-50 p-3 text-xs font-bold leading-relaxed break-all text-neutral-700">
          {React.string(account.sessionToken)}
        </code>
        {accountKeyCopyStatus->Option.mapOr(React.null, status =>
          <p className="mt-2 mb-0 text-xs font-black uppercase tracking-[0.12em] text-neutral-500">
            {React.string(status)}
          </p>
        )}
      </aside>
    )

  let renderOpenProfileButton = () =>
    redeemedAccount->Option.mapOr(React.null, _account =>
      <Button variant=Outline type_="button" onClick={_ => goHome()}>
        {React.string("Skip for now")}
      </Button>
    )

  let renderAccountKeyRestore = () =>
    <section className="mt-6 rounded-2xl border border-neutral-200 bg-neutral-50 p-4">
      <p className="m-0 text-[11px] font-black uppercase tracking-[0.16em] text-neutral-500">
        {React.string("Already accepted?")}
      </p>
      <p className="mt-1 mb-3 text-sm leading-snug text-neutral-600">
        {React.string("Paste your account key to reopen your Vibespace on this browser.")}
      </p>
      <div className="grid gap-2">
        <input
          className=inputClass
          value=manualSessionToken
          placeholder="Paste account key"
          onChange={event => {
            dispatch(ManualSessionTokenChanged(BrowserBridge.eventTargetValue(event)))
          }}
        />
        <div className="flex justify-end">
          <Button type_="button" onClick={_ => restoreManualSession()}>
            {React.string("Use account key")}
          </Button>
        </div>
      </div>
      {manualSessionMessage->Option.mapOr(React.null, text =>
        <p className="mt-2 mb-0 text-xs font-bold text-neutral-500"> {React.string(text)} </p>
      )}
    </section>

  let renderPolaroid = mode => {
    let selected = switch selectedMode {
    | Some(current) => current == mode
    | None => false
    }
    let label = if selected {
      modeTitle(mode)
    } else {
      switch mode {
      | People => "I like people"
      | Nature => "I like nature"
      }
    }
    let imageVisible = selected && imageDataUrl->Option.isSome
    let polaroidClass =
      "group grid gap-4 rounded-[2rem] border bg-white p-4 text-center shadow-2xl transition hover:-translate-y-1 " ++
      (selected
        ? "border-neutral-950 shadow-neutral-950/20"
        : "border-white/80 shadow-neutral-950/10")

    <article className="grid gap-3">
      <p className="m-0 text-center text-lg font-black leading-tight text-neutral-800">
        {React.string(label)}
      </p>
      <button
        className=polaroidClass
        type_="button"
        onClick={_ => {
          dispatch(ModeSelected(mode))
        }}>
        <div className="grid aspect-[4/5] place-items-center overflow-hidden rounded-[1.35rem] bg-neutral-100">
          {switch (imageVisible, imageDataUrl) {
          | (true, Some(dataUrl)) =>
            <img className="h-full w-full object-cover" src=dataUrl alt="Uploaded onboarding reference" />
          | _ =>
            <div className={selected
              ? "grid size-32 place-items-center rounded-full bg-white text-7xl shadow-inner"
              : "grid size-32 place-items-center rounded-full border border-dashed border-neutral-300 bg-white/70 text-5xl text-neutral-300"}>
              {React.string(selected ? mode->placeholderGlyph : "＋")}
            </div>
          }}
        </div>
        <span className="text-sm font-black text-neutral-500">
          {React.string(selected ? "Click or drop a photo below" : "Choose this vibe")}
        </span>
      </button>
    </article>
  }

  let renderUploader = () =>
    <label
      className="mt-8 grid cursor-pointer gap-3 rounded-3xl border border-dashed border-neutral-300 bg-white/70 p-6 text-center shadow-lg transition hover:border-neutral-950 hover:bg-white"
      onDragOver={event => ReactEvent.Synthetic.preventDefault(event->ReactEvent.toSyntheticEvent)}
      onDrop={event => readImage(event->ReactEvent.toSyntheticEvent)}>
      <input
        className="sr-only"
        type_="file"
        accept="image/*"
        onChange={event => readImage(event->ReactEvent.toSyntheticEvent)}
      />
      <span className="text-sm font-black uppercase tracking-[0.16em] text-neutral-500">
        {React.string("Upload photo")}
      </span>
      <span className="text-base font-semibold text-neutral-700">
        {React.string("Drag and drop or click to choose the photo that starts your profile vibe.")}
      </span>
    </label>

  let renderConfirm = inviterName =>
    <BaseUi.Dialog.Root open_={step == ConfirmInvite} modal={BaseUi.Types.Modal.Bool(true)} onOpenChange={(_, _details) => ()}>
      <BaseUi.Dialog.Portal>
        <BaseUi.Dialog.Backdrop className="fixed inset-0 z-[90] bg-neutral-950/35 backdrop-blur-md" />
        <BaseUi.Dialog.Popup className="fixed left-1/2 top-1/2 z-[91] w-[min(520px,calc(100vw-32px))] -translate-x-1/2 -translate-y-1/2 rounded-[2rem] border border-white/70 bg-white p-7 text-neutral-950 shadow-2xl">
          <BaseUi.Dialog.Title className="m-0 text-5xl font-black leading-none tracking-normal max-md:text-4xl">
            {React.string("Start your Vibespace?")}
          </BaseUi.Dialog.Title>
          <BaseUi.Dialog.Description className="mt-4 text-base leading-relaxed text-neutral-600">
            {React.string("This invite from " ++ inviterName ++ " creates your account now. Then we will catch your vibe and make a starter profile.")}
          </BaseUi.Dialog.Description>
          {message->Option.mapOr(React.null, text =>
            <Alert className="mt-4">
              <Alert.Description> {React.string(text)} </Alert.Description>
            </Alert>
          )}
          <div className="mt-6 flex justify-end gap-2">
            <Button variant=Outline type_="button" onClick={_ => router.push(editorLink)}>
              {React.string("Not now")}
            </Button>
            <Button type_="button" disabled=redeemInviteInFlight onClick={_ => confirmRedeem()}>
              {React.string(redeemInviteInFlight ? "Redeeming..." : "Redeem invite")}
            </Button>
          </div>
        </BaseUi.Dialog.Popup>
      </BaseUi.Dialog.Portal>
    </BaseUi.Dialog.Root>

  let renderChoice = () =>
    <article className="w-full">
      <div className="mb-10 grid justify-items-center gap-5">
        {renderWelcome()}
        <p className="m-0 max-w-2xl text-center text-lg leading-relaxed text-neutral-600">
          {React.string("Pick the kind of photo that feels closest to the profile you want people to walk into.")}
        </p>
        {renderAccountKey()}
      </div>
      <section className="grid grid-cols-2 gap-8 max-md:grid-cols-1">
        {renderPolaroid(People)}
        {renderPolaroid(Nature)}
      </section>
      {selectedMode->Option.isSome ? renderUploader() : React.null}
      {message->Option.mapOr(React.null, text =>
        <Alert className="mx-auto mt-5 w-[min(620px,100%)]">
          <Alert.Description> {React.string(text)} </Alert.Description>
        </Alert>
      )}
      <div className="mt-7 flex flex-wrap justify-center gap-2.5">
        {renderOpenProfileButton()}
        <Button type_="button" onClick={_ => startQuestions()}>
          {React.string("Continue")}
        </Button>
      </div>
    </article>

  let renderQuestions = () =>
    <article className="w-[min(760px,100%)] rounded-[2rem] border border-white/70 bg-white/90 p-7 shadow-2xl backdrop-blur-xl">
      <p className="m-0 text-xs font-black uppercase tracking-[0.18em] text-neutral-500">
        {React.string("Almost ready")}
      </p>
      <h1 className="mt-2 mb-0 text-5xl font-black leading-none tracking-normal max-md:text-4xl">
        {React.string("Tell us a little more.")}
      </h1>
      <div className="mt-5">
        {renderAccountKey()}
      </div>
      <div className="mt-6 grid gap-4">
        <label className="grid gap-1.5 text-sm font-black text-neutral-700">
          {React.string("Favorite song")}
          <input
            className=inputClass
            value=answers.favoriteSong
            placeholder="The song that says it all"
            onChange={event => updateAnswer(FavoriteSong, BrowserBridge.eventTargetValue(event))}
          />
        </label>
        <label className="grid gap-1.5 text-sm font-black text-neutral-700">
          {React.string("Likes")}
          <textarea
            className=textareaClass
            value=answers.likes
            placeholder="People, places, styles, colors, moods"
            onChange={event => updateAnswer(Likes, BrowserBridge.eventTargetValue(event))}
          />
        </label>
        <label className="grid gap-1.5 text-sm font-black text-neutral-700">
          {React.string("Dislikes")}
          <textarea
            className=textareaClass
            value=answers.dislikes
            placeholder="Anything your profile should avoid"
            onChange={event => updateAnswer(Dislikes, BrowserBridge.eventTargetValue(event))}
          />
        </label>
        <label className="grid gap-1.5 text-sm font-black text-neutral-700">
          {React.string("Anything else?")}
          <textarea
            className=textareaClass
            value=answers.vibeNote
            placeholder="A mood, a memory, a weird detail, a whole direction"
            onChange={event => updateAnswer(VibeNote, BrowserBridge.eventTargetValue(event))}
          />
        </label>
        <label className="grid gap-1.5 text-sm font-black text-neutral-700">
          {React.string("Profile name")}
          <input
            className=inputClass
            value=answers.profileName
            placeholder="What should this profile be called?"
            onChange={event => updateAnswer(ProfileName, BrowserBridge.eventTargetValue(event))}
          />
        </label>
        <label className="grid gap-1.5 text-sm font-black text-neutral-700">
          {React.string("Sendtag")}
          <input
            className=inputClass
            value=answers.sendtag
            placeholder="Optional, like Blusy19 or /Blusy19"
            onChange={event => updateAnswer(Sendtag, BrowserBridge.eventTargetValue(event))}
          />
        </label>
        {message->Option.mapOr(React.null, text =>
          <Alert>
            <Alert.Description> {React.string(text)} </Alert.Description>
          </Alert>
        )}
        <div className="flex flex-wrap justify-end gap-2.5">
          {renderOpenProfileButton()}
          <Button variant=Outline type_="button" onClick={_ => dispatch(BackToChooseVibe)}>
            {React.string("Back")}
          </Button>
          <Button
            type_="button"
            disabled={sendtagValidationInFlight || submitAgentEditInFlight || !(answers->answerIsReady)}
            onClick={_ => generateStarterProfile()}>
            {React.string(
              sendtagValidationInFlight
                ? "Checking..."
                : submitAgentEditInFlight
                ? "Designing..."
                : "Design my profile",
            )}
          </Button>
        </div>
      </div>
    </article>

  let renderGenerating = () =>
    <div className="grid w-[min(760px,100%)] gap-4">
      <article className="grid justify-items-center gap-4 rounded-[2rem] border border-white/70 bg-white/90 p-8 text-center shadow-2xl backdrop-blur-xl">
        <span className="size-12 rounded-full border-4 border-amber-200 bg-amber-100 shadow-[0_0_0_10px_rgba(251,191,36,0.16)]" />
        <p className="m-0 text-xs font-black uppercase tracking-[0.18em] text-amber-700">
          {React.string("Building in the background")}
        </p>
        <h1 className="m-0 text-4xl font-black leading-none tracking-normal">
          {React.string("Your starter profile is on the way.")}
        </h1>
        <p className="m-0 max-w-xl text-base leading-relaxed text-neutral-600">
          {React.string("Reasoning model generations usually take about 3-5 minutes. You can leave this page now; Vibespace will keep checking and show a small notification when your profile is ready.")}
        </p>
        {message->Option.mapOr(React.null, text =>
          <Alert>
            <Alert.Description> {React.string(text)} </Alert.Description>
          </Alert>
        )}
        <div className="flex flex-wrap justify-center gap-2.5">
          <RelayRouter.Link
            className="inline-flex h-10 items-center rounded-md border border-neutral-950 bg-neutral-950 px-4 text-sm font-black text-white no-underline hover:bg-neutral-800"
            to_=exploreLink
            preloadCode=OnInView
            preloadData=OnIntent
            preloadPriority=High>
            {React.string("Explore profiles")}
          </RelayRouter.Link>
          <RelayRouter.Link
            className="inline-flex h-10 items-center rounded-md border border-neutral-300 bg-white px-4 text-sm font-black text-neutral-950 no-underline hover:bg-neutral-50"
            to_=editorLink
            preloadCode=OnInView
            preloadData=OnIntent>
            {React.string("Open app")}
          </RelayRouter.Link>
        </div>
      </article>
      {renderAccountKey()}
    </div>

  switch data.inviteByCode {
  | None =>
    renderShell(
      <article className="w-[min(560px,100%)] rounded-3xl border border-white/70 bg-white/90 p-7 shadow-2xl backdrop-blur-xl">
        <p className="m-0 text-xs font-black uppercase tracking-[0.18em] text-amber-700">
          {React.string("Invite unavailable")}
        </p>
        <h1 className="mt-3 mb-0 text-5xl font-black leading-none tracking-normal max-md:text-4xl">
          {React.string("This link cannot start a profile.")}
        </h1>
        <p className="mt-4 mb-0 text-base leading-relaxed text-neutral-600">
          {React.string("The invite may be missing, already used, or no longer active. Vibespace is invite-only during this MVP.")}
        </p>
        <div className="mt-6">
          <Button variant=Outline type_="button" onClick={_ => router.push(editorLink)}>
            {React.string("Back to vibespace")}
          </Button>
        </div>
        {renderAccountKeyRestore()}
      </article>,
    )
  | Some(invite) =>
    let status = invite.status->inviteStatusLabel
    let available = status == "Available"
    let inviteBelongsToViewer = switch (data.viewer, invite.invitee) {
    | (Some(viewer), Some(invitee)) => viewer.id == invitee.id
    | _ => false
    }
    let locallyRedeemedThisInvite = switch locallyRedeemedInviteId {
    | Some(inviteId) => inviteId == invite.id
    | None => false
    }
    let canUseInvite = available || (
      redeemedAccount->Option.isSome && (inviteBelongsToViewer || locallyRedeemedThisInvite)
    )
    if !canUseInvite {
      renderShell(
        <article className="w-[min(560px,100%)] rounded-3xl border border-white/70 bg-white/90 p-7 shadow-2xl backdrop-blur-xl">
          <p className="m-0 text-xs font-black uppercase tracking-[0.18em] text-amber-700">
            {React.string("Invite " ++ status->String.toLowerCase)}
          </p>
          <h1 className="mt-3 mb-0 text-5xl font-black leading-none tracking-normal max-md:text-4xl">
            {React.string("This invite was already claimed.")}
          </h1>
          <p className="mt-4 mb-0 text-base leading-relaxed text-neutral-600">
            {React.string("Ask your inviter for the next link in the chain.")}
          </p>
          {renderAccountKeyRestore()}
        </article>,
      )
    } else {
      let inviterName = invite.inviter->Option.mapOr("Someone", inviter => inviter.displayName)
      renderShell(
        <>
          {step == ConfirmInvite ? renderConfirm(inviterName) : React.null}
          {switch step {
          | ConfirmInvite => React.null
          | ChooseVibe => renderChoice()
          | Questions => renderQuestions()
          | Generating => renderGenerating()
          }}
        </>,
      )
    }
  }
}
