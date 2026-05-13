const cleanHtmlByteCeiling = 40000;
const cleanCssByteCeiling = 30000;
const maxSnippetsPerKind = 3;
const snippetExcerptLength = 240;

function byteLength(value) {
  if (typeof value !== "string") return 0;
  return Buffer.byteLength(value, "utf8");
}

function excerpt(source, index, length = snippetExcerptLength) {
  const start = Math.max(0, index - 40);
  return source.slice(start, start + length).replace(/\s+/g, " ").trim();
}

function pushSnippet(snippets, kind, source, index) {
  const bucket = snippets.filter((entry) => entry.kind === kind);
  if (bucket.length >= maxSnippetsPerKind) return;
  snippets.push({ kind, excerpt: excerpt(source, index) });
}

function scanHtml(html, snippets) {
  const source = String(html || "");
  let inlineSvgCount = 0;
  let trustedImageCount = 0;
  const externalRefs = new Set();

  const svgMatches = source.matchAll(/<svg\b/gi);
  for (const match of svgMatches) {
    inlineSvgCount += 1;
    if (inlineSvgCount > 4) {
      pushSnippet(snippets, "svg_density", source, match.index || 0);
      break;
    }
  }

  const trustedImageMatches = source.matchAll(/data-vibespace-capability="trusted_image"/gi);
  for (const _ of trustedImageMatches) trustedImageCount += 1;

  const dataUriMatches = source.matchAll(/\bdata:[^"'\s>]{1,200}/gi);
  for (const match of dataUriMatches) {
    pushSnippet(snippets, "data_uri", source, match.index || 0);
  }

  const styleAttrMatches = source.matchAll(/\bstyle\s*=\s*"[^"]*"/gi);
  for (const match of styleAttrMatches) {
    const value = match[0] || "";
    if (/url\s*\(/i.test(value)) {
      pushSnippet(snippets, "inline_style_url", source, match.index || 0);
    }
  }

  const refMatches = source.matchAll(/\b(?:src|href|data-vibespace-src)\s*=\s*"([^"]+)"/gi);
  for (const match of refMatches) {
    const value = String(match[1] || "").trim();
    if (!value) continue;
    if (value.startsWith("#") || value.startsWith("mailto:") || value.startsWith("tel:")) continue;
    if (value.startsWith("https://")) {
      try {
        externalRefs.add(new URL(value).origin);
      } catch {
        pushSnippet(snippets, "malformed_url", source, match.index || 0);
      }
      continue;
    }
    pushSnippet(snippets, "unusual_ref", source, match.index || 0);
  }

  const longBase64 = source.match(/[A-Za-z0-9+/]{600,}={0,2}/);
  if (longBase64 && typeof longBase64.index === "number") {
    pushSnippet(snippets, "long_base64", source, longBase64.index);
  }

  return { inlineSvgCount, trustedImageCount, externalRefs: Array.from(externalRefs) };
}

function scanCss(css, snippets) {
  const source = String(css || "");
  const urlMatches = source.matchAll(/url\s*\(\s*[^)]+\)/gi);
  for (const match of urlMatches) {
    pushSnippet(snippets, "css_url", source, match.index || 0);
  }
  const importMatches = source.matchAll(/@import\b/gi);
  for (const match of importMatches) {
    pushSnippet(snippets, "css_import", source, match.index || 0);
  }
}

export function summarizeProfileRisk(patch) {
  const html = String(patch?.html || "");
  const css = String(patch?.css || "");
  const htmlBytes = byteLength(html);
  const cssBytes = byteLength(css);
  const suspiciousSnippets = [];

  const { inlineSvgCount, trustedImageCount, externalRefs } = scanHtml(html, suspiciousSnippets);
  scanCss(css, suspiciousSnippets);

  const oversized = htmlBytes > cleanHtmlByteCeiling || cssBytes > cleanCssByteCeiling;
  const clean = suspiciousSnippets.length === 0 && !oversized;

  return {
    clean,
    htmlBytes,
    cssBytes,
    inlineSvgCount,
    trustedImageCount,
    externalRefs,
    suspiciousSnippets,
    oversized,
  };
}
