# GitHub Pages Navigation Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Ensure the home page and each programme page can navigate to one another after deployment to GitHub Pages from a project repository.

**Architecture:** HTML pages are all published in the repository root. Internal page navigation uses `./`-prefixed relative URLs, which retain the project repository path during browser resolution. Same-page anchors and external destinations remain untouched.

**Tech Stack:** Static HTML, GitHub Pages.

---

### Task 1: Normalize home-page programme links

**Files:**
- Modify: `index.html:46-48,157,170,272-274`
- Test: manual static link audit

- [ ] **Step 1: Confirm the required destination files exist**

Run: `rg --files -g '*.html' | rg '^(index|Khai_Van_Hieu_Suat_Thuc_Chien\.dc|Khai_Van_Quan_Tri_Chuyen_Nghiep\.dc|Chuyen_Gia_Khai_Van_Hieu_Suat_Cao\.dc)\.html$'`

Expected: the home page and all three programme-page files are listed.

- [ ] **Step 2: Replace home-page programme URLs with explicit relative URLs**

Replace each programme-page `href` in `index.html` with its matching value:

```html
./Khai_Van_Hieu_Suat_Thuc_Chien.dc.html
./Chuyen_Gia_Khai_Van_Hieu_Suat_Cao.dc.html
./Khai_Van_Quan_Tri_Chuyen_Nghiep.dc.html
```

Use the matching URL in the header, solution-card, and footer links.

- [ ] **Step 3: Audit the home page URLs**

Run: `rg -n 'href="/?(?:Khai_Van_Hieu_Suat_Thuc_Chien|Khai_Van_Quan_Tri_Chuyen_Nghiep|Chuyen_Gia_Khai_Van_Hieu_Suat_Cao).*\.html"' index.html`

Expected: every matching local programme URL starts with `./`, and none starts with `/`.

### Task 2: Normalize programme-page return links

**Files:**
- Modify: `Khai_Van_Hieu_Suat_Thuc_Chien.dc.html:39`
- Modify: `Khai_Van_Quan_Tri_Chuyen_Nghiep.dc.html:39`
- Modify: `Chuyen_Gia_Khai_Van_Hieu_Suat_Cao.dc.html:40`
- Test: manual static link audit

- [ ] **Step 1: Replace the logo return links**

In each programme page, change the logo anchor from:

```html
<a href="/index.html" style="display: flex; align-items: center;">
```

to:

```html
<a href="./index.html" style="display: flex; align-items: center;">
```

- [ ] **Step 2: Confirm every programme page has one relative home-page return URL**

Run: `rg -n 'href="(?:/index\.html|\./index\.html)"' Khai_Van_Hieu_Suat_Thuc_Chien.dc.html Khai_Van_Quan_Tri_Chuyen_Nghiep.dc.html Chuyen_Gia_Khai_Van_Hieu_Suat_Cao.dc.html`

Expected: exactly three matches, all using `./index.html`.

### Task 3: Verify all internal page-file links

**Files:**
- Verify: `index.html`
- Verify: `Khai_Van_Hieu_Suat_Thuc_Chien.dc.html`
- Verify: `Khai_Van_Quan_Tri_Chuyen_Nghiep.dc.html`
- Verify: `Chuyen_Gia_Khai_Van_Hieu_Suat_Cao.dc.html`

- [ ] **Step 1: Inspect all local HTML destinations**

Run: `rg -n 'href="[^"]+\.html"' -g '*.html' .`

Expected: each listed URL is either `./index.html` or one of the three `./...dc.html` programme files; there are no leading-slash local HTML URLs.

- [ ] **Step 2: Confirm every referenced local destination exists**

Run: `test -f index.html && test -f Khai_Van_Hieu_Suat_Thuc_Chien.dc.html && test -f Khai_Van_Quan_Tri_Chuyen_Nghiep.dc.html && test -f Chuyen_Gia_Khai_Van_Hieu_Suat_Cao.dc.html && echo 'all local page targets exist'`

Expected: `all local page targets exist`.

- [ ] **Step 3: Review the final page-link diff**

Run: `git diff -- index.html Khai_Van_Hieu_Suat_Thuc_Chien.dc.html Khai_Van_Quan_Tri_Chuyen_Nghiep.dc.html Chuyen_Gia_Khai_Van_Hieu_Suat_Cao.dc.html`

Expected: only the local-page `href` values change.

- [ ] **Step 4: Commit the navigation fix**

Run: `git add index.html Khai_Van_Hieu_Suat_Thuc_Chien.dc.html Khai_Van_Quan_Tri_Chuyen_Nghiep.dc.html Chuyen_Gia_Khai_Van_Hieu_Suat_Cao.dc.html && git commit -m "fix: use GitHub Pages-safe navigation links"`

Expected: one commit containing only the four navigation-file updates.
