import {createHmac, randomBytes, timingSafeEqual} from "node:crypto";

const tokenVersion = "vs1";
const tokenPurpose = "vibespace-local-viewer-session";

function sessionSecret() {
  return String(process.env.VIBESPACE_SESSION_SECRET || "").trim();
}

function encodeBase64Url(value) {
  return Buffer.from(value).toString("base64url");
}

function decodeBase64Url(value) {
  return Buffer.from(value, "base64url").toString("utf8");
}

function sign(encodedPayload, secret) {
  return createHmac("sha256", secret).update(encodedPayload).digest("base64url");
}

function constantTimeEqual(left, right) {
  const leftBuffer = Buffer.from(String(left));
  const rightBuffer = Buffer.from(String(right));

  if (leftBuffer.length !== rightBuffer.length) {
    return false;
  }

  return timingSafeEqual(leftBuffer, rightBuffer);
}

function bearerTokenFromAuthorizationHeader(value) {
  const header = String(value || "").trim();
  const prefix = "Bearer ";
  if (!header.startsWith(prefix)) {
    return "";
  }

  return header.slice(prefix.length).trim();
}

export function issueForUserId(userId) {
  const secret = sessionSecret();
  const normalizedUserId = String(userId || "").trim();
  if (!secret || !normalizedUserId) {
    return "";
  }

  const payload = {
    purpose: tokenPurpose,
    userId: normalizedUserId,
    issuedAt: new Date().toISOString(),
    nonce: randomBytes(16).toString("base64url"),
  };
  const encodedPayload = encodeBase64Url(JSON.stringify(payload));
  const signature = sign(encodedPayload, secret);

  return `${tokenVersion}.${encodedPayload}.${signature}`;
}

export function verifyToken(token) {
  const secret = sessionSecret();
  const rawToken = String(token || "").trim();
  if (!secret || !rawToken) {
    return "";
  }

  const [version, encodedPayload, signature, extra] = rawToken.split(".");
  if (version !== tokenVersion || !encodedPayload || !signature || extra !== undefined) {
    return "";
  }

  const expectedSignature = sign(encodedPayload, secret);
  if (!constantTimeEqual(signature, expectedSignature)) {
    return "";
  }

  try {
    const payload = JSON.parse(decodeBase64Url(encodedPayload));
    if (payload?.purpose !== tokenPurpose || typeof payload?.userId !== "string") {
      return "";
    }

    return payload.userId.trim();
  } catch {
    return "";
  }
}

export function verifiedUserIdFromHeaders(authorizationHeader, sessionHeader) {
  const explicitToken = String(sessionHeader || "").trim();
  const bearerToken = bearerTokenFromAuthorizationHeader(authorizationHeader);
  return verifyToken(explicitToken || bearerToken);
}
