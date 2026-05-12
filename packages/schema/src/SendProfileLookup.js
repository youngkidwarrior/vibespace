function normalizeSendtag(value) {
  const trimmed = String(value || "").trim();
  const withoutOneSlash = trimmed.startsWith("/") ? trimmed.slice(1) : trimmed;
  const normalized = withoutOneSlash.trim();
  return normalized || "";
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
  const baseUrl = sendBaseUrl();
  const anonKey = sendAnonKey();

  if (!sendtag || !baseUrl || !anonKey) return null;

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

    if (!response.ok) return null;
    return avatarUrlFromLookupResponse(await response.json());
  } catch {
    return null;
  }
}

export { avatarUrlFromLookupResponse, lookupSendAvatarUrl, normalizeSendtag };
