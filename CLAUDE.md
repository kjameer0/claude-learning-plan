# Orchestration guide for installing this bundle

This directory packages the `learning-plan` Claude Code skill plus dependencies. When the user invokes you from this directory and asks to install/set up/reconstruct the bundle, follow the steps below.

## What this bundle installs

| Source (in `payload/`) | Destination | Notes |
|---|---|---|
| `payload/skills/learning-plan` | `~/.claude/skills/learning-plan` | Main skill |
| `payload/skills/math-worksheet` | `~/.claude/skills/math-worksheet` | Required dependency |
| `payload/skills/wolfram` | `~/.claude/skills/wolfram` | Ad-hoc Wolfram queries (wraps `math-worksheet/verify.py`) |
| `payload/workspace/ai-resources/learning-philosophy.md` | `~/claude-workspace/ai-resources/learning-philosophy.md` | Foundational reference |
| `payload/workspace/sample-modules/quadratics` | `~/claude-workspace/sample-modules/quadratics` | Canonical example module |

Paths in `payload/skills/**` use `{{WORKSPACE}}` and `{{SKILLS_DIR}}` tokens. `install.sh` resolves them to absolute paths at install time. Do not edit installed skill files to re-tokenize — re-run the installer instead.

## Installation procedure

1. **Confirm prerequisites with the user** before running the installer:
   - `python3` is on PATH (`python3 --version`).
   - `requests` is importable (`python3 -c 'import requests'`). If not, suggest `python3 -m pip install --user requests`.
   - The user has (or will obtain) a Wolfram Alpha App ID. If they don't, point them at https://developer.wolframalpha.com/access and pause — installation can proceed, but the `math-worksheet` skill won't work until the App ID is in place.

2. **Ask whether to use default install paths** (`~/.claude/skills`, `~/claude-workspace`). If the user wants custom paths, set `CLAUDE_SKILLS_DIR` and/or `CLAUDE_WORKSPACE_DIR` before the install call.

3. **Run the installer:**

   ```sh
   ./install.sh
   ```

   The installer prompts before overwriting existing files. If the user already has files at the destinations, surface what would be overwritten (`ls` the destinations first) so they can decide deliberately. Do not auto-answer `y` to overwrites without their consent.

4. **Write the Wolfram App ID** if the user provides it:

   ```sh
   mkdir -p ~/.config/wolfram
   printf '%s' 'THEIR_APP_ID' > ~/.config/wolfram/app_id
   ```

   Never echo the App ID back into chat after it's written.

5. **Verify install:**
   - Confirm the four destinations exist and are non-empty.
   - Grep the installed skill files for unresolved tokens: `grep -rn '{{WORKSPACE}}\|{{SKILLS_DIR}}' ~/.claude/skills/learning-plan ~/.claude/skills/math-worksheet` should return nothing.
   - Spot-check one path in `~/.claude/skills/learning-plan/SKILL.md` to confirm it resolved to an absolute path that actually exists on disk.
   - If a Wolfram App ID was written, dry-run `verify.py` against a trivial expression to confirm credentials work (see `payload/skills/math-worksheet/SKILL.md` for invocation).

6. **Report what to do next:** tell the user they can now invoke `/learning-plan` in Claude Code. Suggest `/learning-plan generate <topic>` as the first command.

## Things to avoid

- Do not modify files under `payload/` during installation — that's the source-of-truth template. If the user wants to change defaults, edit `install.sh` or pass env vars.
- Do not commit the user's Wolfram App ID anywhere, and do not include it in any summary you produce.
- Do not skip the overwrite prompts in `install.sh` without explicit user consent — existing skill files may be theirs, not a previous install of this bundle.
- Do not assume `~/claude-workspace` should exist before install. The installer creates it; only warn if it exists and contains unrelated files that might collide.

## If something goes wrong

- **`sed` errors during token substitution:** likely a non-macOS `sed`. The script uses BSD `sed -i ''` syntax. On GNU sed, change `sed -i.bak` calls to plain `sed -i`. Offer to patch this for the user.
- **Skill not appearing in Claude Code:** the user's Claude Code instance may need to be restarted to pick up new skills in `~/.claude/skills/`.
- **`verify.py` reports "app id file not found":** the Wolfram App ID step was skipped. Walk the user through step 4 above.
