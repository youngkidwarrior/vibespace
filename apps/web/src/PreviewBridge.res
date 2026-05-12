let escapeAttribute = value =>
  value
  ->String.replaceAll("&", "&amp;")
  ->String.replaceAll("\"", "&quot;")
  ->String.replaceAll("<", "&lt;")
  ->String.replaceAll(">", "&gt;")

@val external encodeURIComponent: string => string = "encodeURIComponent"

type inviteChainFriend = {
  id: string,
  displayName: string,
  profileSlug: string,
  profileTitle: string,
  avatarInitials: string,
  avatarColor: string,
  avatarUrl: option<string>,
}

type inviteChainFriends = {friends: array<inviteChainFriend>}

type ownerProfileImage = {
  displayName: string,
  avatarUrl: option<string>,
}

type url

@new external makeUrl: string => url = "URL"
@get external urlOrigin: url => string = "origin"
@get external urlProtocol: url => string = "protocol"

let selectedIdToString = selectedId =>
  switch selectedId {
  | Some(id) => id->ProfileElementId.toString
  | None => ""
  }

let escapeJsString = value =>
  value
  ->String.replaceAll("\\", "\\\\")
  ->String.replaceAll("\"", "\\\"")
  ->String.replaceAll("\n", "\\n")
  ->String.replaceAll("\r", "\\r")

let jsString = value => "\"" ++ value->escapeJsString ++ "\""

let safeHttpsOrigin = value =>
  try {
    let url = value->makeUrl
    url->urlProtocol == "https:" ? Some(url->urlOrigin) : None
  } catch {
  | _ => None
  }

let firstInitial = value => value->String.trim->String.slice(~start=0, ~end=1)->String.toUpperCase

let ownerInitials = displayName => {
  let parts = displayName->String.trim->String.split(" ")->Array.filter(part => part != "")
  let initials =
    parts->Array.get(0)->Option.mapOr("", firstInitial) ++
    parts->Array.get(1)->Option.mapOr("", firstInitial)

  initials == "" ? "VS" : initials
}

let previewScriptNonce = "vibespace-preview"

let trustedImageRuntimeScript =
  "(() => {\n" ++
  "  const mark = (image, state) => {\n" ++
  "    const wrapper = image.closest('[data-vibespace-capability=\"trusted_image\"]');\n" ++
  "    if (!wrapper) return;\n" ++
  "    wrapper.setAttribute('data-vibespace-image-state', state);\n" ++
  "  };\n" ++
  "  document.querySelectorAll('[data-vibespace-trusted-image-img=\"true\"]').forEach((image) => {\n" ++
  "    if (image.complete) {\n" ++
  "      mark(image, image.naturalWidth > 0 && image.naturalHeight > 0 ? 'loaded' : 'broken');\n" ++
  "    }\n" ++
  "    image.addEventListener('load', () => mark(image, 'loaded'));\n" ++
  "    image.addEventListener('error', () => mark(image, 'broken'));\n" ++
  "  });\n" ++
  "})();"

let systemFriendsRuntimeScript =
  "(() => {\n" ++
  "  const friends = document.querySelector('[data-vibespace-system-component=\"invite-chain-friends\"]');\n" ++
  "  const root = document.querySelector('[data-vibespace-id=\"profile-root\"]');\n" ++
  "  if (friends && root && friends.parentElement !== root) root.appendChild(friends);\n" ++
  "  if (!friends) return;\n" ++
  "  friends.querySelectorAll('.vibespace-system-friends__avatar-img').forEach((image) => {\n" ++
  "    const avatar = image.closest('.vibespace-system-friends__avatar');\n" ++
  "    const markLoaded = () => avatar && avatar.setAttribute('data-vibespace-avatar-state', 'loaded');\n" ++
  "    const fallback = () => {\n" ++
  "      image.remove();\n" ++
  "      if (avatar) avatar.setAttribute('data-vibespace-avatar-state', 'fallback');\n" ++
  "    };\n" ++
  "    if (image.complete) {\n" ++
  "      image.naturalWidth > 0 && image.naturalHeight > 0 ? markLoaded() : fallback();\n" ++
  "    }\n" ++
  "    image.addEventListener('load', markLoaded);\n" ++
  "    image.addEventListener('error', fallback);\n" ++
  "  });\n" ++
  "})();"

let systemOwnerImageRuntimeScript = ownerImage =>
  switch ownerImage {
  | None => ""
  | Some(ownerImage) =>
    let displayName = ownerImage.displayName
    let avatarUrl = ownerImage.avatarUrl->Option.getOr("")
    let initials = displayName->ownerInitials

    "(() => {\n" ++
    "  const displayName = " ++ displayName->jsString ++ ";\n" ++
    "  const avatarUrl = " ++ avatarUrl->jsString ++ ";\n" ++
    "  const initials = " ++ initials->jsString ++ ";\n" ++
    "  document.querySelectorAll('[data-vibespace-system-component=\"owner-profile-image\"]').forEach((slot) => {\n" ++
    "    slot.classList.add('vibespace-system-owner-image');\n" ++
    "    slot.setAttribute('data-vibespace-system-ready', 'true');\n" ++
    "    const fallback = () => {\n" ++
    "      slot.setAttribute('data-vibespace-owner-image-state', 'fallback');\n" ++
    "      if (!slot.textContent.trim()) slot.textContent = initials;\n" ++
    "    };\n" ++
    "    if (!avatarUrl) {\n" ++
    "      fallback();\n" ++
    "      return;\n" ++
    "    }\n" ++
    "    const image = document.createElement('img');\n" ++
    "    image.className = 'vibespace-system-owner-image__img';\n" ++
    "    image.src = avatarUrl;\n" ++
    "    image.alt = displayName ? `${displayName} profile image` : 'Profile image';\n" ++
    "    image.loading = 'lazy';\n" ++
    "    image.decoding = 'async';\n" ++
    "    image.addEventListener('load', () => slot.setAttribute('data-vibespace-owner-image-state', 'loaded'));\n" ++
    "    image.addEventListener('error', () => {\n" ++
    "      image.remove();\n" ++
    "      fallback();\n" ++
    "    });\n" ++
    "    slot.replaceChildren(image);\n" ++
    "  });\n" ++
    "})();"
  }

let systemFriendsCss =
  ".vibespace-system-friends { all: initial; display: block; max-width: 980px; margin: 28px auto 0; padding: 0 24px 44px; box-sizing: border-box; color: #111827; font-family: Inter, ui-sans-serif, system-ui, -apple-system, BlinkMacSystemFont, \"Segoe UI\", sans-serif; }\n" ++
  ".vibespace-system-friends *, .vibespace-system-friends *::before, .vibespace-system-friends *::after { box-sizing: border-box; }\n" ++
  ".vibespace-system-friends__panel { display: block; border: 1px solid rgba(17, 24, 39, .16); border-radius: 16px; background: rgba(255, 255, 255, .88); padding: 18px; box-shadow: 0 18px 48px rgba(0, 0, 0, .18); backdrop-filter: blur(14px); }\n" ++
  ".vibespace-system-friends__header { display: flex; align-items: baseline; justify-content: space-between; gap: 12px; margin: 0 0 14px; }\n" ++
  ".vibespace-system-friends__title { margin: 0; color: #111827; font-size: 16px; line-height: 1.1; font-weight: 900; letter-spacing: 0; }\n" ++
  ".vibespace-system-friends__count { color: rgba(17, 24, 39, .58); font-size: 11px; line-height: 1; font-weight: 800; text-transform: uppercase; letter-spacing: .08em; }\n" ++
  ".vibespace-system-friends__grid { display: grid; grid-template-columns: repeat(6, minmax(0, 1fr)); gap: 14px; margin: 0; padding: 0; list-style: none; }\n" ++
  ".vibespace-system-friends__item { min-width: 0; text-align: center; }\n" ++
  ".vibespace-system-friends__avatar { position: relative; display: grid; place-items: center; width: 100%; aspect-ratio: 1; border-radius: 10px; border: 1px solid rgba(255, 255, 255, .56); color: #fff; text-decoration: none; font-size: clamp(18px, 4vw, 34px); line-height: 1; font-weight: 950; letter-spacing: 0; box-shadow: inset 0 0 0 1px rgba(0, 0, 0, .22), 0 10px 24px rgba(0, 0, 0, .16); overflow: hidden; }\n" ++
  ".vibespace-system-friends__avatar:focus-visible { outline: 3px solid #2563eb; outline-offset: 3px; }\n" ++
  ".vibespace-system-friends__avatar-fallback { position: relative; z-index: 1; }\n" ++
  ".vibespace-system-friends__avatar-img { position: absolute; inset: 0; z-index: 2; display: block; width: 100%; height: 100%; object-fit: cover; }\n" ++
  ".vibespace-system-friends__name { display: block; margin-top: 7px; overflow: hidden; color: #111827; text-decoration: none; text-overflow: ellipsis; white-space: nowrap; font-size: 12px; line-height: 1.2; font-weight: 800; letter-spacing: 0; }\n" ++
  ".vibespace-system-friends__empty { margin: 0; color: rgba(17, 24, 39, .62); font-size: 13px; line-height: 1.5; font-weight: 700; }\n" ++
  "@media (max-width: 760px) { .vibespace-system-friends { padding: 0 16px 32px; } .vibespace-system-friends__grid { grid-template-columns: repeat(3, minmax(0, 1fr)); } }\n"

let systemOwnerImageCss =
  "[data-vibespace-system-component=\"owner-profile-image\"] { display: grid; place-items: center; overflow: hidden; min-width: 72px; min-height: 72px; color: currentColor; font-weight: 950; letter-spacing: 0; text-align: center; }\n" ++
  ".vibespace-system-owner-image__img { display: block; width: 100%; height: 100%; min-height: inherit; object-fit: cover; }\n"

let friendProfileHref = slug => "/u/" ++ slug->encodeURIComponent

let friendCardHtml = (friend: inviteChainFriend) => {
  let href = friend.profileSlug->friendProfileHref->escapeAttribute
  let displayName = friend.displayName->escapeAttribute
  let profileTitle = friend.profileTitle->escapeAttribute
  let avatarInitials = friend.avatarInitials->escapeAttribute
  let avatarColor = friend.avatarColor->escapeAttribute
  let ariaLabel = ("Visit " ++ friend.displayName ++ "'s profile")->escapeAttribute
  let avatarImage = switch friend.avatarUrl {
  | Some(avatarUrl) =>
    "          <img class=\"vibespace-system-friends__avatar-img\" src=\"" ++
    avatarUrl->escapeAttribute ++
    "\" alt=\"\" loading=\"lazy\" decoding=\"async\" />\n"
  | None => ""
  }

  "      <li class=\"vibespace-system-friends__item\" data-vibespace-friend-id=\"" ++
  friend.id->escapeAttribute ++ "\">\n" ++
  "        <a class=\"vibespace-system-friends__avatar\" href=\"" ++ href ++ "\" target=\"_top\" rel=\"noopener\" aria-label=\"" ++
  ariaLabel ++ "\" title=\"" ++ profileTitle ++ "\" style=\"background:" ++ avatarColor ++ "\">\n" ++
  "          <span class=\"vibespace-system-friends__avatar-fallback\">" ++ avatarInitials ++ "</span>\n" ++
  avatarImage ++
  "        </a>\n" ++
  "        <a class=\"vibespace-system-friends__name\" href=\"" ++ href ++ "\" target=\"_top\" rel=\"noopener\">" ++
  displayName ++ "</a>\n" ++
  "      </li>\n"
}

let systemFriendsHtml = (friendsList: option<inviteChainFriends>) =>
  switch friendsList {
  | None => ""
  | Some({friends}) =>
    let count = friends->Array.length
    let countLabel = count->Int.toString ++ (count == 1 ? " friend" : " friends")
    let content = if count == 0 {
      "    <p class=\"vibespace-system-friends__empty\">No friends in the chain yet.</p>\n"
    } else {
      "    <ul class=\"vibespace-system-friends__grid\" aria-label=\"Invite-chain friends\">\n" ++
      friends->Array.map(friendCardHtml)->Array.join("") ++
      "    </ul>\n"
    }

    "<aside class=\"vibespace-system-friends\" data-vibespace-system-component=\"invite-chain-friends\" aria-label=\"Friends\">\n" ++
    "  <section class=\"vibespace-system-friends__panel\">\n" ++
    "    <div class=\"vibespace-system-friends__header\">\n" ++
    "      <h2 class=\"vibespace-system-friends__title\">Friends</h2>\n" ++
    "      <span class=\"vibespace-system-friends__count\">" ++ countLabel->escapeAttribute ++ "</span>\n" ++
    "    </div>\n" ++
    content ++
    "  </section>\n" ++
    "</aside>\n"
  }

let ownerImageCspSource = ownerImage =>
  switch ownerImage {
  | Some({avatarUrl: Some(avatarUrl)}) =>
    switch avatarUrl->safeHttpsOrigin {
    | Some(origin) => " " ++ origin->escapeAttribute
    | None => ""
    }
  | Some({avatarUrl: None}) | None => ""
  }

let friendsImageCspSource = friendsList =>
  switch friendsList {
  | Some({friends}) =>
    friends
    ->Array.filterMap(friend => friend.avatarUrl->Option.flatMap(safeHttpsOrigin))
    ->Array.map(origin => " " ++ origin->escapeAttribute)
    ->Array.join("")
  | None => ""
  }

let buildPreviewDocument = (
  html: HtmlSource.t,
  css: CssSource.t,
  selectedId: option<ProfileElementId.t>,
  editMode,
  friendsList: option<inviteChainFriends>,
  ownerImage: option<ownerProfileImage>,
) => {
  // TODO(public-render-security): This preview CSP is defense-in-depth for the
  // editor iframe. Public profile rendering must rely on server validation and
  // persisted valid versions, not CSP as the canonical sanitizer.
  let expandedHtml = html->HtmlSource.toString->WebCapabilities.expandWebCapabilityPlaceholders
  let selectedId = selectedId->selectedIdToString->escapeAttribute
  let editMode = editMode ? "true" : "false"
  "<!doctype html>\n" ++
  "<html>\n" ++
  "<head>\n" ++
  "  <meta charset=\"UTF-8\" />\n" ++
  "  <meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\" />\n" ++
  "  <meta name=\"referrer\" content=\"strict-origin-when-cross-origin\" />\n" ++
  "  <meta http-equiv=\"Content-Security-Policy\" content=\"default-src 'none'; style-src 'unsafe-inline'; img-src data: blob: " ++
  WebCapabilities.trustedImageCspSourceList ++
  friendsList->friendsImageCspSource ++
  ownerImage->ownerImageCspSource ++
  "; frame-src " ++
  WebCapabilities.trustedFrameCspSourceList ++
  "; base-uri 'none'; form-action 'none'; connect-src 'none'; media-src 'none'; font-src 'none'; script-src 'nonce-" ++
  previewScriptNonce ++
  "';\" />\n" ++
  "  <style>\n" ++
  "    " ++ css->CssSource.toString ++ "\n" ++
  "    " ++ WebCapabilities.webCapabilityCss() ++ "\n" ++
  "    " ++ systemFriendsCss ++ "\n" ++
  "    " ++ systemOwnerImageCss ++ "\n" ++
  "    [data-vibespace-hover=\"true\"] { outline: 2px dashed #38f8ff !important; outline-offset: 4px; box-shadow: 0 0 0 2px rgba(0,0,0,.92), 0 0 0 5px rgba(255,255,255,.94), 0 0 18px rgba(56,248,255,.86) !important; cursor: crosshair; }\n" ++
  "    [data-vibespace-selected=\"true\"] { outline: 3px solid #f8ff38 !important; outline-offset: 5px; box-shadow: 0 0 0 2px rgba(0,0,0,.92), 0 0 0 6px rgba(255,255,255,.94), 0 0 24px rgba(248,255,56,.9) !important; }\n" ++
  "  </style>\n" ++
  "</head>\n" ++
  "<body data-vibespace-edit-mode=\"" ++ editMode ++ "\" data-vibespace-selected-id=\"" ++
  selectedId ++ "\">\n" ++
  expandedHtml ++ "\n" ++
  friendsList->systemFriendsHtml ++
  "<script nonce=\"" ++ previewScriptNonce ++ "\">\n" ++
  trustedImageRuntimeScript ++ "\n" ++
  systemFriendsRuntimeScript ++ "\n" ++
  ownerImage->systemOwnerImageRuntimeScript ++ "\n" ++
  "</script>\n" ++
  "</body>\n" ++
  "</html>"
}
