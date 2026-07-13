---
description: Pull the latest .dc.html pages from the "GWP Webiste" Claude Design project into this repo, showing a diff before overwriting and re-running fix-dc.sh after.
---

Pull page content from this project's Claude Design project down into the local repo. This is the **read** direction (design.claude.ai → local files) — the opposite of a normal `/design-sync`-style push.

## Config

Project reference and the list of syncable files live in `.claude/design-sync.json`:
- `project.projectId` — pass this as `projectId` to every `DesignSync` call.
- `syncFiles` — local paths that exist 1:1 at the same relative path in the design project.

## Steps

1. Read `.claude/design-sync.json` for `projectId` and `syncFiles`.
2. Determine target files:
   - If the user named specific file(s) in `$ARGUMENTS`, sync only those (validate they're in `syncFiles`, or ask if not).
   - Otherwise, sync every file in `syncFiles`.
3. For each target file, call `DesignSync` with `method: "get_file"`, the config `projectId`, and `path` = the file's repo-relative path.
4. Write each fetched file's content to a scratch path (not the real file yet), then run `diff -u <local-file> <scratch-file>` for every target to see exactly what would change.
5. Summarize the diffs for the user in plain language (copy changes vs. structural/CSS changes) — do not just dump raw diff output. Call out anything that looks like it would revert a recent local-only fix (check `git log --oneline -- <file>` for recent "fix:" commits touching that file) — this project has previously had cases where the design project was a stale/older content snapshot vs. local, so don't assume design.claude.ai is always newer.
6. Ask the user to confirm before overwriting, unless they already said "just sync" / "overwrite" / equivalent up front in `$ARGUMENTS` or this conversation.
7. On confirmation, copy each scratch file over its real local path.
8. Run `./fix-dc.sh <file1> <file2> ...` (only the files that were actually updated) to reconfirm GitHub Pages compatibility (support.js script tag + index.html redirect for index.dc.html).
9. Run `git status --short` and `git diff --stat` and report the result. Do not commit unless the user asks.

## Notes

- `DesignSync`'s `list_files` / `get_project` methods are useful if the user asks "what's in the design project" or wants to sync a file not yet in `syncFiles` — add newly-discovered `.dc.html` files to `.claude/design-sync.json`'s `syncFiles` array when found, so future runs pick them up automatically.
- Never call `finalize_plan` / `write_files` / `delete_files` as part of this command — those are for pushing local → design, which is a distinct, separate workflow this command does not perform.
