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

## Questions To Carry Forward

- Should Send Stores persist a full HTML/CSS document or structured sections plus CSS?
- Should generated storefront themes be public immediately or require preview/publish?
- Which CSS features should be blocked in production?
- How should theme documents reference store item data without allowing arbitrary JavaScript?

