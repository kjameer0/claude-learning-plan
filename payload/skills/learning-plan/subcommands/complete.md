# complete

Mark a session done. Updates `plan.yaml`, writes the log template for the next session, regenerates the `.ics` with shifted downstream targets, and pre-generates a fresh fluency worksheet if the next session is a review.

## Inputs

- **Module path** — required.
- **Session id** — required, e.g. `02` or `session-02`.
- **Completion date** — optional, default today (`YYYY-MM-DD`).

## Steps

1. **Read** `plan.yaml`.

2. **Find the session.** If the session id doesn't exist or is already completed, surface the issue and stop.

3. **Set `completed_on`** to the completion date for that session.

4. **Recompute downstream dates** using `lib/cadence.md`. The next uncompleted session's target date is computed from this completion date + cadence + blackouts. All subsequent sessions chain forward from there.

5. **Write the next session's log file** at `<module>/schedule/logs/session-<NN+1>.md` from `templates/session-log.md` if it doesn't exist (where NN is the session just completed). Pre-fill the header (session id, type, nodes, date, expected duration from `cadence.minutes_per_session`). The user fills in the marginal-gains body. This step always runs, even if the just-completed session was already marked complete in a prior invocation — re-running `complete` is the recovery path for a missing next-session log.

6. **If the next session is a `review`:**
   - Find the reviewed node via `review_of_session` → the original session's `nodes[0]`
   - Find the latest existing worksheet version under `<module>/nodes/<NN-slug>/` (e.g. `fluency-v1.md` exists → next is `v2`)
   - Call `math-worksheet` with the same `fluency_spec` to generate `fluency-vN.md` + `fluency-vN-key.md`
   - Update the upcoming review session's `activities` to reference the new worksheet path

7. **If a calibration refinement marked any worksheets stale** (file named `*.stale`):
   - For each stale worksheet, regenerate with the current `fluency_spec`
   - Remove the `.stale` suffix when regeneration succeeds

8. **Write the updated `plan.yaml`.**

9. **Regenerate `<module>/schedule/learning-plan.ics`** with the new dates. Same UIDs.

10. **Regenerate `<module>/schedule/sessions.md`** to reflect new dates.

11. **Open the `.ics` file** by running:
    ```
    open "<module>/schedule/learning-plan.ics"
    ```
    This hands it to Apple Calendar automatically. Calendar will update existing events in place via UID matching.

12. **Commit and push** all changes made during this `complete` run:
    ```
    git add -A
    git commit -m "complete session <NN> — <YYYY-MM-DD>"
    git push
    ```
    This keeps the repo in sync so the session state is available on other machines.

13. **Surface to the user:**
    - "Session NN marked complete on <date>"
    - "Next session: NN — <type> — <date>"
    - "Worksheet for next session: <path>" (if applicable)

## Notes

- If the user completes a session significantly later than its target date, downstream sessions slide automatically — no manual intervention needed.
- If the user completes ahead of target, downstream sessions also slide (they get earlier dates). This is fine — they're following the cadence rule from the new completion date.
- A user can complete sessions out of order (e.g. complete session 04 while 03 is still null). If this happens, warn — the philosophy doc cares about dependency order — but allow it. Set `completed_on` on the requested session only.
