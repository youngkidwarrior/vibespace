type mode =
  | Fast
  | Reasoning

type codexPatch = {
  summary: PatchSummary.t,
  warnings: PatchWarnings.t,
}

type requestState =
  | Idle
  | Pending
  | Failed(string)
  | Ready(codexPatch)

let modeValue = mode =>
  switch mode {
  | Fast => "fast"
  | Reasoning => "reasoning"
  }

let modeFromValue = value =>
  switch value {
  | "reasoning" => Some(Reasoning)
  | "fast" => Some(Fast)
  | _ => None
  }

let modeLabel = mode =>
  switch mode {
  | Fast => "Quick edits"
  | Reasoning => "Deeper edits"
  }

let estimateMode = mode =>
  switch mode {
  | Fast => AssistantEstimate.Fast
  | Reasoning => AssistantEstimate.Reasoning
  }

let isPending = requestState =>
  switch requestState {
  | Pending => true
  | Idle | Failed(_) | Ready(_) => false
  }

let errorMessage = requestState =>
  switch requestState {
  | Failed(message) => Some(message)
  | Idle | Pending | Ready(_) => None
  }

let readyPatch = requestState =>
  switch requestState {
  | Ready(patch) => Some(patch)
  | Idle | Pending | Failed(_) => None
  }

@react.component
let make = (
  ~enabled: bool,
  ~disabledReason: string,
  ~onSubmit: (string, mode, codexPatch => unit, string => unit) => unit,
) => {
  let (value, setValue) = React.useState(() => "")
  let (mode, setMode) = React.useState(() => Fast)
  let (requestState, setRequestState) = React.useState(() => Idle)
  let pending = requestState->isPending

  let submit = (event: ReactEvent.Form.t) => {
    ReactEvent.Form.preventDefault(event)
    let instruction = value->String.trim
    if instruction != "" && !pending {
      setRequestState(_ => Pending)
      onSubmit(
        instruction,
        mode,
        patch => {
          setRequestState(_ => Ready(patch))
          setValue(_ => "")
        },
        message => setRequestState(_ => Failed(message)),
      )
    }
  }

  if !enabled {
    <div className="grid gap-3 pt-1">
      <Alert>
        <Alert.Description>
          {React.string(disabledReason == "" ? "Assistant changes require a saved profile." : disabledReason)}
        </Alert.Description>
      </Alert>
    </div>
  } else {
    <div className="grid gap-3 pt-1">
      <form onSubmit=submit className="grid gap-3">
        <div className="flex flex-wrap items-center gap-2">
          <ToggleGroup
            ariaLabel="Model mode"
            type_="single"
            value={[mode->modeValue]}
            onValueChange={(nextModes, _event) =>
              switch nextModes->Array.get(0)->Option.flatMap(modeFromValue) {
              | Some(nextMode) => setMode(_ => nextMode)
              | None => ()
              }
            }
            variant=Outline
            size=Sm>
            <ToggleGroup.Item value="fast" ariaLabel="Quick edits">
              {React.string("Quick")}
            </ToggleGroup.Item>
            <ToggleGroup.Item value="reasoning" ariaLabel="Deeper edits">
              {React.string("Deep")}
            </ToggleGroup.Item>
          </ToggleGroup>
          <span className="font-mono text-xs font-bold text-neutral-500"> {React.string(mode->modeLabel)} </span>
          <span className="rounded-full bg-neutral-100 px-2 py-1 text-xs font-bold text-neutral-600">
            {React.string("ETA " ++ (mode->estimateMode)->AssistantEstimate.label)}
          </span>
        </div>
        <p className="m-0 text-xs leading-snug text-neutral-500">
          {React.string(
            pending
              ? (mode->estimateMode)->AssistantEstimate.waitingCopy
              : (mode->estimateMode)->AssistantEstimate.detail,
          )}
        </p>
        <Textarea
          className="min-h-32 resize-y"
          value
          onChange={event => setValue(_ => BrowserBridge.eventTargetValue(event))}
          placeholder="Ask the assistant to update the selected part of your profile..."
        />
        <Button variant=Secondary type_="submit" disabled={pending || value->String.trim == ""}>
          {React.string(pending ? "Working..." : "Make changes")}
        </Button>
      </form>
      {switch requestState->errorMessage {
      | Some(message) =>
        <Alert variant=Destructive>
          <Alert.Description> {React.string(message)} </Alert.Description>
        </Alert>
      | None => React.null
      }}
      {switch requestState->readyPatch {
      | Some(patch) =>
        <Card>
          <Card.Header>
            <Card.Title> {React.string("Assistant changes")} </Card.Title>
            <Card.Description> {React.string(patch.summary->PatchSummary.toString)} </Card.Description>
          </Card.Header>
          <Card.Content className="grid gap-3">
            {patch.warnings->PatchWarnings.toString == ""
              ? React.null
              : <Alert variant=Destructive>
                  <Alert.Description>
                    {React.string(patch.warnings->PatchWarnings.toString)}
                  </Alert.Description>
                </Alert>}
            <p className="m-0 text-sm leading-snug text-neutral-500"> {React.string("Applied to the saved profile version.")} </p>
          </Card.Content>
        </Card>
      | None => React.null
      }}
    </div>
  }
}
