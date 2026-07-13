# Project — GoWise Partners

**Brand is locked.** Before designing any new page, read `DESIGN.md` (frozen tokens, components, motion, snippets) and use `brand/gowise.css` + `brand/tailwind.config.js`.

Rules:
- Only use the colors, fonts (Playfair Display + Montserrat), radii, and gradients defined in `DESIGN.md` §2–3. Never invent new ones. Gold ≤ 10% of the surface.
- Reuse component classes from `brand/gowise.css` (`.gp-btn`, `.gp-card-dark/-light`, `.gp-eyebrow`, `.gp-icon-ring`, `.gp-reveal`, …).
- SVG icons in Design Components: store full `<svg>` string in `data-svg` and inject via `innerHTML` on mount (see `DESIGN.md` §10). Holes and `dangerouslySetInnerHTML` on `<svg>` don't work.
- Scroll-reveal + count-up: use the snippet in `DESIGN.md` §11; always respect `prefers-reduced-motion`.
- Reference implementation: `Khai_Van_Hieu_Suat_Thuc_Chien.html`.
- Top-level pages are served as `PageName.html` (not `.dc.html`) so GitHub Pages resolves extensionless links (`href="PageName"`) — it doesn't auto-resolve the double `.dc.html` extension. `Header.dc.html`/`Footer.dc.html` keep the `.dc.html` name since `<dc-import>` fetches partials by that hardcoded suffix. Internal links use the extensionless convention (`href="Lien_He"`, `href="./"` for home) — follow it for any new link.

## Syncing from Claude Design

This project's Claude Design project ("GWP Webiste") stores pages as `.dc.html` — its URL and the remote-to-local filename mapping are saved in `.claude/design-sync.json`. Run `/design-sync` (see `.claude/commands/design-sync.md`) to pull the latest content from Claude Design into the repo — it diffs before overwriting, writes to the renamed local `.html` filename, and re-runs `fix-dc.sh` after. Claude Design content isn't always newer than local — check the diff before confirming.
