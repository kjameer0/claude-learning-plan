# generate

Create a new learning module folder for a given topic, conforming to the structure of `/Users/khalidjameer/claude-workspace/sample-modules/quadratics/`.

## Inputs to confirm with the user

- **Topic** (e.g. "trigonometry basics", "linear algebra: vectors")
- **Learner state** — a short markdown blob describing what they know, what they're shaky on, what they haven't touched. Used to (a) pick the entry node and (b) flag missing prereqs.
- **Output path** — default `/Users/khalidjameer/claude-workspace/sample-modules/<topic-slug>/`. Confirm before writing if the path already exists.

If the user invokes without learner state, ask for it before generating. Without it, the entry node guess is unreliable.

## Steps

1. **Read the philosophy doc.** `/Users/khalidjameer/claude-workspace/ai-resources/learning-philosophy.md`. Anchor on §4 (encoding tiers), §6 (fluency vs schema), §9 (metacog), §12 (prerequisite structure).

2. **Read the canonical module.** `/Users/khalidjameer/claude-workspace/sample-modules/quadratics/` — every file. The shape of the output should match this exactly.

3. **Draft the concept DAG.** Decompose the topic into 5–10 nodes. For each:
   - Identify prereqs (incoming edges) and what it enables (outgoing edges)
   - Identify which tier it sits at (fluency-heavy vs schema-heavy)
   - Identify the schema-building peak (the analog of `08-parabola-geometry` for quadratics) — the extended-encoding goal of the module

4. **Cross-check against learner state.** For every node, ask: is the prereq satisfied by the learner's current knowledge? If not, flag it. If a critical prereq is missing entirely (e.g. user wants calculus but hasn't touched trig), surface that and recommend a feeder module instead of generating.

5. **Write the module folder.** Use `templates/node.md` for node files. Required files:
   - `README.md` — module overview, how to read, what this module is testing (mirror quadratics README structure)
   - `goals.md` — mastery target (extended encoding), minimum bar, ideal bar, metacog checks definition, non-goals
   - `concept-graph.md` — assumed external prereqs, ASCII DAG diagram, edge semantics, where fluency vs schema lives, interleaving opportunities
   - `nodes/NN-<slug>.md` for each node — prereqs, enables, sources (with real URLs when possible — Khan Academy, 3Blue1Brown, textbook chapter refs), 3–5 fluency exercises, 3–4 schema exercises, three metacog checks (explanation / transfer / connection)
   - `plan.yaml` — machine-readable model. See structure below.
   - Do **not** create `nodes/NN-<slug>/` subfolders or `schedule/` here — those are created by `schedule`.

6. **Initialize a git repo in the module folder.** Modules are living documents — every subcommand (`refine`, `schedule`, `complete`, `reschedule`) mutates them, and session logs accrete over weeks/months. Tracking the module in git from day one preserves the audit trail of decisions and lets the user roll back a bad refine. Run:

   ```sh
   cd <module>
   git init -b main
   printf '%s\n' '.DS_Store' '*.pdf' > .gitignore
   git add .
   git commit -m "Initial commit — <module> module scaffold"
   ```

   Then ask the user whether they want a remote (GitHub or otherwise). Don't push unprompted — that's a publishing action. If they say yes and `gh` is installed and authenticated, use `gh repo create <module> --source=. --remote=origin --push` with `--private` or `--public` per their preference (default `--private` for personal learning notes).

7. **Recommend next steps.** End by telling the user to run `/learning-plan audit <path>` and then `/learning-plan diagnose <path>` before `schedule`. Remind them to commit after each major subcommand run so the module's history is legible.

## `plan.yaml` structure for `generate`

Write a minimal version — cadence/sessions are filled in by `schedule`.

```yaml
module: <topic-slug>
goal_node: <NN-slug-of-schema-peak>
created_on: <YYYY-MM-DD>
learner_state: |
  <verbatim from input>
nodes:
  - id: 01-<slug>
    prereqs: []
    enables: [02-<slug>, 03-<slug>]
    tier: fluency-heavy        # or schema-heavy
    fluency_spec:
      topic: "<concrete math-worksheet topic string>"
      count: 10
      difficulty: <e.g. algebra-1>
    schema_exercises: 3
    metacog: [explanation, transfer, connection]
  - id: 02-<slug>
    ...
cadence: null                  # filled by schedule
review_policy:
  spacing: [1, 3, 7, 14]       # sessions-after-completion (default)
sessions: []                   # filled by schedule
```

## Quality bar before finishing

- Every node has both fluency and schema exercises
- Every node has three metacog checks
- The DAG has no orphans (every node except entry has prereqs; every node except the goal enables something)
- The goal node is reachable from at least one entry node
- Sources cite specific resources, not vague references — when unsure, write `TODO: source` rather than fabricating a URL

## Notes

- Do not invent fluency-spec topics that math-worksheet can't generate problems for. If a node's content is hard to express as discrete problems (e.g. a derivation node), set `fluency_spec: null` and let the node be schema-only.
- For domains that are not strictly prerequisite-ordered (history, philosophy), warn the user — the philosophy doc's §12 only fully applies to directed-graph domains.
