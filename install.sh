#!/usr/bin/env bash
# Installer for the learning-plan skill bundle.
# Places skills under ~/.claude/skills and reference content under ~/claude-workspace.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PAYLOAD="$SCRIPT_DIR/payload"

CLAUDE_SKILLS="${CLAUDE_SKILLS_DIR:-$HOME/.claude/skills}"
WORKSPACE="${CLAUDE_WORKSPACE_DIR:-$HOME/claude-workspace}"

echo "Installing learning-plan bundle"
echo "  skills        -> $CLAUDE_SKILLS"
echo "  workspace     -> $WORKSPACE"
echo

confirm_overwrite() {
  local path="$1"
  if [ -e "$path" ]; then
    read -r -p "  '$path' exists. Overwrite? [y/N] " ans
    [[ "$ans" =~ ^[Yy]$ ]] || { echo "  skipped $path"; return 1; }
    rm -rf "$path"
  fi
  return 0
}

mkdir -p "$CLAUDE_SKILLS" "$WORKSPACE/ai-resources" "$WORKSPACE/sample-modules"

for skill in learning-plan math-worksheet; do
  dest="$CLAUDE_SKILLS/$skill"
  if confirm_overwrite "$dest"; then
    cp -R "$PAYLOAD/skills/$skill" "$dest"
    echo "  installed skill: $skill"
  fi
done

phil_dest="$WORKSPACE/ai-resources/learning-philosophy.md"
if confirm_overwrite "$phil_dest"; then
  cp "$PAYLOAD/workspace/ai-resources/learning-philosophy.md" "$phil_dest"
  echo "  installed: $phil_dest"
fi

quad_dest="$WORKSPACE/sample-modules/quadratics"
if confirm_overwrite "$quad_dest"; then
  cp -R "$PAYLOAD/workspace/sample-modules/quadratics" "$quad_dest"
  echo "  installed: $quad_dest"
fi

chmod +x "$CLAUDE_SKILLS/math-worksheet/verify.py" 2>/dev/null || true

cat <<'EOF'

Install complete.

Post-install steps:
  1. Get a Wolfram Alpha App ID (free tier works):
       https://developer.wolframalpha.com/access
  2. Write it to ~/.config/wolfram/app_id:
       mkdir -p ~/.config/wolfram
       printf 'YOUR_APP_ID_HERE' > ~/.config/wolfram/app_id
  3. Ensure python3 + `requests` is available:
       python3 -m pip install --user requests
  4. In Claude Code, invoke the skill:
       /learning-plan generate <topic>

If your workspace lives elsewhere, set CLAUDE_WORKSPACE_DIR before running,
and update any path references in the installed skills accordingly.
EOF
