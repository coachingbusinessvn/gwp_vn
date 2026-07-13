# Parity-First Static Conversion Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (- [ ]) syntax for tracking.

**Goal:** Convert all five GoWise Partners pages from client-rendered DC templates to tested, dependency-free static HTML while preserving every visual state, interaction, URL, and content item.

**Architecture:** Migrate one page at a time through two gates. Layer A removes DC/React and restores the current behavior while preserving page scope and exact styling; Layer B moves inline styling into shared or page-scoped CSS and proves parity again. A zero-dependency Node build validates every rendered page before writing root output, while small vanilla-JS controllers own reveal/count-up, navigation, program tabs/FAQ, and contact submission.

**Tech Stack:** Static HTML, plain CSS, vanilla JavaScript, Node 18 or newer with node:test and standard-library APIs only, Python http.server, and the available browser automation skill for visual and interaction verification.

---

## Non-negotiable constraints

- Final desktop and mobile screenshots match the original pages.
- No content, visual design, brand token, public filename, or internal URL changes.
- No React, ReactDOM, Babel, DC runtime, npm runtime package, or unpkg request.
- The page root ids gp-root, lh-root, kv-root, hpc-root, and mc-root remain.
- Every sc-for, sc-if, data-html value, component state, and DC event handler has an explicit static equivalent before the DC script is removed.
- Shared partials contain no style attributes, style-hover attributes, DC attributes, or hard-coded colors.
- Above-the-fold hero images load eagerly; below-the-fold images use loading=\"lazy\".
- All animations stop under prefers-reduced-motion: reduce.
- Tracked root HTML is build output; both source and output are committed.
- Commit after every task only after its verification commands pass.

## Behavior inventory

| Page | Required behavior |
|---|---|
| index.html | SVG injection, 75 ms stagger, grouped 900 ms count-up, reveal animation, shared navigation |
| Lien_He.html | SVG injection, reveal animation, Web3Forms captcha, mocked success/error submission states |
| Khai_Van_Hieu_Suat_Thuc_Chien.html | SVG injection, 75 ms stagger, plain 900 ms count-up, showChallengeNumbers=true |
| Chuyen_Gia_Khai_Van_Hieu_Suat_Cao.html | SVG and data-html expansion, 70 ms stagger, plain 900 ms count-up, three module tabs with Module 1 initially selected |
| Khai-Van_Quan_Tri_Chuyen_Nghiep.html | SVG injection, 70 ms stagger, grouped 1000 ms count-up, four module tabs with first selected, four FAQ items with first open |

## Target files

**Create:**

- build.mjs
- tests/build.test.mjs
- tests/static-contract.test.mjs
- tests/fixtures/reveal.html
- tests/fixtures/nav.html
- tests/fixtures/program-ui.html
- tests/fixtures/contact.html
- src/layout.html
- src/partials/header.html
- src/partials/footer.html
- src/pages/index.html
- src/pages/Lien_He.html
- src/pages/Khai_Van_Hieu_Suat_Thuc_Chien.html
- src/pages/Chuyen_Gia_Khai_Van_Hieu_Suat_Cao.html
- src/pages/Khai-Van_Quan_Tri_Chuyen_Nghiep.html
- css/gowise.css
- css/pages/index.css
- css/pages/contact.css
- css/pages/workshop.css
- css/pages/performance-coach.css
- css/pages/management-coach.css
- js/reveal.js
- js/nav.js
- js/contact.js
- js/program-ui.js
- docs/static-conversion-baseline.md

**Modify:**

- the five root HTML outputs
- .gitignore
- CLAUDE.md
- DESIGN.md

**Delete only after all five pages pass:**

- tracked: support.js, image-slot.js, .image-slots.state.json, Header.dc.html, Footer.dc.html
- ignored local files when present: fix-dc.sh, .claude/design-sync.json, .claude/commands/design-sync.md

The ignored brand/tailwind.config.js remains a development token reference. There is no root tailwind.config.js to remove.

---

## Task 0: Create the worktree and freeze the baseline

**Files:**

- Create: docs/static-conversion-baseline.md
- Create locally: screenshots/baseline/*

- [ ] **Step 1: Create the isolated worktree**

Use superpowers:using-git-worktrees to create branch refactor/static-conversion from main. Run every later command inside that worktree.

- [ ] **Step 2: Confirm the starting tree**

Run:

~~~bash
git status --short
git branch --show-current
~~~

Expected: no status output and branch refactor/static-conversion.

- [ ] **Step 3: Start the original static preview**

Run:

~~~bash
python3 -m http.server 8777
~~~

Expected: server listens on port 8777 and the five root .html URLs load.

- [ ] **Step 4: Capture deterministic initial screenshots**

Using the browser automation skill:

1. Set viewport to 1280×900.
2. Open each root .html URL directly.
3. Wait for document.fonts.ready and every image to complete.
4. Emulate prefers-reduced-motion: reduce.
5. Capture a full-page PNG under screenshots/baseline/<page>-desktop.png.
6. Repeat at 390×844 under screenshots/baseline/<page>-mobile.png.

Expected: ten initial-state screenshots.

- [ ] **Step 5: Capture interactive states**

Capture:

- HPC modules 1, 2, and 3 at desktop;
- Management Coaching modules 1 through 4 at desktop;
- Management Coaching FAQ items 1 through 4 open individually;
- desktop program dropdown open;
- mobile navigation and mobile program submenu open;
- contact form captcha-required state.

Expected: every current state has a named baseline image.

- [ ] **Step 6: Record the frozen contract**

Write docs/static-conversion-baseline.md with:

~~~markdown
# Static Conversion Baseline

## Viewports
- Desktop: 1280×900, full page
- Mobile: 390×844, full page
- Screenshot mode: prefers-reduced-motion = reduce

## Initial UI state
- Header menus: closed
- HPC program: Module 1 selected
- Management Coaching program: Module 1 selected
- Management Coaching FAQ: first item open
- Contact success/error messages: hidden

## Count-up behavior
- index: grouped, 900 ms
- workshop: plain, 900 ms
- performance coach: plain, 900 ms
- management coach: grouped, 1000 ms

## Interaction matrix
- Header desktop dropdown: hover and click
- Header mobile menu: open/close
- Header mobile program submenu: open/close
- HPC: all 3 module tabs
- Management Coaching: all 4 module tabs
- Management Coaching: all 4 FAQ toggles
- Contact: captcha required, mocked success, mocked failure
~~~

- [ ] **Step 7: Commit**

~~~bash
git add docs/static-conversion-baseline.md
git commit -m "docs: freeze static conversion baseline contract"
~~~

---

## Task 1: Build script through node:test

**Files:**

- Create: tests/build.test.mjs
- Create: build.mjs
- Create: src/layout.html
- Create: src/partials/header.html
- Create: src/partials/footer.html
- Create: src/pages/_smoke.html

### Build API

- parseFrontMatter(raw, file)
- renderPage({ layout, partials, raw, file })
- validateOutput(html, file)
- buildSite(root, { write })
- CLI: node build.mjs

- [ ] **Step 1: Write the failing build tests**

Create tests/build.test.mjs:

~~~js
import test from 'node:test';
import assert from 'node:assert/strict';
import {
  mkdtempSync, mkdirSync, writeFileSync, existsSync, readFileSync,
} from 'node:fs';
import { join } from 'node:path';
import { tmpdir } from 'node:os';
import {
  parseFrontMatter, renderPage, validateOutput, buildSite,
} from '../build.mjs';

function fixture() {
  const root = mkdtempSync(join(tmpdir(), 'gwp-build-'));
  mkdirSync(join(root, 'src', 'partials'), { recursive: true });
  mkdirSync(join(root, 'src', 'pages'), { recursive: true });
  writeFileSync(join(root, 'src', 'layout.html'), [
    '<!doctype html><html><head>',
    '<title>{{title}}</title>',
    '<meta name="description" content="{{description}}">',
    '<link rel="canonical" href="{{canonical}}">',
    '<meta property="og:title" content="{{ogTitle}}">',
    '<meta property="og:image" content="{{ogImage}}">',
    '{{head_extra}}</head><body class="{{body_class}}">',
    '<!--#include header--><main>{{content}}</main>',
    '<!--#include footer--></body></html>',
  ].join(''));
  writeFileSync(join(root, 'src', 'partials', 'header.html'), '<header>H</header>');
  writeFileSync(join(root, 'src', 'partials', 'footer.html'), '<footer>F</footer>');
  return root;
}

function page(extra = '', body = '<section>BODY</section>') {
  return [
    '<!--',
    'title: Page title',
    'description: Page description',
    'canonical: https://www.gwp.vn/Page',
    'ogImage: https://www.gwp.vn/images/og.jpg',
    extra,
    '-->',
    body,
  ].filter(Boolean).join('\n');
}

test('parseFrontMatter rejects duplicate keys', () => {
  assert.throws(
    () => parseFrontMatter(page('title: Duplicate'), 'Page.html'),
    /duplicate front-matter key "title"/,
  );
});

test('renderPage applies includes, escaping, fallback, and optional values', () => {
  const layout = '<title>{{title}}</title>{{head_extra}}<!--#include header-->' +
    '<main class="{{body_class}}">{{content}}</main><!--#include footer-->' +
    '<meta property="og:title" content="{{ogTitle}}">';
  const out = renderPage({
    layout,
    partials: { header: '<header>H</header>', footer: '<footer>F</footer>' },
    raw: page(
      'bodyClass: page-test\nheadExtra: <link rel="stylesheet" href="x.css">',
    ).replace('Page title', 'A & "B"'),
    file: 'Page.html',
  });
  assert.match(out, /<header>H<\/header>/);
  assert.match(out, /<footer>F<\/footer>/);
  assert.match(out, /class="page-test"/);
  assert.match(out, /href="x.css"/);
  assert.match(out, /<title>A &amp; &quot;B&quot;<\/title>/);
  assert.match(out, /og:title" content="A &amp; &quot;B&quot;"/);
});

test('renderPage rejects missing required metadata', () => {
  const raw = '<!--\ntitle: X\n-->\n<section>X</section>';
  assert.throws(
    () => renderPage({
      layout: '{{content}}',
      partials: { header: '', footer: '' },
      raw,
      file: 'bad.html',
    }),
    /missing required front-matter key "description"/,
  );
});

test('renderPage rejects unknown placeholders', () => {
  assert.throws(
    () => renderPage({
      layout: '{{content}}{{unknown}}',
      partials: { header: '', footer: '' },
      raw: page(),
      file: 'bad.html',
    }),
    /unknown layout placeholder "unknown"/,
  );
});

test('validateOutput rejects every DC/runtime family', () => {
  const bad = [
    '<x-dc></x-dc>',
    '<sc-if value="x">x</sc-if>',
    '<span data-html="x"></span>',
    '<button onClick="{{ action }}">x</button>',
    '<script src="support.js"></script>',
    '<script src="https://unpkg.com/react"></script>',
  ];
  for (const html of bad) {
    assert.throws(() => validateOutput(html, 'bad.html'), /forbidden static output/);
  }
});

test('buildSite skips private fixtures and returns unchanged basenames', () => {
  const root = fixture();
  writeFileSync(join(root, 'src', 'pages', '_smoke.html'), page());
  writeFileSync(join(root, 'src', 'pages', 'index.html'), page());
  const outputs = buildSite(root, { write: false });
  assert.deepEqual([...outputs.keys()], ['index.html']);
  assert.match(outputs.get('index.html'), /<section>BODY<\/section>/);
});

test('buildSite validates every page before writing any output', () => {
  const root = fixture();
  writeFileSync(join(root, 'src', 'pages', 'good.html'), page());
  writeFileSync(
    join(root, 'src', 'pages', 'bad.html'),
    page('', '<sc-for>BAD</sc-for>'),
  );
  assert.throws(() => buildSite(root), /forbidden static output/);
  assert.equal(existsSync(join(root, 'good.html')), false);
  assert.equal(existsSync(join(root, 'bad.html')), false);
});

test('buildSite writes validated output', () => {
  const root = fixture();
  writeFileSync(join(root, 'src', 'pages', 'index.html'), page());
  buildSite(root);
  assert.match(readFileSync(join(root, 'index.html'), 'utf8'), /<header>H<\/header>/);
});
~~~

- [ ] **Step 2: Run tests and verify RED**

Run:

~~~bash
node --test tests/build.test.mjs
~~~

Expected: FAIL because build.mjs does not exist.

- [ ] **Step 3: Write the minimal tested build**

Create build.mjs:

~~~js
import {
  readFileSync, writeFileSync, readdirSync,
} from 'node:fs';
import { join, basename, resolve } from 'node:path';
import { pathToFileURL } from 'node:url';

const REQUIRED = ['title', 'description', 'canonical', 'ogImage'];
const FORBIDDEN = [
  /<\s*\/?\s*(?:x-dc|dc-import|sc-for|sc-if)\b/i,
  /\bstyle-hover\s*=/i,
  /\bdata-dc-script\b/i,
  /\bdata-html\s*=/i,
  /\son(?:click|submit|change|mouseenter|mouseleave)\s*=/i,
  /\{\{[\s\S]*?\}\}/,
  /\b(?:support|image-slot)\.js\b/i,
  /\bunpkg\.com\b/i,
  /\b(?:react|react-dom|babel)(?:\.production)?(?:\.min)?\.js\b/i,
];

function escapeHtml(value) {
  return String(value)
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;')
    .replace(/'/g, '&#39;');
}

export function parseFrontMatter(raw, file) {
  const match = raw.match(/^\s*<!--([\s\S]*?)-->\s*/);
  if (!match) throw new Error(file + ': missing front-matter comment block');
  const meta = {};
  for (const line of match[1].split('\n')) {
    const text = line.trim();
    if (!text) continue;
    const colon = text.indexOf(':');
    if (colon < 1) throw new Error(file + ': bad front-matter line: ' + text);
    const key = text.slice(0, colon).trim();
    const value = text.slice(colon + 1).trim();
    if (Object.hasOwn(meta, key)) {
      throw new Error(file + ': duplicate front-matter key "' + key + '"');
    }
    meta[key] = value;
  }
  return { meta, body: raw.slice(match[0].length) };
}

export function validateOutput(html, file) {
  for (const pattern of FORBIDDEN) {
    if (pattern.test(html)) {
      throw new Error(file + ': forbidden static output matched ' + pattern);
    }
  }
}

export function renderPage({ layout, partials, raw, file }) {
  const parsed = parseFrontMatter(raw, file);
  const meta = parsed.meta;
  for (const key of REQUIRED) {
    if (!meta[key]) {
      throw new Error(file + ': missing required front-matter key "' + key + '"');
    }
  }
  if (meta.bodyClass && !/^[A-Za-z0-9 _-]*$/.test(meta.bodyClass)) {
    throw new Error(file + ': invalid bodyClass');
  }

  const values = {
    title: escapeHtml(meta.title),
    description: escapeHtml(meta.description),
    canonical: escapeHtml(meta.canonical),
    ogTitle: escapeHtml(meta.ogTitle || meta.title),
    ogImage: escapeHtml(meta.ogImage),
    head_extra: meta.headExtra || '',
    body_class: escapeHtml(meta.bodyClass || ''),
    content: parsed.body,
  };

  let output = layout
    .replace(/<!--#include header-->/g, partials.header)
    .replace(/<!--#include footer-->/g, partials.footer);

  output = output.replace(/\{\{([A-Za-z0-9_]+)\}\}/g, (_, key) => {
    if (!Object.hasOwn(values, key)) {
      throw new Error(file + ': unknown layout placeholder "' + key + '"');
    }
    return values[key];
  });
  validateOutput(output, file);
  return output;
}

export function buildSite(root = process.cwd(), options = {}) {
  const src = join(root, 'src');
  const layout = readFileSync(join(src, 'layout.html'), 'utf8');
  const partials = {
    header: readFileSync(join(src, 'partials', 'header.html'), 'utf8'),
    footer: readFileSync(join(src, 'partials', 'footer.html'), 'utf8'),
  };
  const pagesDir = join(src, 'pages');
  const files = readdirSync(pagesDir)
    .filter((file) => file.endsWith('.html') && !file.startsWith('_'))
    .sort();
  const outputs = new Map();

  for (const file of files) {
    const raw = readFileSync(join(pagesDir, file), 'utf8');
    outputs.set(
      basename(file),
      renderPage({ layout, partials, raw, file }),
    );
  }

  if (options.write !== false) {
    for (const [file, html] of outputs) {
      writeFileSync(join(root, file), html);
    }
  }
  return outputs;
}

function main() {
  try {
    const outputs = buildSite();
    for (const file of outputs.keys()) console.log('built ' + file);
    console.log('Built ' + outputs.size + ' page(s).');
  } catch (error) {
    console.error(error.message);
    process.exitCode = 1;
  }
}

const invoked = process.argv[1]
  && pathToFileURL(resolve(process.argv[1])).href === import.meta.url;
if (invoked) main();
~~~

- [ ] **Step 4: Add private smoke fixtures**

Create src/layout.html:

~~~html
<!doctype html>
<html lang="vi">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>{{title}}</title>
<meta name="description" content="{{description}}">
<link rel="canonical" href="{{canonical}}">
<meta property="og:title" content="{{ogTitle}}">
<meta property="og:image" content="{{ogImage}}">
{{head_extra}}
</head>
<body class="{{body_class}}">
<!--#include header-->
<main>{{content}}</main>
<!--#include footer-->
</body>
</html>
~~~

Create src/partials/header.html:

~~~html
<header>HEADER</header>
~~~

Create src/partials/footer.html:

~~~html
<footer>FOOTER</footer>
~~~

Create src/pages/_smoke.html:

~~~html
<!--
title: Smoke
description: Smoke fixture
canonical: https://www.gwp.vn/smoke
ogImage: https://www.gwp.vn/images/og-index.jpg
-->
<section>SMOKE</section>
~~~

The leading underscore keeps this fixture out of production output.

- [ ] **Step 5: Run tests and verify GREEN**

~~~bash
node --test tests/build.test.mjs
node build.mjs
~~~

Expected: all tests pass and CLI prints Built 0 page(s).

- [ ] **Step 6: Commit**

~~~bash
git add build.mjs tests/build.test.mjs src
git commit -m "feat: add validated zero-dependency static builder"
~~~

---

## Task 2: Shared stylesheet, layout, and clean partials

**Files:**

- Create: css/gowise.css
- Create: css/pages/
- Modify: src/layout.html
- Modify: src/partials/header.html
- Modify: src/partials/footer.html

- [ ] **Step 1: Copy locked tokens**

~~~bash
mkdir -p css/pages
cp brand/gowise.css css/gowise.css
~~~

- [ ] **Step 2: Add global and shared component rules**

Append this exact shared layer to css/gowise.css:

~~~css
* { margin: 0; padding: 0; box-sizing: border-box; }
html { scroll-behavior: smooth; }
html, body { overflow-x: hidden; }
body {
  background: var(--gp-navy-950);
  color: var(--gp-mist);
  font-family: var(--gp-font-sans);
}
::selection { background: var(--gp-gold-400); color: var(--gp-navy-950); }
a { color: var(--gp-gold-300); text-decoration: none; }
a:hover { color: var(--gp-gold-200); }
img { display: block; max-width: 100%; }
[hidden] { display: none !important; }

#gp-hdr {
  position: sticky; top: 0; z-index: 100;
  background: rgba(7,18,31,0.86);
  backdrop-filter: blur(14px); -webkit-backdrop-filter: blur(14px);
  border-bottom: 1px solid rgba(201,166,104,0.14);
}
#gp-hdr .gp-hdr-inner {
  max-width: 1200px; min-height: 78px; margin: 0 auto; padding: 0 24px;
  display: flex; align-items: center; justify-content: space-between; gap: 24px;
}
#gp-hdr .gp-logo-link { display: flex; align-items: center; flex-shrink: 0; }
#gp-hdr .gp-logo { width: auto; height: 42px; }
#gp-hdr .gp-desktop-nav { display: flex; align-items: center; gap: 36px; }
#gp-hdr .gp-navlink {
  color: var(--gp-mist); font-size: 13px; font-weight: 500;
  letter-spacing: 0.05em; transition: color 0.2s;
}
#gp-hdr .gp-navlink:hover,
#gp-hdr .gp-navlink.is-active { color: var(--gp-gold-200); }
#gp-hdr .gp-navlink.is-active { font-weight: 600; }
#gp-hdr .gp-train-wrap { position: relative; }
#gp-hdr .gp-train-btn {
  display: inline-flex; align-items: center; gap: 7px; padding: 0;
  color: var(--gp-mist); background: none; border: 0; cursor: pointer;
  font: 500 13px var(--gp-font-sans); letter-spacing: 0.05em;
}
#gp-hdr .gp-train-btn:hover,
#gp-hdr .gp-train-btn.is-active { color: var(--gp-gold-200); }
#gp-hdr .gp-chevron { font-size: 9px; opacity: 0.8; }
#gp-hdr .gp-train-menu {
  display: none; position: absolute; top: calc(100% + 18px); left: 50%;
  width: 320px; padding: 10px; z-index: 120;
  transform: translateX(-50%);
  background: var(--gp-navy-900);
  border: 1px solid rgba(201,166,104,0.22); border-radius: 12px;
  box-shadow: 0 24px 60px rgba(0,0,0,0.55);
}
#gp-hdr .gp-train-menu::before {
  content: ""; position: absolute; top: -18px; left: 0; right: 0; height: 18px;
}
#gp-hdr .gp-train-menu.is-open { display: block; }
#gp-hdr .gp-drop-item {
  display: block; padding: 13px 16px; border-radius: 8px;
  color: var(--gp-mist); font-size: 13.5px; font-weight: 500;
  line-height: 1.4; transition: background 0.2s, color 0.2s;
}
#gp-hdr .gp-drop-item:hover {
  color: var(--gp-gold-200); background: rgba(201,166,104,0.08);
}
#gp-hdr .gp-desktop-cta,
#gp-hdr .gp-mobile-cta {
  color: var(--gp-navy-950);
  background: linear-gradient(180deg,var(--gp-gold-200),var(--gp-gold-400));
  font-size: 12px; font-weight: 700; letter-spacing: 0.06em;
}
#gp-hdr .gp-desktop-cta {
  flex-shrink: 0; padding: 12px 22px; transition: filter 0.2s, transform 0.2s;
}
#gp-hdr .gp-desktop-cta:hover {
  color: var(--gp-navy-950); filter: brightness(1.06); transform: translateY(-1px);
}
#gp-hdr .gp-burger {
  display: none; width: 46px; height: 46px; align-items: center; justify-content: center;
  background: none; border: 1px solid rgba(201,166,104,0.3);
  border-radius: 8px; cursor: pointer;
}
#gp-hdr .gp-burger-lines { position: relative; display: block; width: 20px; height: 14px; }
#gp-hdr .gp-burger-line {
  position: absolute; left: 0; width: 100%; height: 2px;
  background: var(--gp-gold-200);
}
#gp-hdr .gp-burger-line:nth-child(1) { top: 0; }
#gp-hdr .gp-burger-line:nth-child(2) { top: 6px; }
#gp-hdr .gp-burger-line:nth-child(3) { top: 12px; }
#gp-hdr .gp-mobile-panel {
  display: none; padding: 10px 24px 22px;
  background: rgba(7,18,31,0.98);
  border-top: 1px solid rgba(201,166,104,0.14);
}
#gp-hdr .gp-mobile-panel.is-open { display: block; }
#gp-hdr .gp-mobile-link {
  display: block; padding: 15px 0; font-size: 15px;
  border-bottom: 1px solid rgba(201,166,104,0.1);
}
#gp-hdr .gp-mobile-program-toggle {
  width: 100%; padding: 15px 0; justify-content: space-between;
  font-size: 15px; border-bottom: 1px solid rgba(201,166,104,0.1);
}
#gp-hdr .gp-mobile-program-links {
  display: none; flex-direction: column; padding: 6px 0 6px 14px;
  border-bottom: 1px solid rgba(201,166,104,0.1);
}
#gp-hdr .gp-mobile-program-links.is-open { display: flex; }
#gp-hdr .gp-mobile-program-link {
  padding: 11px 0; color: var(--gp-slate); font-size: 13.5px; line-height: 1.4;
}
#gp-hdr .gp-mobile-cta { display: inline-flex; margin-top: 18px; padding: 13px 24px; }

#gp-ftr {
  padding: 64px 0 40px; background: var(--gp-navy-950);
  border-top: 1px solid rgba(201,166,104,0.14);
}
#gp-ftr .gp-footer-grid {
  max-width: 1200px; margin: 0 auto; padding: 0 24px;
  display: grid; grid-template-columns: 1.7fr 1.1fr 1.2fr; gap: 44px;
}
#gp-ftr .gp-footer-brand-copy {
  max-width: 320px; margin-top: 20px; color: var(--gp-slate);
  font-size: 13.5px; line-height: 1.7;
}
#gp-ftr .gp-footer-title {
  margin-bottom: 18px; color: var(--gp-gold-500);
  font-size: 11px; font-weight: 600; letter-spacing: 0.2em;
}
#gp-ftr .gp-footer-links,
#gp-ftr .gp-footer-contact { display: flex; flex-direction: column; gap: 13px; }
#gp-ftr .gp-footer-link { color: var(--gp-mist); font-size: 14px; }
#gp-ftr .gp-footer-link:hover { color: var(--gp-gold-200); }
#gp-ftr .gp-footer-label {
  margin-bottom: 4px; color: var(--gp-slate);
  font-size: 11px; letter-spacing: 0.06em;
}
#gp-ftr .gp-footer-phone {
  color: var(--gp-text); font: 600 17px var(--gp-font-serif);
}
#gp-ftr .gp-footer-muted { color: var(--gp-slate); font-size: 13px; }
#gp-ftr .gp-footer-socials { display: flex; gap: 18px; margin-top: 4px; }
#gp-ftr .gp-footer-socials .gp-footer-link { font-size: 13px; }
#gp-ftr .gp-footer-bottom {
  max-width: 1200px; margin: 48px auto 0; padding: 24px 24px 0;
  display: flex; justify-content: space-between; gap: 16px;
  color: var(--gp-slate-deep); border-top: 1px solid rgba(201,166,104,0.1);
  font-size: 11px; letter-spacing: 0.14em;
}

.gp-anim-fade { animation: gp-fade 0.8s ease both; }
.gp-anim-fade-2 { animation: gp-fade 0.9s ease 0.15s both; }
.gp-anim-spin { animation: gp-spin 44s linear infinite; }
.gp-anim-float { animation: gp-float 6s ease-in-out infinite; }
.gp-anim-float-slow { animation: gp-float-slow 7s ease-in-out infinite; }

@media (max-width: 940px) {
  #gp-hdr .gp-desktop-nav,
  #gp-hdr .gp-desktop-cta { display: none !important; }
  #gp-hdr .gp-burger { display: inline-flex; }
}
@media (min-width: 941px) {
  #gp-hdr .gp-mobile-panel { display: none !important; }
}
@media (max-width: 820px) {
  #gp-ftr .gp-footer-grid { grid-template-columns: 1fr; gap: 34px; }
  #gp-ftr .gp-footer-bottom { flex-direction: column; text-align: center; }
}
@media (prefers-reduced-motion: reduce) {
  html { scroll-behavior: auto; }
  .gp-anim-fade, .gp-anim-fade-2, .gp-anim-spin,
  .gp-anim-float, .gp-anim-float-slow { animation: none !important; }
}
~~~

- [ ] **Step 3: Replace the real layout**

Replace src/layout.html:

~~~html
<!doctype html>
<html lang="vi">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
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
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Playfair+Display:ital,wght@0,400;0,500;0,600;0,700;1,400;1,500&family=Montserrat:wght@400;500;600;700&display=swap" rel="stylesheet">
<link rel="stylesheet" href="css/gowise.css">
{{head_extra}}
</head>
<body class="{{body_class}}">
<!--#include header-->
<main>{{content}}</main>
<!--#include footer-->
<script src="js/reveal.js"></script>
<script src="js/nav.js"></script>
<script src="js/program-ui.js"></script>
</body>
</html>
~~~

- [ ] **Step 4: Replace header fixture with semantic markup**

Use this exact structural markup:

~~~html
<header id="gp-hdr" data-screen-label="Header">
  <div class="gp-hdr-inner">
    <a href="./" class="gp-logo-link">
      <img class="gp-logo" src="assets/logo-wordmark-gold.png"
        alt="GoWise Partners — Strategic Management Coaching">
    </a>
    <nav class="gp-desktop-nav" aria-label="Điều hướng chính">
      <a href="./" class="gp-navlink" data-nav="home">TRANG CHỦ</a>
      <div class="gp-train-wrap" data-train-wrap>
        <button type="button" class="gp-train-btn" data-train-toggle
          data-nav="train" aria-expanded="false" aria-controls="gp-train-menu">
          CHƯƠNG TRÌNH <span class="gp-chevron" aria-hidden="true">▼</span>
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
    <button type="button" class="gp-burger" data-mobile-toggle
      aria-label="Menu" aria-expanded="false" aria-controls="gp-mnav">
      <span class="gp-burger-lines" aria-hidden="true">
        <span class="gp-burger-line"></span>
        <span class="gp-burger-line"></span>
        <span class="gp-burger-line"></span>
      </span>
    </button>
  </div>
  <div id="gp-mnav" class="gp-mobile-panel">
    <a href="./" class="gp-navlink gp-mobile-link" data-nav="home">TRANG CHỦ</a>
    <button type="button" class="gp-train-btn gp-mobile-program-toggle"
      data-mobile-program-toggle aria-expanded="false"
      aria-controls="gp-train-mobile">
      ĐÀO TẠO <span class="gp-chevron" aria-hidden="true">▼</span>
    </button>
    <div id="gp-train-mobile" class="gp-mobile-program-links">
      <a href="Chuyen_Gia_Khai_Van_Hieu_Suat_Cao" class="gp-mobile-program-link">Chuyên gia Khai vấn Hiệu suất cao</a>
      <a href="Khai-Van_Quan_Tri_Chuyen_Nghiep" class="gp-mobile-program-link">Chuyên gia Khai vấn Quản trị</a>
      <a href="Khai_Van_Hieu_Suat_Thuc_Chien" class="gp-mobile-program-link">WS Khai vấn Hiệu suất cao thực chiến</a>
    </div>
    <a href="Lien_He" class="gp-navlink gp-mobile-link" data-nav="contact">LIÊN HỆ</a>
    <a href="Lien_He" class="gp-mobile-cta">Đặt lịch tư vấn</a>
  </div>
</header>
~~~

- [ ] **Step 5: Replace footer fixture with semantic markup**

Use this exact structural markup:

~~~html
<footer id="gp-ftr" data-screen-label="Footer">
  <div class="gp-footer-grid">
    <div>
      <img class="gp-logo" src="assets/logo-wordmark-gold.png"
        alt="GoWise Partners — Strategic Management Coaching">
      <p class="gp-footer-brand-copy">Strategic Management Coaching — Đối tác hiệu suất chiến lược của bạn. Kết hợp tư duy quản trị, nghệ thuật khai vấn và công nghệ AI.</p>
    </div>
    <div>
      <div class="gp-footer-title">HỆ SINH THÁI</div>
      <div class="gp-footer-links">
        <a href="Chuyen_Gia_Khai_Van_Hieu_Suat_Cao" class="gp-footer-link">Chuyên gia Khai vấn Hiệu suất cao</a>
        <a href="Khai-Van_Quan_Tri_Chuyen_Nghiep" class="gp-footer-link">Chuyên gia Khai vấn Quản trị</a>
        <a href="Khai_Van_Hieu_Suat_Thuc_Chien" class="gp-footer-link">WS Khai vấn Hiệu suất cao thực chiến</a>
      </div>
    </div>
    <div>
      <div class="gp-footer-title">LIÊN HỆ</div>
      <div class="gp-footer-contact">
        <div>
          <div class="gp-footer-label">Hotline / Zalo</div>
          <a href="tel:0868680793" class="gp-footer-phone">0868 680 793</a>
          <span class="gp-footer-muted"> · Mr. Huy</span>
        </div>
        <a href="mailto:info@gwp.vn" class="gp-footer-link">info@gwp.vn</a>
        <div class="gp-footer-socials">
          <a href="#" class="gp-footer-link">LinkedIn</a>
          <a href="#" class="gp-footer-link">Facebook</a>
          <a href="#" class="gp-footer-link">YouTube</a>
        </div>
      </div>
    </div>
  </div>
  <div class="gp-footer-bottom">
    <span>© 2026 GOWISE PARTNERS</span>
    <span>STRATEGIC MANAGEMENT COACHING</span>
  </div>
</footer>
~~~

- [ ] **Step 6: Add a source-contract check**

Run:

~~~bash
rg -n 'style=|style-hover|onClick|onSubmit|\{\{' src/partials
~~~

Expected: only documented layout placeholders may appear in src/layout.html; no output from src/partials.

- [ ] **Step 7: Commit**

~~~bash
git add css/gowise.css src/layout.html src/partials
git commit -m "feat: add static layout and clean shared partials"
~~~

---

## Task 3: Shared reveal and count-up behavior

**Files:**

- Create: js/reveal.js
- Create temporarily: tests/fixtures/reveal.html

- [ ] **Step 1: Create the browser fixture before implementation**

The fixture contains:

- encoded data-svg;
- one gp-reveal element;
- one data-stagger group with three reveal children;
- grouped and plain count elements;
- custom 70 ms stagger and 1000 ms duration examples.

Open it before js/reveal.js exists. Expected RED: behavior is absent or script request fails.

- [ ] **Step 2: Implement reveal.js**

Create js/reveal.js:

~~~js
(function () {
  function numberAttr(element, name, fallback) {
    var value = Number(element.getAttribute(name));
    return Number.isFinite(value) && value >= 0 ? value : fallback;
  }

  function format(value, mode) {
    return mode === 'plain'
      ? String(value)
      : Number(value).toLocaleString('en-US');
  }

  function finalCount(element) {
    var target = parseInt(element.getAttribute('data-count'), 10) || 0;
    var mode = element.getAttribute('data-count-format') || 'grouped';
    element.textContent = format(target, mode);
  }

  function countUp(element) {
    var target = parseInt(element.getAttribute('data-count'), 10) || 0;
    var mode = element.getAttribute('data-count-format') || 'grouped';
    var duration = numberAttr(element, 'data-count-duration', 900);
    var start = performance.now();
    function tick(now) {
      var progress = duration === 0 ? 1 : Math.min(1, (now - start) / duration);
      var eased = 1 - Math.pow(1 - progress, 3);
      element.textContent = format(Math.round(eased * target), mode);
      if (progress < 1) requestAnimationFrame(tick);
      else finalCount(element);
    }
    requestAnimationFrame(tick);
  }

  function init() {
    var root = document;
    root.querySelectorAll('[data-svg]').forEach(function (element) {
      var svg = element.getAttribute('data-svg');
      if (svg && element.childElementCount === 0) element.innerHTML = svg;
    });

    root.querySelectorAll('[data-stagger]').forEach(function (group) {
      var delay = numberAttr(group, 'data-stagger-ms', 75);
      Array.prototype.filter.call(group.children, function (child) {
        return child.classList.contains('gp-reveal');
      }).forEach(function (child, index) {
        child.style.transitionDelay = String(index * delay) + 'ms';
      });
    });

    var reduced = window.matchMedia
      && window.matchMedia('(prefers-reduced-motion: reduce)').matches;
    var reveals = root.querySelectorAll('.gp-reveal');
    var counts = root.querySelectorAll('[data-count]');
    if (reduced || !('IntersectionObserver' in window)) {
      reveals.forEach(function (element) { element.classList.add('in'); });
      counts.forEach(finalCount);
      return;
    }

    var revealObserver = new IntersectionObserver(function (entries) {
      entries.forEach(function (entry) {
        if (!entry.isIntersecting) return;
        entry.target.classList.add('in');
        revealObserver.unobserve(entry.target);
      });
    }, { threshold: 0.12, rootMargin: '0px 0px -6% 0px' });
    reveals.forEach(function (element) { revealObserver.observe(element); });

    var countObserver = new IntersectionObserver(function (entries) {
      entries.forEach(function (entry) {
        if (!entry.isIntersecting) return;
        countUp(entry.target);
        countObserver.unobserve(entry.target);
      });
    }, { threshold: 0.6 });
    counts.forEach(function (element) {
      element.textContent = '0';
      countObserver.observe(element);
    });
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', init);
  } else {
    init();
  }
})();
~~~

- [ ] **Step 3: Syntax and fixture verification**

~~~bash
node --check js/reveal.js
~~~

Browser expected:

- SVG is present;
- delays are 0, 70, and 140 ms in the custom group;
- grouped 11000 becomes 11,000;
- plain 11000 remains 11000;
- reduced motion shows final values immediately.

- [ ] **Step 4: Commit**

~~~bash
git add js/reveal.js tests/fixtures/reveal.html
git commit -m "feat: add configurable reveal and count-up controller"
~~~

---

## Task 4: Navigation controller

**Files:**

- Create: js/nav.js
- Create temporarily: tests/fixtures/nav.html

- [ ] **Step 1: Write the fixture and failing interaction checklist**

The fixture uses the exact ids/classes/data attributes from src/partials/header.html.
Before implementation verify RED:

- desktop trigger does not open the menu;
- burger does not open the mobile panel;
- ARIA state does not change.

- [ ] **Step 2: Implement nav.js**

Create js/nav.js:

~~~js
(function () {
  function init() {
    var header = document.getElementById('gp-hdr');
    if (!header) return;

    var trainWrap = header.querySelector('[data-train-wrap]');
    var trainToggle = header.querySelector('[data-train-toggle]');
    var trainMenu = document.getElementById('gp-train-menu');
    var mobileToggle = header.querySelector('[data-mobile-toggle]');
    var mobilePanel = document.getElementById('gp-mnav');
    var mobileProgramToggle = header.querySelector('[data-mobile-program-toggle]');
    var mobileProgram = document.getElementById('gp-train-mobile');

    function setOpen(toggle, panel, open) {
      if (!toggle || !panel) return;
      toggle.setAttribute('aria-expanded', open ? 'true' : 'false');
      panel.classList.toggle('is-open', open);
    }

    function closeAll() {
      setOpen(trainToggle, trainMenu, false);
      setOpen(mobileToggle, mobilePanel, false);
      setOpen(mobileProgramToggle, mobileProgram, false);
    }

    if (trainWrap && trainToggle && trainMenu) {
      trainWrap.addEventListener('mouseenter', function () {
        setOpen(trainToggle, trainMenu, true);
      });
      trainWrap.addEventListener('mouseleave', function () {
        setOpen(trainToggle, trainMenu, false);
      });
      trainToggle.addEventListener('click', function () {
        setOpen(
          trainToggle,
          trainMenu,
          !trainMenu.classList.contains('is-open'),
        );
      });
    }

    if (mobileToggle && mobilePanel) {
      mobileToggle.addEventListener('click', function () {
        setOpen(
          mobileToggle,
          mobilePanel,
          !mobilePanel.classList.contains('is-open'),
        );
      });
    }

    if (mobileProgramToggle && mobileProgram) {
      mobileProgramToggle.addEventListener('click', function () {
        setOpen(
          mobileProgramToggle,
          mobileProgram,
          !mobileProgram.classList.contains('is-open'),
        );
      });
    }

    document.addEventListener('click', function (event) {
      if (!header.contains(event.target)) closeAll();
    });
    document.addEventListener('keydown', function (event) {
      if (event.key === 'Escape') closeAll();
    });

    var desktop = window.matchMedia && window.matchMedia('(min-width: 941px)');
    if (desktop) {
      var resetMobile = function (event) {
        if (!event.matches) return;
        setOpen(mobileToggle, mobilePanel, false);
        setOpen(mobileProgramToggle, mobileProgram, false);
      };
      if (desktop.addEventListener) desktop.addEventListener('change', resetMobile);
      else desktop.addListener(resetMobile);
    }

    try {
      var file = decodeURIComponent(
        (location.pathname.split('/').pop() || '').toLowerCase(),
      );
      var key = 'home';
      if (/lien_he|lien-he/.test(file)) key = 'contact';
      else if (/chuyen_gia|quan_tri|thuc_chien|hieu_suat/.test(file)) key = 'train';
      header.querySelectorAll('[data-nav="' + key + '"]').forEach(function (link) {
        link.classList.add('is-active');
        if (link.tagName === 'A') link.setAttribute('aria-current', 'page');
      });
    } catch (_) {}
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', init);
  } else {
    init();
  }
})();
~~~

- [ ] **Step 3: Verify fixture GREEN**

~~~bash
node --check js/nav.js
~~~

Browser expected: every RED item passes, keyboard Escape works, and resizing mobile to desktop leaves no mobile panel visible.

- [ ] **Step 4: Commit**

~~~bash
git add js/nav.js tests/fixtures/nav.html
git commit -m "feat: add accessible static navigation controller"
~~~

---

## Task 5: Program tabs and FAQ controller

**Files:**

- Create: js/program-ui.js
- Create temporarily: tests/fixtures/program-ui.html

### Markup contract

~~~html
<div data-tabs>
  <div role="tablist">
    <button role="tab" data-tab data-target="panel-1"
      aria-selected="true" tabindex="0">Module 1</button>
    <button role="tab" data-tab data-target="panel-2"
      aria-selected="false" tabindex="-1">Module 2</button>
  </div>
  <section id="panel-1" role="tabpanel" data-panel>...</section>
  <section id="panel-2" role="tabpanel" data-panel hidden>...</section>
</div>

<div data-accordion data-single>
  <button data-accordion-trigger aria-expanded="true"
    aria-controls="faq-1">Question</button>
  <div id="faq-1" data-accordion-panel>Answer</div>
</div>
~~~

- [ ] **Step 1: Create fixture and verify RED**

Before implementation, clicking tabs or accordion triggers does not update state.

- [ ] **Step 2: Implement program-ui.js**

Create js/program-ui.js:

~~~js
(function () {
  function initTabs(root) {
    var tabs = Array.from(root.querySelectorAll('[data-tab]'));
    var panels = Array.from(root.querySelectorAll('[data-panel]'));
    if (!tabs.length || !panels.length) return;

    function activate(tab, focus) {
      var target = tab.getAttribute('data-target');
      tabs.forEach(function (candidate) {
        var selected = candidate === tab;
        candidate.setAttribute('aria-selected', selected ? 'true' : 'false');
        candidate.setAttribute('tabindex', selected ? '0' : '-1');
        candidate.classList.toggle('is-active', selected);
      });
      panels.forEach(function (panel) {
        panel.hidden = panel.id !== target;
      });
      if (focus) tab.focus();
    }

    tabs.forEach(function (tab, index) {
      tab.addEventListener('click', function () { activate(tab, false); });
      tab.addEventListener('keydown', function (event) {
        var next = index;
        if (event.key === 'ArrowRight') next = (index + 1) % tabs.length;
        else if (event.key === 'ArrowLeft') next = (index - 1 + tabs.length) % tabs.length;
        else if (event.key === 'Home') next = 0;
        else if (event.key === 'End') next = tabs.length - 1;
        else return;
        event.preventDefault();
        activate(tabs[next], true);
      });
    });

    activate(
      tabs.find(function (tab) {
        return tab.getAttribute('aria-selected') === 'true';
      }) || tabs[0],
      false,
    );
  }

  function initAccordion(root) {
    var triggers = Array.from(root.querySelectorAll('[data-accordion-trigger]'));
    function setOpen(trigger, open) {
      var panel = document.getElementById(trigger.getAttribute('aria-controls'));
      trigger.setAttribute('aria-expanded', open ? 'true' : 'false');
      trigger.classList.toggle('is-open', open);
      if (panel) panel.hidden = !open;
    }

    triggers.forEach(function (trigger) {
      setOpen(trigger, trigger.getAttribute('aria-expanded') === 'true');
      trigger.addEventListener('click', function () {
        var next = trigger.getAttribute('aria-expanded') !== 'true';
        if (next && root.hasAttribute('data-single')) {
          triggers.forEach(function (candidate) {
            if (candidate !== trigger) setOpen(candidate, false);
          });
        }
        setOpen(trigger, next);
      });
    });
  }

  function init() {
    document.querySelectorAll('[data-tabs]').forEach(initTabs);
    document.querySelectorAll('[data-accordion]').forEach(initAccordion);
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', init);
  } else {
    init();
  }
})();
~~~

- [ ] **Step 3: Verify GREEN**

~~~bash
node --check js/program-ui.js
~~~

Browser expected: all tab keyboard controls and single-open accordion behavior pass.

- [ ] **Step 4: Commit**

~~~bash
git add js/program-ui.js tests/fixtures/program-ui.html
git commit -m "feat: add static program tabs and FAQ controller"
~~~

---

## Layer A conversion rule used by Tasks 6–10

Layer A may retain ordinary inline style attributes temporarily, but it may not
retain style-hover. For each original style-hover declaration:

1. assign a page-scoped class to that element;
2. copy the declaration verbatim into the matching :hover rule in the page CSS;
3. preserve the original transition declaration;
4. verify the hover state before committing Layer A.

Dynamic display state must use hidden, is-open, or is-active before inline style
extraction. Do not leave display:none in a class that JavaScript later needs to
show. Entity-encode SVG attribute values as &lt;svg ...&gt; so the HTML parser
decodes a valid SVG string for reveal.js.

---

## Task 6: Convert index through both parity layers

**Files:**

- Create: src/pages/index.html
- Create: css/pages/index.css
- Modify: index.html

- [ ] **Step 1: Build Layer A source**

Use current index.html as the only content source.

Exact conversion:

- front matter copies current title, description, canonical, OG title, and OG image;
- headExtra links css/pages/index.css;
- retain div id=gp-root;
- remove DC imports;
- expand clients, articles, leads, and experts in their current order;
- encode every generated data-svg attribute;
- convert every image-slot, preserving source, fit, position, dimensions, and alt context;
- map gp-reveal classes without changing transition values;
- move the complete current head style block into css/pages/index.css;
- keep current inline layout declarations for the Layer A commit;
- add grouped data-count-format and 900 ms data-count-duration.

- [ ] **Step 2: Build and run static validation**

~~~bash
node build.mjs
rg -n 'x-dc|dc-import|sc-for|sc-if|style-hover|data-html|data-dc-script|onClick|onSubmit|\{\{|support\.js|unpkg\.com' index.html
~~~

Expected: build reports one page and rg has no output.

- [ ] **Step 3: Verify Layer A parity**

Browser requirements:

- desktop and mobile screenshot match baseline;
- grouped count-up works under normal motion;
- reduced motion shows final counts;
- header desktop and mobile interactions pass;
- console has zero errors;
- network has no DC/React requests.

- [ ] **Step 4: Commit Layer A**

~~~bash
git add src/pages/index.html css/pages/index.css index.html
git commit -m "refactor: render index as static HTML with parity"
~~~

- [ ] **Step 5: Perform Layer B CSS extraction**

Replace inline styles with existing gp classes first. Add named index classes only for declarations that remain unique. Preserve all responsive contracts with explicit classes; do not retain selectors that search style attribute text.

- [ ] **Step 6: Assert CSS extraction**

~~~bash
rg -n 'style=|style-hover' src/pages/index.html
~~~

Expected: no output.

- [ ] **Step 7: Re-run Layer B parity and commit**

Repeat Step 3, then:

~~~bash
git add src/pages/index.html css/gowise.css css/pages/index.css index.html
git commit -m "refactor: externalize index styling without visual drift"
~~~

---

## Task 7: Convert the workshop through both parity layers

**Files:**

- Create: src/pages/Khai_Van_Hieu_Suat_Thuc_Chien.html
- Create: css/pages/workshop.css
- Modify: Khai_Van_Hieu_Suat_Thuc_Chien.html

- [ ] **Step 1: Build Layer A source**

Exact conversion:

- preserve kv-root;
- copy all metadata verbatim;
- headExtra links css/pages/workshop.css;
- move the entire current style block, including kvSheen and mobile rules;
- replace style-substring mobile selectors with explicit workshop grid classes;
- expand metrics, pains, challenges, learn, outcomes, audience, modules, and nested points;
- evaluate showChallengeNumbers as true and include the challenge numbers;
- map rv, rv-l, rv-r to gp reveal classes;
- use data-stagger-ms=75;
- use data-count-format=plain and data-count-duration=900;
- convert all image slots with the current fit and position.

- [ ] **Step 2: Build, validate, verify, and commit Layer A**

~~~bash
node build.mjs
rg -n 'x-dc|dc-import|sc-for|sc-if|style-hover|data-html|data-dc-script|onClick|\{\{|support\.js|unpkg\.com' Khai_Van_Hieu_Suat_Thuc_Chien.html
git add src/pages/Khai_Van_Hieu_Suat_Thuc_Chien.html css/pages/workshop.css Khai_Van_Hieu_Suat_Thuc_Chien.html
git commit -m "refactor: render workshop page as static HTML with parity"
~~~

Expected before commit: no grep output; desktop/mobile, reveal, plain count-up, header, and network checks pass.

- [ ] **Step 3: Perform Layer B CSS extraction**

Remove every style and style-hover attribute. Promote only truly shared patterns into css/gowise.css; keep workshop-specific responsive and sheen rules in workshop.css.

- [ ] **Step 4: Verify and commit Layer B**

~~~bash
rg -n 'style=|style-hover|\[style\*=' src/pages/Khai_Van_Hieu_Suat_Thuc_Chien.html css/pages/workshop.css
git add src/pages/Khai_Van_Hieu_Suat_Thuc_Chien.html css/gowise.css css/pages/workshop.css Khai_Van_Hieu_Suat_Thuc_Chien.html
git commit -m "refactor: externalize workshop styling without visual drift"
~~~

Expected: no grep output and browser parity passes again.

---

## Task 8: Convert contact with safe form verification

**Files:**

- Create: src/pages/Lien_He.html
- Create: css/pages/contact.css
- Create: js/contact.js
- Create: tests/fixtures/contact.html
- Modify: Lien_He.html

- [ ] **Step 1: Create the contact fixture and verify RED**

Fixture markup includes:

- form action=https://api.web3forms.com/submit and method=POST;
- the current hidden fields and public fields;
- .h-captcha;
- data-contact-form;
- data-contact-success and data-contact-error elements hidden initially.

Before contact.js, controlled submit states do not appear.

- [ ] **Step 2: Implement contact.js**

Create js/contact.js:

~~~js
(function () {
  function init() {
    var form = document.querySelector('[data-contact-form]');
    if (!form) return;
    var button = form.querySelector('button[type="submit"]');
    var success = document.querySelector('[data-contact-success]');
    var error = document.querySelector('[data-contact-error]');
    var errorText = error && error.querySelector('[data-contact-error-text]');
    var defaultError = errorText ? errorText.textContent : '';

    function showError(message) {
      if (errorText) errorText.textContent = message || defaultError;
      if (error) error.hidden = false;
    }

    form.addEventListener('submit', async function (event) {
      event.preventDefault();
      if (success) success.hidden = true;
      if (error) error.hidden = true;

      var captcha = form.querySelector('textarea[name="h-captcha-response"]');
      if (form.querySelector('.h-captcha') && !(captcha && captcha.value)) {
        showError('Vui lòng hoàn thành xác minh captcha trước khi gửi.');
        return;
      }

      if (button) {
        button.disabled = true;
        button.classList.add('is-loading');
      }
      try {
        var response = await fetch(form.action, {
          method: form.method || 'POST',
          headers: { Accept: 'application/json' },
          body: new FormData(form),
        });
        var data = await response.json();
        if (data.success) {
          if (success) success.hidden = false;
          form.reset();
        } else {
          showError();
        }
      } catch (_) {
        showError();
      } finally {
        if (button) {
          button.disabled = false;
          button.classList.remove('is-loading');
        }
      }
    });
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', init);
  } else {
    init();
  }
})();
~~~

- [ ] **Step 3: Build Layer A source**

Exact conversion:

- preserve lh-root;
- copy current metadata exactly, including title capitalization;
- headExtra contains the contact stylesheet, deferred js/contact.js, and the async/defer Web3Forms client script;
- preserve exact form action, method, access key, subject, names, validation attributes, captcha container, and messages;
- replace onSubmit binding with data-contact-form;
- move all current contact CSS, including form fields and breakpoints, to contact.css;
- map rv to gp-reveal;
- expand infos and encode SVG values.

- [ ] **Step 4: Build and static validation**

~~~bash
node --check js/contact.js
node build.mjs
rg -n 'x-dc|dc-import|sc-for|sc-if|style-hover|data-html|data-dc-script|onSubmit|\{\{|support\.js|unpkg\.com' Lien_He.html
rg -n 'web3forms.com/client/script.js|data-contact-form|api.web3forms.com/submit' Lien_He.html
~~~

Expected: first rg has no output; second rg finds all three required contact contracts.

- [ ] **Step 5: Verify without creating a production lead**

Using browser request interception:

1. Submit without captcha response; expect the Vietnamese captcha error and no request.
2. Inject a test h-captcha-response and intercept POST with JSON {\"success\":true}; expect success, reset, and button restoration.
3. Intercept POST with JSON {\"success\":false}; expect the current error message and button restoration.
4. Repeat with a network error.

- [ ] **Step 6: Commit Layer A**

~~~bash
git add src/pages/Lien_He.html css/pages/contact.css js/contact.js Lien_He.html
git commit -m "refactor: render contact page statically with safe form parity"
~~~

- [ ] **Step 7: Perform Layer B, verify, and commit**

Remove all inline style attributes, re-run desktop/mobile screenshots and the four mocked form cases, then:

~~~bash
rg -n 'style=|style-hover' src/pages/Lien_He.html
git add src/pages/Lien_He.html css/gowise.css css/pages/contact.css Lien_He.html
git commit -m "refactor: externalize contact styling without visual drift"
~~~

---

## Task 9: Convert Performance Coach with all module states

**Files:**

- Create: src/pages/Chuyen_Gia_Khai_Van_Hieu_Suat_Cao.html
- Create: css/pages/performance-coach.css
- Modify: Chuyen_Gia_Khai_Van_Hieu_Suat_Cao.html

- [ ] **Step 1: Build Layer A source**

Exact conversion:

- preserve hpc-root;
- copy metadata verbatim;
- headExtra links performance-coach.css;
- move complete page CSS, including gpPulse and all mobile rules;
- render all three module records as static data-panel sections;
- create three tab buttons from moduleTabs with Module 1 initially selected;
- replace data-html experience values with actual child HTML, preserving strong text;
- expand heroStats, audience, outcomes, topics, tools, coaches, experience, highlights, journey, eventInfo, and features;
- evaluate every hasLine and hasDate sc-if explicitly;
- map reveal classes;
- use data-stagger-ms=70;
- use data-count-format=plain and data-count-duration=900;
- encode every data-svg attribute.

- [ ] **Step 2: Build and validate**

~~~bash
node build.mjs
rg -n 'x-dc|dc-import|sc-for|sc-if|style-hover|data-html|data-dc-script|onClick|\{\{|support\.js|unpkg\.com' Chuyen_Gia_Khai_Van_Hieu_Suat_Cao.html
~~~

Expected: no output.

- [ ] **Step 3: Verify all states**

At desktop and mobile:

- Module 1 is initially selected;
- Modules 1, 2, and 3 each show their correct title, topics, tools, and active tab;
- click and arrow-key navigation work;
- switching tabs does not create console errors or lose SVG icons;
- screenshots match all captured module baselines.

- [ ] **Step 4: Commit Layer A**

~~~bash
git add src/pages/Chuyen_Gia_Khai_Van_Hieu_Suat_Cao.html css/pages/performance-coach.css Chuyen_Gia_Khai_Van_Hieu_Suat_Cao.html
git commit -m "refactor: render performance coach page with static modules"
~~~

- [ ] **Step 5: Perform Layer B, verify, and commit**

Remove inline styles and style-substring responsive selectors. Preserve page-specific text balancing, pulse, responsive grids, and module state classes.

~~~bash
rg -n 'style=|style-hover|\[style\*=' src/pages/Chuyen_Gia_Khai_Van_Hieu_Suat_Cao.html css/pages/performance-coach.css
git add src/pages/Chuyen_Gia_Khai_Van_Hieu_Suat_Cao.html css/gowise.css css/pages/performance-coach.css Chuyen_Gia_Khai_Van_Hieu_Suat_Cao.html
git commit -m "refactor: externalize performance coach styling without drift"
~~~

Expected: no grep output and every module-state browser check still passes.

---

## Task 10: Convert Management Coaching tabs and FAQ

**Files:**

- Create: src/pages/Khai-Van_Quan_Tri_Chuyen_Nghiep.html
- Create: css/pages/management-coach.css
- Modify: Khai-Van_Quan_Tri_Chuyen_Nghiep.html

- [ ] **Step 1: Build Layer A source**

Exact conversion:

- preserve mc-root;
- copy metadata verbatim;
- headExtra links management-coach.css;
- move complete page CSS and replace inline-style substring responsive selectors;
- render all four modules as data-panel sections;
- create four module tabs with the first selected;
- render all four FAQ answers in static HTML with the first visible;
- use data-accordion and data-single for the FAQ;
- expand metrics, audience, pillars, outcomes, modules, toolkit, experts, journey, hooks, and faqs;
- evaluate journey date conditionals explicitly;
- map reveal classes;
- use data-stagger-ms=70;
- use data-count-format=grouped and data-count-duration=1000;
- encode SVG attributes.

- [ ] **Step 2: Build and validate**

~~~bash
node build.mjs
rg -n 'x-dc|dc-import|sc-for|sc-if|style-hover|data-html|data-dc-script|onClick|\{\{|support\.js|unpkg\.com' Khai-Van_Quan_Tri_Chuyen_Nghiep.html
~~~

Expected: no output and build reports five pages.

- [ ] **Step 3: Verify tabs and FAQ**

At desktop and mobile:

- module tabs 1 through 4 show the matching title, description, topics, and tools;
- click and keyboard navigation work;
- FAQ item 1 is initially open;
- opening an FAQ closes its sibling;
- each answer matches the source data;
- grouped counts finish at the current values after 1000 ms;
- all captured state screenshots match.

- [ ] **Step 4: Commit Layer A**

~~~bash
git add src/pages/Khai-Van_Quan_Tri_Chuyen_Nghiep.html css/pages/management-coach.css Khai-Van_Quan_Tri_Chuyen_Nghiep.html
git commit -m "refactor: render management coach tabs and FAQ statically"
~~~

- [ ] **Step 5: Perform Layer B, verify, and commit**

~~~bash
rg -n 'style=|style-hover|\[style\*=' src/pages/Khai-Van_Quan_Tri_Chuyen_Nghiep.html css/pages/management-coach.css
git add src/pages/Khai-Van_Quan_Tri_Chuyen_Nghiep.html css/gowise.css css/pages/management-coach.css Khai-Van_Quan_Tri_Chuyen_Nghiep.html
git commit -m "refactor: externalize management coach styling without drift"
~~~

Expected: no grep output and all tab/FAQ checks still pass.

---

## Task 11: Add final static contract tests

**Files:**

- Create: tests/static-contract.test.mjs

- [ ] **Step 1: Write the static contract test**

Create tests/static-contract.test.mjs:

~~~js
import test from 'node:test';
import assert from 'node:assert/strict';
import { existsSync, readFileSync } from 'node:fs';
import { dirname, join, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';

const root = resolve(dirname(fileURLToPath(import.meta.url)), '..');
const pages = [
  'index.html',
  'Lien_He.html',
  'Khai_Van_Hieu_Suat_Thuc_Chien.html',
  'Chuyen_Gia_Khai_Van_Hieu_Suat_Cao.html',
  'Khai-Van_Quan_Tri_Chuyen_Nghiep.html',
];
const forbidden = /x-dc|dc-import|sc-for|sc-if|\sstyle=|style-hover|data-html|data-dc-script|onClick|onSubmit|\{\{|support\.js|image-slot\.js|unpkg\.com|react-dom|babel/i;

function read(page) {
  return readFileSync(join(root, page), 'utf8');
}

function count(html, pattern) {
  return (html.match(pattern) || []).length;
}

test('all exact public outputs exist with required metadata', () => {
  for (const page of pages) {
    assert.equal(existsSync(join(root, page)), true, page);
    const html = read(page);
    assert.equal(count(html, /<title>[\s\S]*?<\/title>/gi), 1, page + ' title');
    assert.equal(count(html, /<meta name="description"/gi), 1, page + ' description');
    assert.equal(count(html, /<link rel="canonical"/gi), 1, page + ' canonical');
    assert.equal(count(html, /<meta property="og:image"/gi), 1, page + ' og image');
    assert.match(html, /href="css\/gowise\.css"/);
    assert.match(html, /src="js\/reveal\.js"/);
    assert.match(html, /src="js\/nav\.js"/);
    assert.match(html, /src="js\/program-ui\.js"/);
    assert.doesNotMatch(html, forbidden, page);
  }
});

test('local file and extensionless page targets resolve', () => {
  for (const page of pages) {
    const html = read(page);
    const attributes = html.matchAll(/\b(?:href|src)="([^"]+)"/g);
    for (const match of attributes) {
      const target = match[1].split('#')[0].split('?')[0];
      if (!target || target === './' || target.startsWith('#')) continue;
      if (/^(?:https?:|mailto:|tel:|data:)/.test(target)) continue;
      if (/\.[A-Za-z0-9]+$/.test(target)) {
        assert.equal(existsSync(join(root, target)), true, page + ' -> ' + target);
      } else {
        assert.equal(existsSync(join(root, target + '.html')), true, page + ' -> ' + target);
      }
    }
  }
});

test('page-specific assets and interaction markup are scoped correctly', () => {
  const contact = read('Lien_He.html');
  assert.match(contact, /css\/pages\/contact\.css/);
  assert.match(contact, /js\/contact\.js/);
  assert.match(contact, /web3forms\.com\/client\/script\.js/);
  assert.match(contact, /data-contact-form/);

  const hpc = read('Chuyen_Gia_Khai_Van_Hieu_Suat_Cao.html');
  assert.equal(count(hpc, /\bdata-panel\b/g), 3);
  assert.equal(count(hpc, /\bdata-tab\b/g), 3);

  const management = read('Khai-Van_Quan_Tri_Chuyen_Nghiep.html');
  assert.equal(count(management, /\bdata-panel\b/g), 4);
  assert.equal(count(management, /\bdata-tab\b/g), 4);
  assert.equal(count(management, /\bdata-accordion-panel\b/g), 4);
  assert.equal(count(management, /\bdata-accordion-trigger\b/g), 4);

  for (const page of pages.filter((name) => name !== 'Lien_He.html')) {
    assert.doesNotMatch(read(page), /js\/contact\.js|css\/pages\/contact\.css/);
  }
});
~~~

- [ ] **Step 2: Run tests**

~~~bash
node --test tests/build.test.mjs tests/static-contract.test.mjs
~~~

Expected: all tests pass.

- [ ] **Step 3: Commit**

~~~bash
git add tests/static-contract.test.mjs
git commit -m "test: enforce final static site contracts"
~~~

---

## Task 12: Remove runtime and update tracked documentation

**Files:**

- Delete tracked: support.js, image-slot.js, .image-slots.state.json, Header.dc.html, Footer.dc.html
- Remove locally when present: fix-dc.sh, .claude/design-sync.json, .claude/commands/design-sync.md
- Modify: .gitignore, CLAUDE.md, DESIGN.md

- [ ] **Step 1: Prove tracked output has no dependency on deleted files**

~~~bash
rg -n 'support\.js|image-slot|dc-import|x-dc|sc-for|sc-if|data-dc-script|unpkg\.com' \
  index.html Lien_He.html Khai_Van_Hieu_Suat_Thuc_Chien.html \
  Chuyen_Gia_Khai_Van_Hieu_Suat_Cao.html \
  Khai-Van_Quan_Tri_Chuyen_Nghiep.html src css js
~~~

Expected: no output.

- [ ] **Step 2: Remove only tracked runtime files**

~~~bash
git rm support.js image-slot.js .image-slots.state.json Header.dc.html Footer.dc.html
~~~

- [ ] **Step 3: Remove obsolete ignored local tooling separately**

Check each path with test -e before removing it. Do not pass ignored or absent paths to git rm.

- [ ] **Step 4: Track project documentation**

Edit .gitignore:

- remove CLAUDE.md;
- remove DESIGN.md;
- remove fix-dc.sh;
- retain /.claude/, /brand/, /screenshots/, and /uploads/.

Update CLAUDE.md and DESIGN.md to describe:

- edit source in src/;
- run node build.mjs;
- run node --test tests/*.test.mjs;
- commit source and built output;
- use css/gowise.css and page styles;
- use js/reveal.js for data-svg and motion;
- use program-ui data contracts for tabs/FAQ;
- no Claude Design sync workflow.

- [ ] **Step 5: Build and test after cleanup**

~~~bash
node build.mjs
node --test tests/build.test.mjs tests/static-contract.test.mjs
git diff --check
~~~

Expected: five pages built, all tests pass, and diff check is clean.

- [ ] **Step 6: Commit**

~~~bash
git add -A
git commit -m "chore: remove DC runtime and track static workflow docs"
~~~

---

## Task 13: Final browser, asset, and visual verification

**Files:** none.

- [ ] **Step 1: Run fresh automated verification**

~~~bash
node build.mjs
node --test tests/build.test.mjs tests/static-contract.test.mjs
git diff --check
git status --short
~~~

Expected: five pages built, all tests pass, no diff errors, and no uncommitted output.

- [ ] **Step 2: Verify served assets**

With python http.server running on 8777, request:

- all five .html URLs;
- css/gowise.css and all five page stylesheets;
- reveal.js, nav.js, program-ui.js, and contact.js;
- every local image referenced by built HTML.

Expected: every request returns 200.

- [ ] **Step 3: Run the complete browser matrix**

At 1280×900 and 390×844:

- all five initial-state screenshots match baseline;
- no console errors;
- no React, Babel, unpkg, support.js, or image-slot.js request;
- header desktop and mobile interactions pass;
- normal-motion reveal/count-up passes;
- reduced-motion behavior passes;
- all HPC tabs pass;
- all Management Coaching tabs and FAQs pass;
- mocked contact validation/success/error/network-error cases pass.

- [ ] **Step 4: Run final forbidden-token scan**

~~~bash
rg -n 'x-dc|dc-import|sc-for|sc-if| style=|style-hover|data-html|data-dc-script|onClick|onSubmit|\{\{|support\.js|image-slot\.js|unpkg\.com|react-dom|babel' \
  index.html Lien_He.html Khai_Van_Hieu_Suat_Thuc_Chien.html \
  Chuyen_Gia_Khai_Van_Hieu_Suat_Cao.html \
  Khai-Van_Quan_Tri_Chuyen_Nghiep.html src css js
~~~

Expected: no output.

- [ ] **Step 5: Finish the branch**

Use superpowers:finishing-a-development-branch only after Steps 1 through 4 have fresh passing evidence.

---

## Self-review checklist

- Build behavior is test-first and validates all pages before write.
- sc-if, data-html, stateful tabs, FAQ, and captcha are explicitly covered.
- Existing page root ids and page CSS scopes are preserved.
- Every page has separate static-parity and CSS-extraction commits.
- Header hover bridge and desktop resize behavior are preserved.
- Contact verification does not submit a real production lead.
- Cleanup separates tracked files from ignored or absent local files.
- CLAUDE.md and DESIGN.md become tracked.
- Final scans include sc-if, data-html, unresolved placeholders, and bound events.
- No implementation begins until this plan is approved.
