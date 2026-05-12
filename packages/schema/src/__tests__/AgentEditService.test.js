import { describe, expect, it } from "vitest";
import { shouldPersistSendtag } from "../AgentEditService.js";

describe("AgentEditService Sendtag persistence", () => {
  it("ignores omitted or undefined Sendtag inputs", () => {
    expect(shouldPersistSendtag({})).toBe(false);
    expect(shouldPersistSendtag({ sendtag: undefined })).toBe(false);
    expect(shouldPersistSendtag({ sendtag: null })).toBe(false);
  });

  it("persists explicit string Sendtag inputs", () => {
    expect(shouldPersistSendtag({ sendtag: "Blusy19" })).toBe(true);
    expect(shouldPersistSendtag({ sendtag: "" })).toBe(true);
  });
});
