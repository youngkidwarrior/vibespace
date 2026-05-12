import { describe, expect, it } from "vitest";
import {
  repairGeneratedCss,
  resolveWebContextForPrompt,
  shouldPersistSendtag,
} from "../AgentEditService.js";
import { validateCssSource } from "../ProfileHtmlValidation.js";

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

describe("AgentEditService generated CSS repair", () => {
  it("repairs common model CSS syntax mistakes before validation", async () => {
    const css = [
      ".profile-page&gt;{position:relative;z-index:1}",
      ".profile-card{border-width:0!important}/ remove borders on selected room cards /.profile-card{border:0!important}",
      "/ ===== Added player styling ===== */.music-player{display:grid}",
    ].join("");

    const repaired = repairGeneratedCss(css);

    expect(repaired).toContain(".profile-page> * {position:relative");
    expect(repaired).toContain("/*remove borders on selected room cards*/");
    expect(repaired).toContain("/*===== Added player styling =====*/");
    await expect(validateCssSource(repaired)).resolves.toBe("");
  });
});

describe("AgentEditService web context resolution", () => {
  it("turns YouTube watch URLs into trusted frame context", async () => {
    const webContext = await resolveWebContextForPrompt(
      "use oembed for https://www.youtube.com/watch?v=GR3Liudev18&list=RDGR3Liudev18&start_radio=1",
      {fetchImpl: undefined},
    );

    expect(webContext.status).toBe("resolved");
    expect(webContext.safeFrames[0]).toMatchObject({
      origin: "https://www.youtube.com",
      frameUrl: "https://www.youtube.com/embed/GR3Liudev18",
    });
  });

  it("uses YouTube oEmbed metadata when available", async () => {
    const webContext = await resolveWebContextForPrompt(
      "embed https://www.youtube.com/watch?v=GR3Liudev18",
      {
        fetchImpl: async () => ({
          ok: true,
          json: async () => ({
            title: "Pass the Vibes",
            html: '<iframe src="https://www.youtube.com/embed/GR3Liudev18?feature=oembed"></iframe>',
          }),
        }),
      },
    );

    expect(webContext.safeFrames[0]).toMatchObject({
      title: "Pass the Vibes",
      frameUrl: "https://www.youtube.com/embed/GR3Liudev18",
    });
  });
});
