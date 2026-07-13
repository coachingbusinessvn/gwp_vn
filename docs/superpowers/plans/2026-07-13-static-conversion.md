# Static Conversion Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Convert the GoWise Partners site from client-rendered Claude Design (DC) templates into plain static HTML with external, reusable CSS/JS, assembled by a zero-dependency build script — with pixel-parity to the current site.

**Architecture:** Hand-edited sources live in `src/` (a `layout.html` skeleton, `partials/header.html` + `partials/footer.html`, and per-page bodies in `pages/`). A zero-dependency Node script `build.mjs` injects partials + per-page front-matter into the layout and writes finished pages to the repo root, which GitHub Pages serves. Shared styling lives in `css/gowise.css`; shared behavior (scroll-reveal, count-up, SVG injection, header nav) lives in `js/`. The DC runtime (`support.js` + React CDN) is removed once all pages pass.

**Tech Stack:** Static HTML, plain CSS (no Tailwind), vanilla JS (ES modules not required — classic scripts), Node ≥ 18 (stdlib only) for the build, Python `http.server` for local preview.

## Global Constraints

- **Pixel-parity:** every page must render identically to the pre-refactor original at desktop and mobile widths. No visual/design/content changes.
- **Brand locked:** only colors/fonts/radii/gradients from `DESIGN.md` §2–3 and `css/gowise.css` tokens. Never invent tokens. Gold ≤ 10% of surface. Fonts: Playfair Display + Montserrat.
- **No new runtime dependencies:** `build.mjs` uses Node stdlib only; no npm install, no `package.json` required.
- **URLs unchanged:** built files keep exact root filenames (`index.html`, `Lien_He.html`, `Khai_Van_Hieu_Suat_Thuc_Chien.html`, `Chuyen_Gia_Khai_Van_Hieu_Suat_Cao.html`, `Khai-Van_Quan_Tri_Chuyen_Nghiep.html`). Internal links stay extensionless (`href="Lien_He"`, `href="./"` for home).
- **Served paths must not be gitignored:** `.gitignore` excludes `/brand/`, `/.claude/`, `CLAUDE.md`, `DESIGN.md`, `fix-dc.sh`. The served stylesheet therefore lives at `css/gowise.css` (committed), NOT `brand/`. New served dirs `css/`, `js/`, `src/` must not be added to `.gitignore`.
- **Reduced motion:** all animation must be disabled under `prefers-reduced-motion: reduce`, matching current behavior.
- **`data-svg` pattern kept:** inline SVG strings stored in `data-svg` are injected via `innerHTML` on load (DESIGN.md §10).
- **SVG icons:** in `.gp-icon-ring`/`.gp-icon-chip`, only inject icon markup; do not restyle.
- **All work on branch `refactor/static-conversion` in a dedicated git worktree.** Commit after every task (full, reviewable commits).

---

## File Structure

**Created (hand-edited source):**
- `src/layout.html` — HTML skeleton with `{{title}}`, `{{description}}`, `{{canonical}}`, `{{ogImage}}`, `{{ogTitle}}`, `{{head_extra}}`, `{{body_class}}`, `{{content}}` placeholders + `<!--#include header-->` / `<!--#include footer-->` markers.
- `src/partials/header.html` — static nav (from `Header.dc.html`).
- `src/partials/footer.html` — static footer (from `Footer.dc.html`).
- `src/pages/*.html` — one per page: a front-matter comment block + static body.
- `build.mjs` — assembles pages.

**Created (served assets):**
- `css/gowise.css` — the served design system (copied from `brand/gowise.css`, then extended).
- `js/reveal.js` — scroll-reveal + count-up + `data-svg` injection.
- `js/nav.js` — header dropdown, mobile menu, active-link highlight.

**Modified:**
- Root `*.html` (5 pages) — become build output.
- `CLAUDE.md`, `DESIGN.md` — update workflow docs (Task 11).
- `.claude/launch.json` — already serves the repo statically on :8777 (no change needed).

**Removed (Task 11):** `support.js`, `fix-dc.sh`, `tailwind.config.js`, `.image-slots.state.json`, `image-slot.js`, `Header.dc.html`, `Footer.dc.html`, `.claude/design-sync.json`.

---

## Task 0: Worktree + scaffolding

**Files:**
- Create: `src/partials/.gitkeep`, `src/pages/.gitkeep`, `css/.gitkeep`, `js/.gitkeep`

- [ ] **Step 1: Create the worktree and branch**

Use the `superpowers:using-git-worktrees` skill to create an isolated worktree on a new branch `refactor/static-conversion` off `main`. All subsequent steps run inside that worktree.

- [ ] **Step 2: Create directory scaffold**

```bash
mkdir -p src/partials src/pages css js
touch src/partials/.gitkeep src/pages/.gitkeep css/.gitkeep js/.gitkeep
```

- [ ] **Step 3: Confirm served dirs are not gitignored**

Run: `git check-ignore css js src || echo "OK: css js src are tracked"`
Expected: prints `OK: css js src are tracked` (none are ignored).

- [ ] **Step 4: Commit**

```bash
git add -A
git commit -m "chore: scaffold src/, css/, js/ for static conversion"
```

---

## Task 1: Build script (`build.mjs`)

**Files:**
- Create: `build.mjs`
- Create (temporary fixtures for the smoke test): `src/layout.html`, `src/partials/header.html`, `src/partials/footer.html`, `src/pages/_smoke.html`

**Interfaces:**
- Produces: a CLI `node build.mjs` that reads `src/layout.html`, `src/partials/{header,footer}.html`, and every `src/pages/*.html` except files whose name starts with `_`, and writes `<basename>.html` to repo root.
- Front-matter contract: each page file begins with an HTML comment block of `key: value` lines, then a blank line, then the body:
  ```html
  <!--
  title: Page Title
  description: Meta description
  canonical: https://www.gwp.vn/Path
  ogTitle: OG title
  ogImage: https://www.gwp.vn/images/og-x.jpg
  bodyClass: page-index
  headExtra: <link rel="stylesheet" href="css/pages/index.css">
  -->
  <section>…</section>
  ```
  `headExtra` and `bodyClass` are optional (default empty). Missing required keys → build error.
- Layout placeholders: `{{title}}`, `{{description}}`, `{{canonical}}`, `{{ogTitle}}` (falls back to `title`), `{{ogImage}}`, `{{head_extra}}`, `{{body_class}}`, `{{content}}`.
- Include markers in layout/partials: `<!--#include header-->` and `<!--#include footer-->` are replaced by the partial file contents (partials may themselves contain no further includes).

- [ ] **Step 1: Write `build.mjs`**

```js
// build.mjs — zero-dependency static site build for GoWise Partners.
// Reads src/layout.html + src/partials/*.html + src/pages/*.html and writes
// finished pages to the repo root. Run: `node build.mjs`.
//
// Page front-matter: an HTML comment at the top of each src/pages/*.html with
// `key: value` lines, a blank line, then the body. See docs plan Task 1.
import { readFileSync, writeFileSync, readdirSync } from 'node:fs';
import { join, basename } from 'node:path';

const ROOT = process.cwd();
const SRC = join(ROOT, 'src');

const readText = (p) => readFileSync(p, 'utf8');

function parseFrontMatter(raw, file) {
  const m = raw.match(/^\s*<!--([\s\S]*?)-->\s*/);
  if (!m) throw new Error(`${file}: missing front-matter comment block`);
  const meta = {};
  for (const line of m[1].split('\n')) {
    const t = line.trim();
    if (!t) continue;
    const idx = t.indexOf(':');
    if (idx === -1) throw new Error(`${file}: bad front-matter line: ${t}`);
    meta[t.slice(0, idx).trim()] = t.slice(idx + 1).trim();
  }
  const body = raw.slice(m[0].length);
  return { meta, body };
}

function applyIncludes(html, partials) {
  return html
    .replace(/<!--#include header-->/g, partials.header)
    .replace(/<!--#include footer-->/g, partials.footer);
}

function render(layout, partials, meta, body, file) {
  const required = ['title', 'description', 'canonical', 'ogImage'];
  for (const k of required) {
    if (!meta[k]) throw new Error(`${file}: missing required front-matter key "${k}"`);
  }
  const vals = {
    title: meta.title,
    description: meta.description,
    canonical: meta.canonical,
    ogTitle: meta.ogTitle || meta.title,
    ogImage: meta.ogImage,
    head_extra: meta.headExtra || '',
    body_class: meta.bodyClass || '',
    content: body,
  };
  let out = applyIncludes(layout, partials);
  out = out.replace(/\{\{(\w+)\}\}/g, (whole, key) =>
    key in vals ? vals[key] : whole
  );
  return out;
}

function main() {
  const layout = readText(join(SRC, 'layout.html'));
  const partials = {
    header: readText(join(SRC, 'partials', 'header.html')),
    footer: readText(join(SRC, 'partials', 'footer.html')),
  };
  const pagesDir = join(SRC, 'pages');
  const files = readdirSync(pagesDir).filter(
    (f) => f.endsWith('.html') && !f.startsWith('_')
  );
  let n = 0;
  for (const f of files) {
    const raw = readText(join(pagesDir, f));
    const { meta, body } = parseFrontMatter(raw, f);
    const out = render(layout, partials, meta, body, f);
    writeFileSync(join(ROOT, basename(f)), out);
    console.log(`✓ ${f} -> ${basename(f)}`);
    n++;
  }
  console.log(`Built ${n} page(s).`);
}

main();
```

- [ ] **Step 2: Write minimal fixtures to smoke-test the build**

`src/layout.html`:
```html
<!DOCTYPE html>
<html lang="vi">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>{{title}}</title>
<meta name="description" content="{{description}}">
<link rel="canonical" href="{{canonical}}">
{{head_extra}}
</head>
<body class="{{body_class}}">
<!--#include header-->
<main>{{content}}</main>
<!--#include footer-->
</body>
</html>
```

`src/partials/header.html`:
```html
<header>HEADER</header>
```

`src/partials/footer.html`:
```html
<footer>FOOTER</footer>
```

`src/pages/_smoke.html`:
```html
<!--
title: Smoke
description: smoke desc
canonical: https://www.gwp.vn/smoke
ogImage: https://www.gwp.vn/images/og-index.jpg
-->
<section>SMOKE BODY</section>
```

- [ ] **Step 3: Run the build; verify `_smoke` is skipped (leading underscore)**

Run: `node build.mjs`
Expected: prints `Built 0 page(s).` (the only page starts with `_`, so it is skipped and no root file is written).

- [ ] **Step 4: Temporarily rename fixture to confirm rendering**

Run:
```bash
cp src/pages/_smoke.html src/pages/smoketest.html
node build.mjs
grep -q "SMOKE BODY" smoketest.html && grep -q "HEADER" smoketest.html && grep -q "smoke desc" smoketest.html && echo "RENDER OK"
```
Expected: prints `✓ smoketest.html -> smoketest.html`, `Built 1 page(s).`, then `RENDER OK`.

- [ ] **Step 5: Clean up smoke output**

```bash
rm -f src/pages/smoketest.html smoketest.html
```

- [ ] **Step 6: Commit**

```bash
git add build.mjs src/layout.html src/partials/header.html src/partials/footer.html src/pages/_smoke.html
git commit -m "feat: add zero-dependency static build script"
```

---

## Task 2: Shared behavior — `js/reveal.js`

**Files:**
- Create: `js/reveal.js`

**Interfaces:**
- Produces: a classic (non-module) script that on `DOMContentLoaded` (1) injects `data-svg` markup via `innerHTML`, (2) applies staggered transition delays inside `[data-stagger]`, (3) reveals `.gp-reveal` elements via IntersectionObserver, (4) runs count-up on `[data-count]` elements — all respecting `prefers-reduced-motion`. Operates on the whole `document` (no `#gp-root` requirement). Replaces the per-page `class Component extends DCLogic` `initAnim` logic.

- [ ] **Step 1: Write `js/reveal.js`**

```js
/* reveal.js — scroll-reveal, count-up, and data-svg injection.
   Framework-free; replaces the former DC Component initAnim logic. */
(function () {
  function fmt(n) { return Number(n).toLocaleString('en-US'); }

  function countUp(el) {
    var target = parseInt(el.getAttribute('data-count'), 10) || 0;
    var dur = 900, start = performance.now();
    function tick(now) {
      var p = Math.min(1, (now - start) / dur);
      var eased = 1 - Math.pow(1 - p, 3);
      el.textContent = fmt(Math.round(eased * target));
      if (p < 1) requestAnimationFrame(tick);
      else el.textContent = fmt(target);
    }
    requestAnimationFrame(tick);
  }

  function init() {
    var root = document;

    root.querySelectorAll('[data-svg]').forEach(function (el) {
      var svg = el.getAttribute('data-svg');
      if (svg && el.childElementCount === 0) el.innerHTML = svg;
    });

    var reduce = window.matchMedia &&
      window.matchMedia('(prefers-reduced-motion: reduce)').matches;

    root.querySelectorAll('[data-stagger]').forEach(function (group) {
      var kids = Array.prototype.filter.call(group.children, function (c) {
        return c.classList.contains('gp-reveal');
      });
      kids.forEach(function (el, i) { el.style.transitionDelay = (i * 75) + 'ms'; });
    });

    if (reduce || !('IntersectionObserver' in window)) {
      root.querySelectorAll('.gp-reveal').forEach(function (el) { el.classList.add('in'); });
      root.querySelectorAll('[data-count]').forEach(function (el) {
        el.textContent = fmt(el.getAttribute('data-count'));
      });
      return;
    }

    var io = new IntersectionObserver(function (entries) {
      entries.forEach(function (e) {
        if (!e.isIntersecting) return;
        e.target.classList.add('in');
        io.unobserve(e.target);
      });
    }, { threshold: 0.12, rootMargin: '0px 0px -6% 0px' });
    root.querySelectorAll('.gp-reveal').forEach(function (el) { io.observe(el); });

    var cio = new IntersectionObserver(function (entries) {
      entries.forEach(function (e) {
        if (!e.isIntersecting) return;
        countUp(e.target);
        cio.unobserve(e.target);
      });
    }, { threshold: 0.6 });
    root.querySelectorAll('[data-count]').forEach(function (el) {
      el.textContent = '0'; cio.observe(el);
    });
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', init);
  } else {
    init();
  }
})();
```

- [ ] **Step 2: Syntax-check**

Run: `node --check js/reveal.js && echo OK`
Expected: `OK`

- [ ] **Step 3: Commit**

```bash
git add js/reveal.js
git commit -m "feat: add reveal.js (scroll-reveal, count-up, svg inject)"
```

---

## Task 3: Header behavior — `js/nav.js`

**Files:**
- Create: `js/nav.js`

**Interfaces:**
- Produces: a classic script that wires the header built in Task 5: desktop dropdown (`#gp-train-menu`) open/close on hover + click of `[data-nav="train"]` button, mobile panel (`#gp-mnav`) toggle from `.gp-burger`, mobile sub-menu (`#gp-train-mobile`) toggle, and active-link highlight by pathname. Replaces the `Header.dc.html` DC Component. Uses `.is-open` classes (styled in Task 4), not inline `style.display`.

- [ ] **Step 1: Write `js/nav.js`**

```js
/* nav.js — header dropdown, mobile menu, active-link highlight.
   Replaces the former Header DC Component. Toggles .is-open classes. */
(function () {
  function init() {
    var hdr = document.getElementById('gp-hdr');
    if (!hdr) return;

    var trainWrap = hdr.querySelector('[data-train-wrap]');
    var trainMenu = document.getElementById('gp-train-menu');
    var trainBtn = hdr.querySelector('[data-nav="train"]');
    if (trainWrap && trainMenu) {
      trainWrap.addEventListener('mouseenter', function () { trainMenu.classList.add('is-open'); });
      trainWrap.addEventListener('mouseleave', function () { trainMenu.classList.remove('is-open'); });
    }
    if (trainBtn && trainMenu) {
      trainBtn.addEventListener('click', function () { trainMenu.classList.toggle('is-open'); });
    }

    var burger = hdr.querySelector('.gp-burger');
    var mnav = document.getElementById('gp-mnav');
    if (burger && mnav) {
      burger.addEventListener('click', function () { mnav.classList.toggle('is-open'); });
    }

    var trainMobileBtn = hdr.querySelector('[data-train-mobile-btn]');
    var trainMobile = document.getElementById('gp-train-mobile');
    if (trainMobileBtn && trainMobile) {
      trainMobileBtn.addEventListener('click', function () { trainMobile.classList.toggle('is-open'); });
    }

    try {
      var file = decodeURIComponent((location.pathname.split('/').pop() || '').toLowerCase());
      var key = 'home';
      if (/lien_he|lien-he/.test(file)) key = 'contact';
      else if (/chuyen_gia|quan_tri|thuc_chien|hieu_suat/.test(file)) key = 'train';
      hdr.querySelectorAll('[data-nav="' + key + '"]').forEach(function (el) {
        el.classList.add('is-active');
      });
    } catch (e) {}
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', init);
  } else {
    init();
  }
})();
```

- [ ] **Step 2: Syntax-check**

Run: `node --check js/nav.js && echo OK`
Expected: `OK`

- [ ] **Step 3: Commit**

```bash
git add js/nav.js
git commit -m "feat: add nav.js (header dropdown, mobile menu, active link)"
```

---

## Task 4: Served stylesheet — `css/gowise.css`

**Files:**
- Create: `css/gowise.css`
- Reference (read-only): `brand/gowise.css` (dev copy), the `<style>` blocks in `index.html`, `Header.dc.html`, `Footer.dc.html`.

**Interfaces:**
- Produces: the single served stylesheet. Contains everything in `brand/gowise.css` PLUS: the global base rules, the page-level responsive breakpoints (`@media (max-width:900px)` and `(max-width:640px)` from index's `<style>`), and header/footer classes so nav/footer need no inline `<style>`. All class names below are the contract consumed by page conversions (Tasks 6–10) and by `nav.js` (Task 3).

- [ ] **Step 1: Copy the dev stylesheet to the served path**

```bash
cp brand/gowise.css css/gowise.css
```

- [ ] **Step 2: Append the global base + responsive + header/footer layer**

Append to `css/gowise.css`:

```css
/* ============ GLOBAL BASE (from former per-page <style>) ============ */
* { margin: 0; padding: 0; box-sizing: border-box; }
html { scroll-behavior: smooth; }
html, body { overflow-x: hidden; }
body { background: var(--gp-navy-950); font-family: var(--gp-font-sans); color: var(--gp-mist); }
::selection { background: var(--gp-gold-400); color: var(--gp-navy-950); }
a { color: var(--gp-gold-300); text-decoration: none; }
a:hover { color: var(--gp-gold-200); }
img { max-width: 100%; }

/* ============ HEADER ============ */
#gp-hdr { position: sticky; top: 0; z-index: 100; background: rgba(7,18,31,0.86);
  backdrop-filter: blur(14px); -webkit-backdrop-filter: blur(14px);
  border-bottom: 1px solid rgba(201,166,104,0.14); }
#gp-hdr .gp-hdr-inner { max-width: 1200px; margin: 0 auto; padding: 0 24px; min-height: 78px;
  display: flex; align-items: center; justify-content: space-between; gap: 24px; }
#gp-hdr a { text-decoration: none; }
#gp-hdr .gp-navlink { color: var(--gp-mist); font-size: 13px; letter-spacing: 0.05em; font-weight: 500; transition: color 0.2s; }
#gp-hdr .gp-navlink:hover { color: var(--gp-gold-200); }
#gp-hdr .gp-navlink.is-active { color: var(--gp-gold-200); font-weight: 600; }
#gp-hdr .gp-desktop-nav { display: flex; align-items: center; gap: 36px; }
#gp-hdr .gp-train-btn { display: inline-flex; align-items: center; gap: 7px; background: none; border: 0;
  cursor: pointer; font-family: var(--gp-font-sans); color: var(--gp-mist); font-size: 13px;
  letter-spacing: 0.05em; font-weight: 500; padding: 0; transition: color 0.2s; }
#gp-hdr .gp-train-btn:hover, #gp-hdr .gp-train-btn.is-active { color: var(--gp-gold-200); }
#gp-hdr .gp-train-menu { display: none; position: absolute; top: calc(100% + 18px); left: 50%;
  transform: translateX(-50%); width: 320px; background: var(--gp-navy-900);
  border: 1px solid rgba(201,166,104,0.22); border-radius: 12px;
  box-shadow: 0 24px 60px rgba(0,0,0,0.55); padding: 10px; z-index: 120; }
#gp-hdr .gp-train-menu.is-open { display: block; }
#gp-hdr .gp-drop-item { display: block; color: var(--gp-mist); font-size: 13.5px; font-weight: 500;
  padding: 13px 16px; border-radius: 8px; line-height: 1.4; transition: background 0.2s, color 0.2s; }
#gp-hdr .gp-drop-item:hover { background: rgba(201,166,104,0.08); color: var(--gp-gold-200); }
#gp-hdr .gp-desktop-cta { flex-shrink: 0; background: linear-gradient(180deg, var(--gp-gold-200), var(--gp-gold-400));
  color: var(--gp-navy-950); font-size: 12px; font-weight: 700; letter-spacing: 0.06em;
  padding: 12px 22px; transition: filter 0.2s, transform 0.2s; }
#gp-hdr .gp-desktop-cta:hover { filter: brightness(1.06); transform: translateY(-1px); }
#gp-hdr .gp-burger { display: none; width: 46px; height: 46px; align-items: center; justify-content: center;
  background: none; border: 1px solid rgba(201,166,104,0.3); border-radius: 8px; cursor: pointer; }
#gp-hdr .gp-mobile-panel { display: none; border-top: 1px solid rgba(201,166,104,0.14);
  background: rgba(7,18,31,0.98); padding: 10px 24px 22px; }
#gp-hdr .gp-mobile-panel.is-open { display: block; }
#gp-hdr .gp-train-mobile { display: none; flex-direction: column; padding: 6px 0 6px 14px;
  border-bottom: 1px solid rgba(201,166,104,0.1); }
#gp-hdr .gp-train-mobile.is-open { display: flex; }
@media (max-width: 940px) {
  #gp-hdr .gp-desktop-nav, #gp-hdr .gp-desktop-cta { display: none !important; }
  #gp-hdr .gp-burger { display: inline-flex !important; }
}

/* ============ FOOTER ============ */
#gp-ftr { background: var(--gp-navy-950); border-top: 1px solid rgba(201,166,104,0.14);
  padding: 64px 0 40px; font-family: var(--gp-font-sans); }
#gp-ftr a { text-decoration: none; }
#gp-ftr .gp-flink { color: var(--gp-mist); font-size: 14px; transition: color 0.2s; }
#gp-ftr .gp-flink:hover { color: var(--gp-gold-200); }
#gp-ftr .gp-fgrid { max-width: 1200px; margin: 0 auto; padding: 0 24px;
  display: grid; grid-template-columns: 1.7fr 1.1fr 1.2fr; gap: 44px; }
#gp-ftr .gp-fbottom { max-width: 1200px; margin: 48px auto 0; padding: 24px 24px 0;
  border-top: 1px solid rgba(201,166,104,0.1); font-size: 11px; letter-spacing: 0.14em;
  color: var(--gp-slate-deep); display: flex; justify-content: space-between; gap: 16px; }
@media (max-width: 820px) {
  #gp-ftr .gp-fgrid { grid-template-columns: 1fr; gap: 34px; }
  #gp-ftr .gp-fbottom { flex-direction: column; text-align: center; }
}

/* ============ PAGE RESPONSIVE (from index <style>) ============ */
@media (max-width: 900px) {
  .gp-section { padding-top: 64px !important; padding-bottom: 64px !important; }
  .gp-hero-grid { grid-template-columns: 1fr !important; gap: 38px !important;
    padding: 56px 20px 52px !important; }
  .gp-hero-visual { height: 420px !important; width: 100%; max-width: 360px; margin: 0 auto; }
  .gp-spin-ring { display: none !important; }
  .gp-2col { grid-template-columns: 1fr !important; gap: 44px !important; }
  .gp-3col { grid-template-columns: 1fr 1fr !important; }
  .gp-experts-grid { grid-template-columns: repeat(3, 1fr) !important; }
  .gp-lead-card { display: block !important; }
  .gp-lead-img { height: auto !important; aspect-ratio: 3 / 4; width: 100%; }
  .gp-about-img-wrap { height: 260px !important; }
  .gp-about-badge { position: static !important; margin-top: 12px; }
  .gp-sol-card { padding: 32px 24px !important; }
}
@media (max-width: 640px) {
  .gp-section { padding-top: 48px !important; padding-bottom: 48px !important; }
  .gp-3col { grid-template-columns: 1fr !important; }
  .gp-experts-grid { grid-template-columns: repeat(2, 1fr) !important; }
  .gp-hero-visual { height: 300px !important; }
  .gp-hero-photo { left: 16px !important; width: calc(100% - 76px) !important; height: 255px !important; }
  .gp-trust-bar { justify-content: center !important; gap: 16px !important; }
}
```

> Note: the responsive selectors target class names (`.gp-hero-grid`, `.gp-2col`, `.gp-3col`, `.gp-experts-grid`, `.gp-lead-card`, `.gp-lead-img`, `.gp-about-img-wrap`, `.gp-about-badge`, `.gp-sol-card`, `.gp-hero-visual`, `.gp-hero-photo`, `.gp-spin-ring`, `.gp-trust-bar`). Page conversions MUST keep these class names on the corresponding elements so the breakpoints keep working. The old `[style*="gpSpin"]` reduced-motion selector is replaced: spinning/floating elements get classes `.gp-anim-spin`, `.gp-anim-float`, `.gp-anim-float-slow` (defined next).

- [ ] **Step 3: Add animation utility classes (replace inline `animation:` + the `[style*=…]` reduced-motion hook)**

Append:

```css
/* ============ ANIMATION UTILITIES ============ */
.gp-anim-fade { animation: gp-fade 0.8s ease both; }
.gp-anim-fade-2 { animation: gp-fade 0.9s ease 0.15s both; }
.gp-anim-spin { animation: gp-spin 44s linear infinite; }
.gp-anim-float { animation: gp-float 6s ease-in-out infinite; }
.gp-anim-float-slow { animation: gp-float-slow 7s ease-in-out infinite; }
@media (prefers-reduced-motion: reduce) {
  .gp-anim-fade, .gp-anim-fade-2, .gp-anim-spin, .gp-anim-float, .gp-anim-float-slow { animation: none !important; }
}
```

- [ ] **Step 4: Commit**

```bash
git add css/gowise.css
git commit -m "feat: served css/gowise.css with base, header/footer, responsive, anim utils"
```

---

## Task 5: Layout + header/footer partials (real content)

**Files:**
- Modify: `src/layout.html` (replace Task 1 fixture with the real skeleton)
- Modify: `src/partials/header.html` (replace fixture with converted nav)
- Modify: `src/partials/footer.html` (replace fixture with converted footer)

**Interfaces:**
- Consumes: `css/gowise.css` classes from Task 4; `js/reveal.js`, `js/nav.js` from Tasks 2–3.
- Produces: the shared skeleton every page renders into. Header/footer contain zero inline `<style>` and zero DC attributes.

- [ ] **Step 1: Write the real `src/layout.html`**

```html
<!DOCTYPE html>
<html lang="vi">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<!-- Google tag (gtag.js) -->
<script async src="https://www.googletagmanager.com/gtag/js?id=G-HJ6WBCD2DM"></script>
<script>
  window.dataLayer = window.dataLayer || [];
  function gtag(){dataLayer.push(arguments);}
  gtag('js', new Date());
  gtag('config', 'G-HJ6WBCD2DM');
</script>
<title>{{title}}</title>
<meta name="description" content="{{description}}">
<link rel="canonical" href="{{canonical}}">
<meta property="og:type" content="website">
<meta property="og:site_name" content="GoWise Partners">
<meta property="og:locale" content="vi_VN">
<meta property="og:url" content="{{canonical}}">
<meta property="og:title" content="{{ogTitle}}">
<meta property="og:description" content="{{description}}">
<meta property="og:image" content="{{ogImage}}">
<meta property="og:image:width" content="1200">
<meta property="og:image:height" content="630">
<meta name="twitter:card" content="summary_large_image">
<meta name="twitter:title" content="{{ogTitle}}">
<meta name="twitter:description" content="{{description}}">
<meta name="twitter:image" content="{{ogImage}}">
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin="">
<link href="https://fonts.googleapis.com/css2?family=Playfair+Display:ital,wght@0,400;0,500;0,600;0,700;1,400;1,500&family=Montserrat:wght@400;500;600;700&display=swap" rel="stylesheet">
<link rel="stylesheet" href="css/gowise.css">
{{head_extra}}
</head>
<body class="{{body_class}}">
<!--#include header-->
<main>
{{content}}
</main>
<!--#include footer-->
<script src="js/reveal.js"></script>
<script src="js/nav.js"></script>
</body>
</html>
```

- [ ] **Step 2: Write the real `src/partials/header.html`** (converted from `Header.dc.html`: DC attrs removed, inline styles → classes from Task 4, `style-hover`/`onClick`/`{{ }}` removed, hooks are `data-*` + ids that `nav.js` binds)

```html
<header id="gp-hdr" data-screen-label="Header">
  <div class="gp-hdr-inner">
    <a href="./" style="display: flex; align-items: center; flex-shrink: 0;">
      <img src="assets/logo-wordmark-gold.png" alt="GoWise Partners — Strategic Management Coaching" style="height: 42px; width: auto; display: block;">
    </a>

    <nav class="gp-desktop-nav">
      <a href="./" class="gp-navlink" data-nav="home">TRANG CHỦ</a>

      <div style="position: relative;" data-train-wrap>
        <button type="button" class="gp-train-btn" data-nav="train">
          CHƯƠNG TRÌNH
          <span style="font-size: 9px; opacity: 0.8;">▼</span>
        </button>
        <div id="gp-train-menu" class="gp-train-menu">
          <a href="Chuyen_Gia_Khai_Van_Hieu_Suat_Cao" class="gp-drop-item">Chuyên gia Khai vấn Hiệu suất cao</a>
          <a href="Khai-Van_Quan_Tri_Chuyen_Nghiep" class="gp-drop-item">Chuyên gia Khai vấn Quản trị</a>
          <a href="Khai_Van_Hieu_Suat_Thuc_Chien" class="gp-drop-item">WS Khai vấn Hiệu suất cao thực chiến</a>
        </div>
      </div>

      <a href="Lien_He" class="gp-navlink" data-nav="contact">LIÊN HỆ</a>
    </nav>

    <a href="Lien_He" class="gp-desktop-cta">Đặt lịch tư vấn</a>

    <button type="button" class="gp-burger" aria-label="Menu">
      <span style="display: block; width: 20px; height: 14px; position: relative;">
        <span style="position: absolute; top: 0; left: 0; width: 100%; height: 2px; background: #E7D0A2;"></span>
        <span style="position: absolute; top: 6px; left: 0; width: 100%; height: 2px; background: #E7D0A2;"></span>
        <span style="position: absolute; top: 12px; left: 0; width: 100%; height: 2px; background: #E7D0A2;"></span>
      </span>
    </button>
  </div>

  <div id="gp-mnav" class="gp-mobile-panel">
    <a href="./" class="gp-navlink" style="display: block; padding: 15px 0; border-bottom: 1px solid rgba(201,166,104,0.1); font-size: 15px;">TRANG CHỦ</a>
    <button type="button" class="gp-train-btn" data-train-mobile-btn style="width: 100%; text-align: left; justify-content: space-between; border-bottom: 1px solid rgba(201,166,104,0.1); font-size: 15px; padding: 15px 0;">
      ĐÀO TẠO
      <span style="font-size: 10px; color: #B98A48;">▼</span>
    </button>
    <div id="gp-train-mobile" class="gp-train-mobile">
      <a href="Chuyen_Gia_Khai_Van_Hieu_Suat_Cao" style="color: #B7C2CE; font-size: 13.5px; padding: 11px 0; line-height: 1.4;">Chuyên gia Khai vấn Hiệu suất cao</a>
      <a href="Khai-Van_Quan_Tri_Chuyen_Nghiep" style="color: #B7C2CE; font-size: 13.5px; padding: 11px 0; line-height: 1.4;">Chuyên gia Khai vấn Quản trị</a>
      <a href="Khai_Van_Hieu_Suat_Thuc_Chien" style="color: #B7C2CE; font-size: 13.5px; padding: 11px 0; line-height: 1.4;">WS Khai vấn Hiệu suất cao thực chiến</a>
    </div>
    <a href="Lien_He" class="gp-navlink" style="display: block; padding: 15px 0; border-bottom: 1px solid rgba(201,166,104,0.1); font-size: 15px;">LIÊN HỆ</a>
    <a href="Lien_He" style="display: inline-flex; margin-top: 18px; background: linear-gradient(180deg, #E7D0A2, #C9A668); color: #07121F; font-size: 12px; font-weight: 700; letter-spacing: 0.06em; padding: 13px 24px;">Đặt lịch tư vấn</a>
  </div>
</header>
```

- [ ] **Step 3: Write the real `src/partials/footer.html`** (converted from `Footer.dc.html`; footer has no interactivity)

```html
<footer id="gp-ftr" data-screen-label="Footer">
  <div class="gp-fgrid">
    <div>
      <img src="assets/logo-wordmark-gold.png" alt="GoWise Partners — Strategic Management Coaching" style="height: 42px; width: auto; display: block;">
      <p style="font-size: 13.5px; line-height: 1.7; color: #8193A4; margin-top: 20px; max-width: 320px;">Strategic Management Coaching — Đối tác hiệu suất chiến lược của bạn. Kết hợp tư duy quản trị, nghệ thuật khai vấn và công nghệ AI.</p>
    </div>
    <div>
      <div style="font-size: 11px; letter-spacing: 0.2em; color: #B98A48; font-weight: 600; margin-bottom: 18px;">HỆ SINH THÁI</div>
      <div style="display: flex; flex-direction: column; gap: 13px;">
        <a href="Chuyen_Gia_Khai_Van_Hieu_Suat_Cao" class="gp-flink">Chuyên gia Khai vấn Hiệu suất cao</a>
        <a href="Khai-Van_Quan_Tri_Chuyen_Nghiep" class="gp-flink">Chuyên gia Khai vấn Quản trị</a>
        <a href="Khai_Van_Hieu_Suat_Thuc_Chien" class="gp-flink">WS Khai vấn Hiệu suất cao thực chiến</a>
      </div>
    </div>
    <div>
      <div style="font-size: 11px; letter-spacing: 0.2em; color: #B98A48; font-weight: 600; margin-bottom: 18px;">LIÊN HỆ</div>
      <div style="display: flex; flex-direction: column; gap: 14px;">
        <div>
          <div style="font-size: 11px; letter-spacing: 0.06em; color: #8193A4; margin-bottom: 4px;">Hotline / Zalo</div>
          <a href="tel:0868680793" style="color: #F7F1E7; font-size: 17px; font-weight: 600; font-family: 'Playfair Display', serif;">0868 680 793</a>
          <span style="color: #8193A4; font-size: 13px;"> · Mr. Huy</span>
        </div>
        <a href="mailto:info@gwp.vn" class="gp-flink">info@gwp.vn</a>
        <div style="display: flex; gap: 18px; margin-top: 4px;">
          <a href="#" class="gp-flink" style="font-size: 13px;">LinkedIn</a>
          <a href="#" class="gp-flink" style="font-size: 13px;">Facebook</a>
          <a href="#" class="gp-flink" style="font-size: 13px;">YouTube</a>
        </div>
      </div>
    </div>
  </div>
  <div class="gp-fbottom">
    <span>© 2026 GOWISE PARTNERS</span>
    <span>STRATEGIC MANAGEMENT COACHING</span>
  </div>
</footer>
```

- [ ] **Step 4: Commit**

```bash
git add src/layout.html src/partials/header.html src/partials/footer.html
git commit -m "feat: real layout skeleton + static header/footer partials"
```

---

## Page conversion tasks (6–10): shared procedure

Each page task converts one `<x-dc>` template into a `src/pages/<Name>.html` body, builds, and verifies pixel-parity. **Before converting, capture a baseline screenshot of the current (pre-refactor) page** so you can diff. Because `main` is untouched, serve the original from a separate checkout or capture baselines up front in Task 6 Step 1.

**Transformation rules (apply to every page):**
1. Copy the per-page `<head>` `<meta>` values (title, description, canonical, og:*, twitter:*) into the page's front-matter block (`title`, `description`, `canonical`, `ogTitle`, `ogImage`).
2. Take everything inside `<div id="gp-root">…</div>` as the body. Drop the `id="gp-root"` wrapper's inline font/color styles (now on `body` via `css/gowise.css`); if a page relies on `#gp-root` context, wrap the body in `<div class="gp-page">` instead — but prefer no wrapper.
3. Remove `<dc-import name="Header">`/`<dc-import name="Footer">` — the layout injects them.
4. Expand every `<sc-for list="{{ x }}" as="item">…{{ item.field }}…</sc-for>` into static repeated markup using the values from that page's `renderVals()` block (bottom `<script type="text/x-dc">`). Interpolations `{{ … }}` become literal text.
5. Convert inline `style="…"` to classes: **first** reuse existing `css/gowise.css` classes (`.gp-container`, `.gp-section(-dark|-darker|-light)`, `.gp-hero-bg`, `.gp-eyebrow`, `.gp-display`, `.gp-h2`, `.gp-h3`, `.gp-lead`, `.gp-body`, `.gp-btn`, `.gp-btn-outline`, `.gp-card-dark`, `.gp-card-light`, `.gp-list`, `.gp-icon-ring`, `.gp-icon-chip`, `.gp-reveal(--l|--r)`, `.gp-accent`, `.gp-serif-quote`, `.gp-divider`, `.gp-text-link`, `.gp-eyebrow-num`, `.gp-image-overlay`); keep layout/grid class names the responsive rules depend on (`.gp-hero-grid`, `.gp-hero-visual`, `.gp-hero-photo`, `.gp-spin-ring`, `.gp-2col`, `.gp-3col`, `.gp-experts-grid`, `.gp-lead-card`, `.gp-lead-img`, `.gp-about-img-wrap`, `.gp-about-badge`, `.gp-sol-card`, `.gp-trust-bar`). Truly one-off styles may remain as inline `style` on that element (acceptable when unique) OR go to `css/pages/<name>.css` linked via `headExtra` if the page has a recurring page-specific pattern.
6. Replace `style-hover="…"` with a real CSS `:hover` rule (reuse `.gp-btn`/`.gp-btn-outline` where the hover matches; otherwise add a small page-specific class).
7. Replace inline `animation: gpFade…/gpSpin…/gpFloat…` with `.gp-anim-fade`, `.gp-anim-fade-2`, `.gp-anim-spin`, `.gp-anim-float`, `.gp-anim-float-slow`.
8. Replace `<image-slot … src="URL" …>` with `<img src="URL" alt="…" loading="lazy" style="width:100%;height:100%;object-fit:cover;">` (use the slot's `fit` to choose `object-fit`; `alt` from the slot `placeholder`/context). Keep the wrapping element's classes/inline styles.
9. Keep `data-svg="…"`, `data-count="…"`, `data-stagger`, `.gp-reveal` attributes as-is — `reveal.js` drives them.
10. Delete the trailing `<script type="text/x-dc">` block entirely.

**Verification (every page):** in the browser preview (`static` server on :8777),
- the built page loads with **zero console errors**,
- the **network panel shows no request to `unpkg.com`, `react`, or `support.js`**,
- scroll-reveal + any count-up fire; dropdown/mobile-menu work (header),
- desktop (1280) and mobile (390) screenshots match the baseline (no layout drift).

---

## Task 6: Convert `index.html` (reference page)

**Files:**
- Create: `src/pages/index.html`
- Modify (build output): `index.html`
- Reference: current `index.html` (lines 84–301 body; 302–388 `renderVals`).

- [ ] **Step 1: Capture baselines of ALL five current pages**

Start preview server `static` (:8777). For each current root page, capture desktop (1280×900) + mobile (390×844) screenshots to `screenshots/baseline/<name>-{desktop,mobile}.png`. (Do this once, now, before any root file is overwritten.)

- [ ] **Step 2: Delete the `_smoke.html` fixture (no longer needed)**

```bash
git rm src/pages/_smoke.html
```

- [ ] **Step 3: Write `src/pages/index.html`**

Apply the shared transformation rules to the current `index.html`. Front-matter uses the existing meta:
```
title: GoWise Partners | Khai Vấn Hiệu Suất & Phát Triển Lãnh Đạo
description: GoWise Partners kết hợp quản trị chiến lược, khai vấn chuyên nghiệp và công nghệ AI, giúp lãnh đạo và tổ chức tạo ra kết quả đo lường được.
canonical: https://www.gwp.vn/
ogImage: https://www.gwp.vn/images/og-index.jpg
```
Expand the four `renderVals()` collections (`clients`, `articles`, `leads`, `experts`) into static markup. Convert the hero `<image-slot>`s to `<img>`. Keep all `.gp-hero-*`, `.gp-2col`, `.gp-3col`, `.gp-experts-grid`, `.gp-lead-*`, `.gp-trust-bar` class names.

- [ ] **Step 4: Build**

Run: `node build.mjs`
Expected: `✓ index.html -> index.html` and `Built 1 page(s).`

- [ ] **Step 5: Verify in browser**

Reload `http://localhost:8777/index.html`. Confirm: zero console errors; **no `unpkg`/`react`/`support.js` network requests**; hero animations + trust-bar reveal + stat count-ups fire; header dropdown + mobile menu work. Screenshot desktop + mobile and compare to `screenshots/baseline/index-*`. Fix source until parity holds.

- [ ] **Step 6: Commit**

```bash
git add src/pages/index.html index.html
git rm -q src/pages/_smoke.html 2>/dev/null || true
git commit -m "refactor: convert index.html to static (parity verified)"
```

---

## Task 7: Convert `Lien_He.html`

**Files:**
- Create: `src/pages/Lien_He.html`
- Modify (build output): `Lien_He.html`
- Reference: current `Lien_He.html`.

**Note:** this page has a contact form. Preserve the exact form markup, field names, `action`/`method`, and any submit handling. If submission was wired through the DC Component, re-implement the same behavior in a small `js/contact.js` (add `<script src="js/contact.js">` via `headExtra` or append to layout only if every page needs it — prefer `headExtra`). Do not change where the form submits.

- [ ] **Step 1: Inspect the form's current submit path**

Read the current `Lien_He.html` `<script type="text/x-dc">` block. Determine how the form submits (native `action`, `fetch`, mailto, or third-party). Record it. If there is JS logic, plan `js/contact.js` with the identical behavior.

- [ ] **Step 2: Write `src/pages/Lien_He.html`**

Apply the shared transformation rules. Front-matter:
```
title: Liên hệ | GoWise Partners
description: (copy from current Lien_He.html meta description)
canonical: https://www.gwp.vn/Lien_He
ogImage: https://www.gwp.vn/images/og-lien-he.jpg
```
(Use the exact description string from the current file.) If form JS exists, create `js/contact.js` with identical behavior and reference it via `headExtra`.

- [ ] **Step 3: Build**

Run: `node build.mjs`
Expected: includes `✓ Lien_He.html -> Lien_He.html`.

- [ ] **Step 4: Verify in browser**

Load `http://localhost:8777/Lien_He.html`. Zero console errors; no `unpkg`/`react`/`support.js`; **fill and submit the form** — confirm it behaves exactly as before (same endpoint / same success state). Screenshot desktop + mobile vs baseline.

- [ ] **Step 5: Commit**

```bash
git add src/pages/Lien_He.html Lien_He.html js/contact.js 2>/dev/null
git commit -m "refactor: convert Lien_He.html to static (form parity verified)"
```

---

## Task 8: Convert `Khai_Van_Hieu_Suat_Thuc_Chien.html`

**Files:**
- Create: `src/pages/Khai_Van_Hieu_Suat_Thuc_Chien.html`
- Modify (build output): `Khai_Van_Hieu_Suat_Thuc_Chien.html`
- Reference: current file (this is the DESIGN.md reference implementation — treat parity as strict).

- [ ] **Step 1: Write `src/pages/Khai_Van_Hieu_Suat_Thuc_Chien.html`**

Apply shared rules. Front-matter title/description/canonical/ogImage copied verbatim from the current file's meta (`canonical: https://www.gwp.vn/Khai_Van_Hieu_Suat_Thuc_Chien`, `ogImage: https://www.gwp.vn/images/og-khai-van-hieu-suat-thuc-chien.jpg`). Expand any `sc-for`; convert `image-slot`s; map inline styles to gowise classes.

- [ ] **Step 2: Build**

Run: `node build.mjs`
Expected: includes `✓ Khai_Van_Hieu_Suat_Thuc_Chien.html -> …`.

- [ ] **Step 3: Verify in browser** (same checklist; screenshots vs baseline).

- [ ] **Step 4: Commit**

```bash
git add "src/pages/Khai_Van_Hieu_Suat_Thuc_Chien.html" "Khai_Van_Hieu_Suat_Thuc_Chien.html"
git commit -m "refactor: convert Khai_Van_Hieu_Suat_Thuc_Chien.html to static"
```

---

## Task 9: Convert `Chuyen_Gia_Khai_Van_Hieu_Suat_Cao.html`

**Files:**
- Create: `src/pages/Chuyen_Gia_Khai_Van_Hieu_Suat_Cao.html`
- Modify (build output): `Chuyen_Gia_Khai_Van_Hieu_Suat_Cao.html`
- Reference: current file (738 lines, 220 inline styles — the heaviest; expect the most class extraction).

- [ ] **Step 1: Write `src/pages/Chuyen_Gia_Khai_Van_Hieu_Suat_Cao.html`**

Apply shared rules. Front-matter meta copied verbatim (`canonical: https://www.gwp.vn/Chuyen_Gia_Khai_Van_Hieu_Suat_Cao`, `ogImage: https://www.gwp.vn/images/og-chuyen-gia-khai-van-hieu-suat-cao.jpg`). Where a styling pattern repeats within this page and isn't already a gowise class, add a page-scoped class in `css/pages/chuyen-gia.css` (linked via `headExtra`) rather than repeating inline styles.

- [ ] **Step 2: Build**

Run: `node build.mjs`
Expected: includes the page's build line.

- [ ] **Step 3: Verify in browser** (same checklist; screenshots vs baseline).

- [ ] **Step 4: Commit**

```bash
git add "src/pages/Chuyen_Gia_Khai_Van_Hieu_Suat_Cao.html" "Chuyen_Gia_Khai_Van_Hieu_Suat_Cao.html" css/pages/chuyen-gia.css 2>/dev/null
git commit -m "refactor: convert Chuyen_Gia_Khai_Van_Hieu_Suat_Cao.html to static"
```

---

## Task 10: Convert `Khai-Van_Quan_Tri_Chuyen_Nghiep.html`

**Files:**
- Create: `src/pages/Khai-Van_Quan_Tri_Chuyen_Nghiep.html`
- Modify (build output): `Khai-Van_Quan_Tri_Chuyen_Nghiep.html`
- Reference: current file (821 lines, 330 inline styles — largest).

- [ ] **Step 1: Write `src/pages/Khai-Van_Quan_Tri_Chuyen_Nghiep.html`**

Apply shared rules. Front-matter meta copied verbatim (`canonical: https://www.gwp.vn/Khai-Van_Quan_Tri_Chuyen_Nghiep`, `ogImage: https://www.gwp.vn/images/og-khai-van-quan-tri-chuyen-nghiep.jpg`). Reuse gowise + any classes introduced in Task 9; add `css/pages/quan-tri.css` only for genuinely page-specific recurring patterns.

- [ ] **Step 2: Build**

Run: `node build.mjs`
Expected: includes the page's build line, `Built 5 page(s).`

- [ ] **Step 3: Verify in browser** (same checklist; screenshots vs baseline).

- [ ] **Step 4: Commit**

```bash
git add "src/pages/Khai-Van_Quan_Tri_Chuyen_Nghiep.html" "Khai-Van_Quan_Tri_Chuyen_Nghiep.html" css/pages/quan-tri.css 2>/dev/null
git commit -m "refactor: convert Khai-Van_Quan_Tri_Chuyen_Nghiep.html to static"
```

---

## Task 11: Remove DC runtime + sync machinery, update docs

**Files:**
- Delete: `support.js`, `fix-dc.sh`, `tailwind.config.js`, `.image-slots.state.json`, `image-slot.js`, `Header.dc.html`, `Footer.dc.html`, `.claude/design-sync.json`
- Modify: `CLAUDE.md`, `DESIGN.md`, `.gitignore`

**Interfaces:**
- Consumes: all 5 pages converted and verified (Tasks 6–10). This task must run only after the final page passes.

- [ ] **Step 1: Confirm nothing served references the removed files**

Run:
```bash
grep -rn "support.js\|image-slot\|dc-import\|x-dc\|design-sync" index.html Lien_He.html Khai_Van_Hieu_Suat_Thuc_Chien.html Chuyen_Gia_Khai_Van_Hieu_Suat_Cao.html Khai-Van_Quan_Tri_Chuyen_Nghiep.html src/ && echo "FOUND REFS (fix before deleting)" || echo "CLEAN"
```
Expected: `CLEAN`.

- [ ] **Step 2: Delete DC/runtime/sync files**

```bash
git rm support.js fix-dc.sh tailwind.config.js .image-slots.state.json image-slot.js Header.dc.html Footer.dc.html .claude/design-sync.json
```

- [ ] **Step 3: Update `CLAUDE.md`**

Replace the "Syncing from Claude Design" section and the `.dc.html`/`fix-dc.sh` build notes with the new static workflow: edit `src/`, run `node build.mjs`, commit both `src/` and the built root `*.html`. Remove references to `<dc-import>`, `support.js`, `data-svg` injection being DC-specific (the `data-svg` pattern stays, now driven by `js/reveal.js`). Keep the brand-lock rules pointing at `css/gowise.css` (served) with `brand/gowise.css` noted as the dev token reference.

- [ ] **Step 4: Update `DESIGN.md`**

Update any snippet/reference that mentions the DC runtime, `support.js`, or `<x-dc>` to point at `css/gowise.css` + `js/reveal.js`. The §11 scroll-reveal/count-up snippet now lives in `js/reveal.js`.

- [ ] **Step 5: Update `.gitignore`**

Remove `fix-dc.sh` from ignore (file deleted). Leave `/brand/` ignored (dev-only). Ensure `css/`, `js/`, `src/` are NOT ignored. Add `screenshots/baseline/` if you don't want baselines committed (optional).

- [ ] **Step 6: Rebuild to confirm the build still works standalone**

Run: `node build.mjs`
Expected: `Built 5 page(s).` with no errors.

- [ ] **Step 7: Commit**

```bash
git add -A
git commit -m "chore: remove DC runtime + sync machinery; update docs for static build"
```

---

## Task 12: Final full verification

**Files:** none (verification only).

- [ ] **Step 1: Clean build from scratch**

```bash
node build.mjs
```
Expected: `Built 5 page(s).`

- [ ] **Step 2: Grep the built output for any leftover DC constructs**

Run:
```bash
grep -rn "x-dc\|dc-import\|sc-for\|style-hover\|{{ \|data-dc-script\|unpkg.com" index.html Lien_He.html Khai_Van_Hieu_Suat_Thuc_Chien.html Chuyen_Gia_Khai_Van_Hieu_Suat_Cao.html Khai-Van_Quan_Tri_Chuyen_Nghiep.html && echo "LEFTOVER DC FOUND" || echo "CLEAN"
```
Expected: `CLEAN`.

- [ ] **Step 3: Browser pass over all five pages**

For each page at desktop (1280) and mobile (390): load via :8777, confirm zero console errors, no `unpkg`/`react`/`support.js` network requests, animations + interactions work, and screenshot matches the Task 6 baseline. Navigate every header/footer link and confirm it resolves (extensionless links work under the static server path or note that GitHub Pages resolves them).

- [ ] **Step 4: Verify links + assets return 200**

Run:
```bash
for p in / index.html Lien_He.html Khai_Van_Hieu_Suat_Thuc_Chien.html Chuyen_Gia_Khai_Van_Hieu_Suat_Cao.html Khai-Van_Quan_Tri_Chuyen_Nghiep.html css/gowise.css js/reveal.js js/nav.js; do
  code=$(curl -s -o /dev/null -w "%{http_code}" "http://localhost:8777/$p"); echo "$code  $p";
done
```
Expected: all `200`.

- [ ] **Step 5: Finish the branch**

Use `superpowers:finishing-a-development-branch` to open the PR for review (full commit history is already in place per the per-task commits).

---

## Self-Review notes (author)

- **Spec coverage:** every spec section maps to a task — build script (T1), reveal/svg/count-up (T2), header behavior (T3), CSS extraction + tokens + responsive (T4), layout + partials (T5), per-page static conversion + image-slot→img + sc-for expansion (T6–T10), removal of DC runtime/sync + doc updates (T11), final parity + no-CDN verification (T12).
- **Gotchas encoded:** served CSS at `css/` not gitignored `brand/`; class names the responsive breakpoints depend on must be preserved on page elements; reduced-motion moved from `[style*=…]` hooks to `.gp-anim-*` classes; `Lien_He` form behavior must be preserved exactly; `Khai_Van_Hieu_Suat_Thuc_Chien` is the strict-parity reference page.
- **Deferred-but-specified:** the full converted HTML of each page is not inlined (it is a mechanical transform of ~2,700 lines gated by pixel-parity verification); the transformation rules + class contract + verification checklist are the acceptance criteria.
