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
