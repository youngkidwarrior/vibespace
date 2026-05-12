import React, { useState } from "react";
import { ComponentRenderer, useTambo, useTamboThreadInput } from "@tambo-ai/react";

function contentToText(content) {
  if (!Array.isArray(content)) return "";
  return content
    .filter((part) => part?.type === "text")
    .map((part) => part.text)
    .join("\n");
}

function composePrompt({ instruction, documentHtml, documentCss, selectedId, selectedSelector, selectedText }) {
  return [
    "Edit the Vibespace profile page.",
    "",
    "User instruction:",
    instruction,
    "",
    "Selected element context:",
    selectedId
      ? JSON.stringify({ id: selectedId, selector: selectedSelector, text: selectedText }, null, 2)
      : "No selected element. Treat the request as applying to the full profile.",
    "",
    "Current HTML:",
    "```html",
    documentHtml,
    "```",
    "",
    "Current CSS:",
    "```css",
    documentCss,
    "```",
    "",
    "Return a ProfileDocumentPatch component with complete replacement html and css. No JavaScript.",
  ].join("\n");
}

function TamboChatInner({
  documentHtml,
  documentCss,
  selectedId,
  selectedSelector,
  selectedText,
}) {
  const { messages, isStreaming, currentThreadId } = useTambo();
  const { value, setValue, submit, isPending } = useTamboThreadInput();
  const [error, setError] = useState("");

  async function onSubmit(event) {
    event.preventDefault();
    const instruction = value.trim();
    if (!instruction) return;
    setError("");
    setValue(
      composePrompt({
        instruction,
        documentHtml,
        documentCss,
        selectedId,
        selectedSelector,
        selectedText,
      })
    );
    await new Promise((resolve) => requestAnimationFrame(resolve));
    try {
      await submit({ debug: true });
      setValue("");
    } catch (caught) {
      setError(caught instanceof Error ? caught.message : "Tambo request failed");
    }
  }

  return (
    <div className="tambo-chat">
      <form onSubmit={onSubmit} className="tambo-chat-form">
        <textarea
          className="prompt-input"
          value={value}
          onChange={(event) => setValue(event.target.value)}
          placeholder="Ask Tambo to rewrite the selected HTML/CSS profile section..."
        />
        <button className="secondary-action" type="submit" disabled={isPending || isStreaming}>
          {isPending || isStreaming ? "Generating..." : "Ask Tambo"}
        </button>
      </form>
      {error ? <p className="agent-warning">{error}</p> : null}
      <div className="tambo-messages">
        {messages.map((message) => (
          <article className={`tambo-message tambo-message--${message.role}`} key={message.id}>
            <p className="kicker">{message.role}</p>
            {contentToText(message.content) ? <p>{contentToText(message.content)}</p> : null}
            {message.content.map((content, index) =>
              content?.type === "component" ? (
                <ComponentRenderer
                  key={content.id || index}
                  content={content}
                  threadId={currentThreadId}
                  messageId={message.id}
                  fallback={<p className="muted">Unknown generated component.</p>}
                />
              ) : null
            )}
          </article>
        ))}
      </div>
    </div>
  );
}

export default function TamboChat(props) {
  if (!props.enabled) {
    return (
      <div className="tambo-chat tambo-chat--disabled">
        <p className="muted">
          Add <code>VITE_TAMBO_API_KEY</code> to <code>.env.local</code> to enable the real Tambo
          agent call. The local safe edit button above keeps the HTML/CSS loop testable.
        </p>
      </div>
    );
  }

  return <TamboChatInner {...props} />;
}
