# Design: Parity-first static conversion of GoWise Partners

**Date:** 2026-07-13
**Status:** Approved
**Branch/worktree:** create `refactor/static-conversion` from `main` in a dedicated worktree

## Problem

The five public pages are Claude Design (DC) templates rendered in the browser by
`support.js`, React, ReactDOM, and Babel from `unpkg.com`. The templates depend on
DC-only elements and bindings:

- `<dc-import>` for the shared header and footer;
- `<sc-for>`, `<sc-if>`, and `{{ ... }}` for content and conditional rendering;
- `onClick`, `onSubmit`, `style-hover`, `data-html`, and component state;
- `<image-slot>` and its editor/runtime script;
- page-local animation, responsive CSS, and interaction code inside
  `<script type="text/x-dc">`.

The current implementation is difficult to debug, slow to start, dependent on a
third-party runtime, and dominated by inline CSS. A direct one-pass rewrite would
mix runtime removal, behavior replacement, responsive migration, and CSS cleanup,
making visual regressions hard to isolate.

## Locked decisions

1. The repository becomes the source of truth. Claude Design sync is retired.
2. Public output is plain static HTML. No React, Babel, DC runtime, or production
   dependency on `unpkg.com` remains.
3. The build remains zero-dependency and uses Node standard-library APIs only.
4. Root output filenames and extensionless internal URLs remain unchanged.
5. The final result has pixel parity at desktop and mobile widths. Content and
   interactions remain unchanged.
6. Brand tokens remain locked to `DESIGN.md` and `css/gowise.css`.
7. The migration uses the **parity-first, two-layer approach** described below.
8. `CLAUDE.md` and `DESIGN.md` become tracked project documentation instead of
   ignored local files.

## Chosen migration strategy

Each page is migrated through two separately verified layers:

### Layer A: static parity

- Capture the original page at every meaningful UI state.
- Remove DC/React rendering while retaining the page root id, DOM order, page
  scope, content, responsive behavior, and visible styling.
- Move the page's `<style>` block to an external page stylesheet without trying
  to deduplicate it yet.
- Replace DC state with small vanilla-JS controllers.
- Verify desktop, mobile, content, and interactions before proceeding.

### Layer B: CSS consolidation

- Replace inline styles with semantic or page-scoped classes.
- Promote genuinely repeated patterns into `css/gowise.css`.
- Keep unique rules in `css/pages/<page>.css`.
- Re-run the same screenshot and interaction checks.

This order isolates behavioral conversion from styling cleanup. If a regression
appears, the commit that introduced it is small and the cause is clear.

## Target structure

```text
src/
├── layout.html
├── partials/
│   ├── header.html
│   └── footer.html
└── pages/
    ├── index.html
    ├── Lien_He.html
    ├── Khai_Van_Hieu_Suat_Thuc_Chien.html
    ├── Chuyen_Gia_Khai_Van_Hieu_Suat_Cao.html
    └── Khai-Van_Quan_Tri_Chuyen_Nghiep.html

css/
├── gowise.css
└── pages/
    ├── index.css
    ├── contact.css
    ├── workshop.css
    ├── performance-coach.css
    └── management-coach.css

js/
├── reveal.js
├── nav.js
├── contact.js
└── program-ui.js

tests/
├── build.test.mjs
├── static-contract.test.mjs
└── fixtures/
    ├── reveal.html
    ├── nav.html
    ├── program-ui.html
    └── contact.html

build.mjs

index.html
Lien_He.html
Khai_Van_Hieu_Suat_Thuc_Chien.html
Chuyen_Gia_Khai_Van_Hieu_Suat_Cao.html
Khai-Van_Quan_Tri_Chuyen_Nghiep.html
```

`src/`, `css/`, `js/`, `tests/`, `build.mjs`, and built root pages are tracked.
GitHub Pages continues serving the committed root HTML.

## Build contract

`build.mjs` exports testable parsing, rendering, validation, and build functions,
and also acts as the `node build.mjs` CLI.

For every `src/pages/*.html` file whose name does not start with `_`, it:

1. parses one leading HTML-comment front-matter block;
2. rejects duplicate or missing required metadata;
3. injects header and footer partials into the layout;
4. replaces only documented layout placeholders;
5. renders every page in memory;
6. validates every result before writing any root output;
7. writes all validated pages under their unchanged basenames.

Required metadata: `title`, `description`, `canonical`, and `ogImage`.
Optional metadata: `ogTitle`, `bodyClass`, and a single-line `headExtra` value.

The build fails if output contains any of the following:

- unresolved `{{...}}` placeholders;
- `<x-dc>`, `<dc-import>`, `<sc-for>`, or `<sc-if>`;
- `style-hover`, `data-dc-script`, DC-bound event handlers, or `data-html`;
- references to `support.js`, `image-slot.js`, React, Babel, or `unpkg.com`.

`data-svg` remains supported. SVG stored in an HTML attribute must be
entity-encoded so `getAttribute('data-svg')` returns valid SVG markup.

## CSS architecture

### Shared layer

`css/gowise.css` contains:

- brand tokens copied from `brand/gowise.css`;
- reset and global base rules;
- shared typography, section, card, button, icon, reveal, and animation classes;
- complete header and footer styling;
- shared reduced-motion rules.

Shared partials contain no `style` attributes and no hard-coded colors.

### Page layer

Each page keeps a stable root id during the migration:

- `#gp-root`
- `#lh-root`
- `#kv-root`
- `#hpc-root`
- `#mc-root`

The first static-parity commit moves each original `<style>` block into the
matching page stylesheet. Responsive selectors that currently depend on inline
style substrings are replaced with explicit layout classes before those inline
styles are removed.

Final page sources contain no DC attributes and no `style-hover`. Repeated inline
styles are eliminated; unique styling lives in page-scoped classes rather than
being left in shared partials.

## Behavior architecture

### `js/reveal.js`

Responsible only for:

- entity-decoded `data-svg` injection;
- reveal observation;
- stagger delays;
- count-up animation;
- reduced-motion and IntersectionObserver fallbacks.

Per-element configuration preserves existing page differences:

- `data-stagger-ms`, default `75`;
- `data-count-duration`, default `900`;
- `data-count-format="grouped|plain"`, default `grouped`.

All old `.rv`, `.rv-l`, and `.rv-r` classes are mapped to `.gp-reveal`,
`.gp-reveal--l`, and `.gp-reveal--r` during static conversion.

### `js/nav.js`

Controls desktop dropdown, mobile navigation, mobile program submenu, and active
link highlighting. It preserves the 18px hover bridge between the desktop
trigger and menu, updates `aria-expanded`, closes on Escape/outside click, and
resets mobile state when resizing to desktop.

### `js/program-ui.js`

Controls both program-page interaction patterns using data attributes:

- `[data-tabs]`, `[data-tab]`, and `[data-panel]` for module switching;
- `[data-accordion]`, `[data-accordion-trigger]`, and
  `[data-accordion-panel]` for FAQ toggles.

All module and FAQ content is present in static HTML. JavaScript changes hidden,
active, and ARIA state; it never fetches or constructs content at runtime.

### `js/contact.js`

Preserves the current Web3Forms endpoint, field names, captcha client script,
loading state, success message, error message, and form reset behavior. Browser
verification intercepts the submit request and returns controlled success/error
responses; it does not create a real production lead.

## Static conversion rules

1. Copy metadata verbatim into front matter.
2. Preserve the page root id and meaningful section ids.
3. Remove imported DC header/footer elements.
4. Expand every `sc-for` using the complete corresponding data collection.
5. Evaluate every `sc-if` explicitly. For interactive content, render all states
   as separate static panels and let `program-ui.js` control visibility.
6. Replace `data-html` with real child markup.
7. Entity-encode `data-svg` values.
8. Replace `image-slot` with an `<img>` that preserves source, fit, position,
   dimensions, and accessible alternative text. Above-the-fold hero images are
   eager; below-the-fold images are lazy.
9. Replace DC event attributes with the documented `data-*` contracts.
10. Preserve third-party page dependencies that are still required, including
    the Web3Forms captcha client.
11. Remove all DC scripts only after their content and behavior have an explicit
    static equivalent.

## Verification gates

### Automated build tests

Node's built-in `node:test` verifies:

- metadata parsing and duplicate-key errors;
- required-key errors and `ogTitle` fallback;
- include and placeholder replacement;
- private `_` fixture exclusion;
- unknown placeholder rejection;
- DC-token rejection;
- validate-all-before-write behavior;
- exact output basenames.

### Static contract checks

Every built page must:

- have one title, canonical URL, description, and OG image;
- reference existing local CSS, JS, and image assets;
- contain no DC/runtime artifacts;
- preserve the required root filename and internal-link convention.

### Browser checks

For each page:

- capture full-page screenshots at 1280×900 and 390×844;
- wait for `document.fonts.ready` and images before capture;
- use reduced motion for deterministic screenshot comparison;
- separately test normal-motion reveal and count-up behavior;
- require zero console errors;
- require no React, Babel, `unpkg.com`, or `support.js` requests.

Interaction coverage includes desktop/mobile nav, every module tab, every FAQ
item, reduced motion, contact captcha validation, mocked successful submission,
and mocked failed submission.

## Migration order

1. Create the worktree and capture all visual/behavior baselines.
2. Build the tested static assembler and validation contracts.
3. Add shared CSS, layout, header/footer, and behavior controllers using fixtures.
4. Convert `index.html` through Layer A and Layer B.
5. Convert `Khai_Van_Hieu_Suat_Thuc_Chien.html` through both layers.
6. Convert `Lien_He.html`, including mocked form verification.
7. Convert `Chuyen_Gia_Khai_Van_Hieu_Suat_Cao.html`, including all module states.
8. Convert `Khai-Van_Quan_Tri_Chuyen_Nghiep.html`, including tabs and FAQ states.
9. Remove runtime and sync machinery, then update tracked documentation.
10. Run the full automated, static, browser, and visual verification matrix.

## Cleanup policy

Tracked runtime files are removed with `git rm`. Ignored local tooling is removed
separately only after checking that it exists. The cleanup does not use one mixed
`git rm` command that can fail because a path is untracked or absent.

The root `tailwind.config.js` is not part of the current repository. The ignored
development reference is `brand/tailwind.config.js`; it may remain under the
ignored `brand/` directory. Obsolete ignored files such as `fix-dc.sh`,
`.claude/design-sync.json`, and `.claude/commands/design-sync.md` are removed from
the worktree separately.

`.gitignore` stops ignoring `CLAUDE.md`, `DESIGN.md`, and `fix-dc.sh`. It continues
ignoring `.claude/`, `brand/`, screenshots, uploads, and local OS artifacts.

## Risks and mitigations

- **Visual drift:** two-layer, per-page verification isolates each styling change.
- **Lost conditional content:** explicit `sc-if` inventory plus build rejection of
  leftover DC tags prevents silent loss.
- **Lost interaction:** all stateful DC behavior has a named vanilla-JS owner and
  an interaction test matrix.
- **Broken captcha:** the Web3Forms client remains and network calls are mocked in
  verification.
- **Partial output:** all pages validate before any build output is written.
- **Uncommitted documentation:** project docs become tracked before cleanup commit.

## Out of scope

- visual redesign or content editing;
- changing public URLs;
- replacing Web3Forms;
- adding an SSG framework, npm runtime packages, CI/CD, or deployment automation;
- changing brand tokens or introducing a new design system.
