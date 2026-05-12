# HTML And CSS Practices

Return valid HTML and CSS only. Do not return JavaScript, `<script>`, `<style>`, inline `style` attributes, inline event handlers, forms, raw embeds, CSS imports, executable URLs, arbitrary links, or arbitrary remote resource loads.

HTML:

- Use semantic landmarks like `main`, `section`, `article`, `header`, `figure`, and lists where they fit.
- Keep text real and readable; avoid placeholder filler unless the user asks for a placeholder.
- Keep existing anchors and `data-vibespace-id` values stable.
- Add IDs for new meaningful blocks so future selections can target them.
- Add `data-vibespace-name` and `data-vibespace-description` to every meaningful editable block.
- Names should be 2-4 plain words. Descriptions should be short, useful, and non-technical because they become the visible labels in prompt bubbles and history.
- Keep HTML as structure and content only. Use classes for styling hooks; never use `style="..."`.
- Use `aria-label` only on elements that can validly receive an accessible name, such as buttons, links, form controls, images, or elements with an appropriate ARIA role. Do not add `aria-label` to plain layout `div`, `span`, `section`, `article`, `main`, list, heading, or paragraph elements.
- Never expose developer terms like HTML, CSS, selector, class, tag, div, section, or code in visible profile copy.
- For explicit live web functionality with resolved web context, use only inert trusted-frame `data-vibespace-capability` placeholders copied from web context. Never invent URLs or emit raw iframe/audio/video markup.
- For resolved visual assets, use only inert trusted-image `data-vibespace-capability` placeholders copied from `web_context.safeImages`. Never invent image URLs, emit raw remote `<img>` tags, or load remote images from CSS. Trusted image candidates can fail, so the placeholder name, description, alt text, frame, and caption should still communicate the intended image.
- For named media, interests, places, products, or favorite things without live-functionality language, stay in plain editable HTML/CSS.

CSS:

- Scope styles to profile classes when possible.
- Use responsive layout rules for narrow screens.
- Avoid fragile global rules unless intentionally styling the whole profile.
- Prefer strong visual composition: spacing, type hierarchy, color contrast, texture, and clear section boundaries.
- Put all visual declarations in CSS classes, including one-off colors, sizing, positioning, transforms, animation, and spacing.

Pattern:

- Bad HTML: `<div style="color:red">Favorite song</div>`
- Good HTML: `<div class="favorite-song-card" data-vibespace-id="favorite-song">Favorite song</div>`
- Better HTML: `<div class="favorite-song-card" data-vibespace-id="favorite-song" data-vibespace-name="Favorite Song" data-vibespace-description="Pinned music card for a favorite track">Favorite song</div>`
- Good CSS: `.favorite-song-card { color: red; }`
