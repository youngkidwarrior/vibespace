# Vibespace Agent Context

These files are short, searchable prompt references for the profile-editing agent. Runtime prompts should use compact excerpts and XML sections; do not dump every file into every request.

Search examples:

```bash
rg "music" docs/agent-context
rg "## audio" docs/agent-context
rg "data-vibespace-id" docs/agent-context
rg "Relay" docs/agent-context
```

Use this context when improving the chat bubble, Codex prompt, or future model request builder.

`rescript-graphql-backend.md` is for backend agents only. Do not inject it into profile HTML/CSS generation prompts.
