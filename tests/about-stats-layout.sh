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
