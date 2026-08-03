#!/usr/bin/env bash
# Install the Digispot AI SEO skills into ~/.claude/skills/.
#
# Two ways to run it:
#
#   A. No clone (recommended for users):
#        curl -fsSL https://raw.githubusercontent.com/digispot-ai/digispot-ai-seo-skills/main/install.sh | bash
#      Downloads a source snapshot to ~/.digispot/seo-skills and installs REAL
#      directories into ~/.claude/skills — self-contained, nothing to keep around.
#
#   B. From a clone (for development):
#        git clone … && ./install.sh
#      Symlinks each skill back into the clone, so edits are live.
#
# In both modes each skill folder gets a generated FOUNDATIONS.md copy of
# _shared/seo-mcp-foundations.md, so the installed skill is self-contained —
# no dangling ../_shared reference once it lives under ~/.claude/skills.
#
# Per-project setup (run once per site repo, after the global install):
#   ./install.sh --project <path-to-site-repo>
#     Writes/refreshes the Digispot routing block in <repo>/AGENTS.md (between
#     "digispot-seo:begin/end" markers — your own AGENTS.md content is kept),
#     points CLAUDE.md at it if no CLAUDE.md exists, and sanity-checks .mcp.json.
#   Piped form (no clone):
#     curl -fsSL <raw-url>/install.sh | bash -s -- --project ~/code/my-site
#
# Idempotent: re-run any time to refresh the sources / foundation copies / block.

set -euo pipefail

REPO_SLUG="${DIGISPOT_SKILLS_REPO:-digispot-ai/digispot-ai-seo-skills}"
REPO_REF="${DIGISPOT_SKILLS_REF:-main}"
CACHE_DIR="${DIGISPOT_SKILLS_HOME:-$HOME/.digispot/seo-skills}"
DEST="${CLAUDE_SKILLS_DIR:-$HOME/.claude/skills}"

# Where do the sources live? When piped through bash there is no BASH_SOURCE,
# so fetch a snapshot instead of reading from disk.
SELF_DIR=""
if [ -n "${BASH_SOURCE[0]:-}" ]; then
  SELF_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" 2>/dev/null && pwd)" || SELF_DIR=""
fi

if [ -n "$SELF_DIR" ] && [ -f "$SELF_DIR/_shared/seo-mcp-foundations.md" ]; then
  REPO_DIR="$SELF_DIR"
  INSTALL_MODE="clone"      # symlink → live edits
else
  REPO_DIR="$CACHE_DIR"
  INSTALL_MODE="download"   # copy → self-contained
  echo "Fetching $REPO_SLUG@$REPO_REF …"
  command -v curl >/dev/null || { echo "✗ curl is required" >&2; exit 1; }
  TMP="$(mktemp -d)"
  trap 'rm -rf "$TMP"' EXIT
  curl -fsSL "https://codeload.github.com/$REPO_SLUG/tar.gz/refs/heads/$REPO_REF" \
    | tar -xz -C "$TMP" \
    || { echo "✗ could not download $REPO_SLUG@$REPO_REF" >&2; exit 1; }
  SRC="$(find "$TMP" -maxdepth 1 -mindepth 1 -type d | head -1)"
  [ -f "$SRC/_shared/seo-mcp-foundations.md" ] || { echo "✗ unexpected archive layout" >&2; exit 1; }
  rm -rf "$CACHE_DIR"
  mkdir -p "$(dirname "$CACHE_DIR")"
  mv "$SRC" "$CACHE_DIR"
  echo "  ✓ sources → $CACHE_DIR"
fi

SKILLS_SRC="$REPO_DIR/skills"
FOUNDATION="$REPO_DIR/_shared/seo-mcp-foundations.md"
AGENTS_TEMPLATE="$REPO_DIR/_shared/AGENTS-template.md"

# ---------------------------------------------------------------- --project
if [ "${1:-}" = "--project" ]; then
  PROJECT_DIR="${2:?usage: ./install.sh --project <path-to-site-repo>}"
  PROJECT_DIR="$(cd "$PROJECT_DIR" && pwd)"
  [ -f "$AGENTS_TEMPLATE" ] || { echo "✗ missing $AGENTS_TEMPLATE" >&2; exit 1; }

  AGENTS_FILE="$PROJECT_DIR/AGENTS.md"
  BEGIN='<!-- digispot-seo:begin'
  END='<!-- digispot-seo:end -->'

  if [ -f "$AGENTS_FILE" ] && grep -q "$BEGIN" "$AGENTS_FILE"; then
    # Replace the existing marked block in place; keep everything else.
    awk -v tmpl="$AGENTS_TEMPLATE" -v begin="$BEGIN" -v end="$END" '
      index($0, begin) == 1 { skipping = 1; while ((getline line < tmpl) > 0) print line; close(tmpl); next }
      index($0, end)   == 1 { skipping = 0; next }
      !skipping { print }
    ' "$AGENTS_FILE" > "$AGENTS_FILE.tmp" && mv "$AGENTS_FILE.tmp" "$AGENTS_FILE"
    echo "  ✓ refreshed Digispot block in $AGENTS_FILE"
  elif [ -f "$AGENTS_FILE" ]; then
    printf '\n' >> "$AGENTS_FILE"
    cat "$AGENTS_TEMPLATE" >> "$AGENTS_FILE"
    echo "  ✓ appended Digispot block to existing $AGENTS_FILE"
  else
    cp "$AGENTS_TEMPLATE" "$AGENTS_FILE"
    echo "  ✓ created $AGENTS_FILE"
  fi

  # Claude Code reads CLAUDE.md; point it at AGENTS.md if the repo has none.
  if [ ! -f "$PROJECT_DIR/CLAUDE.md" ]; then
    printf '@AGENTS.md\n' > "$PROJECT_DIR/CLAUDE.md"
    echo "  ✓ created CLAUDE.md → @AGENTS.md import"
  fi

  # Sanity-check the MCP binding.
  if [ -f "$PROJECT_DIR/.mcp.json" ]; then
    if grep -q "digispot" "$PROJECT_DIR/.mcp.json"; then
      echo "  ✓ .mcp.json has a digispot server entry"
    else
      echo "  ⚠ .mcp.json exists but has no digispot entry — bind the Spider (--project) or add the Platform server"
    fi
  else
    echo "  ⚠ no .mcp.json — connect the Digispot Spider app (writes it) or add the Platform MCP manually"
  fi

  echo "Done — project setup for $PROJECT_DIR. Commit AGENTS.md to share routing with your team."
  exit 0
fi
# --------------------------------------------------------------------------

[ -f "$FOUNDATION" ] || { echo "✗ missing $FOUNDATION" >&2; exit 1; }
mkdir -p "$DEST"

echo "Installing Digispot SEO skills → $DEST  (mode: $INSTALL_MODE)"
count=0
for skill_dir in "$SKILLS_SRC"/*/; do
  name="$(basename "$skill_dir")"
  [ -f "$skill_dir/SKILL.md" ] || { echo "  ⚠ skip $name (no SKILL.md)"; continue; }

  # 1. self-contain: generate the foundation copy beside the skill
  cp "$FOUNDATION" "$skill_dir/FOUNDATIONS.md"

  # 2. place it in the global skills dir
  target="$DEST/$name"
  rm -rf "$target"
  if [ "$INSTALL_MODE" = "clone" ]; then
    ln -s "$skill_dir" "$target"          # dev: edits in the clone go live
  else
    cp -R "$skill_dir" "$target"          # user: real files, no external dependency
  fi

  echo "  ✓ $name"
  count=$((count + 1))
done

echo "Done — $count skill(s) installed. Restart Claude Code to pick them up."
if [ "$INSTALL_MODE" = "clone" ]; then
  echo "Note: skills are symlinked into this clone — keep it where it is, or re-run from elsewhere."
fi
if [ "$INSTALL_MODE" = "clone" ]; then
  echo "Next: set up a site repo →  ./install.sh --project <path-to-site-repo>"
else
  echo "Next: set up a site repo →  $CACHE_DIR/install.sh --project <path-to-site-repo>"
fi
