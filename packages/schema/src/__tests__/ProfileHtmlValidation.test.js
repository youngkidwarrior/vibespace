import { describe, expect, it } from "vitest";
import {
  validateCssSource,
  validateHtmlSource,
  validateProfileDocument,
} from "../ProfileHtmlValidation.js";

const validHtml = `
<main data-vibespace-id="profile-root" data-vibespace-name="Whole Profile" data-vibespace-description="Full profile">
  <section data-vibespace-id="intro" data-vibespace-name="Intro" data-vibespace-description="Profile intro">
    <h1>Vibespace</h1>
    <p>Hello from a safe profile.</p>
  </section>
</main>
`;

const validCss = `
.profile-root { color: #111; background: #fff; }
.profile-root h1 { font-size: 48px; }
`;

describe("ProfileHtmlValidation", () => {
  it("accepts a valid profile document", async () => {
    await expect(validateProfileDocument(validHtml, validCss)).resolves.toBe("");
  });

  it("accepts harmless trailing whitespace in profile HTML", async () => {
    const htmlWithTrailingWhitespace = validHtml.replace("</p>", "</p>   ");

    await expect(validateHtmlSource(htmlWithTrailingWhitespace)).resolves.toBe("");
  });

  it("rejects full HTML documents instead of profile fragments", async () => {
    await expect(validateHtmlSource(`<html><body>${validHtml}</body></html>`)).resolves.toContain(
      "must be a body fragment",
    );
  });

  it("rejects executable HTML", async () => {
    await expect(
      validateHtmlSource(
        `<main data-vibespace-id="root" data-vibespace-name="Root" data-vibespace-description="Root"><script>alert(1)</script></main>`,
      ),
    ).resolves.toContain("cannot include <script>");

    await expect(
      validateHtmlSource(
        `<main data-vibespace-id="root" data-vibespace-name="Root" data-vibespace-description="Root"><div onclick="alert(1)">Click</div></main>`,
      ),
    ).resolves.toContain("cannot include click or load handlers");
  });

  it("rejects remote HTML resources", async () => {
    await expect(
      validateHtmlSource(
        `<main data-vibespace-id="root" data-vibespace-name="Root" data-vibespace-description="Root"><a href="https://example.com">link</a></main>`,
      ),
    ).resolves.toContain("cannot load remote resources");
  });

  it("rejects invalid aria-label usage", async () => {
    await expect(
      validateHtmlSource(
        `<main data-vibespace-id="root" data-vibespace-name="Root" data-vibespace-description="Root"><div aria-label="Not allowed">copy</div></main>`,
      ),
    ).resolves.toContain("aria-label");
  });

  it("rejects invalid or unsafe CSS", async () => {
    await expect(validateCssSource("")).resolves.toContain("cannot be empty");
    await expect(validateCssSource("@import 'theme.css';")).resolves.toContain("cannot import");
    await expect(validateCssSource(".hero { background: url('/hero.png'); }")).resolves.toContain(
      "cannot load URL resources",
    );
    await expect(validateCssSource("<style>.hero { color: red; }</style>")).resolves.toContain(
      "plain CSS",
    );
  });
});
