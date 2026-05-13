function normalizeSendtag(value) {
  const trimmed = String(value || "").trim();
  const withoutOneSlash = trimmed.startsWith("/") ? trimmed.slice(1) : trimmed;
  const normalized = withoutOneSlash.trim();
  return normalized || "";
}

function safeSendtagForLog(value) {
  return normalizeSendtag(value).replace(/[^\w.-]/g, "").slice(0, 80);
}

function logSendProfileLookup(level, event, fields = {}) {
  const payload = {
    event,
    service: "vibespace-graphql",
    integration: "send-profile-lookup",
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

function sendBaseUrl() {
  return String(process.env.SEND_SUPABASE_URL || "").trim().replace(/\/+$/, "");
}

function sendAnonKey() {
  return String(process.env.SEND_SUPABASE_ANON_KEY || "").trim();
}

function safeHttpsUrl(value) {
  const text = String(value || "").trim();
  if (!text) return null;

  try {
    const url = new URL(text);
    return url.protocol === "https:" ? url.toString() : null;
  } catch {
    return null;
  }
}

function avatarUrlFromProfile(row) {
  if (!row || row.is_public !== true) return null;

  return (
    safeHttpsUrl(row.avatar_data?.variants?.md?.webp) ||
    safeHttpsUrl(row.avatar_data?.variants?.sm?.webp) ||
    safeHttpsUrl(row.avatar_url)
  );
}

function avatarUrlFromLookupResponse(value) {
  const row = Array.isArray(value) ? value[0] : value;
  return avatarUrlFromProfile(row);
}

async function lookupSendAvatarUrl(value) {
  const sendtag = normalizeSendtag(value);
  const logSendtag = safeSendtagForLog(sendtag);
  const baseUrl = sendBaseUrl();
  const anonKey = sendAnonKey();
  const startedAt = Date.now();

  if (!sendtag) return null;

  if (!baseUrl || !anonKey) {
    logSendProfileLookup("error", "sendtag.lookup.config_missing", {
      sendtag: logSendtag,
      hasSendSupabaseUrl: Boolean(baseUrl),
      hasSendSupabaseAnonKey: Boolean(anonKey),
    });
    return null;
  }

  logSendProfileLookup("info", "sendtag.lookup.start", { sendtag: logSendtag });

  try {
    const response = await fetch(`${baseUrl}/rest/v1/rpc/profile_lookup`, {
      method: "POST",
      headers: {
        "content-type": "application/json",
        apikey: anonKey,
        authorization: `Bearer ${anonKey}`,
      },
      body: JSON.stringify({
        lookup_type: "tag",
        identifier: sendtag,
      }),
    });

    if (!response.ok) {
      const body = await response.text().catch(() => "");
      logSendProfileLookup("warn", "sendtag.lookup.http_error", {
        sendtag: logSendtag,
        status: response.status,
        elapsedMs: Date.now() - startedAt,
        body: body.slice(0, 500),
      });
      return null;
    }

    const avatarUrl = avatarUrlFromLookupResponse(await response.json());
    logSendProfileLookup(avatarUrl ? "info" : "warn", avatarUrl ? "sendtag.lookup.found" : "sendtag.lookup.not_found", {
      sendtag: logSendtag,
      elapsedMs: Date.now() - startedAt,
    });
    return avatarUrl;
  } catch (error) {
    logSendProfileLookup("error", "sendtag.lookup.exception", {
      sendtag: logSendtag,
      elapsedMs: Date.now() - startedAt,
      message: String(error?.message || error || "Unknown Sendtag lookup error."),
      name: String(error?.name || "Error"),
    });
    return null;
  }
}

export { avatarUrlFromLookupResponse, lookupSendAvatarUrl, normalizeSendtag };
