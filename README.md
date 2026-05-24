# learning-plan bundle

A reproducible package of the `learning-plan` Claude Code skill plus everything it depends on. Lets another Claude Code user install the full setup from scratch.

## What's in here

```
learning-plan-pkg/
├── README.md                  this file
├── install.sh                 installer
└── payload/
    ├── skills/
    │   ├── learning-plan/     the main skill (SKILL.md, subcommands/, lib/, templates/)
    │   └── math-worksheet/    dependency skill — generates + Wolfram-verifies worksheets
    └── workspace/
        ├── ai-resources/
        │   └── learning-philosophy.md   foundational doc referenced by every subcommand
        └── sample-modules/
            └── quadratics/    canonical reference module (matches generated structure)
```

## Install paths

| Source in payload | Destination |
|---|---|
| `payload/skills/learning-plan` | `~/.claude/skills/learning-plan` |
| `payload/skills/math-worksheet` | `~/.claude/skills/math-worksheet` |
| `payload/workspace/ai-resources/learning-philosophy.md` | `~/claude-workspace/ai-resources/learning-philosophy.md` |
| `payload/workspace/sample-modules/quadratics` | `~/claude-workspace/sample-modules/quadratics` |

The skill source files in `payload/` use `{{WORKSPACE}}` and `{{SKILLS_DIR}}` tokens instead of hard-coded paths. `install.sh` resolves these to absolute paths (from `CLAUDE_WORKSPACE_DIR` / `CLAUDE_SKILLS_DIR`, defaults shown above) when copying into place. The installed skill files contain concrete paths — no runtime variable resolution needed.

## Prerequisites

- **Claude Code** (CLI, desktop, IDE — anything that loads `~/.claude/skills/`).
- **Python 3** with `requests` (`python3 -m pip install --user requests`) — used by `math-worksheet/verify.py`.
- **Wolfram Alpha App ID** — `verify.py` calls the Wolfram short-answer + LLM API endpoints. Free tier is sufficient for typical worksheet volumes.
  - Get one: https://developer.wolframalpha.com/access
  - Store it: `mkdir -p ~/.config/wolfram && printf 'YOUR_APP_ID_HERE' > ~/.config/wolfram/app_id`

## Install

```sh
./install.sh
```

The installer prompts before overwriting any existing files. Override defaults with env vars:

```sh
CLAUDE_SKILLS_DIR=/custom/skills CLAUDE_WORKSPACE_DIR=/custom/workspace ./install.sh
```

To update an existing install to the latest bundle on this machine, pull the repo and run:

```sh
./install.sh --update
```

This skips the per-file overwrite prompts. The bundle is opinionated — local edits to installed skill/agent files are not preserved across updates.

## Verify the install

In Claude Code:

```
/learning-plan
```

Should list the subcommands (`generate`, `audit`, `diagnose`, `refine`, `schedule`, `complete`, `reschedule`). Try:

```
/learning-plan generate quadratics-review
```

If Claude reports it can't find `learning-philosophy.md` or the quadratics sample, the workspace paths didn't land where the skill expects them — see "Install paths" above.

## Uninstall

```sh
rm -rf ~/.claude/skills/learning-plan ~/.claude/skills/math-worksheet
rm -rf ~/claude-workspace/sample-modules/quadratics
rm  ~/claude-workspace/ai-resources/learning-philosophy.md
```

## Notes on portability

- The skills assume `~/claude-workspace` is the workspace root and may write generated modules under `~/claude-workspace/modules/`.
- `math-worksheet/verify.py` hard-codes the Wolfram endpoints and reads the App ID from `~/.config/wolfram/app_id`. No other secrets are required.
- No network calls except Wolfram. The skill itself is pure text/markdown plus one Python script.
