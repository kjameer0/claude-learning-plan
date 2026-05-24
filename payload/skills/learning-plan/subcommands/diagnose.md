# diagnose

Produce a learner-facing diagnostic worksheet sampling key nodes. Results inform `refine`.

## Inputs

- **Module path** — required.
- **Optional: scope** — `entry` (just entry-node prereqs), `critical` (default — sample the schema-building peak and 2–3 nodes upstream), or `full` (one problem per node).

## Steps

1. **Read** `plan.yaml`, all node files, and `goals.md`.

2. **Select sample problems.** For each node in scope:
   - Pick 1 problem from the node's existing fluency exercises (or generate a fresh equivalent via the `math-worksheet` skill if the spec is well-defined)
   - For schema-heavy nodes: pick 1 schema-building exercise that has a verifiable answer (skip purely derivation-based exercises — those can't be diagnostic without a human or AI grading them)

3. **Generate a diagnostic worksheet** at `<module>/diagnostic.md`:

   ```markdown
   # Diagnostic — <module> — <YYYY-MM-DD>

   ## Purpose
   Sample problems across critical nodes. Solve what you can without help. Skip what you can't. Your results show where the module's entry point and difficulty calibration are off.

   ## Instructions
   1. Time yourself loosely — note "easy / struggled / no idea" per problem.
   2. Don't look up answers while solving.
   3. When done, run `/learning-plan refine <module-path>` and paste the results section below into the prompt, or save it as `diagnostic-results.md` in the module folder.

   ## Problems

   ### Node: 01-<slug>
   1. <problem text>

   ### Node: 02-<slug>
   1. <problem text>
   ...

   ## Results template (fill in)

   | Node | Problem | Outcome | Notes |
   |---|---|---|---|
   | 01-<slug> | 1 | easy / struggled / no idea | ... |
   ...
   ```

4. **Generate the answer key** at `<module>/diagnostic-key.md`.
   - **Every problem's final answer must be Wolfram-verified before writing the key**, regardless of type. Use the `wolfram` skill (`/Users/khalidjameer/.claude/skills/wolfram/SKILL.md`) — run a query that asks the same question the problem asks, read the `Input interpretation:` line to confirm the parse, then compare Wolfram's result to your worked answer. If they disagree, the worked solution is wrong — find the step where they diverge and fix it.
   - For fluency problems, the answer is whatever `math-worksheet` already verified.
   - For schema / worked-solution problems, write the steps by hand but anchor the final answer to Wolfram. This catches dropped terms, sign errors, and bad substitutions that hand-algebra slips past (e.g. forgetting a constant when substituting `u = x² - 5x` into `… + 4 + 4/u = 8`).
   - Include a rubric only for problems where the answer is qualitative (proof, explanation, "describe the method") and Wolfram can't be asked the same question.

5. **Tell the user** what to do:
   - Solve the diagnostic
   - Fill in the results table
   - Save as `<module>/diagnostic-results.md`
   - Run `/learning-plan refine <module>` to act on the results

## Notes

- `diagnose` is non-blocking — the user can skip it and go straight to `schedule`. Just warn that calibration may be off.
- If the module has too few schema-eligible problems, that's a content gap — flag it in the worksheet header so it shows up to the user.
- Diagnostic problems should *not* be the same problems that will appear in the scheduled fluency worksheets. If `math-worksheet` is used, generate fresh problems.
