let initialHtml =
  "<main class=\"profile-page\" data-vibespace-id=\"profile-root\" data-vibespace-name=\"Whole Profile\" data-vibespace-description=\"The full customizable profile page\">\n" ++
  "  <section class=\"profile-intro\" data-vibespace-id=\"profile-intro\" data-vibespace-name=\"Intro Banner\" data-vibespace-description=\"Top profile area with image, title, and intro text\">\n" ++
  "    <div class=\"profile-photo\" data-vibespace-id=\"profile-photo\" data-vibespace-name=\"Profile Image\" data-vibespace-description=\"Square profile image placeholder\">\n" ++
  "      <span data-vibespace-id=\"profile-photo-initials\" data-vibespace-name=\"Profile Initials\" data-vibespace-description=\"Initials inside the profile image\">VS</span>\n" ++
  "    </div>\n" ++
  "    <div class=\"profile-copy\" data-vibespace-id=\"profile-copy\" data-vibespace-name=\"Intro Copy\" data-vibespace-description=\"Name and short profile description\">\n" ++
  "      <p class=\"profile-kicker\" data-vibespace-id=\"profile-kicker\" data-vibespace-name=\"Profile Link\" data-vibespace-description=\"Small label above the profile title\">vibespace.local/new</p>\n" ++
  "      <h1 data-vibespace-id=\"profile-title\" data-vibespace-name=\"Profile Title\" data-vibespace-description=\"Main name or profile headline\">Your profile page</h1>\n" ++
  "      <p class=\"profile-description\" data-vibespace-id=\"profile-description\" data-vibespace-name=\"Profile Description\" data-vibespace-description=\"Short intro paragraph for visitors\">A plain starting point for an agent-written profile. Select any area and describe the page you want.</p>\n" ++
  "    </div>\n" ++
  "  </section>\n" ++
  "  <section class=\"profile-sections\" data-vibespace-id=\"profile-sections\" data-vibespace-name=\"Profile Blocks\" data-vibespace-description=\"Grid of smaller editable profile sections\">\n" ++
  "    <article class=\"profile-section\" data-vibespace-id=\"about-section\" data-vibespace-name=\"About Card\" data-vibespace-description=\"Short bio or personal note card\">\n" ++
  "      <h2 data-vibespace-id=\"about-title\" data-vibespace-name=\"About Heading\" data-vibespace-description=\"Title for the about card\">About</h2>\n" ++
  "      <p data-vibespace-id=\"about-copy\" data-vibespace-name=\"About Text\" data-vibespace-description=\"Bio text inside the about card\">Write a short bio, a mood, a manifesto, or nothing at all.</p>\n" ++
  "    </article>\n" ++
  "    <article class=\"profile-section\" data-vibespace-id=\"links-section\" data-vibespace-name=\"Links Card\" data-vibespace-description=\"Small list of places or interests\">\n" ++
  "      <h2 data-vibespace-id=\"links-title\" data-vibespace-name=\"Links Heading\" data-vibespace-description=\"Title for the links card\">Links</h2>\n" ++
  "      <ul data-vibespace-id=\"links-list\" data-vibespace-name=\"Links List\" data-vibespace-description=\"List of profile links or interests\">\n" ++
  "        <li>website</li>\n" ++
  "        <li>shop</li>\n" ++
  "        <li>playlist</li>\n" ++
  "      </ul>\n" ++
  "    </article>\n" ++
  "    <article class=\"profile-section profile-section--wide\" data-vibespace-id=\"custom-section\" data-vibespace-name=\"Custom Zone\" data-vibespace-description=\"Wide section for a personal feature or experiment\">\n" ++
  "      <h2 data-vibespace-id=\"custom-title\" data-vibespace-name=\"Custom Heading\" data-vibespace-description=\"Title for the custom zone\">Custom zone</h2>\n" ++
  "      <p data-vibespace-id=\"custom-copy\" data-vibespace-name=\"Custom Text\" data-vibespace-description=\"Starter text for the custom zone\">This empty block is ready to become a shrine, flyer, portfolio, storefront teaser, or personal web page.</p>\n" ++
  "    </article>\n" ++
  "  </section>\n" ++
  "</main>"

let initialCss =
  ":root { color-scheme: light; }\n" ++
  "body { margin: 0; font-family: Inter, ui-sans-serif, system-ui, -apple-system, BlinkMacSystemFont, \"Segoe UI\", sans-serif; background: #ffffff; color: #111111; }\n" ++
  ".profile-page { min-height: 100vh; padding: 56px; background: #ffffff; }\n" ++
  ".profile-intro { max-width: 960px; margin: 0 auto; display: grid; grid-template-columns: 180px minmax(0, 1fr); gap: 36px; align-items: center; border: 1px solid #111111; padding: 28px; }\n" ++
  ".profile-photo { aspect-ratio: 1; border: 1px solid #111111; display: grid; place-items: center; background: repeating-linear-gradient(45deg, #ffffff 0 12px, #f4f4f4 12px 24px); }\n" ++
  ".profile-photo span { width: 86px; height: 86px; border: 1px solid #111111; display: grid; place-items: center; background: #ffffff; font-size: 28px; font-weight: 700; letter-spacing: 0; }\n" ++
  ".profile-kicker { margin: 0 0 10px; font-size: 12px; text-transform: uppercase; letter-spacing: .08em; }\n" ++
  "h1 { margin: 0; font-size: 54px; line-height: 1; letter-spacing: 0; }\n" ++
  ".profile-description { max-width: 620px; margin: 18px 0 0; font-size: 18px; line-height: 1.55; }\n" ++
  ".profile-sections { max-width: 960px; margin: 24px auto 0; display: grid; grid-template-columns: repeat(2, minmax(0, 1fr)); gap: 24px; }\n" ++
  ".profile-section { min-height: 180px; border: 1px solid #111111; padding: 24px; background: #ffffff; }\n" ++
  ".profile-section--wide { grid-column: 1 / -1; }\n" ++
  "h2 { margin: 0 0 12px; font-size: 18px; letter-spacing: 0; }\n" ++
  "p, li { font-size: 15px; line-height: 1.6; }\n" ++
  "ul { margin: 0; padding-left: 18px; }\n" ++
  "[data-vibespace-selected=\"true\"] { outline: 3px solid #111111 !important; outline-offset: 5px; }\n" ++
  "@media (max-width: 760px) { .profile-page { padding: 24px; } .profile-intro { grid-template-columns: 1fr; } .profile-photo { max-width: 220px; } h1 { font-size: 38px; } .profile-sections { grid-template-columns: 1fr; } }"

let initialDocument = ProfileDocument.make(
  ~html=initialHtml->HtmlSource.make,
  ~css=initialCss->CssSource.make,
)
