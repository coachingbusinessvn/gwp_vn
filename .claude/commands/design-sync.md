---
description: Pull the latest pages from the "GWP Webiste" Claude Design project into this repo, showing a diff before overwriting and re-running fix-dc.sh after.
---

Pull page content from this project's Claude Design project down into the local repo. This is the **read** direction (design.claude.ai → local files) — the opposite of a normal `/design-sync`-style push.

## Config

Project reference and the list of syncable files live in `.claude/design-sync.json`:
- `project.projectId` — pass this as `projectId` to every `DesignSync` call.
- `syncFiles` — array of `{ remote, local }` pairs. `remote` is the path inside the Claude Design project (use for `DesignSync` calls). `local` is where it's written in this repo — top-level pages are renamed from `*.dc.html` to `*.html` locally (dropping the middle "dc") so GitHub Pages' clean-URL resolution works; `Header.dc.html`/`Footer.dc.html` keep their name unchanged in both places.

## Steps

1. Read `.claude/design-sync.json` for `projectId` and `syncFiles`.
2. Determine target entries:
   - If the user named specific file(s) in `$ARGUMENTS`, match against either `remote` or `local` in `syncFiles` (validate a match exists, or ask if not).
   - Otherwise, sync every entry in `syncFiles`.
3. For each target entry, call `DesignSync` with `method: "get_file"`, the config `projectId`, and `path` = the entry's `remote` value.
4. Write each fetched file's content to a scratch path (not the real file yet), then run `diff -u <entry.local> <scratch-file>` for every target to see exactly what would change.
5. Summarize the diffs for the user in plain language (copy changes vs. structural/CSS changes) — do not just dump raw diff output. Call out anything that looks like it would revert a recent local-only fix (check `git log --oneline -- <entry.local>` for recent "fix:" commits touching that file) — this project has previously had cases where the design project was a stale/older content snapshot vs. local, so don't assume design.claude.ai is always newer.
6. Ask the user to confirm before overwriting, unless they already said "just sync" / "overwrite" / equivalent up front in `$ARGUMENTS` or this conversation.
7. On confirmation, copy each scratch file over its `local` path.
8. Run `./fix-dc.sh <local1> <local2> ...` (only the files that were actually updated) to reconfirm GitHub Pages compatibility (support.js script tag present).
9. Run `git status --short` and `git diff --stat` and report the result. Do not commit unless the user asks.

## Notes

- `DesignSync`'s `list_files` / `get_project` methods are useful if the user asks "what's in the design project" or wants to sync a file not yet in `syncFiles` — add newly-discovered files as a new `{ remote, local }` entry in `.claude/design-sync.json`'s `syncFiles` array when found (giving top-level pages a `local` value with a plain `.html` extension, not `.dc.html`), so future runs pick them up automatically.
- If a freshly pulled page introduces new `<a href>` links to other pages, rewrite them to the extensionless convention already used across the site (e.g. `href="Lien_He"`, `href="./"` for home) rather than leaving `href="X.dc.html"` from the raw Claude Design export.
- Never call `finalize_plan` / `write_files` / `delete_files` as part of this command — those are for pushing local → design, which is a distinct, separate workflow this command does not perform.
