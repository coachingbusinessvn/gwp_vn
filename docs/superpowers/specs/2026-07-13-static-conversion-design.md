# Design: Static conversion of GoWise Partners website

**Date:** 2026-07-13
**Status:** Approved (brainstorming complete)
**Branch/worktree:** to be created — `refactor/static-conversion`

## Problem

Most CSS and JS on the site is inline, making bugs hard to find and fix and
giving zero reusability. The root cause is deeper than sloppy authoring: the
pages are **client-side-rendered Claude Design (DC) templates**, and inlined
styles + bound data are the native output of that authoring system.

Each page (`index.html`, `Lien_He.html`,
`Khai_Van_Hieu_Suat_Thuc_Chien.html`, `Chuyen_Gia_Khai_Van_Hieu_Suat_Cao.html`,
`Khai-Van_Quan_Tri_Chuyen_Nghiep.html`) is an `<x-dc>` template rendered in the
browser by `support.js` + React (loaded from `unpkg.com`). It uses DC
constructs: `<dc-import>` (partials), `<sc-for>` + `{{ }}` (loops/interpolation
bound to a `renderVals()` data block), `style-hover="..."`, and `<image-slot>`.

## Decisions (locked during brainstorming)

1. **Source of truth = this repo.** Claude Design is abandoned; `/design-sync`
   is retired. We are free to restructure the HTML.
2. **Full static conversion.** Drop the DC runtime and the React CDN dependency.
   Every page becomes plain static HTML with external CSS/JS. Benefits: faster,
   better SEO, debuggable, reusable.
3. **Lightweight build script** assembles pages from shared partials + a layout,
   emitting complete static HTML. No SSG framework (no Astro/11ty/Vite), no npm
   dependency — a zero-dependency Node script (`build.mjs`).
4. **Plain hand-written CSS.** Tailwind is not actually used (no build, no
   compiled output; `tailwind.config.js` was only a token reference).

## Guiding principle: pixel-parity refactor

Every page must render **identically** to today — same layout, colors, fonts,
spacing, and animations. This task changes *how the code is organized*, not
*what it looks like*. Any visual improvement is explicitly out of scope and a
separate future task.

## Target structure

```
src/                          ← hand-edited source
├── layout.html               shared skeleton: <head>, analytics, css/js links,
│                             header + footer include slots, {{title}} etc.
├── partials/
│   ├── header.html           converted from Header.dc.html (no DC)
│   └── footer.html           converted from Footer.dc.html (no DC)
└── pages/
    ├── index.html            front-matter (title/description/canonical/og) + static body
    ├── Lien_He.html
    ├── Khai_Van_Hieu_Suat_Thuc_Chien.html
    ├── Chuyen_Gia_Khai_Van_Hieu_Suat_Cao.html
    └── Khai-Van_Quan_Tri_Chuyen_Nghiep.html
css/
├── gowise.css                tokens + base + component classes (grown from brand/gowise.css)
└── pages/*.css               only for genuinely one-off page styles (avoid if possible)
js/
├── reveal.js                 scroll-reveal + count-up + data-svg injection
└── image-slot.js             (see "image-slot" below)
build.mjs                     zero-dep Node build: layout + partials + page → root *.html

index.html, Lien_He.html, …   ← BUILT output at repo root (served by GitHub Pages; committed)
```

- Root output filenames stay identical, and extensionless internal links
  (`href="Lien_He"`, `href="./"` for home) are preserved — **no URLs change**.
- Both `src/` and the built root `*.html` are committed. GitHub Pages serves the
  built files directly; `build.mjs` is run locally before commit (no CI).

## Build script contract (`build.mjs`)

- Zero external dependencies (Node stdlib only).
- Reads `src/layout.html`, `src/partials/*.html`, and each `src/pages/*.html`.
- Each page source has a small front-matter block (title, description,
  canonical, ogImage, and any extra per-page `<head>` bits) plus a body of pure
  static HTML.
- Substitutes front-matter values + injects header/footer partials into the
  layout, writes the finished page to the repo root under the same filename.
- Include mechanism: simple, explicit tokens (e.g. `{{title}}`, `{{content}}`,
  `{{> header }}`) — chosen concretely during planning; must be unambiguous and
  documented in a short comment at the top of `build.mjs`.

## What gets removed (after all pages pass)

- `support.js` (DC/React runtime) and the React/unpkg CDN loads
- `fix-dc.sh`
- `tailwind.config.js`
- `.image-slots.state.json`
- `.claude/design-sync.json` + the `/design-sync` workflow references
- All DC constructs: `<x-dc>`, `<dc-import>`, `<sc-for>`, `{{ }}`,
  `style-hover`, `data-dc-script`
- `Header.dc.html` / `Footer.dc.html` (replaced by `src/partials/*.html`)
- `CLAUDE.md` / `DESIGN.md` references to the DC/sync workflow are updated to
  describe the new static build instead.

## CSS work (the bulk of the effort)

Convert the ~840 inline `style="..."` attributes across the 5 pages into
semantic classes:

- **Repeated patterns become reusable classes in `gowise.css`** — the gold
  gradient button, dark/light cards, eyebrows, icon rings, stat pills, section
  shells, reveal classes, keyframes. This is exactly what `DESIGN.md` §2–3 and
  `CLAUDE.md` already mandate (`.gp-btn`, `.gp-card-dark/-light`, `.gp-eyebrow`,
  `.gp-icon-ring`, `.gp-reveal`, …).
- **Design tokens** (colors, fonts, radii, gradients from `DESIGN.md`) are
  expressed as CSS custom properties in `gowise.css`; no new tokens invented,
  gold stays ≤ 10% of surface.
- `style-hover="..."` → real CSS `:hover` rules.
- Genuinely unique one-offs → page-scoped classes (prefer reuse first).

## JS work

- Extract the per-page `class Component extends DCLogic` logic (the `initAnim`
  routine: `data-svg` injection, `[data-stagger]` delays, IntersectionObserver
  scroll-reveal, count-up) into a single shared `js/reveal.js` that runs on
  `DOMContentLoaded`. No React.
- Respect `prefers-reduced-motion` exactly as today.
- `data-svg` → `innerHTML` injection pattern is **kept** (documented in
  `CLAUDE.md` §10); `reveal.js` performs the injection on load.
- `renderVals()` data (clients, articles, leads, experts) is rendered directly
  into static HTML at authoring/build time — `<sc-for>` loops expand to static
  markup.

## image-slot decision

Replace `<image-slot src="...">` with plain `<img loading="lazy">`. The images
are already chosen; the slot component's editor/credit machinery is dead weight
in production. `image-slot.js` (56 KB) is then removed. (Reversible: keep
`image-slot.js` if credit overlays are later wanted — it is a standalone web
component, not DC-dependent.)

## Migration order (incremental, verified each step)

1. Create git worktree + branch `refactor/static-conversion`; scaffold `src/`,
   `build.mjs`, and the css/js skeleton.
2. Convert **`index.html` first** (reference page). Build → verify in browser:
   screenshot matches current, zero console errors, and **no unpkg/React network
   requests**.
3. Convert the remaining 4 pages one at a time, reusing and growing
   `gowise.css` component classes each time.
4. Delete the DC runtime & sync machinery once all 5 pages pass.
5. Final pass: verify all 5 pages + mobile/responsive (and dark sections)
   against the originals.

## Verification strategy

- Per page: side-by-side screenshot vs the pre-refactor original at desktop and
  mobile widths; browser console clean; network panel shows no React/unpkg/CDN
  calls; scroll-reveal + count-up animations fire.
- Keep the pre-refactor originals available (git history / the untouched `main`)
  for comparison until the whole conversion is signed off.

## Risks & mitigations

- **Visual regression** (biggest risk): mitigated by strict one-page-at-a-time
  conversion with before/after screenshot comparison and pixel-parity as the
  acceptance bar.
- **Missed DC behavior** (e.g. a subtle bound value): mitigated by converting
  the reference page first and diffing rendered output.
- **Broken internal links**: mitigated by preserving exact root filenames and
  extensionless href convention.

## Out of scope

- Any visual/design change (separate future task).
- Content edits.
- Adding a CI/CD pipeline or SSG framework.
- SEO work beyond what static rendering yields for free.
