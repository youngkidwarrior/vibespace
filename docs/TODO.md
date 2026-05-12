# TODO

## MVP Done Criteria

- [x] Vite app scaffolded.
- [x] ReScript domain modules created.
- [x] Fake profile document seeded as raw HTML/CSS.
- [x] Sandboxed iframe preview renders the profile document.
- [x] Click selection bridge sends element context to the app shell.
- [x] Manual HTML/CSS source editing updates preview.
- [x] Tambo adapter registered for `ProfileDocumentPatch` when an API key exists.
- [x] Local deterministic agent edit keeps the loop testable without an API key.
- [x] Add real Tambo prompt submission once a Tambo key is available.
- [ ] Smoke test a real Tambo generation with `VITE_TAMBO_API_KEY`.
- [ ] Add output validation before applying agent patches.

## Next Prototype Iterations

- Add one-click reset to seeded document.
- Add revision history and undo.
- Add structured patch operations.
- Add visual diff between revisions.
- Add prompt examples focused on profile aesthetics.
- Add a fake Send Store item fixture only after the profile authoring loop feels strong.
