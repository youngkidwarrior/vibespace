import React from "react";
import { TamboProvider } from "@tambo-ai/react";
import {
  ProfileDocumentPatch,
  profileDocumentPatchDescription,
  profileDocumentPatchSchema,
} from "./TamboAdapter.js";

const components = [
  {
    name: "ProfileDocumentPatch",
    description: profileDocumentPatchDescription,
    component: ProfileDocumentPatch,
    propsSchema: profileDocumentPatchSchema,
  },
];

export default function TamboShell({ children }) {
  const apiKey = import.meta.env.VITE_TAMBO_API_KEY;

  if (!apiKey) {
    return children;
  }

  return (
    <TamboProvider
      apiKey={apiKey}
      userKey="vibespace-local-prototype"
      components={components}
      initialMessages={[
        {
          role: "system",
          content: [
            {
              type: "text",
              text:
                "You are Vibespace, an agent that edits one fake profile page. Return plain HTML and CSS through the ProfileDocumentPatch component. Do not include JavaScript. Preserve profile content unless the user asks to rewrite it.",
            },
          ],
        },
      ]}
    >
      {children}
    </TamboProvider>
  );
}
