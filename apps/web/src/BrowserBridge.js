import { toCanvas } from "html-to-image";
import { attachToIframe } from "./SelectionBridge.res.js";

const frameViewportCleanups = new WeakMap();
const profileLinkRouterCleanups = new WeakMap();
const trustedPlayerLayerCleanups = new WeakMap();

export function debugPromptsEnabled() {
  try {
    if (typeof window === "undefined") return false;

    const params = new URLSearchParams(window.location.search || "");
    return (
      params.get("debugPrompts") === "1" ||
      window.localStorage?.getItem("vibespaceDebugPrompts") === "true"
    );
  } catch (_error) {
    return false;
  }
}

export function debugPrompt(eventName, payload = "") {
  if (!debugPromptsEnabled()) return;

  const safePayload = typeof payload === "string" ? payload : String(payload || "");
  console.debug("[vibespace:prompt]", eventName, safePayload);
}

function numeric(value) {
  const next = Number(value);
  return Number.isFinite(next) ? next : 0;
}

function iframeFromLoadEvent(loadEvent) {
  return loadEvent?.currentTarget || loadEvent?.target;
}

function selectionPayloadSummary(payload) {
  const selectedCount = Array.isArray(payload?.selectedElements)
    ? payload.selectedElements.length
    : 0;
  return [
    `kind=${String(payload?.kind || "none")}`,
    `requestId=${String(payload?.requestId || "none")}`,
    `id=${String(payload?.id || "none")}`,
    `nearestId=${String(payload?.nearestId || "none")}`,
    `selectedCount=${selectedCount}`,
    `hasScreenshot=${Boolean(payload?.screenshotDataUrl)}`,
    `bounds=${Math.round(numeric(payload?.width))}x${Math.round(numeric(payload?.height))}`,
  ].join(" ");
}

function frameViewportPayload(frameWindow, iframeDocument) {
  return {
    scrollX: numeric(frameWindow?.scrollX ?? frameWindow?.pageXOffset),
    scrollY: numeric(frameWindow?.scrollY ?? frameWindow?.pageYOffset),
    viewportWidth: numeric(frameWindow?.innerWidth || iframeDocument?.documentElement?.clientWidth),
    viewportHeight: numeric(frameWindow?.innerHeight || iframeDocument?.documentElement?.clientHeight),
  };
}

function trustedFrameUrl(rawSource, rawOrigin) {
  let url;
  try {
    url = new URL(String(rawSource || "").trim());
  } catch (_error) {
    return undefined;
  }

  if (url.protocol !== "https:" || url.username || url.password) return undefined;

  const origin = url.origin;
  const expectedOrigin = String(rawOrigin || "").trim();
  if (expectedOrigin && expectedOrigin !== origin) return undefined;

  if (
    origin === "https://www.youtube.com" ||
    origin === "https://www.youtube-nocookie.com"
  ) {
    return url.pathname.startsWith("/embed/") ? url : undefined;
  }

  if (origin === "https://open.spotify.com") {
    return url.pathname.startsWith("/embed/") ? url : undefined;
  }

  if (origin === "https://w.soundcloud.com") {
    return url.pathname.startsWith("/player/") ? url : undefined;
  }

  if (origin === "https://player.vimeo.com") {
    return url.pathname.startsWith("/video/") ? url : undefined;
  }

  if (origin === "https://embed.music.apple.com") {
    return url;
  }

  return undefined;
}

function trustedPlayerFramesForDocument(iframeDocument) {
  const nodes = Array.from(
    iframeDocument.querySelectorAll(
      '.vibespace-trusted-frame[data-vibespace-capability="trusted_frame"]'
    )
  );

  return nodes
    .map((node, index) => {
      const url = trustedFrameUrl(
        node.getAttribute("data-vibespace-src"),
        node.getAttribute("data-vibespace-origin")
      );
      if (!url) return undefined;

      const rect = node.getBoundingClientRect();
      if (rect.width <= 0 || rect.height <= 0) return undefined;

      return {
        key: [
          String(node.getAttribute("data-vibespace-id") || "trusted-frame"),
          String(index),
          url.href,
        ].join(":"),
        source: url.href,
        title: String(
          node.getAttribute("data-vibespace-name") ||
            node.getAttribute("data-vibespace-description") ||
            "Trusted media"
        ),
        x: numeric(rect.left),
        y: numeric(rect.top),
        width: numeric(rect.width),
        height: numeric(rect.height),
      };
    })
    .filter(Boolean);
}

export function attachTrustedPlayerLayer(loadEvent, callback) {
  const iframe = iframeFromLoadEvent(loadEvent);
  const iframeDocument = iframe?.contentDocument || iframe?.contentWindow?.document;
  const frameWindow = iframe?.contentWindow;
  if (!iframe || !iframeDocument || !frameWindow) return;

  trustedPlayerLayerCleanups.get(iframe)?.();

  let animationFrame = 0;
  const emit = () => {
    if (animationFrame) cancelAnimationFrame(animationFrame);
    animationFrame = requestAnimationFrame(() => {
      animationFrame = 0;
      callback(trustedPlayerFramesForDocument(iframeDocument));
    });
  };
  const options = { passive: true };
  frameWindow.addEventListener("scroll", emit, options);
  frameWindow.addEventListener("resize", emit, options);

  const observer =
    typeof ResizeObserver === "function"
      ? new ResizeObserver(emit)
      : undefined;
  if (observer) {
    observer.observe(iframeDocument.documentElement);
    for (const node of iframeDocument.querySelectorAll(".vibespace-trusted-frame")) {
      observer.observe(node);
    }
  }

  trustedPlayerLayerCleanups.set(iframe, () => {
    frameWindow.removeEventListener("scroll", emit, options);
    frameWindow.removeEventListener("resize", emit, options);
    observer?.disconnect();
    if (animationFrame) cancelAnimationFrame(animationFrame);
  });

  emit();
}

export function attachFrameViewportListener(loadEvent, callback) {
  const iframe = iframeFromLoadEvent(loadEvent);
  const iframeDocument = iframe?.contentDocument || iframe?.contentWindow?.document;
  const frameWindow = iframe?.contentWindow;
  if (!iframe || !iframeDocument || !frameWindow) return;

  frameViewportCleanups.get(iframe)?.();

  const emit = () => callback(frameViewportPayload(frameWindow, iframeDocument));
  const options = { passive: true };
  frameWindow.addEventListener("scroll", emit, options);
  frameWindow.addEventListener("resize", emit, options);
  frameViewportCleanups.set(iframe, () => {
    frameWindow.removeEventListener("scroll", emit, options);
    frameWindow.removeEventListener("resize", emit, options);
  });
  emit();
}

export function attachProfileLinkRouter(loadEvent, callback) {
  const iframe = iframeFromLoadEvent(loadEvent);
  const iframeDocument = iframe?.contentDocument || iframe?.contentWindow?.document;
  if (!iframe || !iframeDocument) return;

  profileLinkRouterCleanups.get(iframe)?.();

  const handleClick = (event) => {
    if (
      event.defaultPrevented ||
      event.button !== 0 ||
      event.metaKey ||
      event.ctrlKey ||
      event.shiftKey ||
      event.altKey
    ) {
      return;
    }

    const anchor = event.target?.closest?.("a[href]");
    if (!anchor) return;

    let url;
    try {
      url = new URL(anchor.getAttribute("href") || "", window.location.origin);
    } catch (_error) {
      return;
    }

    if (url.origin !== window.location.origin) return;

    const target = String(anchor.getAttribute("target") || "").toLowerCase();
    if (target && target !== "_top" && target !== "_self" && target !== "_parent") return;

    const appRoute =
      url.pathname === "/" ||
      url.pathname === "/source" ||
      url.pathname.startsWith("/u/") ||
      url.pathname.startsWith("/invite/");
    if (!appRoute) return;

    event.preventDefault();
    callback(`${url.pathname}${url.search}${url.hash}`);
  };

  iframeDocument.addEventListener("click", handleClick, true);
  profileLinkRouterCleanups.set(iframe, () => {
    iframeDocument.removeEventListener("click", handleClick, true);
  });
}

async function captureAreaFromIframe(iframe, bounds) {
  const iframeDocument = iframe?.contentDocument || iframe?.contentWindow?.document;
  const body = iframeDocument?.body;
  if (!body) return "";

  // Future model context should return both this full-page canvas and the cropped selection.
  // Capture once per request, then derive {fullPageScreenshotDataUrl, selectionScreenshotDataUrl}
  // so the agent can compare the entire "before" page with the selected region.
  const canvas = await toCanvas(body, {
    cacheBust: true,
    pixelRatio: 1,
    backgroundColor: getComputedStyle(body).backgroundColor || "#ffffff",
  });

  const sourceWidth = Math.max(
    body.scrollWidth,
    iframeDocument.documentElement?.scrollWidth || 0,
    canvas.width
  );
  const sourceHeight = Math.max(
    body.scrollHeight,
    iframeDocument.documentElement?.scrollHeight || 0,
    canvas.height
  );
  const scaleX = canvas.width / sourceWidth || 1;
  const scaleY = canvas.height / sourceHeight || 1;
  const cropX = Math.max(0, Math.round(numeric(bounds.documentX) * scaleX));
  const cropY = Math.max(0, Math.round(numeric(bounds.documentY) * scaleY));
  const cropWidth = Math.max(1, Math.round(numeric(bounds.width) * scaleX));
  const cropHeight = Math.max(1, Math.round(numeric(bounds.height) * scaleY));

  const output = document.createElement("canvas");
  if (cropX >= canvas.width || cropY >= canvas.height) return "";
  output.width = Math.min(cropWidth, Math.max(1, canvas.width - cropX));
  output.height = Math.min(cropHeight, Math.max(1, canvas.height - cropY));
  const context = output.getContext("2d");
  if (!context) return "";

  context.drawImage(
    canvas,
    cropX,
    cropY,
    output.width,
    output.height,
    0,
    0,
    output.width,
    output.height
  );

  return output.toDataURL("image/png");
}

export function attachSelectionBridge(loadEvent, selectedId, editMode, callback) {
  const iframe = iframeFromLoadEvent(loadEvent);
  debugPrompt(
    "attach-selection-bridge",
    `iframe=${Boolean(iframe)} selectedId=${String(selectedId || "none")} editMode=${Boolean(editMode)}`
  );
  if (!iframe) {
    debugPrompt("attach-selection-bridge-missing", "reason=no-iframe");
    return;
  }

  attachToIframe(iframe, String(selectedId || ""), Boolean(editMode), async (nextPayload) => {
    debugPrompt("selection-callback", selectionPayloadSummary(nextPayload));
    callback(nextPayload);

    if (nextPayload.kind !== "area" || nextPayload.screenshotDataUrl) return;

    try {
      const screenshotDataUrl = await captureAreaFromIframe(iframe, {
        documentX: nextPayload.documentX,
        documentY: nextPayload.documentY,
        width: nextPayload.width,
        height: nextPayload.height,
      });
      if (screenshotDataUrl) {
        debugPrompt(
          "selection-screenshot-captured",
          `requestId=${String(nextPayload.requestId || "none")} bytes=${screenshotDataUrl.length}`
        );
        callback({ ...nextPayload, screenshotDataUrl });
      }
    } catch (error) {
      console.warn("Vibespace area screenshot capture failed", error);
    }
  });
}
