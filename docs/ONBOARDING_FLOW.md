# Vibespace Invite Onboarding Vision

## Product Shape

Vibespace starts through an invite link. Opening `/invite/:code` should show a
modal that confirms the user wants to redeem the invite. For this MVP, the invite
is redeemed immediately after confirmation, so abandoning onboarding still
consumes the invite and leaves behind a valid default profile.

After redemption, onboarding captures a first profile vibe before sending the
starter profile prompt to the existing generative UI pipeline. Uploaded photos
are browser-only model context. They are not saved to the database and should not
be embedded into the profile unless a later product decision changes that.

## Flow

1. Invite confirmation modal.
   - Shows inviter context when available.
   - Confirming calls `redeemInvite`.
   - The backend allocates the next numeric handle, starting at `0`.
   - The signed local session token is the temporary MVP account key.
   - `LocalViewerSession` saves the key to localStorage and a SameSite=Lax
     browser cookie, then the invite UI attempts to copy it to the clipboard.
   - Onboarding shows the account key so the user can manually save or copy it.
   - Reloading `/invite/:code` with the cookie/key present resumes onboarding for
     the redeemed invite instead of showing the invite as already claimed.

2. Vibe choice.
   - Top copy: `Welcome to vibespace.`
   - Letters should subtly float up and down.
   - Two empty polaroids sit side by side.
   - Left label starts as `I like people`.
   - Right label starts as `I like nature`.
   - Selecting people reveals a laughing Mardi Gras-style mask face and changes
     the label to `Show off a picture of you`.
   - Selecting nature reveals a green leaf and changes the label to
     `Show a picture of a beautiful place`.

3. Photo upload.
   - The selected polaroid supports click upload and drag/drop.
   - The image stays in browser memory as a data URL.
   - The image is sent to the model as onboarding reference context only.

4. Questions.
   - Favorite song.
   - Likes.
   - Dislikes.
   - Freeform vibe note.
   - Final profile name.
   - Optional Sendtag. Accept `Blusy19` or `/Blusy19`; validate it with Send's
     public `profile_lookup` RPC before profile generation; persist only the
     normalized tag on the profile so Send remains the avatar source of truth.
   - Do not ask the user for a handle.

5. Starter profile generation.
   - The frontend sends the default profile HTML/CSS, onboarding answers, mode,
     profile name, optional Sendtag, and image data URL to the existing assistant
     edit pipeline.
   - The backend updates the profile/user display name from the final profile
     name and creates an agent profile version.
   - On success, route to the editor.

## Prompt Templates

### People Photo

Analyze the uploaded image as emotional and social context for a first Vibespace
profile. Capture expression, energy, confidence, color, pose, setting, and social
vibe. Build a starter page that feels like the person's online room, not a
generic social profile. Prioritize warmth, identity, emotional truth, and
tasteful Myspace-inspired personality. Do not claim facts not visible in the
image or provided answers.

### Nature Photo

Analyze the uploaded image as atmosphere, palette, place, weather, light, and
energy. Match the profile's colors, texture, rhythm, and mood to the scene. Build
a starter page that feels like entering that place. Prioritize color harmony,
ambient feeling, composition, and environmental details. Do not invent exact
location unless the user provided it.

## Phases

- [x] Document the onboarding vision and implementation phases.
- [x] Redeem invite immediately from a confirmation modal.
- [x] Generate numeric handles server-side.
- [x] Build the polaroid choice and upload UI.
- [x] Ask the first vibe questions.
- [x] Pass onboarding prompt/image context to Codex.
- [x] Update the profile title/display name from the final profile name.
- [x] Show a ready state with a path back to the editor after starter generation.
- [x] Persist and show the local MVP account key so users can resume onboarding.

## TODOs

- Add a true account recovery/auth system before external users. The current
  frontend-readable cookie is only an internal MVP fallback.
- Decide whether uploaded onboarding photos can become trusted profile assets.
- Tune the prompt templates after observing generated starter profiles.
- Add progress states if starter generation takes too long.
