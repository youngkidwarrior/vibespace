function now() {
  return Date.now();
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
  log(level, "agent_edit.phase", { phase, ...fields });
}

export { logAgentEditPhase, now };
