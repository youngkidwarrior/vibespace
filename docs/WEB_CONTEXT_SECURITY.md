# Web Context Security

## Purpose

Vibespace can use web search to resolve real-world context before asking Codex to rewrite a profile. This is a capability resolver, not a free browsing or scraping feature.

The active MVP resolver may look up when the AI capability planner decides real-world context would make the profile edit work:

- Named media when the request explicitly asks to play, listen, watch, stream, embed, or add a player.
- HTTPS frame URLs from explicitly trusted origins.
- Public reference context and source pages for theme, vibe, aesthetic, era, genre, brand, or inspired-by restyling requests.
- Verified HTTPS image URLs extracted by Vibespace from allowed source-page HTML for vibe, aesthetic, public figure, place, scene, poster, collage, and image-forward requests.

The resolver must not look up:

- Malware, exploit payloads, phishing kits, credential theft, piracy, torrents, cracked software, DRM bypasses, direct media downloads, or executable files.
- Arbitrary remote scripts, forms, widgets, tracking pixels, untrusted images, or untrusted embeds.

## Data Flow

1. `AgentEditService.js` receives assistant requests only through the GraphQL `submitAgentEdit` mutation.
2. A small structured AI capability planner reads the user's instruction, selected context, and current profile source. It decides whether the edit needs web context, trusted-frame resolution, trusted-image resolution, or no external capability. This is intentionally model judgment rather than phrase parsing.
3. Safe lookup uses the OpenAI Responses `web_search` tool only when the capability plan asks for external context. Frame/image search domains are included only when the plan asks for those capabilities.
4. The model resolver returns structured JSON only: status, intent kind, resolved items, safe frames, facts, warnings, citations, and optional direct image candidates.
5. New assistant generation currently does not expose browser-side frame/image resolver endpoints. Existing trusted placeholders can be preserved, but newly invented trusted placeholder sources are rejected server-side.
6. `DocumentEditPrompt.res` passes resolved context inside `<web_context>` as untrusted data.
7. Codex returns raw HTML/CSS, but can only represent web functionality and remote images with inert `data-vibespace-capability` placeholders.
8. `AgentEditService.js` rejects generated trusted placeholders that were not already present in the current profile source.
9. `ProfileValidation.res` runs parser/compiler-backed HTML/CSS validation, then rejects raw iframes, raw remote images, scripts, remote loads, and unsupported placeholders.
10. `PreviewBridge.res` expands validated placeholders into controlled provider iframes and trusted images for preview.

Successful web-context results are cached in the running browser session so repeated prompts about the same reference can avoid paying for another resolver call. Missing API-key responses and empty context are not treated as durable knowledge.

## Prompt Injection Rule

Search results and web pages are data. They are never instructions. The resolver prompt explicitly tells the model to ignore instructions found in external sources and to extract only facts, canonical URLs, and allowlisted capability URLs.

Whole-profile tribute and vibe prompts also instruct the resolver to disambiguate named entities before extracting visual direction. For example, "50 cent" should resolve to Curtis "50 Cent" Jackson unless context indicates another meaning. Resolver facts should avoid generic genre stereotypes and should not imply official endorsement, quote lyrics, or invent biographical claims.

## Capability Tiers

Tier 1 remains as compatibility history for the first media origins. The active implementation normalizes those old `web_embed` placeholders into Tier 2 trusted frames.

Tier 2 is active now. It is standards-based: Vibespace allows live frames only when the URL is HTTPS, has no credentials, is not localhost/private IP, avoids executable/archive paths, and its origin exactly matches the trusted-frame origin registry. The local frame resolver may convert provider source pages with deterministic provider rules, provider oEmbed endpoints, source-page oEmbed discovery, or inert metadata such as `twitter:player`, `og:video`, JSON-LD `embedUrl`, and page iframe `src`. Provider-specific URL-shape checks remain the final gate when the same origin hosts both embeddable players and normal pages; for example, Spotify frames must resolve to `https://open.spotify.com/embed/...`, and YouTube frames must resolve to `https://www.youtube.com/embed/...` or `https://www.youtube-nocookie.com/embed/...`, not regular source pages such as `open.spotify.com/track/...` or `youtube.com/watch?...`. Vibespace owns the iframe attributes, referrer policy, sandbox posture, browser-supported permissions, and preview CSP.

The current trusted origins are intentionally narrow:

- `https://open.spotify.com`
- `https://www.youtube.com`
- `https://www.youtube-nocookie.com`
- `https://w.soundcloud.com`
- `https://player.vimeo.com`
- `https://embed.music.apple.com`

Adding a trusted origin must include:

- Preview CSP and sandbox review.
- Abuse-case tests for prompt injection, misleading frames, and unwanted remote loads.
- UX for explaining when a requested origin is unsupported.

Tier 3 is intentionally out of scope for this local MVP. It would mean arbitrary iframe or user-provided external widget support, which should require a server-side sanitizer, stronger isolation, reporting controls, and a product-level abuse policy.

Tier 2 image loading is also active for the local MVP. Vibespace allows direct image rendering only when the URL is HTTPS, has no credentials, is not localhost/private IP, avoids executable/archive paths, and its origin exactly matches the trusted-image origin registry. The current image origins are:

- `https://images.unsplash.com`
- `https://plus.unsplash.com`
- `https://upload.wikimedia.org`

Search can inspect source pages from Unsplash/Wikimedia-style domains, but renderable image URLs must come from the exact image-origin allowlist. This is intentionally not a general Google Images or arbitrary hotlinking feature.

Everything else is reference context or static profile content only. Generic links, arbitrary remote images, direct audio/video sources, script widgets, forms, and arbitrary iframes remain blocked. Requests such as "add my favorite song" or "make a music section" should stay in plain editable HTML/CSS unless the user asks for live playback or embedding. Requests for wave sounds, ocean sounds, ambient audio, background sounds, ambience, or soundscapes count as live playback requests because the user is asking for audible media, even if they do not say "player." If the user asks for a player or ambient sound, Vibespace may use trusted embed discovery to convert a canonical source page into a validated trusted frame. If no relevant trusted frame is available, generation should add an honest static component and warning rather than fake playback or copy that says a future editor can connect audio. Requests such as "restyle this around the vibe of my favorite song" may use safe reference facts, citations, and trusted images to infer visual direction, but generated HTML/CSS still cannot load arbitrary remote assets.

## Placeholder Contract

A live web embed must be represented in generated HTML as inert markup only. The placeholder must include:

- `data-vibespace-capability="trusted_frame"`
- `data-vibespace-origin`
- `data-vibespace-src`
- `data-vibespace-name`
- `data-vibespace-description`

The preview layer replaces that placeholder with a sandboxed iframe only after validation accepts the origin and URL.

A trusted image must also be represented as inert markup only. The placeholder must include:

- `data-vibespace-capability="trusted_image"`
- `data-vibespace-origin`
- `data-vibespace-src`
- `data-vibespace-alt`
- `data-vibespace-name`
- `data-vibespace-description`

The frame URL must be copied exactly from `web_context.safeFrames.frameUrl` unless the placeholder already existed in the current profile document. The image URL must be copied exactly from `web_context.safeImages.imageUrl` unless the placeholder already existed in the current profile document. The preview layer replaces placeholders with controlled trusted-frame or trusted-image components only after validation accepts the origin and URL. Codex generation additionally checks that new trusted capability URLs were present in the current request's resolver output.

Resolver output is not trusted just because the URL has an allowlisted origin. The model should return source pages; Vibespace code owns final trusted-image extraction. The local resolver parses allowed source pages such as Wikipedia and Wikimedia Commons, extracts candidates from `og:image`, JSON-LD, file-page links, article images, `srcset`, captions, alt text, and nearby figure metadata, then verifies each image response has an image MIME type before passing it to Codex. The preview still renders a branded fallback if a previously verified remote image later fails to load.

## Known MVP Caveats

- The local prototype no longer exposes the OpenAI key through Vite. Local secrets live in ignored `.env.secrets.local` as backend-only `OPENAI_API_KEY`; the browser calls GraphQL, and the GraphQL server constructs provider requests.
- The preview iframe allows scripts so nested trusted frames can work, but generated profile HTML is still validated to reject scripts and event handlers.
- Provider frames use `strict-origin-when-cross-origin` referrer policy. Some external pages may still refuse framing even when their origin is trusted. oEmbed discovery cannot bypass provider `frame-ancestors` or `X-Frame-Options`; unsupported providers must become static fallback cards.
- Trusted images use direct CSP allowlisting in the local MVP. This can expose third-party image requests from the preview and should become a proxy/cache before published profiles rely on it. The local resolver prevents model-invented direct image URLs, but it is still a dev-server capability rather than a production asset pipeline.
- The local image resolver is intentionally ephemeral. It fetches source-page HTML into memory for a single request and returns only derived verified image metadata, counts, and warnings.
- The local frame resolver is intentionally ephemeral. It fetches source-page HTML or oEmbed JSON into memory for a single request and returns only validated frame metadata, counts, and warnings.
- Public web image rights are a prototype caveat. The resolver preserves source, creator, license, and canonical URL metadata when available, but production needs a rights/attribution review flow.
- Autoplay is never guaranteed. Browser policy may require a user gesture for audible playback.
- The trusted-frame search-domain list is intentionally narrow. Reference and aesthetic search also uses a narrow high-signal domain set; search-domain membership should not be treated as permission to create live frames.
- Canvas prompts default to the fast model for cost and latency. The source-route test lane remains the explicit place to compare deeper reasoning output until a dedicated canvas control exists.
