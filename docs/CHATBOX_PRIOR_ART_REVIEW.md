# Chatbox Prior Art Review

This phase is intentionally scheduled after the Codex/OpenAI migration. It is docs-only research for borrowing useful chatbox patterns without pulling the Slack/Claude bot's complexity into the Vibespace MVP.

## Search Scope

Searched only this repo's `docs/` directory with:

```bash
rg -n "Slack|slack|Claude|claude|chatbox|chat box|bot|assistant|prompt|agent" docs
rg --files docs
```

No Slack-specific, Claude-specific, or existing chatbox app docs are currently present under `docs/`. The hits are Vibespace's own agent, prompt, screenshot, and HTML/CSS boundary notes.

## Useful Current Practices

- Keep prompt context short and searchable in `docs/agent-context` instead of injecting every instruction into every request.
- Use XML sections in runtime prompts so task, user intent, screenshots, selection context, source, rules, and response contract are separated in reading order.
- Preserve the local-only prompt history as a lightweight audit trail for non-persistent MVP work.
- Send both selected-region context and a full-page before screenshot once the screenshot path is complete.
- Keep the agent contract focused on complete HTML/CSS replacement until patch semantics are worth the added complexity.

## Suggested Prompt Changes To Explore

- Add a short `<conversation_context>` section only when the chat bubble has prior turns that materially affect the next edit.
- Add a `<non_developer_user>` reminder near the front of the prompt: interpret plain-language requests generously and choose the more polished profile treatment when ambiguous.
- Add a `<selection_confidence>` field that tells the model whether the selected context came from a click, a drag area, or no selection.
- Keep screenshot attachments named in the XML and passed as real image inputs to the model request instead of base64 text inside the prompt.

## Suggested Code Changes To Explore

- Treat the Codex chat bubble as a small state machine: idle, composing, generating, generated, apply failed, applied.
- Store generated patch summaries in prompt history only after the user applies a patch.
- Add a lightweight "regenerate" action that resubmits the same prompt and selection context without mutating the current document.
- Show the model name and mode used for each generated patch so future reviews can compare fast versus reasoning output quality.

## Keep Out Of Scope

- Do not add Slack-style channels, bot mentions, threads, notifications, auth, or multi-user routing.
- Do not add Claude-specific prompt conventions to the runtime path unless they generalize cleanly to Codex/OpenAI.
- Do not add persistence beyond local prompt history until the single-page authoring loop is stronger.
