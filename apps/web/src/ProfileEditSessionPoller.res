module Query = %relay(`
  query ProfileEditSessionPollerQuery($id: ID!) {
    profileEditSessionById(id: $id) {
      id
      prompt
      status
      progressPhase
      summary
      warnings
      error
      failedHtml
      failedCss
      failedValidationMessage
      failedValidationSpanJson
      resultVersionId
      selectionSnapshot {
        id
        label
      }
      resultVersion {
        id
        revisionNumber
        html
        css
        source
        summary
        validationStatus
        validationErrors
        createdBy {
          id
          displayName
        }
        createdAt
      }
      createdAt
      updatedAt
    }
  }
`)

type polledProfileEditSession =
  ProfileEditSessionPollerQuery_graphql.Types.response_profileEditSessionById

type polledProfileVersion =
  ProfileEditSessionPollerQuery_graphql.Types.response_profileEditSessionById_resultVersion

@val external setTimeout: (unit => unit, int) => int = "setTimeout"
@val external clearTimeout: int => unit = "clearTimeout"

let pollIntervalMs = 5000

let statusKey = (status: RelaySchemaAssets_graphql.enum_ProfileEditSessionStatus) =>
  switch status {
  | DRAFT => "draft"
  | RUNNING => "running"
  | APPLIED => "applied"
  | FAILED => "failed"
  | CANCELED => "canceled"
  | FutureAddedValue(value) => "future:" ++ value
  }

module Result = {
  @react.component
  let make = (
    ~queryRef,
    ~pollIndex: int,
    ~requestNextPoll: unit => unit,
    ~onSession: polledProfileEditSession => unit,
    ~onProgress: RelaySchemaAssets_graphql.enum_EditProgressPhase => unit,
    ~onApplied: (polledProfileEditSession, polledProfileVersion) => unit,
    ~onFailed: string => unit,
    ~onFinished: unit => unit,
  ) => {
    let data = Query.usePreloaded(~queryRef)
    let terminalHandled = React.useRef(false)
    let dataKey = switch data.profileEditSessionById {
    | Some(session) =>
      pollIndex->Int.toString ++
      ":" ++
      session.id ++
      ":" ++
      session.status->statusKey ++
      ":" ++
      session.updatedAt ++
      ":" ++
      session.resultVersionId->Option.getOr("no-result-version")
    | None => pollIndex->Int.toString ++ ":missing"
    }

    React.useEffect1(() => {
      switch data.profileEditSessionById {
      | None =>
        if !terminalHandled.current {
          terminalHandled.current = true
          onFailed("Assistant session was not found.")
          onFinished()
        }
        None
      | Some(session) =>
        onSession(session)
        onProgress(session.progressPhase)
        switch session.status {
        | APPLIED =>
          if !terminalHandled.current {
            terminalHandled.current = true
            switch session.resultVersion {
            | Some(version) => onApplied(session, version)
            | None => onFailed("Assistant request applied without returning profile content.")
            }
            onFinished()
          }
          None
        | FAILED =>
          if !terminalHandled.current {
            terminalHandled.current = true
            onFailed(session.error->Option.getOr("Assistant request failed."))
            onFinished()
          }
          None
        | CANCELED =>
          if !terminalHandled.current {
            terminalHandled.current = true
            onFailed(session.error->Option.getOr("Assistant request was canceled."))
            onFinished()
          }
          None
        | DRAFT | RUNNING | FutureAddedValue(_) =>
          let timerId = setTimeout(() => requestNextPoll(), pollIntervalMs)
          Some(() => clearTimeout(timerId))
        }
      }
    }, [dataKey])

    switch data.profileEditSessionById {
    | Some(session) if session.status == FAILED =>
      <FailedPatchPanel
        sessionId={session.id}
        failedHtml=session.failedHtml
        failedCss=session.failedCss
        failedValidationMessage=session.failedValidationMessage
        failedValidationSpanJson=session.failedValidationSpanJson
      />
    | _ => React.null
    }
  }
}

module LoadError = {
  @react.component
  let make = (~onFailed: string => unit, ~onFinished: unit => unit) => {
    let reported = React.useRef(false)

    React.useEffect1(() => {
      if !reported.current {
        reported.current = true
        onFailed("Unable to refresh assistant status.")
        onFinished()
      }
      None
    }, ["load-error"])

    React.null
  }
}

@react.component
let make = (
  ~sessionId: string,
  ~onSession: polledProfileEditSession => unit,
  ~onProgress: RelaySchemaAssets_graphql.enum_EditProgressPhase => unit,
  ~onApplied: (polledProfileEditSession, polledProfileVersion) => unit,
  ~onFailed: string => unit,
  ~onFinished: unit => unit,
) => {
  let (queryRef, loadQuery, disposeQuery) = Query.useLoader()
  let (pollIndex, setPollIndex) = React.useState(() => 0)
  let stopped = React.useRef(false)
  let loadKey = sessionId ++ ":" ++ pollIndex->Int.toString
  let variables: ProfileEditSessionPollerQuery_graphql.Types.variables = {id: sessionId}

  let finish = () => {
    if !stopped.current {
      stopped.current = true
      disposeQuery()
      onFinished()
    }
  }

  React.useEffect1(() => {
    if !stopped.current {
      loadQuery(~variables, ~fetchPolicy=NetworkOnly)
    }
    None
  }, [loadKey])

  React.useEffect1(() => {
    stopped.current = false
    Some(() => {
      disposeQuery()
    })
  }, [sessionId])

  switch queryRef {
  | Some(queryRef) =>
    <RescriptReactErrorBoundary fallback={_error =>
      <LoadError onFailed onFinished=finish />
    }>
      <React.Suspense fallback=React.null>
        <Result
          key=loadKey
          queryRef
          pollIndex
          requestNextPoll={() => setPollIndex(index => index + 1)}
          onSession
          onProgress
          onApplied
          onFailed
          onFinished=finish
        />
      </React.Suspense>
    </RescriptReactErrorBoundary>
  | None => React.null
  }
}
