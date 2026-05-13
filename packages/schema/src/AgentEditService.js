import { Client } from "pg";
import {
  composeProfileEditPrompt,
  emptyWebContext,
  sanitizeWebContext,
} from "@vibespace/generative-ui";
import {
  trustedFrameMatchValue,
  trustedImageMatchValue,
} from "@vibespace/generative-ui/src/WebCapabilityPolicy.res.js";
import {
  checkProfileCurrentVersionUnchanged,
  validateGeneratedPatch,
} from "./AgentEditSafety.res.js";
import {
  ariaLabelAllowedRoles,
  ariaLabelAllowedTags,
  markKnownInlineSvg,
  trustedCapabilityPlaceholdersFromHtml,
  validateGeneratedProfileDocument,
} from "./ProfileHtmlValidation.js";
import { normalizeSendtag } from "./SendProfileLookup.js";
import { summarizeProfileRisk } from "./ProfileRiskSummary.js";
import { logAgentEditPhase, now as agentEditNow } from "./AgentEditLog.js";

const defaultFastModel = "gpt-5.4-nano";
const defaultReasoningModel = "gpt-5.5";
const defaultAuditModel = "gpt-5.1-codex-mini";
const maxFailedPatchSnapshotLength = 200000;
const minSecurityAuditConfidence = 0.85;
const minAllowedSecurityAuditConfidence = 0.5;

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
        description:
          "Complete replacement HTML for the profile body. Standard HTML plus the safe inline SVG subset only; no scripts.",
      },
      css: {
        type: "string",
        description:
          "Complete replacement CSS for the profile page. Plain valid CSS only. Use /* ... */ comments, never slash-only comments, and never end a selector with a combinator.",
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

const profileSecurityAuditFormat = {
  type: "json_schema",
  name: "vibespace_profile_security_audit",
  strict: true,
  schema: {
    type: "object",
    additionalProperties: false,
    properties: {
      allow: {
        type: "boolean",
        description: "True only if the profile HTML and CSS look safe to publish.",
      },
      confidence: {
        type: "number",
        description: "Confidence from 0 to 1 that the safety decision is correct.",
      },
      risk: {
        type: "string",
        enum: ["none", "low", "medium", "high"],
        description: "Highest security risk level found in the profile document.",
      },
      reason: {
        type: "string",
        description: "One short sentence explaining the decision.",
      },
    },
    required: ["allow", "confidence", "risk", "reason"],
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

export function auditModelCandidates() {
  return Array.from(
    new Set(
      [process.env.OPENAI_AUDIT_MODEL || defaultAuditModel, modelForMode("fast")]
        .map((model) => String(model || "").trim())
        .filter(Boolean),
    ),
  );
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

function repairDanglingChildCombinators(css) {
  const source = String(css || "");
  let output = "";
  let cursor = 0;

  for (let index = 0; index < source.length; index += 1) {
    if (source[index] !== ">") continue;

    let nextIndex = index + 1;
    while (nextIndex < source.length && /\s/.test(source[nextIndex])) {
      nextIndex += 1;
    }

    if (source[nextIndex] !== "{") continue;

    const ruleStart = Math.max(
      source.lastIndexOf("{", index),
      source.lastIndexOf("}", index),
      source.lastIndexOf(";", index),
    );
    const selectorPrefix = source.slice(ruleStart + 1, index).trim();
    if (!selectorPrefix || selectorPrefix.startsWith("@")) continue;

    output += source.slice(cursor, index) + "> * ";
    cursor = nextIndex;
    index = nextIndex - 1;
  }

  return output + source.slice(cursor);
}

function replaceGeneratedSlashComments(source, pattern) {
  return source.replace(pattern, (match, prefix, body) => {
    if (!/[A-Za-z]/.test(body)) return match;
    return `${prefix}/*${body.trim()}*/`;
  });
}

function decodeGeneratedCssEntities(css) {
  return String(css || "")
    .replace(/&gt;/g, ">")
    .replace(/&lt;/g, "<")
    .replace(/&quot;/g, "\"")
    .replace(/&#39;/g, "'")
    .replace(/&apos;/g, "'")
    .replace(/&amp;/g, "&");
}

export function repairGeneratedCss(css) {
  let source = decodeGeneratedCssEntities(css);

  source = replaceGeneratedSlashComments(
    source,
    /(^|[}\s;])\/(?![*/])([^{}\n]*?)\*\//g,
  );
  source = replaceGeneratedSlashComments(
    source,
    /(^|[}\s;])\/(?![*/])([^{}\n]*?[A-Za-z][^{}\n]*?)\/(?=\s*(?:[.#[:@]|\*|[A-Za-z_-]|$))/g,
  );
  source = repairDanglingChildCombinators(source);

  return source;
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

function hasMediaIntent(text) {
  return /\b(oembed|embed|playable|player|play|youtube|spotify|soundcloud|video|song|music|audio|track)\b/i.test(
    String(text || ""),
  );
}

function hasImageIntent(text) {
  return /\b(real\s+)?(photo|image|picture|portrait|poster|visual|wikimedia|commons|celebrity|headshot)\b/i.test(
    String(text || ""),
  );
}

function trimUrlToken(value) {
  return String(value || "")
    .replace(/&amp;/g, "&")
    .replace(/[)\].,;!?]+$/g, "")
    .trim();
}

function extractPromptHttpsUrls(text) {
  const matches = String(text || "").match(/https:\/\/[^\s<>"']+/gi) || [];
  return Array.from(new Set(matches.map(trimUrlToken).filter(Boolean))).slice(0, 8);
}

function safeUrl(value, base) {
  try {
    const url = new URL(value, base);
    if (url.protocol !== "https:") return undefined;
    if (url.username || url.password) return undefined;
    return url;
  } catch {
    return undefined;
  }
}

function stripHtml(value) {
  return String(value || "")
    .replace(/<[^>]*>/g, " ")
    .replace(/\s+/g, " ")
    .trim();
}

function truncateText(value, maxLength) {
  return stripHtml(value).slice(0, maxLength);
}

function wikimediaFileTitleFromUrl(rawUrl) {
  const url = safeUrl(rawUrl);
  if (!url) return "";

  const host = url.hostname.toLowerCase();
  if (host !== "commons.wikimedia.org" && host !== "upload.wikimedia.org") {
    return "";
  }

  if (host === "commons.wikimedia.org") {
    const wikiMatch = decodeURIComponent(url.pathname).match(/\/wiki\/(File:[^?#]+)/i);
    return wikiMatch ? wikiMatch[1].replaceAll("_", " ") : "";
  }

  const filename = decodeURIComponent(url.pathname.split("/").filter(Boolean).pop() || "");
  return filename ? `File:${filename.replaceAll("_", " ")}` : "";
}

function imageSearchQueryFromPrompt(prompt) {
  const withoutUrls = String(prompt || "").replace(/https:\/\/[^\s<>"']+/gi, " ");
  const cleaned = withoutUrls
    .replace(
      /\b(use|add|make|create|show|include|find|fetch|get|real|photo|image|picture|portrait|poster|visual|wikimedia|commons|celebrity|headshot|profile|page|of|for|from|the|a|an|and|with)\b/gi,
      " ",
    )
    .replace(/[^\p{L}\p{N}\s.'-]/gu, " ")
    .replace(/\s+/g, " ")
    .trim();

  return cleaned.slice(0, 80);
}

function commonsApiUrlForSearch(query) {
  const endpoint = new URL("https://commons.wikimedia.org/w/api.php");
  endpoint.searchParams.set("action", "query");
  endpoint.searchParams.set("format", "json");
  endpoint.searchParams.set("origin", "*");
  endpoint.searchParams.set("generator", "search");
  endpoint.searchParams.set("gsrnamespace", "6");
  endpoint.searchParams.set("gsrlimit", "8");
  endpoint.searchParams.set("gsrsearch", query);
  endpoint.searchParams.set("prop", "imageinfo");
  endpoint.searchParams.set("iiprop", "url|mime|extmetadata");
  endpoint.searchParams.set("iiurlwidth", "1200");
  return endpoint.toString();
}

function commonsApiUrlForTitle(title) {
  const endpoint = new URL("https://commons.wikimedia.org/w/api.php");
  endpoint.searchParams.set("action", "query");
  endpoint.searchParams.set("format", "json");
  endpoint.searchParams.set("origin", "*");
  endpoint.searchParams.set("titles", title);
  endpoint.searchParams.set("prop", "imageinfo");
  endpoint.searchParams.set("iiprop", "url|mime|extmetadata");
  endpoint.searchParams.set("iiurlwidth", "1200");
  return endpoint.toString();
}

function extMetadataValue(metadata, key) {
  return stripHtml(metadata?.[key]?.value || "");
}

function isTrustedWikimediaRasterImageUrl(value) {
  const url = safeUrl(value);
  if (!url) return false;
  if (url.origin !== "https://upload.wikimedia.org") return false;
  if (/\.svg(?:$|[?#])/i.test(url.pathname)) return false;
  return /\.(?:avif|gif|jpe?g|png|webp|tiff?)(?:$|[?#])/i.test(url.pathname);
}

function safeImageFromCommonsPage(page, query) {
  const imageInfo = Array.isArray(page?.imageinfo) ? page.imageinfo[0] : undefined;
  const metadata = imageInfo?.extmetadata || {};
  const imageUrl = String(imageInfo?.thumburl || imageInfo?.url || "").trim();
  const mime = String(imageInfo?.mime || "").toLowerCase();
  if (!imageUrl || mime === "image/svg+xml" || !mime.startsWith("image/")) return undefined;
  if (!isTrustedWikimediaRasterImageUrl(imageUrl)) return undefined;

  const canonicalUrl = `https://commons.wikimedia.org/wiki/${encodeURIComponent(
    String(page?.title || "").replaceAll(" ", "_"),
  )}`;
  const title = truncateText(extMetadataValue(metadata, "ObjectName") || page?.title || query, 160);
  const description = truncateText(
    extMetadataValue(metadata, "ImageDescription") || `Wikimedia Commons image for ${query}`,
    220,
  );

  return {
    origin: "https://upload.wikimedia.org",
    title,
    source: "Wikimedia Commons",
    creator: truncateText(extMetadataValue(metadata, "Artist"), 120),
    license: truncateText(extMetadataValue(metadata, "LicenseShortName"), 120),
    licenseUrl: truncateText(extMetadataValue(metadata, "LicenseUrl"), 300),
    imageUrl,
    canonicalUrl,
    altText: description || title || `Wikimedia Commons image for ${query}`,
    subjectTags: [query, "Wikimedia Commons"].filter(Boolean),
    visualCues: [title, description].filter(Boolean).slice(0, 4),
  };
}

async function fetchWikimediaImages(apiUrl, query, fetchImpl) {
  if (typeof fetchImpl !== "function" || !query) return [];

  const controller = typeof AbortController === "function" ? new AbortController() : undefined;
  const timeout = controller ? setTimeout(() => controller.abort(), 3000) : undefined;
  try {
    const response = await fetchImpl(apiUrl, {
      signal: controller?.signal,
      headers: {
        accept: "application/json",
        "user-agent": "Vibespace/1.0 safe-media-resolver",
      },
    });
    if (!response?.ok) return [];
    const payload = await response.json().catch(() => null);
    const pages = Object.values(payload?.query?.pages || {});
    return pages
      .map((page) => safeImageFromCommonsPage(page, query))
      .filter(Boolean)
      .slice(0, 6);
  } catch {
    return [];
  } finally {
    if (timeout) clearTimeout(timeout);
  }
}

function youtubeVideoIdFromUrl(url) {
  const host = url.hostname.toLowerCase();
  const pathParts = url.pathname.split("/").filter(Boolean);

  if (host === "youtu.be") {
    return pathParts[0] || "";
  }

  if (host === "www.youtube.com" || host === "youtube.com" || host === "m.youtube.com") {
    if (url.pathname === "/watch") {
      return url.searchParams.get("v") || "";
    }

    if (["embed", "shorts", "live"].includes(pathParts[0])) {
      return pathParts[1] || "";
    }
  }

  if (host === "www.youtube-nocookie.com" && pathParts[0] === "embed") {
    return pathParts[1] || "";
  }

  return "";
}

function youtubeStartSeconds(url) {
  const raw = url.searchParams.get("start") || url.searchParams.get("t") || "";
  if (/^\d+$/.test(raw)) return raw;

  const match = raw.match(/^(?:(\d+)h)?(?:(\d+)m)?(?:(\d+)s?)?$/i);
  if (!match) return "";

  const hours = Number(match[1] || 0);
  const minutes = Number(match[2] || 0);
  const seconds = Number(match[3] || 0);
  const total = hours * 3600 + minutes * 60 + seconds;
  return total > 0 ? String(total) : "";
}

function youtubeFrameFromUrl(rawUrl, metadata = {}) {
  const url = safeUrl(rawUrl);
  if (!url) return undefined;

  const videoId = youtubeVideoIdFromUrl(url);
  if (!/^[A-Za-z0-9_-]{6,32}$/.test(videoId)) return undefined;

  const frameUrl = new URL(`https://www.youtube.com/embed/${videoId}`);
  const start = youtubeStartSeconds(url);
  if (start) {
    frameUrl.searchParams.set("start", start);
  }

  const canonicalUrl =
    typeof metadata.canonicalUrl === "string" && metadata.canonicalUrl.trim() !== ""
      ? metadata.canonicalUrl.trim()
      : rawUrl;

  return {
    origin: "https://www.youtube.com",
    title: String(metadata.title || "YouTube video"),
    canonicalUrl,
    frameUrl: frameUrl.toString(),
    frameKind: "youtube_video",
    autoplaySupported: false,
  };
}

function iframeSourceFromHtml(html) {
  const match = String(html || "").match(/<iframe\b[^>]*\ssrc=["']([^"']+)["'][^>]*>/i);
  return match ? match[1].replace(/&amp;/g, "&") : "";
}

async function fetchYoutubeOEmbedFrame(rawUrl, fetchImpl) {
  if (typeof fetchImpl !== "function") return undefined;

  const endpoint = new URL("https://www.youtube.com/oembed");
  endpoint.searchParams.set("url", rawUrl);
  endpoint.searchParams.set("format", "json");

  const controller = typeof AbortController === "function" ? new AbortController() : undefined;
  const timeout = controller ? setTimeout(() => controller.abort(), 2500) : undefined;
  try {
    const response = await fetchImpl(endpoint.toString(), {
      signal: controller?.signal,
      headers: { accept: "application/json" },
    });
    if (!response?.ok) return undefined;

    const payload = await response.json().catch(() => null);
    const iframeSource = iframeSourceFromHtml(payload?.html);
    const frame = iframeSource
      ? youtubeFrameFromUrl(iframeSource, {
          canonicalUrl: rawUrl,
          title: payload?.title || "YouTube video",
        })
      : undefined;

    return frame || youtubeFrameFromUrl(rawUrl, { title: payload?.title || "YouTube video" });
  } catch {
    return undefined;
  } finally {
    if (timeout) clearTimeout(timeout);
  }
}

async function trustedFrameForPromptUrl(rawUrl, fetchImpl) {
  const url = safeUrl(rawUrl);
  if (!url) return undefined;

  const host = url.hostname.toLowerCase();
  if (
    host === "youtu.be" ||
    host === "youtube.com" ||
    host === "www.youtube.com" ||
    host === "m.youtube.com" ||
    host === "www.youtube-nocookie.com"
  ) {
    return (await fetchYoutubeOEmbedFrame(rawUrl, fetchImpl)) || youtubeFrameFromUrl(rawUrl);
  }

  return undefined;
}

export async function resolveWebContextForPrompt(prompt, options = {}) {
  const urls = extractPromptHttpsUrls(prompt);
  const mediaIntent = hasMediaIntent(prompt);
  const imageIntent = hasImageIntent(prompt);

  const fetchImpl = Object.prototype.hasOwnProperty.call(options, "fetchImpl")
    ? options.fetchImpl
    : globalThis.fetch;
  const safeFrames = [];
  for (const url of urls) {
    const frame = await trustedFrameForPromptUrl(url, fetchImpl);
    if (frame) safeFrames.push(frame);
  }

  const safeImages = [];
  const wikimediaTitles = urls.map(wikimediaFileTitleFromUrl).filter(Boolean);
  for (const title of wikimediaTitles) {
    safeImages.push(...(await fetchWikimediaImages(commonsApiUrlForTitle(title), title.replace(/^File:/i, ""), fetchImpl)));
  }

  const promptImageQuery = imageIntent ? imageSearchQueryFromPrompt(prompt) : "";
  if (promptImageQuery && safeImages.length === 0) {
    safeImages.push(
      ...(await fetchWikimediaImages(commonsApiUrlForSearch(promptImageQuery), promptImageQuery, fetchImpl)),
    );
  }

  const dedupedSafeImages = Array.from(
    new Map(safeImages.map((image) => [image.imageUrl, image])).values(),
  ).slice(0, 6);

  if (safeFrames.length === 0 && dedupedSafeImages.length === 0) {
    return sanitizeWebContext({
      status: mediaIntent || imageIntent ? "not_found" : "not_needed",
      intentKind: mediaIntent ? "media" : imageIntent ? "person" : "reference",
      warnings: mediaIntent
        ? ["Media lookup did not produce a trusted-origin frame URL."]
        : imageIntent
          ? ["Image lookup did not produce a trusted raster image from Wikimedia Commons."]
          : [],
    });
  }

  return sanitizeWebContext({
    status: "resolved",
    intentKind: mediaIntent ? "media" : "person",
    summary:
      safeFrames.length > 0 && dedupedSafeImages.length > 0
        ? "Resolved trusted media and image context for this profile request."
        : safeFrames.length > 0
          ? "Resolved a trusted media frame from the user's prompt URL."
          : "Resolved trusted Wikimedia Commons image context for this profile request.",
    safeFrames,
    safeImages: dedupedSafeImages,
    resolvedItems: safeFrames.map((frame) => ({
      title: frame.title,
      description: "Trusted playable media frame resolved for this profile request.",
      canonicalUrl: frame.canonicalUrl,
      provider: frame.origin,
      itemType: "media",
    })).concat(
      dedupedSafeImages.map((image) => ({
        title: image.title,
        description: image.altText,
        canonicalUrl: image.canonicalUrl,
        provider: image.source,
        itemType: "image",
      })),
    ),
    citations: safeFrames
      .map((frame) => ({
        title: frame.title,
        url: frame.canonicalUrl,
      }))
      .concat(
        dedupedSafeImages.map((image) => ({
          title: image.title,
          url: image.canonicalUrl,
        })),
      ),
  });
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

function normalizeProfileSecurityAudit(value) {
  const confidence = Number(value?.confidence);
  const risk = String(value?.risk || "").toLowerCase();
  return {
    allow: value?.allow === true,
    confidence: Number.isFinite(confidence) ? Math.max(0, Math.min(1, confidence)) : 0,
    risk: ["none", "low", "medium", "high"].includes(risk) ? risk : "high",
    reason: String(value?.reason || "Security audit did not provide a reason.").slice(0, 500),
  };
}

export function securityAuditDecision(audit) {
  const result = normalizeProfileSecurityAudit(audit);
  const allowedRisk = result.risk === "none" || result.risk === "low";
  const confidenceThreshold = result.allow === true && allowedRisk
    ? minAllowedSecurityAuditConfidence
    : minSecurityAuditConfidence;
  const ok = result.allow === true && result.confidence >= confidenceThreshold && allowedRisk;

  return {
    ok,
    message: ok
      ? ""
      : `Security audit blocked this profile: ${result.reason} (risk=${result.risk}, confidence=${result.confidence.toFixed(2)}).`,
    audit: result,
  };
}

export function composeSecurityAuditPrompt(riskSummary) {
  const summary = riskSummary || {};
  const snippets = Array.isArray(summary.suspiciousSnippets) ? summary.suspiciousSnippets : [];
  const externalRefs = Array.isArray(summary.externalRefs) ? summary.externalRefs : [];
  return [
    "Audit this generated profile for publish security risk.",
    "The deterministic validator has already accepted the document and blocked scripts, event handlers, executable protocols, remote http resources, forms, blocked tags, and unsafe SVG/CSS at-rules.",
    "You are reviewing only specific suspicious constructs that survived deterministic validation. Decide whether any of them indicate a real publish risk under a no-scripts sandbox with parent-owned trusted media.",
    "Return allow=true only when no flagged construct indicates a concrete publish risk.",
    "Set confidence high when the flagged constructs are clearly benign. Set confidence low only when a specific snippet is genuinely ambiguous; cite it in reason.",
    "",
    "Risk summary:",
    JSON.stringify(
      {
        htmlBytes: summary.htmlBytes || 0,
        cssBytes: summary.cssBytes || 0,
        inlineSvgCount: summary.inlineSvgCount || 0,
        trustedImageCount: summary.trustedImageCount || 0,
        externalRefs,
        oversized: Boolean(summary.oversized),
      },
      null,
      0,
    ),
    "",
    "Flagged snippets:",
    snippets.length === 0
      ? "(none — review based on size/origins only)"
      : snippets
          .slice(0, 12)
          .map((entry, index) => `${index + 1}. [${entry.kind}] ${entry.excerpt}`)
          .join("\n"),
  ].join("\n");
}

async function requestProfileSecurityAudit({ apiKey, riskSummary, model }) {
  const response = await fetch("https://api.openai.com/v1/responses", {
    method: "POST",
    headers: {
      authorization: `Bearer ${apiKey}`,
      "content-type": "application/json",
    },
    body: JSON.stringify({
      model,
      input: [{ role: "user", content: [{ type: "input_text", text: composeSecurityAuditPrompt(riskSummary) }] }],
      text: { format: profileSecurityAuditFormat },
    }),
  });

  const payload = await response.json().catch(() => null);
  if (!response.ok) {
    const message = payload?.error?.message || `OpenAI security audit failed with HTTP ${response.status}.`;
    const error = new Error(message);
    error.status = response.status;
    error.code = payload?.error?.code;
    error.type = payload?.error?.type;
    throw error;
  }

  const outputText = extractOutputText(payload);
  if (!outputText) {
    throw new Error("OpenAI returned no security audit content.");
  }

  return normalizeProfileSecurityAudit(JSON.parse(stripJsonFence(outputText)));
}

function isAuditModelUnavailableError(error) {
  const status = Number(error?.status || 0);
  const code = String(error?.code || "").toLowerCase();
  const type = String(error?.type || "").toLowerCase();
  const message = String(error?.message || "").toLowerCase();
  return (
    status === 404 ||
    code.includes("model_not_found") ||
    code.includes("model_not_available") ||
    type.includes("model_not_found") ||
    /\bmodel\b.*\b(not found|not available|unavailable|does not exist|unsupported)\b/.test(message)
  );
}

async function requestProfileSecurityAuditWithFallback({ apiKey, riskSummary }) {
  const models = auditModelCandidates();
  let lastError;
  let usedModel;
  for (const [index, model] of models.entries()) {
    try {
      const audit = await requestProfileSecurityAudit({ apiKey, riskSummary, model });
      usedModel = model;
      return { audit, model: usedModel };
    } catch (error) {
      lastError = error;
      if (index >= models.length - 1 || !isAuditModelUnavailableError(error)) {
        throw error;
      }
    }
  }
  throw lastError || new Error("OpenAI security audit failed before model selection.");
}

function trustedCapabilityKey(kind, source) {
  return `${kind}\u0000${String(source || "").trim()}`;
}

function trustedFrameSource(source, origin) {
  const match = trustedFrameMatchValue(String(source || ""), String(origin || ""));
  if (!match) return undefined;
  return {
    kind: "trusted_frame",
    source: match.url.href,
    origin: match.origin,
  };
}

function trustedImageSource(source, origin) {
  const match = trustedImageMatchValue(String(source || ""), String(origin || ""));
  if (!match) return undefined;
  const [url, normalizedOrigin] = match;
  return {
    kind: "trusted_image",
    source: url.href,
    origin: normalizedOrigin,
  };
}

function trustedCapabilityFromPlaceholder(placeholder) {
  if (placeholder.capability === "trusted_frame") {
    if (!placeholder.origin) return { message: "Trusted frame placeholders must include data-vibespace-origin." };
    if (!placeholder.source) return { message: "Trusted frame placeholders must include data-vibespace-src." };
    const capability = trustedFrameSource(placeholder.source, placeholder.origin);
    if (!capability) return { message: "Profile content includes an unsupported or unsafe trusted frame URL." };
    if (!placeholder.name || !placeholder.description) {
      return { message: "Trusted frame placeholders must include data-vibespace-name and data-vibespace-description." };
    }
    return { capability };
  }

  if (placeholder.capability === "trusted_image") {
    if (!placeholder.origin) return { message: "Trusted image placeholders must include data-vibespace-origin." };
    if (!placeholder.source) return { message: "Trusted image placeholders must include data-vibespace-src." };
    const capability = trustedImageSource(placeholder.source, placeholder.origin);
    if (!capability) return { message: "Profile content includes an unsupported or unsafe trusted image URL." };
    if (!placeholder.name || !placeholder.description) {
      return { message: "Trusted image placeholders must include data-vibespace-name and data-vibespace-description." };
    }
    if (!placeholder.alt) return { message: "Trusted image placeholders must include data-vibespace-alt." };
    return { capability };
  }

  return { message: `Unsupported web capability "${placeholder.capability}".` };
}

function trustedCapabilitiesFromHtml(html) {
  const capabilities = [];
  for (const placeholder of trustedCapabilityPlaceholdersFromHtml(html)) {
    const result = trustedCapabilityFromPlaceholder(placeholder);
    if (result.message) return { message: result.message, capabilities: [] };
    capabilities.push(result.capability);
  }
  return { message: "", capabilities };
}

function trustedCapabilitiesFromWebContext(webContext) {
  const capabilities = [];
  for (const frame of Array.isArray(webContext?.safeFrames) ? webContext.safeFrames : []) {
    const capability = trustedFrameSource(frame?.frameUrl, frame?.origin);
    if (capability) {
      capabilities.push({
        ...capability,
        canonicalUrl: String(frame?.canonicalUrl || ""),
        metadataJson: JSON.stringify(frame || {}),
      });
    }
  }
  for (const image of Array.isArray(webContext?.safeImages) ? webContext.safeImages : []) {
    const capability = trustedImageSource(image?.imageUrl, image?.origin);
    if (capability) {
      capabilities.push({
        ...capability,
        canonicalUrl: String(image?.canonicalUrl || ""),
        metadataJson: JSON.stringify(image || {}),
      });
    }
  }
  return capabilities;
}

function trustedCapabilityMetadataForSource(webContext, capability) {
  const contextMatch = trustedCapabilitiesFromWebContext(webContext).find(
    (candidate) => trustedCapabilityKey(candidate.kind, candidate.source) === trustedCapabilityKey(capability.kind, capability.source),
  );

  return {
    canonicalUrl: String(contextMatch?.canonicalUrl || ""),
    metadataJson: String(contextMatch?.metadataJson || "{}"),
  };
}

export function trustedCapabilityRowsFromHtml(html, webContext) {
  const parsed = trustedCapabilitiesFromHtml(html);
  if (parsed.message) {
    return [];
  }

  const rowsByKey = new Map();
  for (const capability of parsed.capabilities) {
    const key = trustedCapabilityKey(capability.kind, capability.source);
    if (!rowsByKey.has(key)) {
      rowsByKey.set(key, {
        ...capability,
        ...trustedCapabilityMetadataForSource(webContext, capability),
      });
    }
  }
  return Array.from(rowsByKey.values());
}

function trustedCapabilityAllowedSet(currentHtml, webContext) {
  const allowed = new Set();
  const existing = trustedCapabilitiesFromHtml(currentHtml);
  if (!existing.message) {
    for (const capability of existing.capabilities) {
      allowed.add(trustedCapabilityKey(capability.kind, capability.source));
    }
  }

  for (const capability of trustedCapabilitiesFromWebContext(webContext)) {
    allowed.add(trustedCapabilityKey(capability.kind, capability.source));
  }
  return allowed;
}

function trustedCapabilityUsageMessage(generatedCapabilities, allowed) {
  for (const capability of generatedCapabilities) {
    if (!allowed.has(trustedCapabilityKey(capability.kind, capability.source))) {
      return capability.kind === "trusted_frame"
        ? "Profile content used a media embed that was not already trusted by this profile."
        : "Profile content used an image that was not already trusted by this profile.";
    }
  }
  return "";
}

function withGeneratedCssRepairs(patch) {
  const css = repairGeneratedCss(patch?.css || "");
  return css === patch?.css ? patch : { ...patch, css };
}

const ariaLabelAttributePattern = /\s+aria-label\s*=\s*(?:"[^"]*"|'[^']*')/gi;
const ariaLabelTagScanPattern = /<([A-Za-z][\w:-]*)\b([^>]*)>/g;
const ariaLabelRoleValuePattern = /\brole\s*=\s*(?:"([^"]*)"|'([^']*)')/i;

export function repairGeneratedHtml(html) {
  const source = String(html || "");
  if (!/\baria-label\s*=/i.test(source)) return source;

  return source.replace(ariaLabelTagScanPattern, (match, tagName, attrs) => {
    if (!/\baria-label\s*=/i.test(attrs)) return match;
    if (ariaLabelAllowedTags.has(tagName.toLowerCase())) return match;

    const roleMatch = attrs.match(ariaLabelRoleValuePattern);
    const role = ((roleMatch && (roleMatch[1] || roleMatch[2])) || "").trim().toLowerCase();
    if (role && ariaLabelAllowedRoles.has(role)) return match;

    const stripped = attrs.replace(ariaLabelAttributePattern, "");
    return `<${tagName}${stripped}>`;
  });
}

function withGeneratedHtmlRepairs(patch) {
  const html = repairGeneratedHtml(patch?.html || "");
  return html === patch?.html ? patch : { ...patch, html };
}

function withGeneratedRepairs(patch) {
  return withGeneratedHtmlRepairs(withGeneratedCssRepairs(patch));
}

export async function validateProfilePatch(patch, { currentHtml, webContext }) {
  const html = String(patch?.html || "");
  const css = String(patch?.css || "");

  const validationMessage = await validateGeneratedProfileDocument(html, css);
  if (validationMessage) {
    return validationMessage;
  }

  const generated = trustedCapabilitiesFromHtml(html);
  if (generated.message) return generated.message;

  return trustedCapabilityUsageMessage(
    generated.capabilities,
    trustedCapabilityAllowedSet(currentHtml, webContext),
  );
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
  failed_html AS "failedHtml",
  failed_css AS "failedCss",
  failed_validation_message AS "failedValidationMessage",
  created_at::text AS "createdAt",
  updated_at::text AS "updatedAt"
`;

async function createSessionAndLoadSource(databaseUrl, input) {
  return await withClient(databaseUrl, async (client) => {
    const actorUserId = String(input.actorUserId || "").trim();
    if (!actorUserId) {
      return { error: "Authenticated actor is required to start an assistant edit." };
    }

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

async function updateSessionFailure(
  databaseUrl,
  sessionId,
  { summary, warnings, error, progressPhase, failedHtml, failedCss, failedValidationMessage },
) {
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
          failed_html = $6,
          failed_css = $7,
          failed_validation_message = $8,
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
        failedHtml ?? null,
        failedCss ?? null,
        failedValidationMessage ?? null,
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

export function assertProfileCurrentVersionUnchanged(profile, state) {
  const result = checkProfileCurrentVersionUnchanged(profile, state);

  if (!result.ok) {
    throw new Error(result.message);
  }
}

function validatedGeneratedPatch(patch, validationMessage) {
  const result = validateGeneratedPatch(patch, validationMessage || "");
  if (!result.ok) {
    throw new Error(result.message);
  }
  return { ...result.patch, html: markKnownInlineSvg(result.patch.html) };
}

async function persistAppliedPatch(databaseUrl, input, state, patch, providerConversationId, model, webContext) {
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
      assertProfileCurrentVersionUnchanged(profile, state);

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

      for (const capability of trustedCapabilityRowsFromHtml(patch.html, webContext)) {
        await client.query(
          `
            INSERT INTO vibespace.trusted_capability_references (
              profile_version_id,
              kind,
              origin,
              source,
              canonical_url,
              metadata_json,
              validation_status
            )
            VALUES ($1, $2, $3, $4, $5, $6, 'valid')
          `,
          [
            version.id,
            capability.kind,
            capability.origin,
            capability.source,
            capability.canonicalUrl,
            capability.metadataJson,
          ],
        );
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

function composePrompt(input, currentVersion, webContext) {
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
    webContext,
  });
}

function composeRepairPrompt(input, currentVersion, webContext, failedPatch, validationMessage) {
  const instruction = [
    "Repair the previous generated profile patch so it passes Vibespace validation.",
    `Validation error: ${validationMessage}`,
    `Original user request: ${input.prompt || ""}`,
    "Return a complete replacement JSON patch. Preserve the requested design intent, but fix invalid HTML, invalid CSS syntax, and unsupported web capability placeholders. CSS comments must use /* ... */ and selectors must be complete.",
  ].join("\n");

  return composeProfileEditPrompt({
    instruction,
    documentHtml: currentVersion.html || "",
    documentCss: currentVersion.css || "",
    selectedContext: input.selectionAgentContext || input.selectionLabel || "",
    selectedRegionScreenshotDataUrl: input.selectedRegionScreenshotDataUrl || "",
    fullPageScreenshotDataUrl: input.fullPageScreenshotDataUrl || "",
    previousFailedHtml: failedPatchText(failedPatch?.html, maxFailedPatchSnapshotLength),
    previousFailedCss: failedPatchText(failedPatch?.css, maxFailedPatchSnapshotLength),
    previousFailedSummary: failedPatchText(failedPatch?.summary, 1200),
    previousFailedWarnings: failedPatchText(failedPatch?.warnings, 2000),
    previousFailedValidationMessage: failedPatchText(validationMessage, 2000),
    webContext,
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
  const sessionId = state?.session?.id;
  const totalStartedAt = agentEditNow();
  let providerConversationId;
  let currentPhase = "generating";

  try {
    await updateSessionProgress(databaseUrl, state.session.id, "checking_web_context");
    currentPhase = "checking_web_context";
    const webContextStartedAt = agentEditNow();
    const webContext = await resolveWebContextForPrompt(prompt);
    logAgentEditPhase("web_context", {
      sessionId,
      elapsedMs: agentEditNow() - webContextStartedAt,
      status: webContext?.status,
      safeFrames: webContext?.safeFrames?.length || 0,
      safeImages: webContext?.safeImages?.length || 0,
    });

    await updateSessionProgress(databaseUrl, state.session.id, "generating");
    currentPhase = "generating";
    const generationStartedAt = agentEditNow();
    const providerResult = await requestProfilePatch({
      apiKey,
      prompt: composePrompt({ ...input, prompt }, state.currentVersion, webContext),
      model,
      reasoningEffort,
      input,
    });
    providerConversationId = providerResult.providerConversationId;
    logAgentEditPhase("generation", {
      sessionId,
      elapsedMs: agentEditNow() - generationStartedAt,
      htmlBytes: Buffer.byteLength(String(providerResult?.patch?.html || ""), "utf8"),
      cssBytes: Buffer.byteLength(String(providerResult?.patch?.css || ""), "utf8"),
      model,
    });

    await updateSessionProgress(databaseUrl, state.session.id, "validating");
    currentPhase = "validating";
    const validationStartedAt = agentEditNow();
    let patch = withGeneratedRepairs(providerResult.patch);
    let validationMessage = await validateProfilePatch(patch, {
      currentHtml: state.currentVersion.html,
      webContext,
    });
    logAgentEditPhase("validation", {
      sessionId,
      elapsedMs: agentEditNow() - validationStartedAt,
      passed: !validationMessage,
      error: validationMessage || undefined,
    });
    if (validationMessage) {
      await updateSessionProgress(databaseUrl, state.session.id, "repairing");
      currentPhase = "repairing";
      const repairStartedAt = agentEditNow();
      const repairResult = await requestProfilePatch({
        apiKey,
        prompt: composeRepairPrompt(
          { ...input, prompt },
          state.currentVersion,
          webContext,
          providerResult.patch,
          validationMessage,
        ),
        model,
        reasoningEffort,
        input,
      });
      providerConversationId = repairResult.providerConversationId || providerConversationId;
      logAgentEditPhase("repair", {
        sessionId,
        elapsedMs: agentEditNow() - repairStartedAt,
        model,
      });
      await updateSessionProgress(databaseUrl, state.session.id, "validating");
      currentPhase = "validating";
      const revalidationStartedAt = agentEditNow();
      patch = withGeneratedRepairs(repairResult.patch);
      validationMessage = await validateProfilePatch(patch, {
        currentHtml: state.currentVersion.html,
        webContext,
      });
      logAgentEditPhase("validation", {
        sessionId,
        elapsedMs: agentEditNow() - revalidationStartedAt,
        passed: !validationMessage,
        afterRepair: true,
        error: validationMessage || undefined,
      });

      if (validationMessage) {
        const session = await updateSessionFailure(databaseUrl, state.session.id, {
          summary: "Assistant output failed validation.",
          warnings: warningArray(patch.warnings),
          error: validationMessage,
          progressPhase: "validating",
          failedHtml: patch?.html || null,
          failedCss: patch?.css || null,
          failedValidationMessage: validationMessage,
        });
        logAgentEditPhase("total", {
          sessionId,
          elapsedMs: agentEditNow() - totalStartedAt,
          outcome: "validation_failed",
          error: validationMessage,
        });
        return serverFailure(validationMessage, {
          summary: "Assistant output failed validation.",
          warnings: warningArray(patch.warnings),
          validationErrors: [validationMessage],
          session,
          providerConversationId,
        });
      }
    }

    const validatedPatch = validatedGeneratedPatch(patch, validationMessage);
    await updateSessionProgress(databaseUrl, state.session.id, "validating");
    currentPhase = "risk_summary";
    const riskStartedAt = agentEditNow();
    const riskSummary = summarizeProfileRisk(validatedPatch);
    logAgentEditPhase("risk_summary", {
      sessionId,
      elapsedMs: agentEditNow() - riskStartedAt,
      clean: riskSummary.clean,
      htmlBytes: riskSummary.htmlBytes,
      cssBytes: riskSummary.cssBytes,
      inlineSvgCount: riskSummary.inlineSvgCount,
      trustedImageCount: riskSummary.trustedImageCount,
      snippetCount: riskSummary.suspiciousSnippets.length,
      externalRefs: riskSummary.externalRefs.length,
      oversized: riskSummary.oversized,
    });

    if (!riskSummary.clean) {
      currentPhase = "audit";
      const auditStartedAt = agentEditNow();
      const { audit: securityAudit, model: auditModel } = await requestProfileSecurityAuditWithFallback({
        apiKey,
        riskSummary,
      });
      const securityDecision = securityAuditDecision(securityAudit);
      logAgentEditPhase("audit", {
        sessionId,
        elapsedMs: agentEditNow() - auditStartedAt,
        skipped: false,
        model: auditModel,
        allow: securityDecision.audit.allow,
        risk: securityDecision.audit.risk,
        confidence: securityDecision.audit.confidence,
        ok: securityDecision.ok,
      });
      if (!securityDecision.ok) {
        const session = await updateSessionFailure(databaseUrl, state.session.id, {
          summary: "Assistant output failed security audit.",
          warnings: warningArray(validatedPatch.warnings),
          error: securityDecision.message,
          progressPhase: "validating",
          failedHtml: validatedPatch?.html || null,
          failedCss: validatedPatch?.css || null,
          failedValidationMessage: securityDecision.message,
        });
        logAgentEditPhase("total", {
          sessionId,
          elapsedMs: agentEditNow() - totalStartedAt,
          outcome: "audit_blocked",
          error: securityDecision.message,
        });
        return serverFailure(securityDecision.message, {
          summary: "Assistant output failed security audit.",
          warnings: warningArray(validatedPatch.warnings),
          validationErrors: [securityDecision.message],
          session,
          providerConversationId,
        });
      }
    } else {
      logAgentEditPhase("audit", { sessionId, elapsedMs: 0, skipped: true });
    }

    await updateSessionProgress(databaseUrl, state.session.id, "applying");
    currentPhase = "applying";
    const persistStartedAt = agentEditNow();
    const persisted = await persistAppliedPatch(
      databaseUrl,
      { ...input, prompt },
      state,
      validatedPatch,
      providerConversationId,
      model,
      webContext,
    );
    logAgentEditPhase("persistence", {
      sessionId,
      elapsedMs: agentEditNow() - persistStartedAt,
    });

    logAgentEditPhase("total", {
      sessionId,
      elapsedMs: agentEditNow() - totalStartedAt,
      outcome: "ok",
      auditSkipped: riskSummary.clean,
    });

    return {
      ok: true,
      summary: validatedPatch.summary,
      warnings: persisted.warnings,
      validationErrors: [],
      error: undefined,
      providerConversationId,
      session: persisted.session,
      version: persisted.version,
    };
  } catch (error) {
    const message = error instanceof Error ? error.message : "Assistant edit failed.";
    logAgentEditPhase("total", {
      sessionId,
      elapsedMs: agentEditNow() - totalStartedAt,
      outcome: "error",
      phase: currentPhase,
      error: message,
    });
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

  if (!String(input?.actorUserId || "").trim()) {
    return serverFailure("Authenticated actor is required to start an assistant edit.");
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
