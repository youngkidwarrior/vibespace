# Searchable HTML Tag Notes

## main
Use once for the profile page root. Keep `data-vibespace-id="profile-root"` if it already exists.

## section
Use for major editable profile areas: hero, music, about, links, gallery, store teaser, shrine, or custom zones.
Add a short `data-vibespace-name` and `data-vibespace-description` when the section is meaningful.

## article
Use for self-contained cards or blocks inside the profile, such as a favorite song, post-like note, or featured object.
Add friendly metadata when the article should be selectable later.

## header
Use for title groups inside a section. Pair with headings and short descriptive copy.

## h1
Use for the primary profile title only. Avoid multiple `h1` elements in small edits.

## h2
Use for section titles such as About, Now Playing, Favorite Links, or Custom Zone.

## p
Use for readable body copy, captions, moods, descriptions, and user-provided text.

## ul
Use for lists of links, interests, tracks, items, credits, or small facts.

## a
Avoid links in generated profile HTML unless the runtime prompt explicitly provides a trusted-frame capability contract. Never invent remote URLs.

## img
Avoid raw remote images. Use trusted-image capability placeholders when `web_context.safeImages` provides image URLs. Write useful image metadata because Vibespace shows a fallback if the candidate image fails to load. Prefer designed placeholders only when no trusted asset is available.

## figure
Use for visual modules with a caption, such as album art, profile image, trusted image, or featured object.

## audio
Do not emit raw audio tags or direct audio URLs. If the user explicitly asked for live playback and web context provides a trusted-frame playable capability, use the inert `data-vibespace-capability` placeholder contract. Otherwise create a designed static now-playing block.

## button
Avoid real functional buttons inside generated profile HTML unless they are purely decorative; generated JavaScript is not allowed.
