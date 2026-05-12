import { Client } from "pg";
import {
  composeProfileEditPrompt,
  emptyWebContext,
} from "@vibespace/generative-ui";
import { validateProfileDocument } from "./ProfileHtmlValidation.js";
import { normalizeSendtag } from "./SendProfileLookup.js";

const defaultFastModel = "gpt-5.4-nano";
const defaultReasoningModel = "gpt-5.5";
const maxFailedPatchSnapshotLength = 200000;

const profileDocumentPatchFormat = {
  type: "json_schema",
  name: "vibespace_profile_document_patch",
  strict: true,
  schema: {
    type: "object",
    additionalProperties: false,
    properties: {
      html: {
        type: "string",
        description: "Complete replacement HTML for the profile body. Plain HTML only; no scripts.",
      },
      css: {
        type: "string",
        description: "Complete replacement CSS for the profile page. Plain CSS only.",
      },
      summary: {
        type: "string",
        description: "Short user-facing summary of the design change.",
      },
      warnings: {
        type: "string",
        description: "Optional caveats about the generated profile document. Empty string if none.",
      },
    },
    required: ["html", "css", "summary", "warnings"],
  },
};

function serverFailure(message, overrides = {}) {
  return {
    ok: false,
    summary: overrides.summary || "Agent edit failed.",
    warnings: overrides.warnings || [],
    validationErrors: overrides.validationErrors || [],
    error: message,
    session: overrides.session,
    providerConversationId: overrides.providerConversationId,
  };
}

function modelForMode(mode) {
  if (mode === "reasoning") {
    return process.env.OPENAI_REASONING_MODEL || defaultReasoningModel;
  }

  return process.env.OPENAI_FAST_MODEL || defaultFastModel;
}

function reasoningEffortForMode(mode) {
  return mode === "reasoning" ? "high" : "";
}

function stripJsonFence(text) {
  const trimmed = String(text || "").trim();
  const match = trimmed.match(/^```(?:json)?\s*([\s\S]*?)\s*```$/i);
  return match ? match[1].trim() : trimmed;
}

function stripSourceFence(text) {
  const trimmed = String(text || "").trim();
  const match = trimmed.match(/^```(?:html|css)?\s*([\s\S]*?)\s*```$/i);
  return match ? match[1].trim() : trimmed;
}

function parseProfileDocumentJsonPatch(text) {
  let parsed;
  try {
    parsed = JSON.parse(stripJsonFence(text));
  } catch {
    throw new Error("OpenAI returned text instead of the required JSON profile patch.");
  }

  const patch = parsed?.profileDocumentPatch || parsed;
  if (
    typeof patch?.html !== "string" ||
    typeof patch?.css !== "string" ||
    typeof patch?.summary !== "string"
  ) {
    throw new Error("OpenAI JSON was missing required html, css, or summary fields.");
  }

  return {
    html: stripSourceFence(patch.html),
    css: stripSourceFence(patch.css),
    summary: String(patch.summary || "").trim() || "Applied assistant profile edit.",
    warnings: typeof patch.warnings === "string" ? patch.warnings.trim() : "",
  };
}

function outputContentToText(content) {
  if (!Array.isArray(content)) return "";

  return content
    .map((part) => {
      if (!part) return "";
      if (typeof part.text === "string") return part.text;
      if (typeof part.output_text === "string") return part.output_text;
      if (part.type === "output_text" && typeof part.text === "string") return part.text;
      return "";
    })
    .filter(Boolean)
    .join("\n");
}

function extractOutputText(payload) {
  if (typeof payload?.output_text === "string") {
    return payload.output_text;
  }

  if (Array.isArray(payload?.output)) {
    return payload.output
      .map((item) => {
        if (typeof item?.text === "string") return item.text;
        return outputContentToText(item?.content);
      })
      .filter(Boolean)
      .join("\n");
  }

  return "";
}

function imageParts(label, dataUrl) {
  const url = String(dataUrl || "").trim();
  if (!url || !url.startsWith("data:image/")) return [];

  return [
    {
      type: "input_text",
      text: `<${label}_attachment media_type="image/png">The next image is the current ${label.replaceAll(
        "_",
        " ",
      )} before the requested edit.</${label}_attachment>`,
    },
    {
      type: "input_image",
      image_url: url,
      detail: "high",
    },
  ];
}

async function requestProfilePatch({ apiKey, prompt, model, reasoningEffort, input }) {
  const content = [
    { type: "input_text", text: prompt },
    ...imageParts("full_page_screenshot", input.fullPageScreenshotDataUrl),
    ...imageParts("selected_region_screenshot", input.selectedRegionScreenshotDataUrl),
    ...imageParts("onboarding_reference_image", input.referenceImageDataUrl),
  ];
  const response = await fetch("https://api.openai.com/v1/responses", {
    method: "POST",
    headers: {
      authorization: `Bearer ${apiKey}`,
      "content-type": "application/json",
    },
    body: JSON.stringify({
      model,
      input: [{ role: "user", content }],
      text: { format: profileDocumentPatchFormat },
      ...(reasoningEffort ? { reasoning: { effort: reasoningEffort } } : {}),
    }),
  });

  const payload = await response.json().catch(() => null);
  if (!response.ok) {
    const message = payload?.error?.message || `OpenAI request failed with HTTP ${response.status}.`;
    throw new Error(message);
  }

  const outputText = extractOutputText(payload);
  if (!outputText) {
    throw new Error("OpenAI returned no profile patch content.");
  }

  return {
    patch: parseProfileDocumentJsonPatch(outputText),
    providerConversationId: typeof payload?.id === "string" ? payload.id : undefined,
  };
}

function trustedSourcesFromHtml(html, kind) {
  const capability = kind === "frame" ? "trusted_frame" : "trusted_image";
  return Array.from(
    String(html || "").matchAll(
      new RegExp(
        `<[^>]*data-vibespace-capability\\s*=\\s*["']${capability}["'][^>]*>`,
        "gi",
      ),
    ),
  )
    .map((match) => match[0].match(/\sdata-vibespace-src\s*=\s*["']([^"']+)["']/i)?.[1] || "")
    .map((value) => value.replaceAll("&amp;", "&").trim())
    .filter(Boolean);
}

async function validateProfilePatch(patch, { currentHtml }) {
  const html = String(patch?.html || "");
  const css = String(patch?.css || "");

  const validationMessage = await validateProfileDocument(html, css);
  if (validationMessage) {
    return validationMessage;
  }

  const existingFrames = new Set(trustedSourcesFromHtml(currentHtml, "frame"));
  const generatedFrames = trustedSourcesFromHtml(html, "frame");
  if (generatedFrames.some((source) => !existingFrames.has(source))) {
    return "Profile content used a media embed that was not already trusted by this profile.";
  }

  const existingImages = new Set(trustedSourcesFromHtml(currentHtml, "image"));
  const generatedImages = trustedSourcesFromHtml(html, "image");
  if (generatedImages.some((source) => !existingImages.has(source))) {
    return "Profile content used an image that was not already trusted by this profile.";
  }

  return "";
}

function warningArray(warnings) {
  const text = String(warnings || "").trim();
  return text ? [text] : [];
}

function cleanProfileName(value) {
  const name = String(value || "").trim().replace(/\s+/g, " ");
  return name ? name.slice(0, 80) : "";
}

export function shouldPersistSendtag(input) {
  // ReScript optional record fields can arrive as own properties with undefined values.
  return typeof input?.sendtag === "string";
}

function failedPatchText(value, maxLength) {
  return String(value || "").slice(0, maxLength);
}

async function withClient(databaseUrl, fn) {
  const client = new Client({ connectionString: databaseUrl });
  await client.connect();
  try {
    return await fn(client);
  } finally {
    await client.end();
  }
}

async function queryOne(client, text, values = []) {
  const result = await client.query(text, values);
  return result.rows[0];
}

const profileVersionSelect = `
  id AS "id",
  profile_id AS "profileId",
  revision_number AS "revisionNumber",
  parent_version_id AS "parentVersionId",
  html AS "html",
  css AS "css",
  source AS "source",
  prompt_session_id AS "promptSessionId",
  summary AS "summary",
  validation_status AS "validationStatus",
  validation_errors::text AS "validationErrorsJson",
  created_by_user_id AS "createdByUserId",
  created_at::text AS "createdAt"
`;

const editSessionSelect = `
  id AS "id",
  profile_id AS "profileId",
  user_id AS "userId",
  provider_conversation_id AS "providerConversationId",
  status AS "status",
  progress_phase AS "progressPhase",
  prompt AS "prompt",
  selection_snapshot_id AS "selectionSnapshotId",
  result_version_id AS "resultVersionId",
  summary AS "summary",
  warnings::jsonb AS "warnings",
  error AS "error",
  created_at::text AS "createdAt",
  updated_at::text AS "updatedAt"
`;

async function createSessionAndLoadSource(databaseUrl, input) {
  return await withClient(databaseUrl, async (client) => {
    const profile = await queryOne(
      client,
      `
        SELECT id, owner_user_id AS "ownerUserId", current_version_id AS "currentVersionId"
        FROM vibespace.profiles
        WHERE id = $1
      `,
      [input.profileId],
    );
    if (!profile) {
      return { error: "Profile was not found." };
    }

    const currentVersionId = input.currentVersionId || profile.currentVersionId;
    if (!currentVersionId) {
      return { error: "Profile does not have a current version to edit." };
    }

    const currentVersion = await queryOne(
      client,
      `
        SELECT ${profileVersionSelect}
        FROM vibespace.profile_versions
        WHERE id = $1
          AND profile_id = $2
      `,
      [currentVersionId, input.profileId],
    );
    if (!currentVersion) {
      return { error: "Current profile version was not found." };
    }

    const actorUserId = input.actorUserId || profile.ownerUserId;
    const session = await queryOne(
      client,
      `
        INSERT INTO vibespace.profile_edit_sessions (
          profile_id,
          user_id,
          provider,
          status,
          progress_phase,
          prompt,
          summary,
          warnings
        )
        VALUES ($1, $2, 'openai', 'running', 'generating', $3, '', '[]'::jsonb)
        RETURNING ${editSessionSelect}
      `,
      [input.profileId, actorUserId, input.prompt],
    );

    return {
      profile,
      actorUserId,
      currentVersion,
      session,
    };
  });
}

async function updateSessionFailure(databaseUrl, sessionId, { summary, warnings, error, progressPhase }) {
  if (!sessionId) return undefined;

  return await withClient(databaseUrl, async (client) =>
    await queryOne(
      client,
      `
        UPDATE vibespace.profile_edit_sessions
        SET
          status = 'failed',
          progress_phase = $2,
          summary = $3,
          warnings = $4::jsonb,
          error = $5,
          updated_at = now()
        WHERE id = $1
        RETURNING ${editSessionSelect}
      `,
      [
        sessionId,
        progressPhase || "validating",
        summary || "Agent edit failed.",
        JSON.stringify(warnings || []),
        error,
      ],
    )
  );
}

async function updateSessionProgress(databaseUrl, sessionId, progressPhase) {
  if (!sessionId) return undefined;

  return await withClient(databaseUrl, async (client) =>
    await queryOne(
      client,
      `
        UPDATE vibespace.profile_edit_sessions
        SET
          status = 'running',
          progress_phase = $2,
          updated_at = now()
        WHERE id = $1
        RETURNING ${editSessionSelect}
      `,
      [sessionId, progressPhase],
    )
  );
}

async function persistAppliedPatch(databaseUrl, input, state, patch, providerConversationId, model) {
  return await withClient(databaseUrl, async (client) => {
    await client.query("BEGIN");
    try {
      const profileName = cleanProfileName(input.profileName);
      const persistSendtag = shouldPersistSendtag(input);
      const sendtag = normalizeSendtag(input.sendtag) || null;
      const profile = await queryOne(
        client,
        `
          SELECT id, current_version_id AS "currentVersionId"
          FROM vibespace.profiles
          WHERE id = $1
          FOR UPDATE
        `,
        [input.profileId],
      );
      if (!profile) {
        throw new Error("Profile was not found while applying the assistant edit.");
      }

      const version = await queryOne(
        client,
        `
          WITH target_profile AS (
            SELECT
              p.id,
              COALESCE(MAX(existing_versions.revision_number), 0) + 1 AS next_revision_number
            FROM vibespace.profiles p
            LEFT JOIN vibespace.profile_versions existing_versions ON existing_versions.profile_id = p.id
            WHERE p.id = $1
            GROUP BY p.id
          ),
          inserted_version AS (
            INSERT INTO vibespace.profile_versions (
              profile_id,
              revision_number,
              parent_version_id,
              html,
              css,
              source,
              prompt_session_id,
              summary,
              validation_status,
              validation_errors,
              created_by_user_id
            )
            SELECT
              target_profile.id,
              target_profile.next_revision_number,
              $2,
              $3,
              $4,
              'agent',
              $5,
              $6,
              'valid',
              '[]'::jsonb,
              $7
            FROM target_profile
            RETURNING *
          ),
          updated_profile AS (
            UPDATE vibespace.profiles p
            SET
              current_version_id = inserted_version.id,
              published_at = now(),
              updated_at = now()
            FROM inserted_version
            WHERE p.id = inserted_version.profile_id
            RETURNING p.id
          )
          SELECT ${profileVersionSelect}
          FROM inserted_version
        `,
        [
          input.profileId,
          state.currentVersion.id,
          patch.html,
          patch.css,
          state.session.id,
          patch.summary,
          state.actorUserId,
        ],
      );
      if (!version) {
        throw new Error("Assistant edit did not create a profile version.");
      }

      const warnings = warningArray(patch.warnings);
      const session = await queryOne(
        client,
        `
          UPDATE vibespace.profile_edit_sessions
          SET
            provider_conversation_id = $2,
            status = 'applied',
            progress_phase = 'applying',
            result_version_id = $3,
            summary = $4,
            warnings = $5::jsonb,
            error = NULL,
            updated_at = now()
          WHERE id = $1
          RETURNING ${editSessionSelect}
        `,
        [
          state.session.id,
          providerConversationId,
          version.id,
          patch.summary,
          JSON.stringify(warnings),
        ],
      );

      await client.query(
        `
          INSERT INTO vibespace.agent_conversation_summaries (
            edit_session_id,
            provider,
            provider_conversation_id,
            model,
            prompt,
            selection_label,
            result_version_id,
            summary,
            warnings
          )
          VALUES ($1, 'openai', $2, $3, $4, $5, $6, $7, $8::jsonb)
        `,
        [
          state.session.id,
          providerConversationId,
          model,
          input.prompt,
          input.selectionLabel || undefined,
          version.id,
          patch.summary,
          JSON.stringify(warnings),
        ],
      );

      await client.query(
        `
          INSERT INTO vibespace.profile_update_events (
            actor_user_id,
            profile_id,
            profile_version_id,
            kind,
            title,
            summary,
            visibility
          )
          VALUES ($1, $2, $3, 'profile_published', 'Profile updated', $4, 'friends')
        `,
        [state.actorUserId, input.profileId, version.id, patch.summary],
      );

      if (profileName) {
        await client.query(
          `
            UPDATE vibespace.users
            SET
              display_name = $2,
              updated_at = now()
            WHERE id = $1
          `,
          [state.actorUserId, profileName],
        );
        await client.query(
          `
            UPDATE vibespace.profiles
            SET
              title = $2,
              updated_at = now()
            WHERE id = $1
          `,
          [input.profileId, `${profileName}'s Vibespace`],
        );
      }

      if (persistSendtag) {
        await client.query(
          `
            UPDATE vibespace.profiles
            SET
              sendtag = $2,
              updated_at = now()
            WHERE id = $1
          `,
          [input.profileId, sendtag],
        );
      }

      await client.query("COMMIT");
      return { session, version, warnings };
    } catch (error) {
      await client.query("ROLLBACK");
      throw error;
    }
  });
}

function composePrompt(input, currentVersion) {
  return composeProfileEditPrompt({
    instruction: input.prompt || "",
    documentHtml: currentVersion.html || "",
    documentCss: currentVersion.css || "",
    selectedContext: input.selectionAgentContext || input.selectionLabel || "",
    selectedRegionScreenshotDataUrl: input.selectedRegionScreenshotDataUrl || "",
    fullPageScreenshotDataUrl: input.fullPageScreenshotDataUrl || "",
    previousFailedHtml: failedPatchText(input.previousFailedHtml, maxFailedPatchSnapshotLength),
    previousFailedCss: failedPatchText(input.previousFailedCss, maxFailedPatchSnapshotLength),
    previousFailedSummary: failedPatchText(input.previousFailedSummary, 1200),
    previousFailedWarnings: failedPatchText(input.previousFailedWarnings, 2000),
    previousFailedValidationMessage: failedPatchText(input.previousFailedValidationMessage, 2000),
    webContext: emptyWebContext(null, null),
  });
}

export async function submitAgentEdit(input) {
  const prompt = String(input?.prompt || "").trim();
  if (!prompt) {
    return serverFailure("Prompt is required.", {
      summary: "Agent edit was not submitted.",
    });
  }

  const databaseUrl = input?.databaseUrl || "";
  if (!databaseUrl) {
    return serverFailure("Assistant changes require a database-backed profile.");
  }

  const apiKey = process.env.OPENAI_API_KEY || "";
  if (!apiKey) {
    return serverFailure("OPENAI_API_KEY is not configured for the GraphQL server.");
  }

  let state;
  try {
    state = await createSessionAndLoadSource(databaseUrl, {
      ...input,
      prompt,
    });
  } catch (error) {
    const message = error instanceof Error ? error.message : "Unable to start assistant edit.";
    return serverFailure(message);
  }

  if (state?.error) {
    return serverFailure(state.error);
  }

  return await runAgentEdit({ ...input, prompt }, state);
}

async function runAgentEdit(input, state) {
  const databaseUrl = input?.databaseUrl || "";
  const prompt = String(input?.prompt || "").trim();

  const apiKey = process.env.OPENAI_API_KEY || "";
  const mode = input?.mode === "reasoning" ? "reasoning" : "fast";
  const model = modelForMode(mode);
  const reasoningEffort = reasoningEffortForMode(mode);
  let providerConversationId;

  try {
    const providerResult = await requestProfilePatch({
      apiKey,
      prompt: composePrompt({ ...input, prompt }, state.currentVersion),
      model,
      reasoningEffort,
      input,
    });
    providerConversationId = providerResult.providerConversationId;
    await updateSessionProgress(databaseUrl, state.session.id, "validating");
    const validationMessage = await validateProfilePatch(providerResult.patch, {
      currentHtml: state.currentVersion.html,
    });
    if (validationMessage) {
      const session = await updateSessionFailure(databaseUrl, state.session.id, {
        summary: "Assistant output failed validation.",
        warnings: warningArray(providerResult.patch.warnings),
        error: validationMessage,
        progressPhase: "validating",
      });
      return serverFailure(validationMessage, {
        summary: "Assistant output failed validation.",
        warnings: warningArray(providerResult.patch.warnings),
        validationErrors: [validationMessage],
        session,
        providerConversationId,
      });
    }

    await updateSessionProgress(databaseUrl, state.session.id, "applying");
    const persisted = await persistAppliedPatch(
      databaseUrl,
      { ...input, prompt },
      state,
      providerResult.patch,
      providerConversationId,
      model,
    );

    return {
      ok: true,
      summary: providerResult.patch.summary,
      warnings: persisted.warnings,
      validationErrors: [],
      error: undefined,
      providerConversationId,
      session: persisted.session,
      version: persisted.version,
    };
  } catch (error) {
    const message = error instanceof Error ? error.message : "Assistant edit failed.";
    const session = await updateSessionFailure(databaseUrl, state?.session?.id, {
      summary: "Agent edit failed.",
      warnings: [],
      error: message,
      progressPhase: providerConversationId ? "validating" : "generating",
    }).catch(() => undefined);

    return serverFailure(message, {
      session,
      providerConversationId,
    });
  }
}

export async function startAgentEdit(input) {
  const prompt = String(input?.prompt || "").trim();
  if (!prompt) {
    return serverFailure("Prompt is required.", {
      summary: "Agent edit was not submitted.",
    });
  }

  const databaseUrl = input?.databaseUrl || "";
  if (!databaseUrl) {
    return serverFailure("Assistant changes require a database-backed profile.");
  }

  const apiKey = process.env.OPENAI_API_KEY || "";
  if (!apiKey) {
    return serverFailure("OPENAI_API_KEY is not configured for the GraphQL server.");
  }

  let state;
  try {
    state = await createSessionAndLoadSource(databaseUrl, {
      ...input,
      prompt,
    });
  } catch (error) {
    const message = error instanceof Error ? error.message : "Unable to start assistant edit.";
    return serverFailure(message);
  }

  if (state?.error) {
    return serverFailure(state.error);
  }

  void runAgentEdit({ ...input, prompt }, state).catch(() => undefined);

  return {
    ok: true,
    summary: "Agent edit started.",
    warnings: [],
    validationErrors: [],
    error: undefined,
    providerConversationId: undefined,
    session: state.session,
    version: undefined,
  };
}
