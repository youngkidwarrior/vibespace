import { HtmlValidate, Parser, walk } from "html-validate";
import { transform } from "lightningcss";

const maxProfileDocumentLength = 200000;
const fullDocumentFragmentPattern = /(?:<!doctype\b|<\/?(?:html|head|body)\b)/i;

export const ariaLabelAllowedTags = new Set([
  "a",
  "area",
  "button",
  "img",
  "input",
  "select",
  "summary",
  "textarea",
]);

export const ariaLabelAllowedRoles = new Set([
  "button",
  "checkbox",
  "combobox",
  "dialog",
  "group",
  "img",
  "link",
  "listbox",
  "menuitem",
  "option",
  "progressbar",
  "radio",
  "region",
  "searchbox",
  "slider",
  "spinbutton",
  "switch",
  "tab",
  "tabpanel",
  "textbox",
]);

let compiler;

function loadCompiler() {
  if (!compiler) {
    const htmlValidate = new HtmlValidate({
      extends: ["html-validate:recommended"],
      rules: {
        "doctype-html": "off",
        "no-inline-style": "off",
        "no-trailing-whitespace": "off",
      },
    });

    compiler = {
      htmlValidate,
      htmlPolicyParser: new Parser(htmlValidate.getConfigForSync("profile.html")),
      walk,
    };
  }

  return compiler;
}

function firstHtmlMessage(result) {
  const message = result?.results?.flatMap((entry) => entry.messages || [])?.[0];
  if (!message) return "";

  const location =
    typeof message.line === "number" && typeof message.column === "number"
      ? ` at line ${message.line}, column ${message.column}`
      : "";
  return `Profile content has invalid HTML${location}: ${message.message}`;
}

function parserErrorMessage(caught, sourceLabel) {
  const location =
    caught?.loc && typeof caught.loc.line === "number" && typeof caught.loc.column === "number"
      ? ` near line ${caught.loc.line}, column ${caught.loc.column}`
      : "";
  const message = caught instanceof Error ? caught.message : "Syntax could not be parsed.";
  return `${sourceLabel}${location}: ${message}`;
}

function topLevelElements(root) {
  return Array.from(root?.childNodes || []).filter((node) => node?.nodeType === 1);
}

function hasTopLevelText(root) {
  return Array.from(root?.childNodes || []).some(
    (node) => node?.nodeType === 3 && String(node.textContent || node.text || "").trim() !== "",
  );
}

function fragmentShapeMessage(html, compiler) {
  const source = String(html || "");

  if (source.trim() === "") {
    return "Profile content cannot be empty.";
  }

  if (source.length > maxProfileDocumentLength) {
    return "This profile is too large for the current server validation pipeline.";
  }

  if (fullDocumentFragmentPattern.test(source)) {
    return "Profile content must be a body fragment rooted at <main>, not a full HTML document.";
  }

  let root;
  try {
    root = compiler.htmlPolicyParser.parseHtml(source);
  } catch (caught) {
    return parserErrorMessage(caught, "Profile content has invalid HTML");
  }

  if (hasTopLevelText(root)) {
    return "Profile content must not include loose text outside the main profile root.";
  }

  const roots = topLevelElements(root);
  if (roots.length !== 1) {
    return "Profile content must have exactly one top-level <main> profile root.";
  }

  if (String(roots[0].tagName || "").toLowerCase() !== "main") {
    return "Profile content must be rooted at one <main> element.";
  }

  return "";
}

function normalizeAttributeValue(value) {
  return String(value || "").trim();
}

function attributeMapForElement(element) {
  const attributes = new Map();
  for (const attribute of element?.attributes || []) {
    attributes.set(String(attribute.key || "").toLowerCase(), normalizeAttributeValue(attribute.value));
  }
  return attributes;
}

export function trustedCapabilityPlaceholdersFromHtml(html) {
  const compiler = loadCompiler();
  let root;
  try {
    root = compiler.htmlPolicyParser.parseHtml(`<main data-vibespace-validation-root>${String(html || "")}</main>`);
  } catch (caught) {
    throw new Error(parserErrorMessage(caught, "Profile content has invalid HTML"));
  }

  const placeholders = [];
  compiler.walk.depthFirst(root, (element) => {
    const attributes = attributeMapForElement(element);
    const capability = attributes.get("data-vibespace-capability") || "";
    if (!capability) return;

    placeholders.push({
      capability,
      source: attributes.get("data-vibespace-src") || "",
      origin: attributes.get("data-vibespace-origin") || "",
      name: attributes.get("data-vibespace-name") || "",
      description: attributes.get("data-vibespace-description") || "",
      alt: attributes.get("data-vibespace-alt") || "",
    });
  });

  return placeholders;
}

function hasExecutableProtocol(value) {
  const trimmed = normalizeAttributeValue(value).toLowerCase();
  return (
    trimmed.startsWith("javascript:") ||
    trimmed.startsWith("vbscript:") ||
    trimmed.startsWith("data:text/html:")
  );
}

function hasRemoteHttpProtocol(value) {
  const trimmed = normalizeAttributeValue(value).toLowerCase();
  return trimmed.startsWith("http://") || trimmed.startsWith("https://");
}

const allowedSvgTags = new Set([
  "svg",
  "g",
  "path",
  "rect",
  "circle",
  "ellipse",
  "line",
  "polyline",
  "polygon",
  "title",
  "desc",
  "defs",
  "lineargradient",
  "radialgradient",
  "stop",
  "clippath",
]);

const blockedSvgTags = new Set([
  "script",
  "foreignobject",
  "image",
  "use",
  "animate",
  "animatetransform",
  "animatemotion",
  "set",
  "iframe",
  "audio",
  "video",
  "canvas",
  "style",
]);

const allowedSvgAttributes = new Set([
  "class",
  "id",
  "role",
  "aria-hidden",
  "focusable",
  "viewbox",
  "width",
  "height",
  "x",
  "y",
  "x1",
  "y1",
  "x2",
  "y2",
  "cx",
  "cy",
  "r",
  "rx",
  "ry",
  "d",
  "points",
  "transform",
  "preserveaspectratio",
  "fill",
  "fill-opacity",
  "fill-rule",
  "stroke",
  "stroke-width",
  "stroke-linecap",
  "stroke-linejoin",
  "stroke-miterlimit",
  "stroke-dasharray",
  "stroke-dashoffset",
  "stroke-opacity",
  "opacity",
  "clip-path",
  "gradientunits",
  "gradienttransform",
  "offset",
  "stop-color",
  "stop-opacity",
]);

const knownSvgSourceAttribute = "data-vibespace-svg-source";
const knownSvgPolicyAttribute = "data-vibespace-svg-policy";
const knownSvgSource = "assistant";
const knownSvgPolicy = "safe-static-v1";

function isSvgTag(tagName) {
  return allowedSvgTags.has(tagName) || blockedSvgTags.has(tagName);
}

function svgAttributeEntries(attributes) {
  return Array.from(
    String(attributes || "").matchAll(/([^\s=/"'<>`]+)(?:\s*=\s*(?:"([^"]*)"|'([^']*)'|([^\s"'>`]+)))?/g),
    (attribute) => [
      String(attribute[1] || "").toLowerCase(),
      attribute[2] ?? attribute[3] ?? attribute[4] ?? "",
    ],
  );
}

function hasKnownSvgMarker(attributes) {
  const values = new Map(svgAttributeEntries(attributes));
  return (
    normalizeAttributeValue(values.get(knownSvgSourceAttribute)).toLowerCase() === knownSvgSource &&
    normalizeAttributeValue(values.get(knownSvgPolicyAttribute)).toLowerCase() === knownSvgPolicy
  );
}

export function inspectSvgTrust(html) {
  let knownCount = 0;
  let unknownCount = 0;
  const tags = String(html || "").matchAll(/<\s*svg\b([^>]*)>/gi);
  for (const tag of tags) {
    if (hasKnownSvgMarker(tag[1] || "")) {
      knownCount += 1;
    } else {
      unknownCount += 1;
    }
  }
  return { knownCount, unknownCount };
}

export function markKnownInlineSvg(html) {
  return String(html || "").replace(/<\s*svg\b([^>]*)>/gi, (match, attributes) => {
    if (hasKnownSvgMarker(attributes)) return match;
    return `<svg data-vibespace-svg-source="${knownSvgSource}" data-vibespace-svg-policy="${knownSvgPolicy}"${attributes}>`;
  });
}

function hasExternalSvgReference(value) {
  const text = normalizeAttributeValue(value).toLowerCase();
  return (
    text.includes("http://") ||
    text.includes("https://") ||
    text.includes("//") ||
    /url\(\s*['"]?(?!#)/i.test(text)
  );
}

function svgAttributeMessage(name, value) {
  if (name.startsWith("data-vibespace-")) return "";
  if (name.startsWith("on")) return "Profile SVG cannot include event handlers.";
  if (name === "style") return "Profile SVG must use CSS classes instead of inline styles.";
  if (name === "href" || name === "xlink:href" || name === "src") {
    return "Profile SVG cannot include linked resources.";
  }
  if (!allowedSvgAttributes.has(name)) {
    return `Profile SVG cannot include "${name}" attributes.`;
  }
  if (hasExecutableProtocol(value) || hasExternalSvgReference(value)) {
    return "Profile SVG cannot include executable or remote references.";
  }
  return "";
}

function validateSvgSourcePolicy(html, { allowUnknownSvg = false, blockAllSvg = false } = {}) {
  const tags = String(html || "").matchAll(/<\s*\/?\s*([A-Za-z][\w:-]*)\b([^>]*)>/g);
  for (const tag of tags) {
    const fullTag = String(tag[0] || "");
    const tagName = String(tag[1] || "").toLowerCase();
    const attributes = String(tag[2] || "");
    if (tagName === "svg") {
      if (blockAllSvg) {
        return "Manual profile saves cannot include SVG. Ask the assistant to generate safe vector artwork instead.";
      }
      if (!allowUnknownSvg && !fullTag.startsWith("</") && !hasKnownSvgMarker(attributes)) {
        return "Profile SVG must be generated by the assistant, not pasted into Advanced.";
      }
    }
    if (blockedSvgTags.has(tagName)) {
      return `Profile SVG cannot include <${tagName}>.`;
    }
    if (!isSvgTag(tagName)) continue;
    if (!allowedSvgTags.has(tagName)) {
      return `Profile SVG cannot include <${tagName}>.`;
    }

    for (const [name, value] of svgAttributeEntries(attributes)) {
      const message = svgAttributeMessage(name, value);
      if (message) return message;
    }
  }
  return "";
}

function validateHtmlPolicy(html, compiler, options = {}) {
  let root;
  try {
    root = compiler.htmlPolicyParser.parseHtml(`<main data-vibespace-validation-root>${html}</main>`);
  } catch (caught) {
    return parserErrorMessage(caught, "Profile content has invalid HTML");
  }

  const svgSourceMessage = validateSvgSourcePolicy(html, options);
  if (svgSourceMessage) return svgSourceMessage;

  let message = "";

  compiler.walk.depthFirst(root, (element) => {
    if (message) return;

    const tagName = String(element.tagName || "").toLowerCase();
    if (!tagName || tagName === "#document") return;

    if (
      [
        "script",
        "style",
        "iframe",
        "object",
        "embed",
        "base",
        "meta",
        "link",
        "form",
        "audio",
        "video",
        "source",
        "track",
        "canvas",
        "math",
        "template",
        "noscript",
      ].includes(tagName)
    ) {
      message = `Profile content cannot include <${tagName}>.`;
      return;
    }

    if (blockedSvgTags.has(tagName)) {
      message = `Profile SVG cannot include <${tagName}>.`;
      return;
    }

    if (isSvgTag(tagName) && !allowedSvgTags.has(tagName)) {
      message = `Profile SVG cannot include <${tagName}>.`;
      return;
    }

    if (tagName.includes("-")) {
      message = "Profile content must use standard HTML elements.";
      return;
    }

    let hasVibespaceId = false;
    let friendlyName = "";
    let friendlyDescription = "";
    let hasAriaLabel = false;
    let role = "";

    for (const attribute of element.attributes || []) {
      const name = String(attribute.key || "").toLowerCase();
      const value = attribute.value;

      if (name === "data-vibespace-id") {
        hasVibespaceId = true;
      }

      if (name === "data-vibespace-name") {
        friendlyName = normalizeAttributeValue(value);
      }

      if (name === "data-vibespace-description") {
        friendlyDescription = normalizeAttributeValue(value);
      }

      if (name === "aria-label") {
        hasAriaLabel = true;
      }

      if (name === "role") {
        role = normalizeAttributeValue(value).toLowerCase();
      }

      if (isSvgTag(tagName)) {
        const svgMessage = svgAttributeMessage(name, value);
        if (svgMessage) {
          message = svgMessage;
          return;
        }
      }

      if (name === "style") {
        message = "Move visual rules into Profile look.";
        return;
      }

      if (name.startsWith("on")) {
        message = "Profile content cannot include click or load handlers.";
        return;
      }

      if (name === "popover") {
        message = "Profile content cannot depend on browser popover behavior.";
        return;
      }

      if (name === "src" || name === "href" || name === "poster" || name === "xlink:href") {
        if (hasExecutableProtocol(value)) {
          message = "Profile content cannot include executable links.";
          return;
        }

        if (hasRemoteHttpProtocol(value)) {
          message = "Profile content cannot load remote resources directly.";
          return;
        }
      }
    }

    if (
      hasAriaLabel &&
      !ariaLabelAllowedTags.has(tagName) &&
      (role === "" || !ariaLabelAllowedRoles.has(role))
    ) {
      message = `"aria-label" cannot be used on this element.`;
      return;
    }

    if (hasVibespaceId && (!friendlyName || !friendlyDescription)) {
      message = "Every editable profile part needs a short name and description.";
    }
  });

  return message;
}

export async function validateHtmlSource(html, options = {}) {
  const source = String(html || "");
  const compiler = loadCompiler();
  const fragmentMessage = fragmentShapeMessage(source, compiler);
  if (fragmentMessage) return fragmentMessage;

  try {
    const result = compiler.htmlValidate.validateStringSync(source);
    if (!result.valid) {
      return firstHtmlMessage(result) || "Profile content has invalid HTML.";
    }
  } catch (caught) {
    return parserErrorMessage(caught, "Profile content has invalid HTML");
  }

  return validateHtmlPolicy(source, compiler, options);
}

function propertyName(declaration) {
  if (declaration?.property === "custom") {
    return String(declaration?.value?.name || "").toLowerCase();
  }

  if (declaration?.property === "unparsed") {
    return String(declaration?.value?.propertyId?.property || "").toLowerCase();
  }

  return String(declaration?.property || "").toLowerCase();
}

function ruleMessage(rule) {
  switch (rule?.type) {
    case "import":
      return "Profile look cannot import remote files.";
    case "container":
      return "Profile look should use media queries instead of container queries for browser compatibility.";
    case "layer-block":
    case "layer-statement":
      return "Profile look should avoid cascade layers for browser compatibility.";
    case "property":
      return "Profile look cannot use Houdini custom property registration.";
    case "scope":
      return "Profile look should avoid scoped CSS for browser compatibility.";
    default:
      return "";
  }
}

function declarationMessage(declaration) {
  const property = propertyName(declaration);

  if (property === "behavior") {
    return "Profile look cannot use legacy behavior rules.";
  }

  if (property === "-moz-binding") {
    return "Profile look cannot use browser binding rules.";
  }

  if (property === "anchor-name" || property === "position-anchor" || property.startsWith("position-try")) {
    return "Profile look cannot use CSS anchor positioning yet.";
  }

  if (property === "animation-timeline") {
    return "Profile look cannot use scroll-driven animations yet.";
  }

  if (property.startsWith("scroll-timeline")) {
    return "Profile look cannot use scroll-driven animations yet.";
  }

  if (property.startsWith("view-timeline")) {
    return "Profile look cannot use scroll-driven animations yet.";
  }

  if (property === "view-transition-name") {
    return "Profile look cannot use View Transitions yet.";
  }

  return "";
}

function urlMessage() {
  return "Profile look cannot load URL resources.";
}

function selectorMessage(selector) {
  const hasNesting = Array.isArray(selector)
    ? selector.some((part) => part?.type === "nesting")
    : false;
  return hasNesting ? "Profile look should avoid CSS nesting for browser compatibility." : "";
}

function functionMessage(fn) {
  return String(fn?.name || "").toLowerCase() === "expression"
    ? "Profile look cannot use legacy executable expressions."
    : "";
}

export async function validateCssSource(css) {
  const source = String(css || "");

  if (source.trim() === "") {
    return "Profile look cannot be empty.";
  }

  if (source.length > maxProfileDocumentLength) {
    return "This profile is too large for the current server validation pipeline.";
  }

  if (/<\/?style(?:\s|>)/i.test(source)) {
    return "Profile CSS must be plain CSS, not a style tag.";
  }

  const diagnostics = [];

  try {
    transform({
      filename: "profile.css",
      code: Buffer.from(source),
      minify: false,
      visitor: {
        Rule(rule) {
          const message = ruleMessage(rule);
          if (message) diagnostics.push(message);
        },
        Declaration(declaration) {
          const message = declarationMessage(declaration);
          if (message) diagnostics.push(message);
        },
        Url() {
          const message = urlMessage();
          if (message) diagnostics.push(message);
        },
        Selector(selector) {
          const message = selectorMessage(selector);
          if (message) diagnostics.push(message);
        },
        Function(fn) {
          const message = functionMessage(fn);
          if (message) diagnostics.push(message);
        },
      },
    });
  } catch (caught) {
    return parserErrorMessage(caught, "Profile look has invalid CSS");
  }

  return diagnostics[0] || "";
}

export async function validateProfileDocument(html, css) {
  const htmlMessage = await validateHtmlSource(html);
  if (htmlMessage) return htmlMessage;

  return validateCssSource(css);
}

export async function validateGeneratedProfileDocument(html, css) {
  const htmlMessage = await validateHtmlSource(html, { allowUnknownSvg: true });
  if (htmlMessage) return htmlMessage;

  return validateCssSource(css);
}

export async function validateManualProfileDocument(html, css) {
  const htmlMessage = await validateHtmlSource(html, { blockAllSvg: true });
  if (htmlMessage) return htmlMessage;

  return validateCssSource(css);
}
