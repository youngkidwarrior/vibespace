import { ariaLabelAllowedRoles, ariaLabelAllowedTags } from "./ProfileHtmlValidation.js";

const ariaLabelDisallowedPattern = /^"aria-label" cannot be used on this element\.$/;
const inlineStylePattern = /^Move visual rules into Profile look\.$/;
const htmlLineColumnPattern = /at line (\d+), column (\d+)(?::|$)/;
const cssLineColumnPattern = /at line (\d+)(?:, column (\d+))?(?::|$)/i;

function indexFromLineColumn(source, line, column) {
  if (!Number.isFinite(line) || line < 1) return null;
  let lineIndex = 1;
  let cursor = 0;
  while (lineIndex < line && cursor < source.length) {
    const nextNewline = source.indexOf("\n", cursor);
    if (nextNewline === -1) return null;
    cursor = nextNewline + 1;
    lineIndex += 1;
  }
  const offset = Math.max(0, (column || 1) - 1);
  return Math.min(source.length, cursor + offset);
}

function locateAriaLabel(html) {
  const tagPattern = /<([A-Za-z][\w:-]*)\b([^>]*)>/g;
  let match;
  while ((match = tagPattern.exec(html)) !== null) {
    const [full, tagName, attrs] = match;
    if (!/\baria-label\s*=/i.test(attrs)) continue;
    const tag = tagName.toLowerCase();
    if (ariaLabelAllowedTags.has(tag)) continue;
    const roleMatch = attrs.match(/\brole\s*=\s*(?:"([^"]*)"|'([^']*)')/i);
    const role = ((roleMatch && (roleMatch[1] || roleMatch[2])) || "").trim().toLowerCase();
    if (role && ariaLabelAllowedRoles.has(role)) continue;
    return {
      source: "html",
      charStart: match.index,
      charEnd: match.index + full.length,
      tagName: tag,
    };
  }
  return null;
}

function locateInlineStyle(html) {
  const tagPattern = /<([A-Za-z][\w:-]*)\b([^>]*\bstyle\s*=\s*(?:"[^"]*"|'[^']*')[^>]*)>/i;
  const match = html.match(tagPattern);
  if (!match || typeof match.index !== "number") return null;
  return {
    source: "html",
    charStart: match.index,
    charEnd: match.index + match[0].length,
    tagName: match[1].toLowerCase(),
  };
}

function locateFromLineColumn(source, sourceKind, locationMatch) {
  const line = Number(locationMatch[1]);
  const column = Number(locationMatch[2]);
  const charStart = indexFromLineColumn(source, line, column);
  if (charStart === null) return null;
  const remainder = source.slice(charStart);
  const tagMatch = remainder.match(/^<[A-Za-z][\w:-]*\b[^>]*>/);
  const charEnd = tagMatch
    ? charStart + tagMatch[0].length
    : Math.min(source.length, charStart + 120);
  return {
    source: sourceKind,
    charStart,
    charEnd,
    line,
    column: Number.isFinite(column) ? column : undefined,
  };
}

export function locateValidationProblem({ html = "", css = "", message = "" } = {}) {
  const text = String(message || "").trim();
  if (!text) return null;

  if (ariaLabelDisallowedPattern.test(text)) {
    return locateAriaLabel(String(html || ""));
  }

  if (inlineStylePattern.test(text)) {
    return locateInlineStyle(String(html || ""));
  }

  if (/^Profile content has invalid HTML/i.test(text)) {
    const locationMatch = text.match(htmlLineColumnPattern);
    if (locationMatch) {
      return locateFromLineColumn(String(html || ""), "html", locationMatch);
    }
  }

  if (/^Profile look has invalid CSS/i.test(text) || /^Profile look /i.test(text)) {
    const locationMatch = text.match(cssLineColumnPattern);
    if (locationMatch) {
      return locateFromLineColumn(String(css || ""), "css", locationMatch);
    }
  }

  return null;
}
