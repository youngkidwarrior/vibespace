type spanShape = {
  source: string,
  charStart: int,
  charEnd: int,
}

let parseSpan = (raw: option<string>): option<spanShape> =>
  switch raw {
  | None => None
  | Some(text) =>
    try {
      let json = JSON.parseExn(text)
      let dict = json->JSON.Decode.object->Option.getOr(Dict.make())
      let source =
        dict
        ->Dict.get("source")
        ->Option.flatMap(JSON.Decode.string)
        ->Option.getOr("")
      let charStart =
        dict
        ->Dict.get("charStart")
        ->Option.flatMap(JSON.Decode.float)
        ->Option.map(Float.toInt)
        ->Option.getOr(-1)
      let charEnd =
        dict
        ->Dict.get("charEnd")
        ->Option.flatMap(JSON.Decode.float)
        ->Option.map(Float.toInt)
        ->Option.getOr(-1)
      if source == "" || charStart < 0 || charEnd <= charStart {
        None
      } else {
        Some({source, charStart, charEnd})
      }
    } catch {
    | _ => None
    }
  }

let renderHighlightedSource = (
  source: string,
  span: option<spanShape>,
  expectedSource: string,
) =>
  switch span {
  | Some({source: kind, charStart, charEnd}) if kind == expectedSource =>
    let safeStart = Math.Int.max(0, Math.Int.min(charStart, source->String.length))
    let safeEnd = Math.Int.max(safeStart, Math.Int.min(charEnd, source->String.length))
    <>
      {React.string(source->String.slice(~start=0, ~end=safeStart))}
      <mark className="rounded bg-amber-200 text-amber-900">
        {React.string(source->String.slice(~start=safeStart, ~end=safeEnd))}
      </mark>
      {React.string(source->String.slice(~start=safeEnd, ~end=source->String.length))}
    </>
  | _ => React.string(source)
  }

@react.component
let make = (
  ~sessionId: string,
  ~failedHtml: option<string>,
  ~failedCss: option<string>,
  ~failedValidationMessage: option<string>,
  ~failedValidationSpanJson: option<string>,
) => {
  let span = parseSpan(failedValidationSpanJson)
  let html = failedHtml->Option.getOr("")
  let css = failedCss->Option.getOr("")
  let message =
    failedValidationMessage
    ->Option.map(String.trim)
    ->Option.getOr("Assistant output failed validation.")

  let (copyStatus, setCopyStatus) = React.useState(() => "")
  let (repairStatus, setRepairStatus) = React.useState(() => "")
  let (repairing, setRepairing) = React.useState(() => false)
  let (commitMutation, _) =
    ProfileVersionMutations.RequestTargetedAgentEditRepairMutation.use()
  let canTargetedRepair = switch span {
  | Some({source}) => source == "html"
  | None => false
  }

  let onTryFix = () => {
    setRepairStatus(_ => "")
    setRepairing(_ => true)
    commitMutation(
      ~variables={
        input: {
          editSessionId: sessionId,
        },
      },
      ~onCompleted=(response, errors) => {
        setRepairing(_ => false)
        switch errors {
        | Some(errs) if errs->Array.length > 0 =>
          setRepairStatus(_ => "Targeted repair could not be requested.")
        | _ =>
          switch response.requestTargetedAgentEditRepair {
          | ProfileEditSessionMutationSucceeded(_) =>
            setRepairStatus(_ => "Repair sent. The applied version should arrive on the next poll.")
          | ProfileEditSessionMutationFailed(payload) =>
            setRepairStatus(_ => "Repair failed: " ++ payload.message)
          | UnselectedUnionMember(_) =>
            setRepairStatus(_ => "Repair returned an unexpected response.")
          }
        }
      },
    )->ignore
  }

  let copy = (label, value) => {
    setCopyStatus(_ => "")
    let run = async () => {
      try {
        await Clipboard.writeText(DomGlobal.navigator->Navigator.clipboard, value)
        setCopyStatus(_ => `Copied ${label}.`)
      } catch {
      | _ => setCopyStatus(_ => `Could not copy ${label}.`)
      }
    }
    run()->Promise.ignore
  }

  if html == "" && css == "" {
    React.null
  } else {
    <section
      className="pointer-events-auto fixed left-4 right-4 top-4 z-40 mx-auto max-w-3xl rounded-2xl border border-amber-200 bg-amber-50 p-4 text-sm text-amber-900 shadow-xl md:left-auto md:right-4 md:top-4">
      <header className="mb-2 flex items-start justify-between gap-3">
        <div>
          <p className="text-xs font-semibold uppercase tracking-wide text-amber-700">
            {React.string("Assistant edit could not apply")}
          </p>
          <p className="mt-1 text-base font-medium text-amber-900">{React.string(message)}</p>
        </div>
        <button
          type_="button"
          disabled={!canTargetedRepair || repairing}
          onClick={_ => onTryFix()}
          className="inline-flex shrink-0 items-center gap-1 rounded-md border border-amber-300 bg-amber-100 px-3 py-1 text-xs font-semibold text-amber-900 hover:bg-amber-200 disabled:cursor-not-allowed disabled:opacity-50">
          {React.string(repairing ? "Sending..." : "Try fix with assistant")}
        </button>
      </header>
      {repairStatus == ""
        ? React.null
        : <p className="mb-2 text-xs text-amber-700">{React.string(repairStatus)}</p>}

      {html == ""
        ? React.null
        : <details className="mb-2 rounded-xl border border-amber-200 bg-white/70" open_=true>
            <summary
              className="flex cursor-pointer items-center justify-between px-3 py-2 text-xs font-semibold uppercase tracking-wide text-amber-700">
              {React.string("Failed HTML")}
              <button
                type_="button"
                className="ml-2 inline-flex items-center gap-1 rounded-md border border-amber-200 bg-white px-2 py-1 text-xs font-medium text-amber-900 hover:bg-amber-100"
                onClick={event => {
                  event->ReactEvent.Mouse.stopPropagation
                  event->ReactEvent.Mouse.preventDefault
                  copy("HTML", html)
                }}>
                <Icons.Copy size=12 ariaHidden=true />
                {React.string("Copy")}
              </button>
            </summary>
            <pre
              className="mt-0 max-h-72 overflow-auto whitespace-pre-wrap break-all rounded-b-xl bg-neutral-900/95 p-3 text-xs leading-relaxed text-neutral-50">
              <code>{renderHighlightedSource(html, span, "html")}</code>
            </pre>
          </details>}

      {css == ""
        ? React.null
        : <details className="rounded-xl border border-amber-200 bg-white/70">
            <summary
              className="flex cursor-pointer items-center justify-between px-3 py-2 text-xs font-semibold uppercase tracking-wide text-amber-700">
              {React.string("Failed CSS")}
              <button
                type_="button"
                className="ml-2 inline-flex items-center gap-1 rounded-md border border-amber-200 bg-white px-2 py-1 text-xs font-medium text-amber-900 hover:bg-amber-100"
                onClick={event => {
                  event->ReactEvent.Mouse.stopPropagation
                  event->ReactEvent.Mouse.preventDefault
                  copy("CSS", css)
                }}>
                <Icons.Copy size=12 ariaHidden=true />
                {React.string("Copy")}
              </button>
            </summary>
            <pre
              className="mt-0 max-h-72 overflow-auto whitespace-pre-wrap break-all rounded-b-xl bg-neutral-900/95 p-3 text-xs leading-relaxed text-neutral-50">
              <code>{renderHighlightedSource(css, span, "css")}</code>
            </pre>
          </details>}

      {copyStatus == ""
        ? React.null
        : <p className="mt-2 text-xs text-amber-700">{React.string(copyStatus)}</p>}
    </section>
  }
}
