import React from "react";

let latestApplyDocument = null;

export function setProfileDocumentApplier(applyDocument) {
  latestApplyDocument = applyDocument;
}

export function applyProfileDocumentFromAgent(nextDocument) {
  if (typeof latestApplyDocument === "function") {
    latestApplyDocument(nextDocument);
  }
}

export function hasTamboApiKey() {
  return Boolean(import.meta.env.VITE_TAMBO_API_KEY);
}

export function ProfileDocumentPatch({ html, css, summary, warnings }) {
  return React.createElement(
    "article",
    { className: "agent-card agent-card--patch" },
    React.createElement("h3", null, "Profile document patch"),
    summary ? React.createElement("p", null, summary) : null,
    warnings ? React.createElement("p", { className: "agent-warning" }, warnings) : null,
    React.createElement(
      "button",
      {
        type: "button",
        onClick: () => applyProfileDocumentFromAgent({ html, css }),
      },
      "Apply generated HTML/CSS"
    )
  );
}

export const profileDocumentPatchSchema = {
  type: "object",
  properties: {
    html: {
      type: "string",
      description: "Complete replacement HTML for the fake profile body. Plain HTML only; no scripts.",
    },
    css: {
      type: "string",
      description: "Complete replacement CSS for the fake profile. Plain CSS only.",
    },
    summary: {
      type: "string",
      description: "Short human explanation of the design change.",
    },
    warnings: {
      type: "string",
      description: "Any caveats about the generated profile document.",
    },
  },
  required: ["html", "css", "summary"],
};

export const profileDocumentPatchDescription =
  "Renders an applyable Vibespace profile document patch. Use this whenever the user asks to change the raw HTML/CSS profile page. Preserve existing profile content unless the user asks to rewrite it. Never include JavaScript.";
