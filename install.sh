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

# Resolve to absolute paths for token substitution so installed skills work
# regardless of which directory Claude is invoked from.
ABS_WORKSPACE="$(cd "$WORKSPACE" && pwd)"
ABS_SKILLS="$(cd "$CLAUDE_SKILLS" && pwd)"

substitute_tokens() {
  # In-place replace {{WORKSPACE}} and {{SKILLS_DIR}} across a directory tree.
  local root="$1"
  find "$root" -type f \( -name '*.md' -o -name '*.py' -o -name '*.yaml' -o -name '*.yml' \) -print0 \
    | while IFS= read -r -d '' f; do
        sed -i.bak \
          -e "s|{{WORKSPACE}}|$ABS_WORKSPACE|g" \
          -e "s|{{SKILLS_DIR}}|$ABS_SKILLS|g" \
          "$f"
        rm -f "$f.bak"
      done
}

for skill in learning-plan math-worksheet wolfram; do
  dest="$CLAUDE_SKILLS/$skill"
  if confirm_overwrite "$dest"; then
    cp -R "$PAYLOAD/skills/$skill" "$dest"
    substitute_tokens "$dest"
    echo "  installed skill: $skill (paths resolved)"
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

To install to non-default locations, re-run with:
  CLAUDE_WORKSPACE_DIR=/custom/workspace CLAUDE_SKILLS_DIR=/custom/skills ./install.sh
Path tokens in the skill source are resolved automatically at install time.
EOF
