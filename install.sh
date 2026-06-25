#!/usr/bin/env bash
# Install the Digispot AI SEO skills into ~/.claude/skills/.
#
# For each skill we:
#   1. symlink  skills/<name>/        -> ~/.claude/skills/<name>
#   2. copy     _shared/seo-mcp-foundations.md -> skills/<name>/FOUNDATIONS.md
#      so the installed (symlinked) skill is self-contained — no dangling
#      ../_shared reference once it lives under ~/.claude/skills.
#
# Idempotent: re-run any time to refresh the foundation copies / relink.

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILLS_SRC="$REPO_DIR/skills"
FOUNDATION="$REPO_DIR/_shared/seo-mcp-foundations.md"
DEST="${CLAUDE_SKILLS_DIR:-$HOME/.claude/skills}"

[ -f "$FOUNDATION" ] || { echo "✗ missing $FOUNDATION" >&2; exit 1; }
mkdir -p "$DEST"

echo "Installing Digispot SEO skills → $DEST"
count=0
for skill_dir in "$SKILLS_SRC"/*/; do
  name="$(basename "$skill_dir")"
  [ -f "$skill_dir/SKILL.md" ] || { echo "  ⚠ skip $name (no SKILL.md)"; continue; }

  # 1. self-contain: copy foundation in beside the skill
  cp "$FOUNDATION" "$skill_dir/FOUNDATIONS.md"

  # 2. (re)link into the global skills dir
  link="$DEST/$name"
  [ -L "$link" ] || [ -e "$link" ] && rm -rf "$link"
  ln -s "$skill_dir" "$link"

  echo "  ✓ $name"
  count=$((count + 1))
done

echo "Done — $count skill(s) installed. Restart Claude Code to pick them up."
