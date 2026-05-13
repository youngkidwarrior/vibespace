import { describe, expect, it } from "vitest";
import {
  assertProfileCurrentVersionUnchanged,
  auditModelCandidates,
  repairGeneratedCss,
  resolveWebContextForPrompt,
  securityAuditDecision,
  shouldPersistSendtag,
  startAgentEdit,
  trustedCapabilityRowsFromHtml,
  validateProfilePatch,
} from "../AgentEditService.js";
import { validateGeneratedPatch } from "../AgentEditSafety.res.js";
import {
  inspectSvgTrust,
  markKnownInlineSvg,
  validateCssSource,
  validateGeneratedProfileDocument,
  validateHtmlSource,
  validateManualProfileDocument,
} from "../ProfileHtmlValidation.js";

function commonsPayload({ mime = "image/jpeg", url = "https://upload.wikimedia.org/wikipedia/commons/5/55/50_Cent_2018.jpg" } = {}) {
  return {
    query: {
      pages: {
        123: {
          title: "File:50 Cent 2018.jpg",
          imageinfo: [
            {
              mime,
              url,
              thumburl: url,
              extmetadata: {
                ObjectName: { value: "50 Cent in 2018" },
                ImageDescription: { value: "Curtis Jackson at a public event." },
                Artist: { value: "Wikimedia photographer" },
                LicenseShortName: { value: "CC BY-SA 4.0" },
                LicenseUrl: { value: "https://creativecommons.org/licenses/by-sa/4.0/" },
              },
            },
          ],
        },
      },
    },
  };
}

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

  it("resolves trusted Wikimedia raster images for image prompts", async () => {
    const webContext = await resolveWebContextForPrompt("make a real photo tribute page for 50 Cent", {
      fetchImpl: async () => ({
        ok: true,
        json: async () => commonsPayload(),
      }),
    });

    expect(webContext.status).toBe("resolved");
    expect(webContext.safeImages[0]).toMatchObject({
      origin: "https://upload.wikimedia.org",
      title: "50 Cent in 2018",
      source: "Wikimedia Commons",
      imageUrl: "https://upload.wikimedia.org/wikipedia/commons/5/55/50_Cent_2018.jpg",
    });
  });

  it("drops Wikimedia SVG files from trusted image context", async () => {
    const webContext = await resolveWebContextForPrompt("use a wikimedia image of 50 Cent", {
      fetchImpl: async () => ({
        ok: true,
        json: async () =>
          commonsPayload({
            mime: "image/svg+xml",
            url: "https://upload.wikimedia.org/wikipedia/commons/5/55/50_Cent_logo.svg",
          }),
      }),
    });

    expect(webContext.status).toBe("not_found");
    expect(webContext.safeImages).toEqual([]);
  });
});

describe("AgentEditService trusted capability validation", () => {
  const css = ":root{color-scheme:dark}.player{display:block}";
  const youtubeFrame = {
    origin: "https://www.youtube.com",
    frameUrl: "https://www.youtube.com/embed/GR3Liudev18",
    canonicalUrl: "https://www.youtube.com/watch?v=GR3Liudev18",
    title: "Pass the Vibes",
  };

  function profileHtml(inner) {
    return `
      <main data-vibespace-id="profile-root" data-vibespace-name="Whole profile" data-vibespace-description="Profile root">
        ${inner}
      </main>
    `;
  }

  function youtubePlaceholder(extraBeforeSource = "") {
    return `
      <div
        class="player"
        data-vibespace-capability="trusted_frame"
        data-vibespace-origin="https://www.youtube.com"
        data-vibespace-name="YouTube player"
        data-vibespace-description="Playable song${extraBeforeSource}"
        data-vibespace-src="https://www.youtube.com/embed/GR3Liudev18">
      </div>
    `;
  }

  it("rejects parser-visible trusted frames even when regex extraction would stop at an attribute value", async () => {
    const patch = {
      html: profileHtml(youtubePlaceholder(">")),
      css,
      summary: "Added a player.",
      warnings: "",
    };

    await expect(validateProfilePatch(patch, { currentHtml: profileHtml("<section></section>"), webContext: {} }))
      .resolves.toBe("Profile content used a media embed that was not already trusted by this profile.");
  });

  it("allows trusted frames resolved in current web context", async () => {
    const patch = {
      html: profileHtml(youtubePlaceholder(">")),
      css,
      summary: "Added a player.",
      warnings: "",
    };

    await expect(validateProfilePatch(patch, {
      currentHtml: profileHtml("<section></section>"),
      webContext: { safeFrames: [youtubeFrame], safeImages: [] },
    })).resolves.toBe("");
  });

  it("persists only policy-valid trusted capability rows", () => {
    expect(trustedCapabilityRowsFromHtml(profileHtml(youtubePlaceholder()), {
      safeFrames: [youtubeFrame],
      safeImages: [],
    })).toMatchObject([
      {
        kind: "trusted_frame",
        origin: "https://www.youtube.com",
        source: "https://www.youtube.com/embed/GR3Liudev18",
        canonicalUrl: "https://www.youtube.com/watch?v=GR3Liudev18",
      },
    ]);

    expect(trustedCapabilityRowsFromHtml(profileHtml(`
      <div
        data-vibespace-capability="trusted_frame"
        data-vibespace-origin="https://attacker.example"
        data-vibespace-name="Bad frame"
        data-vibespace-description="Bad frame"
        data-vibespace-src="https://attacker.example/embed">
      </div>
    `), { safeFrames: [], safeImages: [] })).toEqual([]);
  });

  it("fails closed when startAgentEdit has no authenticated actor", async () => {
    const previousApiKey = process.env.OPENAI_API_KEY;
    process.env.OPENAI_API_KEY = "test-key";

    try {
      await expect(startAgentEdit({
        databaseUrl: "postgres://example.invalid/vibespace",
        profileId: "profile-id",
        prompt: "make it cozy",
      })).resolves.toMatchObject({
        ok: false,
        error: "Authenticated actor is required to start an assistant edit.",
      });
    } finally {
      if (previousApiKey === undefined) {
        delete process.env.OPENAI_API_KEY;
      } else {
        process.env.OPENAI_API_KEY = previousApiKey;
      }
    }
  });
});

describe("ProfileHtmlValidation safe inline SVG", () => {
  it("accepts and marks generated static inline SVG shapes and gradients", async () => {
    const html = `
      <main data-vibespace-id="profile-root" data-vibespace-name="Whole profile" data-vibespace-description="Profile root">
        <section data-vibespace-id="badge" data-vibespace-name="Badge" data-vibespace-description="Decorative vector badge">
          <svg class="badge-art" viewBox="0 0 120 120" role="img">
            <title>Star badge</title>
            <desc>Decorative gradient badge</desc>
            <defs>
              <linearGradient id="gold" x1="0" y1="0" x2="1" y2="1">
                <stop offset="0%" stop-color="#fff3a3" />
                <stop offset="100%" stop-color="#f59e0b" />
              </linearGradient>
            </defs>
            <circle cx="60" cy="60" r="54" fill="url(#gold)" stroke="#111" stroke-width="4" />
            <path d="M60 24 L70 50 L98 50 L75 66 L84 94 L60 77 L36 94 L45 66 L22 50 L50 50 Z" fill="#111" />
          </svg>
        </section>
      </main>
    `;

    await expect(validateGeneratedProfileDocument(html, ".badge-art { display: block; }")).resolves.toBe("");
    const marked = markKnownInlineSvg(html);
    expect(inspectSvgTrust(marked)).toEqual({ knownCount: 1, unknownCount: 0 });
    await expect(validateHtmlSource(marked)).resolves.toBe("");
  });

  it("rejects hand-written SVG in normal source validation", async () => {
    const html = `
      <main data-vibespace-id="profile-root" data-vibespace-name="Whole profile" data-vibespace-description="Profile root">
        <svg viewBox="0 0 120 120"><circle cx="60" cy="60" r="50" /></svg>
      </main>
    `;

    expect(inspectSvgTrust(html)).toEqual({ knownCount: 0, unknownCount: 1 });
    await expect(validateHtmlSource(html)).resolves.toContain("generated by the assistant");
  });

  it("rejects all SVG in manual profile saves", async () => {
    const html = markKnownInlineSvg(`
      <main data-vibespace-id="profile-root" data-vibespace-name="Whole profile" data-vibespace-description="Profile root">
        <svg viewBox="0 0 120 120"><circle cx="60" cy="60" r="50" /></svg>
      </main>
    `);

    await expect(validateManualProfileDocument(html, ".profile-root { color: #111; }")).resolves.toContain(
      "Manual profile saves cannot include SVG",
    );
  });

  it("rejects unsafe SVG linked resources", async () => {
    const html = markKnownInlineSvg(`
      <main data-vibespace-id="profile-root" data-vibespace-name="Whole profile" data-vibespace-description="Profile root">
        <svg viewBox="0 0 120 120"><image href="https://example.com/remote.png" /></svg>
      </main>
    `);

    await expect(validateHtmlSource(html)).resolves.toContain("Profile SVG cannot include <image>");
  });

  it("rejects SVG event handlers", async () => {
    const html = markKnownInlineSvg(`
      <main data-vibespace-id="profile-root" data-vibespace-name="Whole profile" data-vibespace-description="Profile root">
        <svg viewBox="0 0 120 120"><circle cx="60" cy="60" r="50" onclick="alert(1)" /></svg>
      </main>
    `);

    await expect(validateHtmlSource(html)).resolves.toContain("Profile SVG cannot include event handlers");
  });
});

describe("AgentEditService version concurrency", () => {
  it("rejects assistant output when the profile was changed after the session started", () => {
    expect(() =>
      assertProfileCurrentVersionUnchanged(
        {currentVersionId: "restored-version"},
        {currentVersion: {id: "assistant-base-version"}},
      )
    ).toThrow("Profile changed while the assistant edit was running");
  });

  it("allows assistant output when the profile is still on the session base version", () => {
    expect(() =>
      assertProfileCurrentVersionUnchanged(
        {currentVersionId: "assistant-base-version"},
        {currentVersion: {id: "assistant-base-version"}},
      )
    ).not.toThrow();
  });
});

describe("AgentEditSafety validated patches", () => {
  it("rejects generated patches with a validation message", () => {
    const result = validateGeneratedPatch(
      {
        html: "<main></main>",
        css: ":root{}",
        summary: "Changed profile.",
        warnings: "",
      },
      "Profile content has invalid HTML.",
    );

    expect(result).toMatchObject({
      ok: false,
      message: "Profile content has invalid HTML.",
    });
    expect(result.patch).toBe(undefined);
  });

  it("rejects generated patches missing required content", () => {
    const result = validateGeneratedPatch(
      {
        html: "",
        css: ":root{}",
        summary: "Changed profile.",
        warnings: "",
      },
      "",
    );

    expect(result).toMatchObject({
      ok: false,
      message: "Assistant output did not include profile HTML.",
    });
  });

  it("returns the patch only after validation has succeeded", () => {
    const patch = {
      html: "<main></main>",
      css: ":root{}",
      summary: "Changed profile.",
      warnings: "",
    };

    const result = validateGeneratedPatch(patch, "");

    expect(result).toMatchObject({
      ok: true,
      message: "",
      patch,
    });
  });
});

describe("AgentEditService security audit decision", () => {
  it("defaults to codex mini and falls back to the fast model", () => {
    const previousAuditModel = process.env.OPENAI_AUDIT_MODEL;
    const previousFastModel = process.env.OPENAI_FAST_MODEL;
    delete process.env.OPENAI_AUDIT_MODEL;
    process.env.OPENAI_FAST_MODEL = "gpt-fast-unit-test";

    try {
      expect(auditModelCandidates()).toEqual(["gpt-5.1-codex-mini", "gpt-fast-unit-test"]);
    } finally {
      if (previousAuditModel === undefined) {
        delete process.env.OPENAI_AUDIT_MODEL;
      } else {
        process.env.OPENAI_AUDIT_MODEL = previousAuditModel;
      }
      if (previousFastModel === undefined) {
        delete process.env.OPENAI_FAST_MODEL;
      } else {
        process.env.OPENAI_FAST_MODEL = previousFastModel;
      }
    }
  });

  it("allows low-risk audit results at the confidence threshold", () => {
    expect(
      securityAuditDecision({
        allow: true,
        confidence: 0.85,
        risk: "low",
        reason: "Deterministic checks passed.",
      }).ok,
    ).toBe(true);
  });

  it("blocks low-confidence audit results", () => {
    const result = securityAuditDecision({
      allow: true,
      confidence: 0.84,
      risk: "low",
      reason: "Mostly safe, but uncertain.",
    });

    expect(result.ok).toBe(false);
    expect(result.message).toContain("confidence=0.84");
  });

  it("blocks explicit audit denials", () => {
    const result = securityAuditDecision({
      allow: false,
      confidence: 0.99,
      risk: "high",
      reason: "Potential script execution.",
    });

    expect(result.ok).toBe(false);
    expect(result.message).toContain("Potential script execution");
  });
});
