function now() {
  return Date.now();
}

function log(level, event, fields = {}) {
  const payload = {
    event,
    service: "vibespace-graphql",
    timestamp: new Date().toISOString(),
    ...fields,
  };
  const line = JSON.stringify(payload);
  if (level === "error") {
    console.error(line);
  } else if (level === "warn") {
    console.warn(line);
  } else {
    console.info(line);
  }
}

function pathnameFromUrl(url) {
  try {
    return new URL(String(url || "")).pathname;
  } catch {
    return "";
  }
}

function logGraphqlRequest(url) {
  const pathname = pathnameFromUrl(url);
  if (pathname === "/graphql") {
    log("info", "graphql.request.start", { pathname });
  }
}

function logGraphqlResponse(url, startedAtMs, response) {
  const pathname = pathnameFromUrl(url);
  if (pathname !== "/graphql") return;

  const status = Number(response?.status || 0);
  const elapsedMs = Math.max(0, Math.round(now() - Number(startedAtMs || 0)));
  log(status >= 500 ? "error" : "info", "graphql.request.finish", {
    pathname,
    status,
    elapsedMs,
  });

  response
    ?.clone?.()
    ?.json?.()
    ?.then((body) => {
      const errors = Array.isArray(body?.errors) ? body.errors : [];
      if (errors.length === 0) return;

      log("error", "graphql.response.errors", {
        pathname,
        status,
        elapsedMs,
        errorCount: errors.length,
        errors: errors.slice(0, 5).map((error) => ({
          message: String(error?.message || "GraphQL error."),
          path: Array.isArray(error?.path) ? error.path.join(".") : "",
          code: String(error?.extensions?.code || ""),
        })),
      });
    })
    .catch(() => {});
}

function logGraphqlError(url, startedAtMs, error) {
  const pathname = pathnameFromUrl(url);
  if (pathname !== "/graphql") return;

  const elapsedMs = Math.max(0, Math.round(now() - Number(startedAtMs || 0)));
  log("error", "graphql.request.error", {
    pathname,
    elapsedMs,
    message: String(error?.message || error || "Unknown GraphQL request error."),
    name: String(error?.name || "Error"),
  });
}

export { logGraphqlError, logGraphqlRequest, logGraphqlResponse, now };
