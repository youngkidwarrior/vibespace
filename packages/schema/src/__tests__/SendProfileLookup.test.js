import { describe, expect, it } from "vitest";
import {
  avatarUrlFromLookupResponse,
  normalizeSendtag,
} from "../SendProfileLookup.js";

describe("SendProfileLookup", () => {
  it("normalizes raw Sendtag input", () => {
    expect(normalizeSendtag("Blusy19")).toBe("Blusy19");
    expect(normalizeSendtag("/Blusy19")).toBe("Blusy19");
    expect(normalizeSendtag("  /Blusy19  ")).toBe("Blusy19");
    expect(normalizeSendtag("//Blusy19")).toBe("/Blusy19");
    expect(normalizeSendtag(" / ")).toBe("");
  });

  it("selects the medium webp avatar for a public profile", () => {
    expect(
      avatarUrlFromLookupResponse([
        {
          is_public: true,
          avatar_url: "https://example.com/fallback.png",
          avatar_data: {
            variants: {
              sm: { webp: "https://example.com/sm.webp" },
              md: { webp: "https://example.com/md.webp" },
            },
          },
        },
      ]),
    ).toBe("https://example.com/md.webp");
  });

  it("falls back and rejects private or unusable avatar responses", () => {
    expect(
      avatarUrlFromLookupResponse({
        is_public: true,
        avatar_url: "https://example.com/fallback.png",
        avatar_data: { variants: { sm: { webp: "https://example.com/sm.webp" } } },
      }),
    ).toBe("https://example.com/sm.webp");

    expect(avatarUrlFromLookupResponse({ is_public: false, avatar_url: "https://example.com/x.png" })).toBe(
      null,
    );
    expect(avatarUrlFromLookupResponse({ is_public: true, avatar_url: "http://example.com/x.png" })).toBe(
      null,
    );
    expect(avatarUrlFromLookupResponse([])).toBe(null);
  });
});
