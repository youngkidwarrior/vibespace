# ReScript-Shadcn Audit

This audit covers app-native Vibespace UI only. It does not apply to generated profile HTML/CSS rendered inside the iframe; that profile document must remain raw HTML/CSS so agents can edit it directly.

Reference: <https://rescript-shadcn.miriad.studio/installation>

## Current Status

Vibespace now uses ReScript-shadcn/shadcn for app-native UI primitives.

Evidence:

- `apps/web/package.json` includes `shadcn`, `@base-ui/react`, `rescript-base-ui`, `tailwind-merge`, `lucide-react`, `tw-animate-css`, Tailwind, and the Tailwind Vite plugin.
- `apps/web/rescript.json` includes `rescript-base-ui`.
- `apps/web/components.json`, `apps/web/jsconfig.json`, and the Vite alias/Tailwind plugin are configured.
- `apps/web/src/ui` contains generated ReScript-shadcn components.
- `apps/web/src/App.res` uses ReScript-shadcn `Button`, `Textarea`, `Badge`, `Alert`, `Card`, `ScrollArea`, and `Label` for app-native controls and panels.
- `apps/web/src/CodexChat.res` uses the generated ReScript-shadcn modules for its visible chat UI.
- `apps/web/src/app.css` is reduced to Tailwind/shadcn setup, app layout, editor geometry, route structure, and small typography helpers.

## Implemented Setup

Implemented from the installation guide:

- Tailwind CSS and `@tailwindcss/vite`.
- `shadcn`, `@base-ui/react`, `rescript-base-ui`, `tailwind-merge`, `lucide-react`, and `tw-animate-css`.
- `apps/web/jsconfig.json` with the `@/*` alias.
- `apps/web/components.json` with ReScript/Vite-compatible aliases.
- Tailwind, `tw-animate-css`, and `shadcn/tailwind.css` imports in `apps/web/src/app.css`.
- `rescript-base-ui` in `apps/web/rescript.json`.

Keep generated profile CSS out of this setup. The Tailwind/shadcn layer should style the React/ReScript shell, not the iframe-authored profile page.

## Completed Rewrite Targets

### `apps/web/src/App.res`

- History sidebar uses `Card` and `ScrollArea`.
- Selection composer uses `Card`, `Textarea`, and `Button`.
- Prompt bubble actions use `Button` variants.
- Canvas toolbar links/buttons use `Button` variants with anchor rendering where navigation semantics matter.
- Document warning and edit hint use `Alert`.
- Source route status uses `Badge`; navigation uses `Button`.
- Source preview and source editors use `Card`, `Label`, and `Textarea`.
- Validation and Codex dev panels use `Alert` and `Card`.

Do not rewrite the iframe elements or geometric selection overlay as shadcn components. The iframe boundary, canvas sizing, and selection box are specialized editor behavior.

### `apps/web/src/CodexChat.res`

- Chat form uses generated `Textarea` and `Button`.
- Fast/reasoning mode uses generated `ToggleGroup`.
- Generated patch summary/warnings use generated `Card`, `Alert`, and `Button`.
- Disabled state uses generated `Alert`.

### `apps/web/src/app.css`

Deleted or reduced custom primitive groups for buttons, textareas, status pills, cards, panels, alerts, model controls, and patch cards.

Keep layout-only CSS that positions the canvas, iframe, source grid, selection overlay, and responsive shell. Shadcn should replace reusable app-native components, not editor geometry.

## Remaining Notes

- `apps/web/src/CodexChat.res` now owns chat UI state in ReScript. Assistant requests are submitted through the Relay `submitAgentEdit` mutation.
- A Yarn peer warning remains because `rescript-base-ui` requests `@rescript/react ~0.14.2` while the app uses `0.15.0`; `yarn rescript` and `yarn build` pass with the current version.

## Acceptance Criteria

- App-native buttons, textareas, badges, alerts, cards, sidebars, and segmented controls use ReScript-shadcn/shadcn primitives.
- Generated profile HTML/CSS remains raw and does not import or depend on shadcn/Tailwind.
- `yarn rescript` and `yarn build` pass.
- `rg "rescript-base-ui|shadcn|@base-ui|tailwind-merge|lucide-react|tw-animate-css" apps/web/package.json apps/web/rescript.json apps/web/components.json apps/web/src` shows actual integration, not just docs.
