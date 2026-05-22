# Quadratics Module (Sample)

A sample learning module built against `ai-resources/learning-philosophy.md`. Purpose: stress-test the framework `curriculum = sources + exercises + goals` against a real learner state (mid-Algebra 1, has derived standard form of a parabola from focus/directrix).

## Structure

- `goals.md` — mastery targets and metacognition checks for the module
- `concept-graph.md` — the DAG: nodes, prerequisites, edges
- `nodes/` — one file per concept node. Each contains:
  - **Prereqs** (incoming edges) and **Enables** (outgoing edges)
  - **Sources** — where to encode from
  - **Fluency exercises** — reps for automaticity (the floor, §6)
  - **Schema-building exercises** — derivations and novel problems (the flight, §6)
  - **Metacog checks** — explanation / transfer / connection (§9)

## How to use

1. Read `concept-graph.md` to see the terrain (Bear Hunter / first Whole, §10)
2. Walk nodes in dependency order
3. At each node, do fluency reps until automatic, then schema exercises
4. Run the metacog checks before advancing — the minimum bar is required, the ideal bar is flagged for return

## What this module is testing

- Does typing exercises (fluency vs schema) produce sensible content?
- Does the DAG correctly recover the path the learner already walked to the parabola derivation?
- Are metacog checks useful gates, or noise?
- What's missing that the philosophy implies should be here?
