# Send App Backchannel

Canonical Send app reference:

`~/Documents/Send/sendapp/docs/plans/vibespace-send-stores-backchannel.local.md`

Use this file to summarize Vibespace discoveries that matter for eventual Send Stores integration. The Vibespace repo should keep product and prototype notes locally, then mirror important integration questions into the Send app backchannel document.

## Current Integration Hypothesis

Send Stores can eventually expose:

- Store profile data.
- Item catalog data.
- Theme document HTML/CSS.
- Agent edit history.
- A constrained render boundary for generated storefront UI.

Vibespace should prove the authoring and preview loop first before Send Stores accepts generated storefront themes.

## Latest Prototype Signal

The frontend has shifted toward canvas-first input: users enter edit mode, drag a visual area or click an element, then write an anchored edit request. Dragged selections capture bounds, viewport metadata, buffered DOM metadata for elements clearly inside the selected area, and a PNG crop for future model input. Edge-near elements inside roughly 20px of the selection border are excluded to reduce accidental context. The next planned payload should pair that crop with a full-page before screenshot captured from the same render. Send Stores should assume the useful request shape may include DOM anchors, full-page screenshots, and selected-region screenshots, not only structured section ids.

The prototype now rejects obviously unsafe generated HTML/CSS before preview/apply. Send Stores should treat this only as a first-pass local policy; production storefront themes need a stronger sanitizer, CSP, asset policy, and publish workflow.

The chat prompt path now uses XML-organized sections and short searchable agent-context docs. Send Stores should expect future prompt builders to retrieve only relevant context snippets instead of injecting a large static instruction blob every time.

The live model path now calls Codex/OpenAI from the GraphQL-side assistant service and returns JSON `{html, css, summary, warnings}` patches through Relay. For Vibespace this uses backend-only `OPENAI_API_KEY` from ignored `.env.secrets.local`; `.env.local` remains generated localnet state and must not contain durable secrets. The lower-cost future direction remains a remote terminal/session that receives the same prompt payload and runs `codex exec` against the raw HTML/CSS artifacts instead of proxying API requests from the browser path.

Vibespace local MVP auth now uses a signed browser-local viewer token instead of trusting a raw user id header. Invite redemption returns and displays the temporary token, and profile write mutations require the token's user to own the profile. Send Stores should treat this only as an interim local-auth bridge; future Sendapp/web extension flows need proper Send identity/session handoff rather than copying this token format.

Prompt edits now run as a server-side GraphQL mutation that creates an edit session, asks the model for a patch, validates it, and persists the resulting profile version. Send Stores should carry forward the split between request UX, generation, validation, persistence, and future capability resolution instead of treating an edit as one opaque long-running model call.

The capability planner now also returns a user-facing warning for unsupported interactivity. For example, requests for real games, apps, tools, stateful controls, or arbitrary JavaScript should warn that Vibespace is HTML/CSS-only and then continue with a decorative Myspace-style interpretation. This is a better UX than silently producing fake controls that imply real gameplay.

Vibespace now preserves existing trusted capability placeholders but rejects newly invented trusted-frame and trusted-image sources from assistant output. Generated HTML cannot include raw iframes, raw remote images, scripts, arbitrary links, or arbitrary remote resources; Send Stores should assume future storefront integrations need explicit trusted-origin capability policy rather than arbitrary agent-provided URLs.

The local MVP currently loads trusted images directly from allowlisted public origins so profile edits can feel visually alive without a custom asset API. Before this pattern moves into Send Stores, it should become a store-owned asset/proxy pipeline with attribution review, rights handling, and publish-time checks.

Trusted images are code-owned rather than model-owned. The current server path preserves previously trusted placeholders but rejects newly invented image/frame sources from generated output. Future image-heavy profile generation should move source-page fetching, metadata extraction, MIME checks, attribution, and caching into a server-side asset pipeline.

Failed generated patches are now kept as prompt-session data instead of being discarded. If validation and the automatic repair pass both fail, Vibespace leaves the live profile unchanged but saves the failed HTML/CSS, summary, warnings, and validator error on the draft so the next follow-up can repair that exact attempt. Send Stores should persist failed model outputs and validation errors as agent trace data, while ensuring failed source never becomes the public storefront/profile version.

Ambient media requests exposed a product distinction Send Stores should preserve: users often imply live playback or motion without developer words such as "player" or "embed." Vibespace now relies on the AI capability planner to infer when those requests need trusted-frame or trusted-image lookup, then generation includes a functional trusted capability when available rather than writing placeholder copy that says audio could be connected later. GIF and moving-background requests remain inside the trusted-image pipeline; animated GIF candidates from trusted origins are preferred when available, with static imagery plus CSS motion as the fallback.

The prototype avoids regex-derived creative scope. Codex receives the full before-edit HTML/CSS, selection metadata, and screenshots, then infers whether the user wants a local section edit or a full-profile redesign. A background/root click is now labeled as weak placement context rather than permission to redesign the whole document, and additive prompts are instructed to preserve existing design by default. Send Stores should likely carry the same distinction by passing richer context rather than pre-classifying user intent with brittle string rules.

The first extraction step is now in-repo as `packages/generative-ui`, a ReScript workspace package with genType-generated TypeScript surfaces. It owns product-neutral prompt construction, typed raw document values, failed-patch shape, web-context sanitization, and trusted URL policy. Vibespace still owns iframe preview, screenshot capture, DOM selection, prompt bubble UI, and placeholder expansion. For Send Stores, treat this package as the future prompt/policy core; React Native will need a separate translation/rendering layer for generated HTML/CSS rather than a direct reuse of the Vibespace iframe shell.

Vibespace onboarding can now store an optional Sendtag on the profile and resolve the current Send avatar server-side at read time. Vibespace persists only the Sendtag, not avatar URLs or Send profile payloads, and renders the avatar through a Vibespace-owned `owner-profile-image` system component instead of allowing generated HTML to load arbitrary remote images. Send Stores should preserve this split: stable Send identity references in app data, Send-owned media as source of truth, and code-owned rendering/proxy policy for profile/store imagery.

## Questions To Carry Forward

- Should Send Stores persist a full HTML/CSS document or structured sections plus CSS?
- Should generated storefront themes be public immediately or require preview/publish?
- Which CSS features should be blocked in production?
- How should theme documents reference store item data without allowing arbitrary JavaScript?
- Should Send Stores store visual edit selections, full-page before screenshots, selected-region screenshots, and prompt metadata as part of an agent edit audit trail?
- Which external capabilities, if any, should Send Stores allow through validated placeholders instead of raw agent-generated embeds or links?
- Should Send Stores require all generated visual assets to be copied into a store-owned media pipeline before publishing?
- Should the shared generative package expose only prompt/policy helpers, or also typed renderer-neutral edit operations once Send Stores has a concrete HTML/CSS translation target?
- Should Send Stores proxy/cache Send-owned avatar and media URLs before public rendering, or can server-resolved direct URLs remain acceptable for internal MVPs?
