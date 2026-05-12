let initialHtml =
  "<main class=\"profile-page\" data-vibespace-id=\"profile-root\">\n" ++
  "  <div class=\"profile-banner\" data-vibespace-id=\"profile-banner\">WELCOME TO MY HTML + CSS PROFILE - CLICK ANYTHING</div>\n" ++
  "  <section class=\"hero-panel\" data-vibespace-id=\"hero\">\n" ++
  "    <p class=\"eyebrow\" data-vibespace-id=\"hero-eyebrow\">vibespace.local/~pixelcassette - agent editable markup</p>\n" ++
  "    <h1 data-vibespace-id=\"profile-title\">Pixel Cassette</h1>\n" ++
  "    <p class=\"tagline\" data-vibespace-id=\"profile-tagline\">Glitter-coded layouts, midnight playlists, and hand-built web shrines.</p>\n" ++
  "    <div class=\"sparkle-row\" data-vibespace-id=\"sparkle-row\"><span>HTML</span><span>CSS</span><span>AGENT</span><span>PREVIEW</span></div>\n" ++
  "  </section>\n" ++
  "  <section class=\"profile-grid\" data-vibespace-id=\"profile-grid\">\n" ++
  "    <aside class=\"profile-card\" data-vibespace-id=\"profile-card\">\n" ++
  "      <div class=\"avatar\" data-vibespace-id=\"avatar\">PC</div>\n" ++
  "      <h2 data-vibespace-id=\"display-name\">Cass</h2>\n" ++
  "      <p data-vibespace-id=\"mood\"><strong>Mood:</strong> rebuilding the web by hand</p>\n" ++
  "      <p data-vibespace-id=\"status\"><strong>Status:</strong> online and rearranging pixels</p>\n" ++
  "      <div class=\"contact-box\" data-vibespace-id=\"contact-box\"><button>message</button><button>add vibe</button><button>view css</button></div>\n" ++
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
  "      <div class=\"sticker-wall\" data-vibespace-id=\"sticker-wall\"><span>NO TEMPLATES</span><span>RAW CSS</span><span>LOUD PAGES</span></div>\n" ++
  "    </article>\n" ++
  "    <article class=\"music-box\" data-vibespace-id=\"music-box\">\n" ++
  "      <h2 data-vibespace-id=\"music-title\">Now playing</h2>\n" ++
  "      <p data-vibespace-id=\"music-copy\">Pixel Cassette - Source of Truth Mix</p>\n" ++
  "      <div class=\"equalizer\" data-vibespace-id=\"equalizer\"><i></i><i></i><i></i><i></i><i></i></div>\n" ++
  "    </article>\n" ++
  "  </section>\n" ++
  "</main>"

let initialCss =
  ":root { color-scheme: light; }\n" ++
  "body { margin: 0; font-family: Verdana, Arial, sans-serif; background: #101018; color: #1a1720; }\n" ++
  ".profile-page { min-height: 100vh; padding: 28px; background: radial-gradient(circle at 12% 12%, #fff200 0 7%, transparent 8%), radial-gradient(circle at 86% 18%, #00f5d4 0 8%, transparent 9%), linear-gradient(135deg, #ff70a6, #70d6ff 42%, #b2f7ef 72%, #fff3b0); }\n" ++
  ".profile-banner { margin-bottom: 18px; padding: 10px 14px; border: 3px solid #231942; background: #101018; color: #fff200; font-size: 14px; font-weight: 900; text-align: center; box-shadow: 6px 6px 0 #ff70a6; }\n" ++
  ".hero-panel { border: 5px double #231942; background: rgba(255,255,255,.86); padding: 24px; box-shadow: 12px 12px 0 #231942; }\n" ++
  ".eyebrow { margin: 0 0 8px; font-size: 12px; letter-spacing: .08em; text-transform: uppercase; color: #6f2dbd; }\n" ++
  "h1 { margin: 0; font-size: 64px; color: #231942; text-shadow: 4px 4px 0 #ff70a6, 8px 8px 0 #fff200; }\n" ++
  ".tagline { max-width: 720px; font-size: 18px; line-height: 1.5; }\n" ++
  ".sparkle-row { display: flex; flex-wrap: wrap; gap: 10px; margin-top: 18px; }\n" ++
  ".sparkle-row span { padding: 8px 12px; border: 2px solid #231942; background: #00f5d4; color: #231942; font-weight: 900; box-shadow: 4px 4px 0 #ff70a6; }\n" ++
  ".profile-grid { display: grid; grid-template-columns: 240px 1fr 1fr; gap: 18px; margin-top: 24px; align-items: stretch; }\n" ++
  ".profile-card, .about-box, .interests-box, .custom-box { border: 3px solid #231942; background: rgba(255,255,255,.9); padding: 18px; box-shadow: 6px 6px 0 rgba(35,25,66,.85); }\n" ++
  ".profile-card { grid-row: span 2; background: #fff3b0; }\n" ++
  ".avatar { width: 128px; height: 128px; border-radius: 14px; display: grid; place-items: center; margin-bottom: 12px; background: conic-gradient(from 45deg, #ff70a6, #fff200, #00f5d4, #70d6ff, #ff70a6); border: 4px solid #231942; color: white; font-size: 42px; font-weight: 900; text-shadow: 2px 2px 0 #231942; }\n" ++
  ".contact-box { display: grid; gap: 8px; margin-top: 14px; }\n" ++
  ".contact-box button { border: 2px solid #231942; background: #ff70a6; color: white; font-weight: 900; padding: 7px; text-transform: uppercase; }\n" ++
  "h2 { margin-top: 0; color: #6f2dbd; }\n" ++
  ".custom-box { grid-column: span 2; background: #e4c1f9; }\n" ++
  ".sticker-wall { display: flex; flex-wrap: wrap; gap: 10px; margin-top: 14px; }\n" ++
  ".sticker-wall span { transform: rotate(-2deg); display: inline-block; padding: 8px 10px; background: #fff200; border: 2px dashed #231942; font-weight: 900; }\n" ++
  ".sticker-wall span:nth-child(even) { transform: rotate(3deg); background: #00f5d4; }\n" ++
  ".music-box { grid-column: span 3; border: 3px solid #231942; background: #101018; color: white; padding: 18px; box-shadow: 6px 6px 0 #fff200; }\n" ++
  ".music-box h2 { color: #fff200; }\n" ++
  ".equalizer { display: flex; gap: 6px; align-items: end; height: 54px; margin-top: 12px; }\n" ++
  ".equalizer i { display: block; width: 22px; background: #00f5d4; border: 2px solid #fff; }\n" ++
  ".equalizer i:nth-child(1) { height: 22px; } .equalizer i:nth-child(2) { height: 42px; } .equalizer i:nth-child(3) { height: 30px; } .equalizer i:nth-child(4) { height: 50px; } .equalizer i:nth-child(5) { height: 36px; }\n" ++
  "li { margin: 8px 0; }\n" ++
  "[data-vibespace-selected=\"true\"] { outline: 4px solid #ff006e !important; outline-offset: 4px; }\n" ++
  "@media (max-width: 800px) { .profile-grid { grid-template-columns: 1fr; } .profile-card, .custom-box, .music-box { grid-column: auto; grid-row: auto; } h1 { font-size: 38px; } }"

let initialDocument = ProfileDocument.make(
  ~html=initialHtml,
  ~css=initialCss,
  ~updatedAt="2026-05-10T00:00:00.000Z",
)
