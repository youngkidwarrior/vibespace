import { describe, expect, it, vi } from "vitest";
import {
  avatarUrlFromLookupResponse,
  normalizeSendtag,
  validateSendtagWithConfig,
} from "../SendProfileLookup.js";

describe("web SendProfileLookup", () => {
  it("normalizes raw Sendtag input", () => {
    expect(normalizeSendtag("Blusy19")).toBe("Blusy19");
    expect(normalizeSendtag("/Blusy19")).toBe("Blusy19");
    expect(normalizeSendtag("  /Blusy19  ")).toBe("Blusy19");
    expect(normalizeSendtag("//Blusy19")).toBe("/Blusy19");
    expect(normalizeSendtag(" / ")).toBe("");
  });

  it("prefers the medium webp avatar from a public Send profile", () => {
    expect(
      avatarUrlFromLookupResponse({
        is_public: true,
        avatar_url: "https://cdn.example.com/avatar.png",
        avatar_data: {
          variants: {
            md: { webp: "https://cdn.example.com/avatar-md.webp" },
            sm: { webp: "https://cdn.example.com/avatar-sm.webp" },
          },
        },
      }),
    ).toBe("https://cdn.example.com/avatar-md.webp");
  });

  it("validates a public profile before submit", async () => {
    const fetchImpl = vi.fn(async () => ({
      ok: true,
      json: async () => [
        {
          is_public: true,
          avatar_data: { variants: { md: { webp: "https://cdn.example.com/avatar.webp" } } },
        },
      ],
    }));

    await expect(
      validateSendtagWithConfig(" /Blusy19 ", {
        baseUrl: "https://send.example.com/",
        anonKey: "anon",
        fetchImpl,
      }),
    ).resolves.toMatchObject({
      ok: true,
      sendtag: "Blusy19",
      avatarUrl: "https://cdn.example.com/avatar.webp",
    });

    expect(fetchImpl).toHaveBeenCalledWith(
      "https://send.example.com/rest/v1/rpc/profile_lookup",
      expect.objectContaining({
        method: "POST",
        body: JSON.stringify({ lookup_type: "tag", identifier: "Blusy19" }),
      }),
    );
  });

  it("allows empty Sendtag without a lookup", async () => {
    const fetchImpl = vi.fn();

    await expect(
      validateSendtagWithConfig("", {
        baseUrl: "",
        anonKey: "",
        fetchImpl,
      }),
    ).resolves.toMatchObject({ ok: true, sendtag: "" });

    expect(fetchImpl).not.toHaveBeenCalled();
  });

  it("blocks unknown or private Sendtag values", async () => {
    await expect(
      validateSendtagWithConfig("/Missing", {
        baseUrl: "https://send.example.com",
        anonKey: "anon",
        fetchImpl: async () => ({ ok: true, json: async () => [] }),
      }),
    ).resolves.toMatchObject({
      ok: false,
      sendtag: "Missing",
    });

    await expect(
      validateSendtagWithConfig("/Private", {
        baseUrl: "https://send.example.com",
        anonKey: "anon",
        fetchImpl: async () => ({ ok: true, json: async () => [{ is_public: false }] }),
      }),
    ).resolves.toMatchObject({
      ok: false,
      sendtag: "Private",
    });
  });
});
