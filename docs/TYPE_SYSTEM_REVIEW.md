# Type System Review

## Research Anchors

- Robin Milner's type-polymorphism work is the relevant foundation: static types should prevent invalid value flows before runtime, but only when the program models the domain instead of overloading primitives.
- ReScript's manual makes the same practical point: variants model "this or that", `option` models absence, pattern matching gives exhaustiveness checks, and `.resi` files/signatures hide representations.
- Local references were saved for targeted lookup, not bulk prompt context:
  - `docs/reference/rescript/language-overview.llm.txt`
  - `docs/reference/rescript/react.llm.txt`

## Current Standard

Vibespace domain state should avoid primitive strings when the value has product meaning.

Allowed primitive-string boundaries:

- JSX/UI copy and class names.
- Generated shadcn/ReScript UI bindings.
- Browser and DOM API externals.
- LocalStorage wire records before decoding.
- Codex/OpenAI request and response wire records before validation.
- Raw HTML/CSS text while crossing iframe, textarea, and model boundaries.

Everything else should prefer:

- Opaque string-backed modules such as `HtmlSource`, `CssSource`, `RequestId`, `PromptDraftId`, `ProfileElementId`, `CssSelector`, `DataUrl`, `IsoTimestamp`, `PromptText`, `SelectionLabel`, `SelectionDescription`, `PatchSummary`, `PatchWarnings`, `ValidationMessage`, and `DraftNotice`.
- Variants for finite state: `Route.t`, `ProfileSelection.kind`, `PromptDrafts.status`, `ProfileValidation.result`.
- `option` for absence instead of `""`.
- Pattern matching over status/kind strings or boolean result records.
- Typed geometry through `ProfileGeometry` instead of ungrouped float clusters.

## Implemented Hardening

- `ProfileDocument` now stores typed HTML, CSS, revision ids, and timestamps.
- `ProfileValidation` now returns `Valid | Invalid(validationError)` instead of `{ok: bool, message: string}`.
- `BrowserBridge` converts hash route strings into `Route.t` and selected ids into `option<ProfileElementId.t>` at the boundary.
- `PreviewBridge` accepts typed HTML/CSS and optional selected element ids.
- `ProfileSelection` decodes raw click/drag payload kinds into a variant-backed selection model. Selected ids, request ids, screenshots, selectors, and class names are no longer represented as empty strings in app state.
- `ProfileSelection` now carries typed friendly labels/descriptions and `ProfileGeometry` bounds, viewport, and anchor values after decoding raw browser payloads.
- `PromptDrafts` stores draft status as `Draft | Submitting | Error(validationMessage) | Applied(summary)`, removing stale parallel `status`, `error`, and `summary` fields from app-domain state.
- `PromptDrafts` now groups selection metadata, screenshot data, failed generated patches, notices, and prompt text into typed domain values instead of flat string/float clusters.
- `PromptHistory` decodes storage wire strings into typed prompt text, ids, timestamps, selection metadata, revision ids, and HTML/CSS source snapshots.
- `DocumentEditPrompt` converts the assistant prompt-composition request into typed prompt, HTML/CSS, screenshot, failed-patch, and selection-context values before building the XML-organized model prompt.
- The web app now submits assistant edits through Relay instead of constructing OpenAI request objects in browser code.
- `WebCapabilities` now keeps trusted-frame origins, unsafe web intent checks, URL validation, capability placeholder validation, and placeholder expansion in ReScript instead of JavaScript.
- `WebCapabilityPolicy` now separates trusted origin lists, safe URL checks, and unsafe intent checks from the larger web capability DOM/JSON boundary, so policy logic can remain visible to Reanalyze.
- `Main.res` owns the React bootstrap with a tiny local `react-dom/client` binding, keeping JSX out of the app entry point.

## Phase 1 Type Scaffolding Rewrite

Phase 1 is intentionally scoped to the prompt/selection/Codex authoring loop,
where agent behavior, UI state, screenshots, and generated source meet.

Implemented in this phase:

- Added small opaque text modules for prompt text, selection labels and descriptions, patch summaries/warnings, validation messages, and draft notices.
- Added `ProfileGeometry` for bounds, viewport, and anchor records, with constructors that keep dimensions non-negative.
- Migrated `ProfileSelection` to typed labels/descriptions and geometry while keeping `ProfileSelection.payload` as the raw browser/JS wire shape.
- Migrated `PromptDrafts.item` from a flat primitive bag to nested typed `selection`, `failedPatch`, `notice`, `prompt`, and `anchor` state.
- Preserved localStorage compatibility by keeping `PromptDrafts.storedItem` flat/stringly and decoding it immediately into the domain shape.
- Added a typed Codex request path in ReScript while preserving the existing JS transport contract.

Phase 1 non-goals:

- Do not refactor `WebCapabilities` wire records yet; they remain suppressed in Reanalyze because they mirror model/JS schemas.
- Do not refactor generated or shadcn-style `apps/web/src/ui` primitives; they remain component-library boundary code.
- Keep provider request-shape and JSON parsing in the GraphQL-side assistant service so browser code does not handle OpenAI transport.
- Do not introduce pixel/newtype arithmetic beyond grouping geometry records; deeper layout units are a Phase 2 topic.

## Phase 2 Type Boundary Rewrite

Phase 2 focused on making Reanalyze useful around real product logic instead
of hiding domain code inside broad wire boundaries.

Implemented in this phase:

- Migrated `PromptHistory.item` to the same typed style as prompt drafts: `PromptText.t`, `SelectionLabel.t`, `SelectionDescription.t`, `PromptConversationId.t`, `RevisionId.t`, `HtmlSource.t`, and `CssSource.t`.
- Preserved existing localStorage history compatibility by keeping `PromptHistory.storedItem` flat/stringly and decoding it immediately.
- Tightened `ProfileDocument` so the primary constructor and replacement path use `HtmlSource.t` and `CssSource.t`; raw strings remain only on textarea update helpers.
- Added `RevisionId.fromString` so history can represent old missing revision ids as `None` instead of `""`.
- Added semantic geometry records for `clientPoint`, `documentPoint`, and `size` while preserving compatibility fields on bounds/anchors for lower-risk migration.
- Updated prompt positioning, visible anchor recomputation, and draft storage to prefer semantic geometry fields.
- Extracted `WebCapabilityPolicy` from `WebCapabilities` for trusted origins, CSP source lists, safe URL matching, and unsafe intent detection.
- Kept `yarn reanalyze:report` budgeted after the rewrite.

## Remaining Critical Areas

- `ProfileSelection.payload` is still a raw browser/JS wire record with `kind: string`. This is acceptable only because `ProfileSelection.fromPayload` is the boundary decoder.
- `PromptDrafts.storedItem` and `PromptHistory.storedItem` are still stringly localStorage wire shapes. Do not pass them into UI or app state.
- `packages/schema/src/AgentEditService.js` owns OpenAI JSON schema request bodies, output text extraction, response parsing, validation, and persistence for assistant edits.
- `BrowserBridge.js` still owns `html-to-image` canvas capture. Keep it as a narrow library adapter unless screenshot geometry logic expands further.
- Geometry values now group client, document, and size records, but still expose compatibility float fields. If layout math grows, introduce pixel/viewport opaque units and remove the compatibility fields.
- `%identity` casts in `SelectionBridge` remain browser interop escape hatches. Keep them isolated and do not copy this pattern into domain modules.
- Generated `apps/web/src/ui` primitives still expose broad string props. Treat that as component-library boundary code, not Vibespace domain code.
