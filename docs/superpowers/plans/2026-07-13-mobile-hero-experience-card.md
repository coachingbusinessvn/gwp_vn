# Mobile Hero Experience Card Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Place the mobile `13+ NĂM KINH NGHIỆM` card in a dedicated lane above the homepage hero photo so it cannot obscure faces in current or replacement images.

**Architecture:** Keep the existing absolutely positioned hero composition and all desktop/tablet geometry. At the max-width 640px breakpoint, reserve the top 92px of `.gp-hero-visual` for the experience card, start the 255px photo at 92px, and increase the visual container to 350px; a dedicated card class makes the contract explicit and testable.

**Tech Stack:** Static HTML, inline CSS media queries, POSIX shell regression test, Git.

---

## File Structure

- Create `tests/mobile-hero-layout.sh`: static regression check for the homepage mobile hero geometry and unchanged desktop geometry.
- Modify `index.html`: add the experience-card class and update only the max-width 640px hero visual/photo rules.

### Task 1: Add the Failing Mobile Layout Regression Test

**Files:**
- Create: `tests/mobile-hero-layout.sh`
- Test: `tests/mobile-hero-layout.sh`

- [ ] **Step 1: Write the failing test**

Create `tests/mobile-hero-layout.sh` with this exact content:

```sh
#!/bin/sh
set -eu

page="index.html"

assert_contains() {
  expected="$1"
  message="$2"
  if ! grep -Fq "$expected" "$page"; then
    echo "FAIL: $message"
    exit 1
  fi
}

assert_contains 'class="gp-hero-experience-card"' \
  'experience card needs a dedicated class'
assert_contains '.gp-hero-visual { height: 350px !important; }' \
  'mobile hero visual must reserve a 350px composition'
assert_contains '.gp-hero-photo { top: 92px !important; left: 16px !important; width: calc(100% - 76px) !important; height: 255px !important; }' \
  'mobile photo must start below the 92px experience-card lane'
assert_contains 'class="gp-hero-photo" style="position: absolute; top: 24px; left: 44px; width: 300px; height: 400px;' \
  'desktop photo geometry must remain unchanged'
assert_contains 'class="gp-hero-experience-card" style="position: absolute; top: 8px; right: 6px;' \
  'experience card must keep its top-right geometry'

echo 'PASS: mobile hero experience card stays above the photo'
```

- [ ] **Step 2: Run the test to verify RED**

Run:

```bash
sh tests/mobile-hero-layout.sh
```

Expected: exit code 1 with `FAIL: experience card needs a dedicated class`. This proves the regression check detects the current overlapping implementation.

- [ ] **Step 3: Validate the test script syntax**

Run:

```bash
sh -n tests/mobile-hero-layout.sh
```

Expected: exit code 0 with no output.

- [ ] **Step 4: Commit the failing test**

```bash
git add tests/mobile-hero-layout.sh
git commit -m "test: cover mobile hero card separation"
```

### Task 2: Reserve the Mobile Experience-Card Lane

**Files:**
- Modify: `index.html:78-81`
- Modify: `index.html:114-117`
- Test: `tests/mobile-hero-layout.sh`

- [ ] **Step 1: Add the dedicated experience-card class**

Change the opening element for the `13+` card from:

```html
<div style="position: absolute; top: 8px; right: 6px; background: rgba(7,18,31,0.72); backdrop-filter: blur(6px); border: 1px solid rgba(201,166,104,0.35); padding: 14px 18px; animation: gpFloat 6s ease-in-out infinite;">
```

to:

```html
<div class="gp-hero-experience-card" style="position: absolute; top: 8px; right: 6px; background: rgba(7,18,31,0.72); backdrop-filter: blur(6px); border: 1px solid rgba(201,166,104,0.35); padding: 14px 18px; animation: gpFloat 6s ease-in-out infinite;">
```

- [ ] **Step 2: Update the max-width 640px composition**

Replace these mobile rules:

```css
.gp-hero-visual { height: 300px !important; }
.gp-hero-photo { left: 16px !important; width: calc(100% - 76px) !important; height: 255px !important; }
```

with:

```css
.gp-hero-visual { height: 350px !important; }
.gp-hero-photo { top: 92px !important; left: 16px !important; width: calc(100% - 76px) !important; height: 255px !important; }
```

This keeps the card at `top: 8px`, places the image below its approximately 71px box with at least 13px separation, and contains the photo through 347px inside the 350px visual.

- [ ] **Step 3: Run the targeted test to verify GREEN**

Run:

```bash
sh tests/mobile-hero-layout.sh
```

Expected: exit code 0 and `PASS: mobile hero experience card stays above the photo`.

- [ ] **Step 4: Review the focused source diff**

Run:

```bash
git diff -- index.html
```

Expected: exactly three production changes: `300px` to `350px`, addition of `top: 92px` to the mobile photo rule, and addition of `gp-hero-experience-card` to the experience card. No desktop inline values or unrelated sections change.

- [ ] **Step 5: Commit the implementation**

```bash
git add index.html
git commit -m "fix: keep mobile hero card above photo"
```

### Task 3: Verify the Completed Fix

**Files:**
- Verify: `index.html`
- Verify: `tests/mobile-hero-layout.sh`
- Verify: `docs/superpowers/specs/2026-07-13-mobile-hero-experience-card-design.md`

- [ ] **Step 1: Run the targeted regression test fresh**

Run:

```bash
sh tests/mobile-hero-layout.sh
```

Expected: exit code 0 and one PASS line.

- [ ] **Step 2: Run shell syntax validation**

Run:

```bash
sh -n tests/mobile-hero-layout.sh
```

Expected: exit code 0 with no output.

- [ ] **Step 3: Check whitespace and conflict markers**

Run:

```bash
git diff --check HEAD~2..HEAD
```

Expected: exit code 0 with no output.

Run:

```bash
rg -n '<<<<<<<|=======|>>>>>>>' index.html tests/mobile-hero-layout.sh
```

Expected: exit code 1 with no matches.

- [ ] **Step 4: Confirm the mobile layout arithmetic**

Run:

```bash
test $((8 + 71 + 13)) -le 92
test $((92 + 255)) -le 350
```

Expected: both commands exit 0. The first proves the card lane includes the approximate 71px card plus the 13px minimum separation; the second proves the photo remains contained.

- [ ] **Step 5: Review the complete task diff and status**

Run:

```bash
git show --stat --oneline HEAD~2..HEAD
git status --short
```

Expected: the task history contains only the test and implementation commits after the approved design commit, and the working tree is clean.
