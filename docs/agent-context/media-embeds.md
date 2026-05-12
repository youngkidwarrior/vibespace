# Media And Embed Intent

Users often ask for outcomes, not implementation. Interpret media requests as profile modules. Named media by itself is a content/design request, not a live embed request.

Music:

- If the user names media without explicit live language, create a polished static now-playing or favorite-media block in plain HTML/CSS.
- If the user clearly asks for playable media or a player and web context includes a trusted frame, represent the working placeholder first, then style the surrounding block.
- Requests for ambient audio, wave sounds, ocean sounds, background sounds, soundscapes, or ambience count as explicit live media requests. Use a trusted frame when one is available.
- If an explicit live request has no trusted frame, create a polished static fallback and explain the limitation in warnings.
- Include title, artist, album-art placeholder, play-state styling, and track metadata when useful.
- Do not invent a real playable source, direct audio URL, pirated stream, or download.
- Do not output raw `<audio>`, `<iframe>`, `<embed>`, or remote media URLs. Use only a resolved `data-vibespace-capability` placeholder.

Trusted frame contract:

- Use `data-vibespace-capability="trusted_frame"`.
- Copy `data-vibespace-origin` and `data-vibespace-src` exactly from `web_context.safeFrames`.
- Include `data-vibespace-name` and `data-vibespace-description` so selection and screenshots remain agent-readable.
- Include short fallback text inside the placeholder for source readability.
- User-provided source URLs are useful context, but generated HTML must use the resolved trusted-frame placeholder. Do not scrape, rewrite, or invent embed URLs inside the profile patch.

Images:

- If web context includes trusted images, use at least one prominently when it helps the request feel real.
- Use `data-vibespace-capability="trusted_image"` and copy `data-vibespace-origin`, `data-vibespace-src`, and alt text exactly from `web_context.safeImages`.
- Do not emit raw `<img src="https://...">` or CSS `url(https://...)`; style trusted image placeholders as heroes, posters, collages, profile photos, or scene panels.
- For GIF, moving waves, animated background, or motion-background requests, prefer a verified animated trusted image when `web_context.safeImages` includes one. If no animated image is available, use a trusted beach/ocean image plus CSS motion layers and explain the limitation in warnings.
- Trusted image URLs are candidates and may fail to load. Write strong `data-vibespace-name`, `data-vibespace-description`, `data-vibespace-alt`, and surrounding frame/caption copy so the Vibespace fallback still feels deliberate.
- If the selected area is a broken trusted image fallback and the user asks to retry, focus on replacing that one image instead of restyling the whole page.
- If no trusted image is available, create a tasteful placeholder or frame ready for a future upload and explain the limitation in warnings.

Video:

- If the user clearly asks to watch, embed, or add a video player and web context includes a trusted frame, use the placeholder contract. Otherwise use a poster-style module or safe static treatment.

Products:

- For store-like requests, create a featured item or tiny catalog teaser using static HTML/CSS placeholders.

Examples:

- `add my favorite song, P.I.M.P by 50 Cent` -> static music card, no trusted-frame capability.
- `make my favorite song playable` -> trusted-frame capability may be used if web context provides one.
- `include wave sounds` -> trusted-frame capability should be used if web context provides one.
- `restyle around my favorite song` -> use safe reference context and trusted images when available.
- `embed this video` -> trusted-frame capability may be used if web context provides one.
- `add a beach gif with moving waves` -> trusted-image capability should be used if an animated trusted image is available; otherwise use static trusted imagery plus CSS motion.
- `make a section for albums I like` -> static HTML/CSS section.

When uncertain, prefer editable static HTML/CSS and make it visually impressive.
