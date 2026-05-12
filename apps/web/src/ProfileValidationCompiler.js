const textEncoder = new TextEncoder();
let compilerPromise = null;

async function loadCompiler() {
  if (!compilerPromise) {
    compilerPromise = Promise.all([
      import("html-validate/browser"),
      import("lightningcss-wasm"),
      import("lightningcss-wasm/lightningcss_node.wasm?url"),
    ]).then(async ([htmlValidateModule, lightningCssModule, lightningCssWasmUrlModule]) => {
      const { HtmlValidate, Parser, walk } = htmlValidateModule;
      const initLightningCss = lightningCssModule.default;
      await initLightningCss(lightningCssWasmUrlModule.default);
      const htmlValidate = new HtmlValidate({
        extends: ["html-validate:recommended"],
        rules: {
          "doctype-html": "off",
          "no-inline-style": "off",
          "no-trailing-whitespace": "off",
        },
      });

      return {
        htmlValidate,
        htmlPolicyParser: new Parser(htmlValidate.getConfigForSync("profile.html")),
        transform: lightningCssModule.transform,
        walk,
      };
    });
  }

  return compilerPromise;
}

const ariaLabelAllowedTags = new Set([
  "a",
  "area",
  "button",
  "img",
  "input",
  "select",
  "summary",
  "textarea",
]);

const ariaLabelAllowedRoles = new Set([
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

const fullDocumentFragmentPattern = /(?:<!doctype\b|<\/?(?:html|head|body)\b)/i;

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

function fragmentShapeMessage(html) {
  const source = String(html || "");

  if (fullDocumentFragmentPattern.test(source)) {
    return "Profile content must be a body fragment rooted at <main>, not a full HTML document.";
  }

  if (typeof document === "undefined" || typeof document.createElement !== "function") {
    return "";
  }

  const template = document.createElement("template");
  template.innerHTML = source;

  const hasTopLevelText = Array.from(template.content.childNodes || []).some(
    (node) => node.nodeType === Node.TEXT_NODE && String(node.textContent || "").trim() !== "",
  );
  if (hasTopLevelText) {
    return "Profile content must not include loose text outside the main profile root.";
  }

  const roots = Array.from(template.content.children || []);
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

function validateHtmlPolicy(html, compiler) {
  const root = compiler.htmlPolicyParser.parseHtml(`<main data-vibespace-validation-root>${html}</main>`);
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
        "svg",
        "math",
        "template",
        "noscript",
      ].includes(tagName)
    ) {
      message = `Profile content cannot include <${tagName}>.`;
      return;
    }

    if (tagName.includes("-")) {
      message = "Profile content must use standard HTML elements.";
      return;
    }

    let hasVibespaceId = false;
    let friendlyName = "";
    let friendlyDescription = "";

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

    if (hasVibespaceId && (!friendlyName || !friendlyDescription)) {
      message = "Every editable profile part needs a short name and description.";
    }
  });

  return message;
}

export async function validateHtmlSource(html) {
  const fragmentMessage = fragmentShapeMessage(html);
  if (fragmentMessage) return fragmentMessage;

  const compiler = await loadCompiler();
  try {
    const result = compiler.htmlValidate.validateStringSync(html || "");
    if (!result.valid) {
      return firstHtmlMessage(result) || "Profile content has invalid HTML.";
    }
  } catch (caught) {
    return parserErrorMessage(caught, "Profile content has invalid HTML");
  }

  return validateHtmlPolicy(html || "", compiler);
}

export async function repairHtmlSource(html) {
  const source = String(html || "");
  if (typeof document === "undefined" || typeof document.createElement !== "function") {
    return source;
  }

  const template = document.createElement("template");
  template.innerHTML = source;

  for (const element of template.content.querySelectorAll("[aria-label]")) {
    const tagName = String(element.tagName || "").toLowerCase();
    const role = normalizeAttributeValue(element.getAttribute("role")).toLowerCase();
    const canReceiveAriaLabel =
      ariaLabelAllowedTags.has(tagName) || (role !== "" && ariaLabelAllowedRoles.has(role));
    if (!canReceiveAriaLabel) {
      element.removeAttribute("aria-label");
    }
  }

  return template.innerHTML.trim();
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

function urlMessage(url) {
  const value = String(url?.url || "").trim().toLowerCase();
  if (value.startsWith("javascript:") || value.startsWith("vbscript:") || value.startsWith("data:text/html:")) {
    return "Profile look cannot include executable links.";
  }

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
  const diagnostics = [];
  const compiler = await loadCompiler();

  try {
    compiler.transform({
      filename: "profile.css",
      code: textEncoder.encode(css || ""),
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
        Url(url) {
          const message = urlMessage(url);
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
