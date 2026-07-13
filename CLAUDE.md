# Project — GoWise Partners

**Brand is locked.** Before designing any new page, read `DESIGN.md` (frozen tokens, components, motion, snippets) and use `brand/gowise.css` + `brand/tailwind.config.js`.

Rules:
- Only use the colors, fonts (Playfair Display + Montserrat), radii, and gradients defined in `DESIGN.md` §2–3. Never invent new ones. Gold ≤ 10% of the surface.
- Reuse component classes from `brand/gowise.css` (`.gp-btn`, `.gp-card-dark/-light`, `.gp-eyebrow`, `.gp-icon-ring`, `.gp-reveal`, …).
- SVG icons in Design Components: store full `<svg>` string in `data-svg` and inject via `innerHTML` on mount (see `DESIGN.md` §10). Holes and `dangerouslySetInnerHTML` on `<svg>` don't work.
- Scroll-reveal + count-up: use the snippet in `DESIGN.md` §11; always respect `prefers-reduced-motion`.
- Reference implementation: `Khai Van Hieu Suat Thuc Chien.dc.html`.

## Syncing from Claude Design

This project's Claude Design project ("GWP Webiste") is the source for the `.dc.html` pages. Its URL and the list of synced files are saved in `.claude/design-sync.json`. Run `/design-sync` (see `.claude/commands/design-sync.md`) to pull the latest content from Claude Design into the repo — it diffs before overwriting and re-runs `fix-dc.sh` after. Claude Design content isn't always newer than local — check the diff before confirming.
