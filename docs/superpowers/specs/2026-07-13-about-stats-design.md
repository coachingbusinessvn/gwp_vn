# About Statistics Content and Layout Design

## Goal

Replace the three statistics in the homepage About section with four approved metrics and present them as a stable 2×2 grid on both mobile and desktop.

## Content

The existing metrics are replaced, not extended. The approved number and label pairs are:

1. `13` — `Năm kinh nghiệm tư vấn Coaching tổ chức`
2. `21.000+` — `Giờ đào tạo Khai vấn`
3. `9.000+` — `Giờ Khai vấn quản trị`
4. `300+` — `Coach được phát triển`

The Vietnamese thousands separator remains a period exactly as supplied. Only the first metric omits a plus sign.

## Layout

The statistics wrapper becomes a named 2×2 CSS grid rather than an implicitly wrapping flex row. It uses `grid-template-columns: repeat(2, minmax(0, 1fr))`, top-aligned items, a 30px row gap, and a 24px column gap. The existing 36px space above the statistics is retained. Each metric is a self-contained item containing one number and one label.

The same two-column grid is used at desktop and mobile widths. This avoids squeezing four long labels into one desktop row and prevents content-dependent wrapping on mobile. Existing typography, gold number color, body-copy color, and spacing above the statistics remain aligned with the current design language.

## Responsive Acceptance Criteria

At the reported 399×761 viewport:

- all four metrics render in two columns and two rows;
- no metric is clipped or overlaps another metric;
- labels wrap within their own equal-width grid cells;
- the following team image remains below the complete statistics block.

At a 1280×900 desktop viewport:

- the About section remains a two-column text-and-image layout;
- the four metrics render as a 2×2 grid inside the left text column;
- labels do not intrude into the right image column;
- the About image and badge retain their current size and positioning.

## Scope

Only the About-section statistics markup and the minimum CSS classes needed for the grid are in scope. The dark hero badges, About paragraph, team image, other homepage metrics, animations, and console/network warnings remain unchanged.

## Testing and Verification

Add a failing static regression test before implementation. It must assert all four exact number/label pairs, the named statistics grid, its two equal columns, and the absence of the three superseded labels in the About block.

After implementation, run the targeted regression test, shell syntax validation, whitespace/conflict checks, and review the focused diff. Visually verify the homepage at 399×761 and 1280×900 when a browser backend is available. If browser control remains unavailable, report that limitation explicitly and use the deterministic grid contract plus source inspection as the fallback evidence; do not claim visual browser verification.
