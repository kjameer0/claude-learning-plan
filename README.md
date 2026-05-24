# learning-plan bundle

An opinionated suite of Claude Code skills for building learning plans from sources, working through them on a schedule, and checking your work quickly. Designed for math and other prerequisite-heavy domains.

## Glossary

You'll see these three words constantly. Their relationship:

- **Module** — one folder, one topic (e.g. `quadratics/`). Contains a concept DAG, node files, a schedule, and session logs. You generate one module per topic you want to learn.
- **Node** — one concept *inside* a module (e.g. `factoring`, `completing-the-square`). Each node is a markdown file plus a folder of generated fluency worksheets. Nodes form the DAG: each lists its prerequisites and what it enables.
- **Session** — one scheduled study event on your calendar (e.g. "Session 04 — schema-building for `factoring`"). Sessions reference nodes. A module's schedule is a sequence of sessions whose dates are computed from a cadence plus your blackout dates.

> Module ⊇ Nodes; Schedule ⊇ Sessions; each Session targets one or more Nodes.

## What's installed

Skills (you invoke these as `/<name>` in Claude Code):

| Skill | Purpose |
|---|---|
| `/learning-plan` | Build, schedule, and run a learning module |
| `/math-worksheet` | Generate a Wolfram-verified problem set |
| `/wolfram` | One-off Wolfram Alpha queries |
| `/image` | Read or grade screenshots, photos, handwritten work, PDFs |

Agents (subagents the skills delegate to — you do not invoke these directly):

| Agent | Role |
|---|---|
| `wolfram-runner` | Runs Wolfram queries on Haiku so verbose API responses stay out of the main session |
| `image-reader` | Transcribes images on Haiku so vision tokens stay out of the main session |
| `grade-runner` | Verifies (Q, A, work) batches against Wolfram on Haiku |

The agents exist purely to keep expensive tokens (vision, long Wolfram responses) off the main model. You don't need to think about them — the skills route through them automatically.

## The learning-plan lifecycle

```
   ┌─────────────┐
   │  generate   │  one-time, per topic
   └──────┬──────┘
          ▼
   ┌─────────────┐     audits the module's *structure*
   │   audit     │     (DAG sanity, philosophy compliance)
   └──────┬──────┘
          ▼
   ┌─────────────┐     produces a worksheet for *you* to take;
   │  diagnose   │     reveals which nodes need work before you start
   └──────┬──────┘
          ▼
   ┌─────────────┐     apply fixes surfaced by audit / diagnose / session logs
   │   refine    │     (edit nodes, adjust fluency specs, etc.)
   └──────┬──────┘
          ▼
   ┌─────────────┐     build cadence, pre-generate worksheets, emit .ics
   │  schedule   │
   └──────┬──────┘
          │
          ▼
   ┌────────────────────┐
   │  do session NN     │  ←─────┐
   └──────┬─────────────┘        │
          ▼                      │  repeat per session
   ┌────────────────────┐        │
   │   finish-session   │  ──────┘
   └────────────────────┘
          │
          ▼
   ┌────────────────────┐     when life happens (vacation, cadence change)
   │   update-schedule  │
   └────────────────────┘
```

Subcommands at a glance:

| `/learning-plan ...` | Phase | What it does |
|---|---|---|
| `generate <topic>` | Plan | Create the module folder + DAG + node files |
| `audit <module>` | Validate | Self-check the module's structure |
| `diagnose <module>` | Validate | Worksheet you take to find your starting gaps |
| `refine <module>` | Fix | Apply changes surfaced by audit / diagnose / logs |
| `schedule <module>` | Plan | Cadence + pre-gen worksheets + `.ics` |
| `finish-session <module> NN` | Run | Mark one session done; recompute downstream |
| `update-schedule <module>` | Run | Apply blackouts / cadence changes; regenerate `.ics` |

## Install paths

| Source in payload | Destination |
|---|---|
| `payload/skills/*` | `~/.claude/skills/*` |
| `payload/agents/*` | `~/.claude/agents/*` |
| `payload/workspace/ai-resources/learning-philosophy.md` | `~/claude-workspace/ai-resources/learning-philosophy.md` |
| `payload/workspace/sample-modules/quadratics` | `~/claude-workspace/sample-modules/quadratics` |

Skill and agent files use `{{WORKSPACE}}`, `{{SKILLS_DIR}}`, and `{{AGENTS_DIR}}` tokens. `install.sh` resolves them to absolute paths at install time. No runtime variable resolution.

## Prerequisites

- **Claude Code** (CLI, desktop, or IDE — anything that loads `~/.claude/skills/`).
- **Python 3** with `requests` (`python3 -m pip install --user requests`) — used by `math-worksheet/verify.py`.
- **Wolfram Alpha App ID** — required for `/math-worksheet`, `/wolfram`, and `/image grade`. Free tier suffices.
  - Get one: https://developer.wolframalpha.com/access
  - Store it: `mkdir -p ~/.config/wolfram && printf 'YOUR_APP_ID' > ~/.config/wolfram/app_id`
  - You can install without this and add it later — the other skills still work.
- **macOS-only for `/image` from clipboard**: `brew install pngpaste`.

## Install

```sh
./install.sh
```

The installer prompts before overwriting any existing files. Override defaults with env vars:

```sh
CLAUDE_SKILLS_DIR=/custom/skills CLAUDE_WORKSPACE_DIR=/custom/workspace ./install.sh
```

To update an existing install on this machine:

```sh
./install.sh --update
```

`--update` skips per-file overwrite prompts. The bundle is opinionated — local edits to installed skill/agent files are not preserved across updates.

## Verify the install

In Claude Code:

```
/learning-plan
```

Should list the subcommands. Try:

```
/learning-plan generate quadratics-review
```

If Claude reports it can't find `learning-philosophy.md` or the quadratics sample, the workspace paths didn't land where the skill expects them — see "Install paths" above.

## Read this before generating your first module

The whole bundle is grounded in `~/claude-workspace/ai-resources/learning-philosophy.md`. About 15 minutes. It explains:

- Why nodes split into **fluency** (rapid recall) and **schema** (relational understanding) exercises
- Why sessions interleave node-fluency, node-schema, interleaving, review, and final-whole types
- What a "metacognition check" is and why every node has three

Skipping it works, but you'll be confused by why the generated artifacts look the way they do.

## Uninstall

```sh
rm -rf ~/.claude/skills/learning-plan ~/.claude/skills/math-worksheet ~/.claude/skills/wolfram ~/.claude/skills/image
rm -f ~/.claude/agents/wolfram-runner.md ~/.claude/agents/image-reader.md ~/.claude/agents/grade-runner.md
rm -rf ~/claude-workspace/sample-modules/quadratics
rm  ~/claude-workspace/ai-resources/learning-philosophy.md
```

## Notes on portability

- The skills assume `~/claude-workspace` is the workspace root and may write generated modules under `~/claude-workspace/modules/`.
- `math-worksheet/verify.py` hard-codes the Wolfram endpoints and reads the App ID from `~/.config/wolfram/app_id`. No other secrets are required.
- No network calls except Wolfram (and your own image files / clipboard for `/image`).
