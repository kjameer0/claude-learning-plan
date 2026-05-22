# refine

Apply fixes to a module from any of three input sources: `audit.md`, `diagnostic-results.md`, or session logs in `schedule/logs/`. Idempotent — running it twice on the same inputs is a no-op.

## Inputs

- **Module path** — required.
- **Optional: source filter** — `audit`, `diagnostic`, `logs`, or `all` (default). Limits which inputs refine acts on.

## Steps

1. **Read inputs** based on filter:
   - `<module>/audit.md` if it exists
   - `<module>/diagnostic-results.md` if it exists
   - All files in `<module>/schedule/logs/` if they exist

2. **Collect refinement actions.** Categorize each finding into:
   - **Content edit** — add/remove/rewrite exercises, sources, metacog checks
   - **DAG edit** — add/remove a node, change prereqs/enables
   - **Calibration edit** — adjust `fluency_spec.count` or `fluency_spec.difficulty`
   - **Schedule edit** — recommend a reschedule (don't do it from refine — surface the recommendation)
   - **Cannot fix automatically** — surface to user for decision

3. **Apply content and DAG edits** by directly editing the relevant files. For each edit:
   - Edit the markdown (node file, goals, README, concept-graph as needed)
   - Update `plan.yaml` to match if structure changed
   - If a node was added, generate its file from `templates/node.md`
   - If a node was removed, delete `nodes/NN-<slug>.md` and the corresponding `nodes/NN-<slug>/` subfolder if it exists

4. **Apply calibration edits** by updating `fluency_spec` in `plan.yaml`. If worksheets have already been pre-generated under `nodes/NN-<slug>/`, mark them stale (rename `fluency-v1.md` → `fluency-v1.md.stale`) so the next `schedule` or review knows to regenerate.

5. **Write a refine log** at `<module>/refine.md`. Append-only (don't overwrite previous refines):

   ```markdown
   # Refine log

   ## <YYYY-MM-DD HH:MM> — sources: audit, diagnostic, logs

   ### Applied
   - <action> — <reason>
   - ...

   ### Surfaced (user decision required)
   - <issue> — <suggested options>
   - ...

   ### Recommended follow-ups
   - Run `/learning-plan audit <module>` to confirm fixes
   - Run `/learning-plan reschedule <module>` because calibration changed
   ```

6. **Surface the "user decision required" list.** Ask the user to resolve each one. After they answer, re-run the affected edits.

## Mapping common findings to actions

| Finding | Action |
|---|---|
| Node missing metacog check | Add the missing check using `templates/node.md` patterns |
| `TODO: source` flagged in audit | Cannot auto-fix; surface to user |
| DAG has a cycle | Cannot auto-fix; surface — likely a prereq direction error |
| Diagnostic: "easy" on entry node | Recommend bumping entry forward or removing the node; surface |
| Diagnostic: "no idea" on a prereq node | Recommend a feeder module; surface |
| Diagnostic: "struggled" on schema peak | Reduce difficulty / add a bridging node; surface |
| Session log: "frustration tolerance 1, problems too hard" | Calibration edit: lower `difficulty` on the most recent node's `fluency_spec`, mark worksheets stale |
| Session log: "comprehension depth 5, problems too easy" | Calibration edit: raise count or difficulty, mark stale |
| Session log: "could not recall yesterday's material" | Schedule edit: recommend inserting an additional review session; surface |

## Notes

- Refine never silently rewrites schema exercises or sources — those are the human-authored core. Only fluency specs and structural metadata are auto-edited.
- The "Recommended follow-ups" section is the bridge between refine and the next command in the cycle.
