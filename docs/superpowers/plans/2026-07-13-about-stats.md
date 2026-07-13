# About Statistics Content and Layout Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace the homepage About section's three metrics with four approved metrics in a stable 2×2 grid on mobile and desktop.

**Architecture:** Keep the existing About section and two-column page structure. Replace only the statistics wrapper and its children, using a named inline CSS grid with two equal columns so the responsive behavior is deterministic without adding a new stylesheet or breakpoint.

**Tech Stack:** Static HTML, inline CSS, POSIX shell regression test, Git.

---

## File Structure

- Create `tests/about-stats-layout.sh`: isolates the About section and verifies its exact four metrics, 2×2 grid contract, and unchanged desktop image geometry.
- Modify `index.html`: replace the current three-item flex metrics wrapper with four named grid items.

### Task 1: Add a Failing About Statistics Regression Test

**Files:**
- Create: `tests/about-stats-layout.sh`
- Test: `tests/about-stats-layout.sh`

- [ ] **Step 1: Write the failing test**

Create `tests/about-stats-layout.sh` with this exact content:

```sh
#!/bin/sh
set -eu

page="index.html"
about=$(sed -n '/<!-- ============ INTRO \/ ABOUT GWP ============ -->/,/<!-- ============ SOLUTION ECOSYSTEM ============ -->/p' "$page")

assert_contains() {
  expected="$1"
  message="$2"
  if ! printf '%s\n' "$about" | grep -Fq "$expected"; then
    echo "FAIL: $message"
    exit 1
  fi
}

assert_absent() {
  rejected="$1"
  message="$2"
  if printf '%s\n' "$about" | grep -Fq "$rejected"; then
    echo "FAIL: $message"
    exit 1
  fi
}

assert_contains 'class="gp-about-stats" style="display: grid; grid-template-columns: repeat(2, minmax(0, 1fr)); gap: 30px 24px; margin-top: 36px; align-items: start;"' \
  'About metrics must use the approved 2x2 grid on mobile and desktop'
assert_contains '>13</div>' \
  'first metric must be 13 without a plus sign'
assert_contains '>Năm kinh nghiệm tư vấn Coaching tổ chức</div>' \
  'first metric label is missing'
assert_contains '>21.000+</div>' \
  'training-hours metric is missing'
assert_contains '>Giờ đào tạo Khai vấn</div>' \
  'training-hours label is missing'
assert_contains '>9.000+</div>' \
  'management-coaching-hours metric is missing'
assert_contains '>Giờ Khai vấn quản trị</div>' \
  'management-coaching-hours label is missing'
assert_contains '>300+</div>' \
  'coach-development metric is missing'
assert_contains '>Coach được phát triển</div>' \
  'coach-development label is missing'
assert_contains 'class="gp-about-img-wrap" style="position: relative; height: 440px;' \
  'desktop About image geometry must remain unchanged'

metric_count=$(printf '%s\n' "$about" | grep -Fo 'class="gp-about-stat"' | wc -l | tr -d ' ')
if [ "$metric_count" -ne 4 ]; then
  echo "FAIL: expected 4 About metrics, found $metric_count"
  exit 1
fi

assert_absent '>2,100+</div>' \
  'superseded 2,100+ metric must be removed from About'
assert_absent '>Chuyên gia được đào tạo</div>' \
  'superseded specialist label must be removed from About'
assert_absent '>Năm kinh nghiệm</div>' \
  'superseded short experience label must be removed from About'

echo 'PASS: About statistics use the approved four-item responsive grid'
```

- [ ] **Step 2: Run the test to verify RED**

Run:

```bash
sh tests/about-stats-layout.sh
```

Expected: exit code 1 with `FAIL: About metrics must use the approved 2x2 grid on mobile and desktop`. This proves the test detects the current flex-based three-item block.

- [ ] **Step 3: Validate the test script syntax**

Run:

```bash
sh -n tests/about-stats-layout.sh
```

Expected: exit code 0 with no output.

- [ ] **Step 4: Commit the failing test**

```bash
git add tests/about-stats-layout.sh
git commit -m "test: cover responsive about statistics"
```

### Task 2: Replace the About Metrics with the Approved 2×2 Grid

**Files:**
- Modify: `index.html:144-156`
- Test: `tests/about-stats-layout.sh`

- [ ] **Step 1: Replace the current statistics wrapper and items**

Replace the existing three-item wrapper after the About paragraph with this exact markup:

```html
<div class="gp-about-stats" style="display: grid; grid-template-columns: repeat(2, minmax(0, 1fr)); gap: 30px 24px; margin-top: 36px; align-items: start;">
  <div class="gp-about-stat">
    <div style="font-family: 'Playfair Display', serif; font-size: 34px; font-weight: 600; color: #A87636; line-height: 1;">13</div>
    <div style="font-size: 12px; letter-spacing: 0.06em; color: #55606C; margin-top: 8px; line-height: 1.5;">Năm kinh nghiệm tư vấn Coaching tổ chức</div>
  </div>
  <div class="gp-about-stat">
    <div style="font-family: 'Playfair Display', serif; font-size: 34px; font-weight: 600; color: #A87636; line-height: 1;">21.000+</div>
    <div style="font-size: 12px; letter-spacing: 0.06em; color: #55606C; margin-top: 8px; line-height: 1.5;">Giờ đào tạo Khai vấn</div>
  </div>
  <div class="gp-about-stat">
    <div style="font-family: 'Playfair Display', serif; font-size: 34px; font-weight: 600; color: #A87636; line-height: 1;">9.000+</div>
    <div style="font-size: 12px; letter-spacing: 0.06em; color: #55606C; margin-top: 8px; line-height: 1.5;">Giờ Khai vấn quản trị</div>
  </div>
  <div class="gp-about-stat">
    <div style="font-family: 'Playfair Display', serif; font-size: 34px; font-weight: 600; color: #A87636; line-height: 1;">300+</div>
    <div style="font-size: 12px; letter-spacing: 0.06em; color: #55606C; margin-top: 8px; line-height: 1.5;">Coach được phát triển</div>
  </div>
</div>
```

- [ ] **Step 2: Run the targeted test to verify GREEN**

Run:

```bash
sh tests/about-stats-layout.sh
```

Expected: exit code 0 and `PASS: About statistics use the approved four-item responsive grid`.

- [ ] **Step 3: Run the existing mobile hero regression test**

Run:

```bash
sh tests/mobile-hero-layout.sh
```

Expected: exit code 0 and `PASS: mobile hero experience card stays above the photo`.

- [ ] **Step 4: Review the focused production diff**

Run:

```bash
git diff -- index.html
```

Expected: only the About statistics wrapper changes from flex to grid, the three old items become the four approved items, and the surrounding paragraph/image markup remains unchanged.

- [ ] **Step 5: Commit the implementation**

```bash
git add index.html
git commit -m "feat: update responsive about statistics"
```

### Task 3: Verify Mobile and Desktop Contracts

**Files:**
- Verify: `index.html`
- Verify: `tests/about-stats-layout.sh`
- Verify: `tests/mobile-hero-layout.sh`

- [ ] **Step 1: Run both regression tests fresh**

Run:

```bash
sh tests/about-stats-layout.sh
sh tests/mobile-hero-layout.sh
```

Expected: both commands exit 0 and print one PASS line each.

- [ ] **Step 2: Validate shell syntax**

Run:

```bash
sh -n tests/about-stats-layout.sh
sh -n tests/mobile-hero-layout.sh
```

Expected: both commands exit 0 with no output.

- [ ] **Step 3: Check whitespace and Git conflict markers**

Run:

```bash
git diff --check HEAD~2..HEAD
rg -n '^(<<<<<<< |=======|>>>>>>> )' index.html tests/about-stats-layout.sh tests/mobile-hero-layout.sh
```

Expected: `git diff --check` exits 0; `rg` exits 1 with no matches.

- [ ] **Step 4: Inspect responsive source contracts**

Run:

```bash
rg -n -C 2 'gp-about-stats|21\.000\+|9\.000\+|Coach được phát triển|gp-about-img-wrap' index.html
```

Expected: one 2×2 grid wrapper, four approved metrics, and the unchanged 440px desktop image wrapper.

- [ ] **Step 5: Check browser availability for mobile and PC review**

Use the configured browser backend, if available, to inspect `/` at 399×761 and 1280×900. Expected at both sizes: four metrics form two columns and two rows, remain inside the left/text area, and do not overlap the image. If no browser backend is available, record that limitation and rely only on the passing deterministic layout contract; do not claim a visual browser check.

- [ ] **Step 6: Review history and working-tree status**

Run:

```bash
git show --stat --oneline HEAD~2..HEAD
git status --short
```

Expected: one test commit and one implementation commit after the approved plan, with a clean working tree.
