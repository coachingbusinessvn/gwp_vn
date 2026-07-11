#!/usr/bin/env bash
# fix-dc.sh — Make a .dc.html file downloaded from Claude design work on GitHub Pages.
#
# Usage:
#   ./fix-dc.sh <file.dc.html>          # fix a specific file
#   ./fix-dc.sh                          # fix ALL *.dc.html in current directory

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CHANGED=0

fix_file() {
  local FILE="$1"
  local FIXED=0

  echo "▶ $FILE"

  # 1. Ensure <script src="./support.js"> exists right after <head>
  if ! grep -q 'src="./support.js"' "$FILE"; then
    # Use perl for portable in-place edit (works on macOS and Linux)
    perl -i -0pe 's|(<head[^>]*>)|$1\n<script src="./support.js"><\/script>|i' "$FILE"
    echo "  + injected <script src=\"./support.js\">"
    FIXED=1
  fi

  # 2. Ensure <x-dc> wrapper is present (Claude design always adds it, but sanity check)
  if ! grep -q '<x-dc' "$FILE"; then
    echo "  ⚠ WARNING: no <x-dc> found — this may not be a valid Claude design file."
  fi

  # 3. If this file is index.dc.html, create/verify index.html redirect
  local BASENAME
  BASENAME="$(basename "$FILE")"
  local DIR
  DIR="$(dirname "$FILE")"

  if [[ "$BASENAME" == "index.dc.html" ]]; then
    local INDEX="$DIR/index.html"
    if [[ ! -f "$INDEX" ]]; then
      cat > "$INDEX" << 'EOF'
<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<script>window.location.replace('index.dc.html');</script>
<noscript><meta http-equiv="refresh" content="0; url=index.dc.html"></noscript>
</head>
<body></body>
</html>
EOF
      echo "  + created index.html redirect"
      FIXED=1
    else
      echo "  ✓ index.html exists"
    fi
  fi

  # 4. Ensure .nojekyll exists so GitHub Pages doesn't ignore _files
  local NOJEKYLL="$SCRIPT_DIR/.nojekyll"
  if [[ ! -f "$NOJEKYLL" ]]; then
    touch "$NOJEKYLL"
    echo "  + created .nojekyll"
    FIXED=1
  fi

  if [[ $FIXED -eq 0 ]]; then
    echo "  ✓ already GitHub Pages-ready"
  else
    CHANGED=1
  fi
}

# --- Main ---

if [[ $# -ge 1 ]]; then
  for ARG in "$@"; do
    if [[ ! -f "$ARG" ]]; then
      echo "Error: not a file: $ARG" >&2
      exit 1
    fi
    fix_file "$ARG"
  done
else
  # No args → fix all *.dc.html in the script's directory
  shopt -s nullglob
  FILES=("$SCRIPT_DIR"/*.dc.html)
  if [[ ${#FILES[@]} -eq 0 ]]; then
    echo "No .dc.html files found in $SCRIPT_DIR"
    exit 0
  fi
  for F in "${FILES[@]}"; do
    fix_file "$F"
  done
fi

echo ""
if [[ $CHANGED -eq 1 ]]; then
  echo "Done. Review changes then: git add -A && git commit -m 'fix: GitHub Pages compat'"
else
  echo "Done. All files are already GitHub Pages-ready."
fi
