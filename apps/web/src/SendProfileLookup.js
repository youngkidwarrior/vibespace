function normalizeSendtag(value) {
  const trimmed = String(value || "").trim();
  const withoutOneSlash = trimmed.startsWith("/") ? trimmed.slice(1) : trimmed;
  const normalized = withoutOneSlash.trim();
  return normalized || "";
}

function browserSendBaseUrl() {
  return String(import.meta.env.VITE_SEND_SUPABASE_URL || "").trim().replace(/\/+$/, "");
}

function browserSendAnonKey() {
  return String(import.meta.env.VITE_SEND_SUPABASE_ANON_KEY || "").trim();
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

function valid(sendtag, avatarUrl = "") {
  return { ok: true, sendtag, message: "", avatarUrl };
}

function invalid(sendtag, message) {
  return { ok: false, sendtag, message, avatarUrl: "" };
}

async function validateSendtagWithConfig(
  value,
  { baseUrl = "", anonKey = "", fetchImpl = globalThis.fetch } = {},
) {
  const sendtag = normalizeSendtag(value);
  if (!sendtag) return valid("");

  const lookupBaseUrl = String(baseUrl || "").trim().replace(/\/+$/, "");
  const lookupAnonKey = String(anonKey || "").trim();
  if (!lookupBaseUrl || !lookupAnonKey) {
    return invalid(sendtag, "Sendtag lookup is not configured. Leave Sendtag blank for now.");
  }

  try {
    const response = await fetchImpl(`${lookupBaseUrl}/rest/v1/rpc/profile_lookup`, {
      method: "POST",
      headers: {
        "content-type": "application/json",
        apikey: lookupAnonKey,
        authorization: `Bearer ${lookupAnonKey}`,
      },
      body: JSON.stringify({
        lookup_type: "tag",
        identifier: sendtag,
      }),
    });

    if (!response.ok) {
      return invalid(sendtag, `We could not find a public Send profile for /${sendtag}. Check the tag or leave it blank.`);
    }

    const avatarUrl = avatarUrlFromLookupResponse(await response.json());
    if (!avatarUrl) {
      return invalid(sendtag, `We could not find a public Send profile for /${sendtag}. Check the tag or leave it blank.`);
    }

    return valid(sendtag, avatarUrl);
  } catch {
    return invalid(sendtag, `We could not find a public Send profile for /${sendtag}. Check the tag or leave it blank.`);
  }
}

function validateSendtag(value) {
  return validateSendtagWithConfig(value, {
    baseUrl: browserSendBaseUrl(),
    anonKey: browserSendAnonKey(),
  });
}

export {
  avatarUrlFromLookupResponse,
  normalizeSendtag,
  validateSendtag,
  validateSendtagWithConfig,
};
