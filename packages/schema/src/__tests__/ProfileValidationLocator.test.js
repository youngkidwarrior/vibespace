import { describe, expect, it } from "vitest";
import { locateValidationProblem } from "../ProfileValidationLocator.js";

describe("locateValidationProblem", () => {
  it("returns null for empty input", () => {
    expect(locateValidationProblem({ html: "", css: "", message: "" })).toBeNull();
    expect(locateValidationProblem({ html: "<main></main>", css: "", message: "" })).toBeNull();
  });

  it("locates the first disallowed aria-label tag in HTML", () => {
    const html = [
      "<main>",
      "<button aria-label=\"Allowed\">go</button>",
      "<section class=\"rest\" aria-label=\"Profile content\">",
      "<p>copy</p>",
      "</section>",
      "</main>",
    ].join("");

    const result = locateValidationProblem({
      html,
      css: "",
      message: "\"aria-label\" cannot be used on this element.",
    });

    expect(result).not.toBeNull();
    expect(result.source).toBe("html");
    expect(result.tagName).toBe("section");
    expect(html.slice(result.charStart, result.charEnd)).toContain("aria-label=\"Profile content\"");
  });

  it("keeps role-allowed aria-label tags untouched", () => {
    const html = "<main><div role=\"region\" aria-label=\"hero\"></div></main>";
    expect(
      locateValidationProblem({
        html,
        css: "",
        message: "\"aria-label\" cannot be used on this element.",
      }),
    ).toBeNull();
  });

  it("locates the first inline style url() tag", () => {
    const html = "<main><div class=\"a\"></div><span style=\"color:red\">x</span></main>";
    const result = locateValidationProblem({
      html,
      css: "",
      message: "Move visual rules into Profile look.",
    });

    expect(result).not.toBeNull();
    expect(result.tagName).toBe("span");
    expect(html.slice(result.charStart, result.charEnd)).toContain("style=\"color:red\"");
  });

  it("converts html-validate line/column to a char range", () => {
    const html = "<main>\n  <bogus></bogus>\n</main>";
    const result = locateValidationProblem({
      html,
      css: "",
      message: "Profile content has invalid HTML at line 2, column 3: Unknown tag.",
    });

    expect(result).not.toBeNull();
    expect(result.source).toBe("html");
    expect(result.line).toBe(2);
    expect(html.slice(result.charStart, result.charEnd)).toContain("<bogus>");
  });

  it("converts CSS line/column references to a char range", () => {
    const css = ".a{color:red}\n.b{display:flex}\n@import bad;";
    const result = locateValidationProblem({
      html: "",
      css,
      message: "Profile look has invalid CSS at line 3, column 1: unsupported.",
    });

    expect(result).not.toBeNull();
    expect(result.source).toBe("css");
    expect(result.line).toBe(3);
  });

  it("returns null when the message is unrecognized", () => {
    expect(
      locateValidationProblem({
        html: "<main></main>",
        css: "",
        message: "Some new error message we have not seen yet.",
      }),
    ).toBeNull();
  });
});
