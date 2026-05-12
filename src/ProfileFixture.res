let initialHtml =
  "<main class=\"profile-page\" data-vibespace-id=\"profile-root\">\n" ++
  "  <section class=\"hero-panel\" data-vibespace-id=\"hero\">\n" ++
  "    <p class=\"eyebrow\" data-vibespace-id=\"hero-eyebrow\">vibespace.local/~pixelcassette</p>\n" ++
  "    <h1 data-vibespace-id=\"profile-title\">Pixel Cassette</h1>\n" ++
  "    <p class=\"tagline\" data-vibespace-id=\"profile-tagline\">Glitter-coded layouts, midnight playlists, and hand-built web shrines.</p>\n" ++
  "  </section>\n" ++
  "  <section class=\"profile-grid\" data-vibespace-id=\"profile-grid\">\n" ++
  "    <aside class=\"profile-card\" data-vibespace-id=\"profile-card\">\n" ++
  "      <div class=\"avatar\" data-vibespace-id=\"avatar\">PC</div>\n" ++
  "      <h2 data-vibespace-id=\"display-name\">Cass</h2>\n" ++
  "      <p data-vibespace-id=\"mood\"><strong>Mood:</strong> rebuilding the web by hand</p>\n" ++
  "      <p data-vibespace-id=\"status\"><strong>Status:</strong> online and rearranging pixels</p>\n" ++
  "    </aside>\n" ++
  "    <article class=\"about-box\" data-vibespace-id=\"about\">\n" ++
  "      <h2 data-vibespace-id=\"about-title\">About this page</h2>\n" ++
  "      <p data-vibespace-id=\"about-copy\">This fake profile is the test canvas. Ask the agent to restyle sections, rewrite layout blocks, or create a full custom theme using plain HTML and CSS.</p>\n" ++
  "    </article>\n" ++
  "    <article class=\"interests-box\" data-vibespace-id=\"interests\">\n" ++
  "      <h2 data-vibespace-id=\"interests-title\">Interests</h2>\n" ++
  "      <ul data-vibespace-id=\"interests-list\">\n" ++
  "        <li>hand-coded profile pages</li>\n" ++
  "        <li>CSS that looks like a mixtape cover</li>\n" ++
  "        <li>tiny shops with giant personalities</li>\n" ++
  "      </ul>\n" ++
  "    </article>\n" ++
  "    <article class=\"custom-box\" data-vibespace-id=\"custom-box\">\n" ++
  "      <h2 data-vibespace-id=\"custom-title\">Custom HTML zone</h2>\n" ++
  "      <p data-vibespace-id=\"custom-copy\">Turn this into anything: shrine, flyer, storefront teaser, zine page, or late-2000s chaos wall.</p>\n" ++
  "    </article>\n" ++
  "  </section>\n" ++
  "</main>"

let initialCss =
  ":root { color-scheme: light; }\n" ++
  "body { margin: 0; font-family: Verdana, Arial, sans-serif; background: #101018; color: #1a1720; }\n" ++
  ".profile-page { min-height: 100vh; padding: 28px; background: radial-gradient(circle at 20% 10%, #ffe45e 0 9%, transparent 10%), linear-gradient(135deg, #7bdff2, #f2b5d4 48%, #b2f7ef); }\n" ++
  ".hero-panel { border: 4px double #231942; background: rgba(255,255,255,.82); padding: 24px; box-shadow: 10px 10px 0 #231942; }\n" ++
  ".eyebrow { margin: 0 0 8px; font-size: 12px; letter-spacing: .08em; text-transform: uppercase; color: #6f2dbd; }\n" ++
  "h1 { margin: 0; font-size: 52px; color: #231942; text-shadow: 3px 3px 0 #ff70a6; }\n" ++
  ".tagline { max-width: 720px; font-size: 18px; line-height: 1.5; }\n" ++
  ".profile-grid { display: grid; grid-template-columns: 240px 1fr 1fr; gap: 18px; margin-top: 24px; align-items: stretch; }\n" ++
  ".profile-card, .about-box, .interests-box, .custom-box { border: 3px solid #231942; background: rgba(255,255,255,.9); padding: 18px; box-shadow: 6px 6px 0 rgba(35,25,66,.85); }\n" ++
  ".profile-card { grid-row: span 2; background: #fff3b0; }\n" ++
  ".avatar { width: 112px; height: 112px; border-radius: 10px; display: grid; place-items: center; margin-bottom: 12px; background: linear-gradient(135deg, #ff70a6, #70d6ff); border: 3px solid #231942; color: white; font-size: 36px; font-weight: 900; }\n" ++
  "h2 { margin-top: 0; color: #6f2dbd; }\n" ++
  ".custom-box { grid-column: span 2; background: #e4c1f9; }\n" ++
  "li { margin: 8px 0; }\n" ++
  "[data-vibespace-selected=\"true\"] { outline: 4px solid #ff006e !important; outline-offset: 4px; }\n" ++
  "@media (max-width: 800px) { .profile-grid { grid-template-columns: 1fr; } .profile-card, .custom-box { grid-column: auto; grid-row: auto; } h1 { font-size: 38px; } }"

let initialDocument = ProfileDocument.make(
  ~html=initialHtml,
  ~css=initialCss,
  ~updatedAt="2026-05-10T00:00:00.000Z",
)
