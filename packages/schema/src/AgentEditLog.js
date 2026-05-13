function now() {
  return Date.now();
}

function truncate(value, length = 240) {
  const text = String(value || "");
  return text.length > length ? text.slice(0, length) + "..." : text;
}

function composePhaseMessage(phase, fields) {
  const parts = [`agent_edit phase=${phase}`];
  const elapsed = fields?.elapsedMs;
  if (Number.isFinite(elapsed)) parts.push(`elapsedMs=${elapsed}`);
  if (fields?.sessionId) parts.push(`sessionId=${fields.sessionId}`);
  if (fields?.outcome) parts.push(`outcome=${fields.outcome}`);
  if (fields?.skipped !== undefined) parts.push(`skipped=${fields.skipped}`);
  if (fields?.passed !== undefined) parts.push(`passed=${fields.passed}`);
  if (fields?.afterRepair) parts.push("afterRepair=true");
  if (fields?.error) parts.push(`error=${JSON.stringify(truncate(fields.error))}`);
  return parts.join(" ");
}

function log(level, event, fields = {}) {
  const payload = {
    event,
    service: "vibespace-schema",
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

function logAgentEditPhase(phase, fields = {}) {
  const level = fields && fields.error ? "error" : "info";
  const message = composePhaseMessage(phase, fields);
  log(level, "agent_edit.phase", { phase, message, ...fields });
}

export { logAgentEditPhase, now };
