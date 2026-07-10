# Project — GoWise Partners

**Brand is locked.** Before designing any new page, read `DESIGN.md` (frozen tokens, components, motion, snippets) and use `brand/gowise.css` + `brand/tailwind.config.js`.

Rules:
- Only use the colors, fonts (Playfair Display + Montserrat), radii, and gradients defined in `DESIGN.md` §2–3. Never invent new ones. Gold ≤ 10% of the surface.
- Reuse component classes from `brand/gowise.css` (`.gp-btn`, `.gp-card-dark/-light`, `.gp-eyebrow`, `.gp-icon-ring`, `.gp-reveal`, …).
- SVG icons in Design Components: store full `<svg>` string in `data-svg` and inject via `innerHTML` on mount (see `DESIGN.md` §10). Holes and `dangerouslySetInnerHTML` on `<svg>` don't work.
- Scroll-reveal + count-up: use the snippet in `DESIGN.md` §11; always respect `prefers-reduced-motion`.
- Reference implementation: `Khai Van Hieu Suat Thuc Chien.dc.html`.
