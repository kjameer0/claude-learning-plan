---
name: learning-plan
description: Generate, audit, refine, schedule, and run learning modules for math (or any prerequisite-heavy domain) following the learning philosophy at {{WORKSPACE}}/ai-resources/learning-philosophy.md. Produces a concept-DAG module folder with typed exercises (fluency + schema-building), pre-generated worksheets via the math-worksheet skill, a calendar (.ics) schedule with stable session UIDs, and session logs for marginal-gains tracking. Use when the user wants to plan a learning module, schedule study sessions on their calendar, mark a session done, shift the schedule around blackouts, or refine an existing module. Subcommands - generate, audit, diagnose, refine, schedule, finish-session, update-schedule.
---

# learning-plan

A full-lifecycle skill for building executable learning modules from the philosophy in `{{WORKSPACE}}/ai-resources/learning-philosophy.md`. Each subcommand maps to a phase: **plan → test → refine → schedule → run → refine continuously**.

## Foundational reference

Before doing any work, treat `{{WORKSPACE}}/ai-resources/learning-philosophy.md` as the source of truth for **why** the artifacts are shaped the way they are. Key sections referenced by subcommands:

- §3 Encoding & retrieval — drives the typed-exercise split
- §4 Encoding tiers — surface / relational / extended
- §6 Fluency floor vs schema-building flight
- §7 Retrieval taxonomy
- §9 Metacognition checks (explanation / transfer / connection)
- §10 Techniques (Bear Hunter, Whole-Part-Whole, GRINDE, interleaving, marginal-gains)
- §12 Prerequisite structure — math is a directed graph

The canonical reference module (matches the structure all generated modules should follow) is at `{{WORKSPACE}}/sample-modules/quadratics/`.

## Dispatch

`/learning-plan <subcommand> [args]`

| Subcommand | File | Purpose |
|---|---|---|
| `generate <topic>` | `subcommands/generate.md` | Create a module folder (DAG, nodes, goals) |
| `audit <module-path>` | `subcommands/audit.md` | Self-audit the module's *structure* (DAG, node coverage, philosophy compliance) — no learner involved |
| `diagnose <module-path>` | `subcommands/diagnose.md` | Generate a diagnostic worksheet for the *learner* to take, then read their answers to find mastery gaps |
| `refine <module-path>` | `subcommands/refine.md` | Apply fixes surfaced by audit, diagnose, or session logs (edit nodes, update fluency specs, etc.) |
| `schedule <module-path>` | `subcommands/schedule.md` | Build the cadence, pre-generate worksheets, and emit the initial `.ics` |
| `finish-session <module> <session-id>` | `subcommands/finish-session.md` | Mark one session done, recompute downstream dates, write next log, regenerate `.ics` |
| `update-schedule <module>` | `subcommands/update-schedule.md` | Apply blackouts/cadence changes and regenerate the `.ics` (does not change session sequence) |

If the user invokes `/learning-plan` with no subcommand, ask which phase they want — don't assume. If the user describes a goal in natural language (e.g. "schedule my quadratics sessions"), pick the matching subcommand without re-asking.

## Shared conventions

- **Module folder shape** — every module conforms to `sample-modules/quadratics/` structure: `README.md`, `goals.md`, `concept-graph.md`, `plan.yaml`, `nodes/NN-<slug>.md` + `nodes/NN-<slug>/`, `schedule/`, `audit.md`.
- **plan.yaml is the source of truth.** Any subcommand that changes scheduling state reads and rewrites it. Other markdown files are human-readable views derived from or paired with `plan.yaml`.
- **Stable UIDs.** Session UIDs are sequence-based: `<module>-session-NN@learning-plan`. Re-imports update events in place.
- **Sessions ride sequence, not dates.** `target_offset` in `plan.yaml` is "sessions after the previous one." Calendar dates are computed at `.ics`-generation time from `start_date` + `cadence` + `blackouts` + `completed_on` timestamps. See `lib/cadence.md`.
- **Worksheet integration.** Fluency worksheets are produced by calling the `math-worksheet` skill (see `{{SKILLS_DIR}}/math-worksheet/SKILL.md`) with each node's `fluency_spec`. Output paths land in `nodes/NN-<slug>/fluency-vN.md` and `fluency-vN-key.md` — not the cwd default.
- **Reuse, don't regenerate.** If a module folder exists, work within it. Do not overwrite a node `.md` unless `refine` explicitly says to.

## Templates and lib

- `templates/node.md` — node file template
- `templates/session-log.md` — marginal-gains log template
- `lib/ics.md` — `.ics` generation conventions
- `lib/cadence.md` — date computation from cadence + blackouts + completions

Subcommands reference these. Read the relevant subcommand file before acting.
