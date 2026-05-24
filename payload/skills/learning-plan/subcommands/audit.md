# audit

Structural self-audit of a module. Findings go to `<module>/audit.md`. Non-fatal — `schedule` works even with audit findings.

## Inputs

- **Module path** — required. Default to `/Users/khalidjameer/claude-workspace/sample-modules/<inferred-slug>/` if unambiguous.

## Steps

1. **Read** all files in the module: `README.md`, `goals.md`, `concept-graph.md`, `plan.yaml`, all `nodes/NN-<slug>.md`.

2. **Run the checks below.** Collect findings as a list. For each: severity (`error` / `warning` / `info`), location (file:line where possible), description.

3. **Write `<module>/audit.md`.** Overwrite the previous audit. Format:

   ```markdown
   # Audit — <module> — <YYYY-MM-DD HH:MM>

   ## Summary
   - <N> errors, <N> warnings, <N> info

   ## Errors
   - [<file>:<line>] <description>

   ## Warnings
   - [...] ...

   ## Info / suggestions
   - [...] ...
   ```

4. **Surface the summary to the user.** Recommend running `refine` if there are errors or many warnings, or proceeding to `diagnose` / `schedule` if it's clean.

## Checks

### DAG integrity (errors)

- Every node referenced in any `prereqs` or `enables` list in `plan.yaml` exists as a `nodes/NN-<slug>.md` file.
- Every `nodes/NN-<slug>.md` file is present in `plan.yaml`.
- The DAG is acyclic. Walk it from each entry node (nodes with empty `prereqs`); a cycle means a node would be encountered twice.
- The `goal_node` in `plan.yaml` is reachable from at least one entry node.
- No orphan nodes — every node either has `prereqs` or is enabled by something, and every node either has `enables` or is the goal.

### Node content (warnings)

For each `nodes/NN-<slug>.md`:

- Has a **Prereqs** section
- Has an **Enables** section
- Has a **Sources** section with at least one entry (warn if any source is `TODO`)
- Has a **Fluency exercises** section with ≥3 items (or explicitly states "fluency-light, schema-heavy node")
- Has a **Schema-building exercises** section with ≥2 items
- Has a **Metacog checks** section with all three: explanation, transfer, connection

### `plan.yaml` integrity (errors)

- Valid YAML
- Required top-level keys: `module`, `goal_node`, `nodes`, `review_policy`
- Each node has: `id`, `prereqs`, `enables`, `tier`, `metacog`
- Each node with `fluency_spec != null` has `fluency_spec.topic`, `fluency_spec.count`, `fluency_spec.difficulty`
- `tier` is one of `fluency-heavy`, `schema-heavy`, `mixed`
- `metacog` includes the three checks

### Goal coherence (warnings)

- `goals.md` mentions the `goal_node` topic
- The mastery target in `goals.md` matches the content of the goal node's schema exercises
- Minimum bar items in `goals.md` are achievable using nodes present in the module (no implicit prereqs the module doesn't cover)

### Source quality (info)

- Sources that are vague ("any algebra textbook") are flagged as info — not blocking, but worth tightening
- Sources without a URL or specific chapter reference are flagged as info

### Cross-link sanity (info)

- Every node's "Connection" metacog check references at least one other node by name or concept that exists in the module

## What this does NOT check

- Pedagogical correctness (whether the topic decomposition is the *right* decomposition)
- Difficulty calibration (whether the fluency_spec is at the learner's level) — that's what `diagnose` is for
- Whether sources are still live URLs — out of scope, model can't fetch reliably from inside the skill

## Notes

- Audit is idempotent. Run it as often as desired.
- If `plan.yaml` is missing, that's a single error and audit stops — recommend running `generate` first or restoring the file.
