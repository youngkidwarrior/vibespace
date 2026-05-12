let isBlank = value => value->String.trim == ""

@react.component
let make = () => {
  let (document, setDocument) = React.useState(() => ProfileFixture.initialDocument)
  let (selected, setSelected) = React.useState(() => Selection.empty)
  let (prompt, setPrompt) = React.useState(() => "")
  let (agentLog, setAgentLog) = React.useState(() => [
    "Agent lane ready. Add VITE_TAMBO_API_KEY to enable Tambo; local deterministic edits work now.",
  ])
  let hasAgentKey = TamboAdapter.hasTamboApiKey()

  React.useEffect0(() => {
    TamboAdapter.setProfileDocumentApplier(next => {
      setDocument(current => ProfileDocument.replace(current, next.html, next.css, Now.nowIso()))
      setAgentLog(current => ["Applied Tambo ProfileDocumentPatch to the raw HTML/CSS document.", ...current])
    })
    None
  })

  React.useEffect0(() => {
    let cleanup = BrowserBridge.addSelectionListener(nextSelection => setSelected(_ => nextSelection))
    Some(cleanup)
  })

  let preview = PreviewBridge.buildPreviewDocument(document.html, document.css, selected.id)

  let runLocalAgent = () => {
    let instruction = prompt->String.trim
    if instruction != "" {
      let targetLabel = selected.id == "" ? "the whole profile" : selected.selector
      let comment = "\n/* Agent note: " ++ instruction ++ " Target: " ++ targetLabel ++ " */\n"
      let nextCss = document.css ++ comment ++ "\n.profile-page { filter: saturate(1.08); }\n"
      setDocument(current => ProfileDocument.updateCss(current, nextCss, Now.nowIso()))
      setAgentLog(current => [
        "Local deterministic agent appended a safe CSS note for: \"" ++ instruction ++ "\"",
        ...current,
      ])
      setPrompt(_ => "")
    }
  }

  <main className="app-shell">
    <section className="topbar">
      <div>
        <p className="kicker"> {React.string("Vibespace MVP")} </p>
        <h1> {React.string("Agent-written profile HTML/CSS")} </h1>
      </div>
      <div className={hasAgentKey ? "status-pill status-pill--live" : "status-pill"}>
        {React.string(hasAgentKey ? "Tambo key detected" : "Local mode: no Tambo key")}
      </div>
    </section>

    <section className="workspace">
      <section className="preview-panel">
        <div className="panel-header">
          <div>
            <p className="kicker"> {React.string("Preview")} </p>
            <h2> {React.string("Fake profile page")} </h2>
          </div>
          <p className="revision"> {React.string("rev " ++ document.revisionId->Int.toString)} </p>
        </div>
        <iframe
          title="Vibespace generated profile preview"
          className="profile-preview"
          sandbox="allow-scripts"
          srcDoc=preview
        />
      </section>

      <aside className="agent-panel">
        <div className="panel-card">
          <p className="kicker"> {React.string("Selected element")} </p>
          {selected.id->isBlank
            ? <p className="muted"> {React.string("Click any element inside the profile preview.")} </p>
            : <div className="selection-readout">
                <p><strong>{React.string(selected.tagName)}</strong> {React.string(" " ++ selected.id)}</p>
                <p>{React.string(selected.text)}</p>
                <code>{React.string(selected.selector)}</code>
              </div>}
        </div>

        <div className="panel-card">
          <p className="kicker"> {React.string("Agent instruction")} </p>
          <textarea
            className="prompt-input"
            placeholder="Make the selected section feel like a neon arcade flyer. Keep it plain HTML and CSS."
            value=prompt
            onChange={event => setPrompt(_ => BrowserBridge.eventTargetValue(event))}
          />
          <button className="primary-action" type_="button" onClick={_ => runLocalAgent()}>
            {React.string("Apply local safe edit")}
          </button>
          <p className="muted">
            {React.string("Tambo is registered for ProfileDocumentPatch components when VITE_TAMBO_API_KEY exists. The local button keeps iteration unblocked without an API key.")}
          </p>
          <TamboChat
            enabled=hasAgentKey
            documentHtml=document.html
            documentCss=document.css
            selectedId=selected.id
            selectedSelector=selected.selector
            selectedText=selected.text
          />
        </div>

        <div className="panel-card">
          <p className="kicker"> {React.string("Agent log")} </p>
          <ul className="agent-log">
            {agentLog->Array.mapWithIndex((item, index) => <li key={index->Int.toString}>{React.string(item)}</li>)->React.array}
          </ul>
        </div>
      </aside>
    </section>

    <section className="source-grid">
      <label className="source-editor">
        <span>{React.string("HTML source of truth")}</span>
        <textarea
          value=document.html
          spellCheck=false
          onChange={event => setDocument(current => ProfileDocument.updateHtml(current, BrowserBridge.eventTargetValue(event), Now.nowIso()))}
        />
      </label>
      <label className="source-editor">
        <span>{React.string("CSS source of truth")}</span>
        <textarea
          value=document.css
          spellCheck=false
          onChange={event => setDocument(current => ProfileDocument.updateCss(current, BrowserBridge.eventTargetValue(event), Now.nowIso()))}
        />
      </label>
    </section>
  </main>
}
