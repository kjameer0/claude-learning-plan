# schedule

Prompt for cadence + constraints, pre-generate fluency worksheets, plan the session sequence, and emit `.ics` + walkthrough files.

## Inputs to confirm with the user (always ask at schedule time)

- **Sessions per week** — e.g. 5
- **Minutes per session** — e.g. 45
- **Start date** — `YYYY-MM-DD`, default tomorrow
- **Standing constraints** — weekdays only? earliest/latest time of day? specific weekdays only?
- **Initial blackouts** — known vacations, holidays. Date or date range. Can be empty.

Defaults: weekdays only, 09:00 start time, no initial blackouts.

## Steps

1. **Read** `plan.yaml` and all node files.

2. **Build the session sequence.** For each node in DAG-topological order:
   - Insert an `orientation` session as session 01 if it doesn't exist (Bear Hunter / first Whole, philosophy §10)
   - For each node: insert a `node-fluency` session (skip if node's `fluency_spec` is null)
   - For each node: insert a `node-schema` session
   - After every 3–4 nodes once their fluency is stable: insert an `interleaving` session covering 2–4 of those nodes
   - Insert a `grinde-map` session at the midpoint
   - Insert `review` sessions per the `review_policy.spacing` (e.g. `[1, 3, 7, 14]` means review a completed node 1, 3, 7, and 14 sessions later). These are appended; each gets `review_of_session: <id>` pointing back.
   - Insert a `final-whole` session as the last session (Whole-Part-Whole closing, §10)

   Each session has:
   - `id` — zero-padded sequence, e.g. `01`, `02`...
   - `type` — `orientation`, `node-fluency`, `node-schema`, `interleaving`, `grinde-map`, `review`, `final-whole`
   - `nodes` — node ids this session touches
   - `activities` — checklist for the user (see activity templates below)
   - `target_offset` — number of sessions after the previous one; default `1`
   - `completed_on` — `null` initially

3. **Write `plan.yaml`** with the new `cadence` and `sessions` blocks. Preserve the existing `nodes`, `goal_node`, `review_policy`, etc.

4. **Pre-generate fluency worksheets.** For each node with a non-null `fluency_spec`:
   - Call the `math-worksheet` skill with topic, count, and difficulty from the spec
   - Save outputs as `<module>/nodes/<NN-slug>/fluency-v1.md` and `<module>/nodes/<NN-slug>/fluency-v1-key.md`
   - Create the `<module>/nodes/<NN-slug>/` directory if needed
   - If `math-worksheet` fails on a node (e.g. Wolfram can't verify), log the failure to `<module>/schedule/worksheet-errors.md` and continue — the user will see the gap

5. **Compute calendar dates** using `lib/cadence.md`. Produce a date for each session from `start_date`, `cadence`, `standing_constraints`, `blackouts`, and (initially empty) `completed_on` timestamps.

6. **Write `<module>/schedule/sessions.md`** — human-readable session-by-session walkthrough. **Every file reference in activities and the References block must be a clickable relative-path markdown link**, not a bare path or backticked path. Markdown links of the form `[display.md](../path/to/file.md)` render as clickable in both Obsidian and GitHub. Paths are relative to `schedule/sessions.md`, so module-root files are `../<file>`, node files are `../nodes/<NN-slug>.md`, worksheets are `../nodes/<NN-slug>/fluency-vN.md`, and session logs are `logs/session-NN.md`.

   ```markdown
   ## Session NN — <type> — <YYYY-MM-DD HH:MM> — <minutes>min

   **Nodes:** `<node id>` (or none for orientation, multiple for interleaving)

   **Activities:**
   - [ ] Read [nodes/<NN-slug>.md](../nodes/<NN-slug>.md)
   - [ ] Work through [nodes/<NN-slug>/fluency-v1.md](../nodes/<NN-slug>/fluency-v1.md)
   - [ ] Check against [fluency-v1-key.md](../nodes/<NN-slug>/fluency-v1-key.md)
   - [ ] Fill in [schedule/logs/session-NN.md](logs/session-NN.md)

   **References:**
   - Node file: [nodes/<NN-slug>.md](../nodes/<NN-slug>.md)
   - Fluency worksheet: [nodes/<NN-slug>/fluency-v1.md](../nodes/<NN-slug>/fluency-v1.md)
   - Answer key (don't peek until done): [fluency-v1-key.md](../nodes/<NN-slug>/fluency-v1-key.md)

   **When done:** run `/learning-plan complete <module> NN`
   ```

   Module-root references in orientation / grinde-map / final-whole sessions follow the same rule: `[README.md](../README.md)`, `[goals.md](../goals.md)`, `[concept-graph.md](../concept-graph.md)`. Do **not** wrap the link itself in backticks.

7. **Write `<module>/schedule/learning-plan.ics`** following `lib/ics.md`. One `VEVENT` per session, stable UIDs.

8. **Create empty log template files** at `<module>/schedule/logs/session-NN.md` from `templates/session-log.md` (don't fill them in — the user does that during/after each session). Actually: only create the first one; the rest are created on `complete`.

9. **Surface to the user:**
   - Total session count, end date
   - Path to `.ics` — instruct to double-click in Finder → choose calendar → import
   - Any worksheet generation errors
   - Next step: do session 01, then `/learning-plan complete <module> 01`

## Activity templates per session type

- **orientation**: `read README.md`, `read goals.md`, `skim concept-graph.md`, `Bear Hunter the node files (titles only)`, `fill in session log`
- **node-fluency**: `read the node file`, `work through fluency-v<N>.md`, `check against fluency-v<N>-key.md`, `note any miss patterns`, `fill in session log`
- **node-schema**: `re-read the node file`, `work through each schema exercise`, `attempt the three metacog checks aloud or in writing`, `fill in session log`
- **interleaving**: `mix problems across listed nodes (5–8 problems total)`, `force yourself to identify which strategy applies before solving`, `fill in session log`
- **grinde-map**: `redraw the concept-graph from memory on paper (GRINDE principles — grouped, reflective, interconnected, non-verbal, directional, emphasized)`, `compare to concept-graph.md`, `note the delta — that's your weakest schema link`, `fill in session log`
- **review**: `regenerate fresh fluency problems` (handled by skill, see `complete`), `work them`, `re-attempt the metacog checks for the reviewed node`, `fill in session log`
- **final-whole**: `re-read concept-graph.md`, `restate the mastery goal from goals.md in your own words`, `attempt the goal-node schema exercise cold`, `fill in session log`, `reflect on what to learn next`

## Notes

- If `schedule` is re-run on a module that already has scheduled sessions, ask the user: replace the existing schedule (regenerates session IDs and worksheets), or only fill in gaps (preserves existing `completed_on` and worksheet files).
- Stable UIDs survive across re-schedules as long as session sequence is preserved.
