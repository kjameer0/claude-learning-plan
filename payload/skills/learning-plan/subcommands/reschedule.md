# reschedule

Apply blackouts or date shifts and regenerate the `.ics` for re-import. Stable UIDs mean Calendar.app updates events in place.

## Inputs

- **Module path** — required.
- **One or more of:**
  - `--add-blackout <DATE>` or `--add-blackout <DATE>..<DATE>` — append to `cadence.blackouts`. Can be repeated.
  - `--remove-blackout <DATE>` or `--remove-blackout <DATE>..<DATE>` — remove matching entries.
  - `--from <DATE>` — shift all sessions from this date forward. Subsequent sessions get target dates starting at this date.
  - `--cadence sessions_per_week=<N>` and/or `minutes_per_session=<N>` — change ongoing cadence.

If no flags are passed, ask the user what they want to change.

## Steps

1. **Read** `plan.yaml`.

2. **Apply requested changes** to the `cadence` block. Merge blackouts (don't duplicate); sort and normalize ranges.

3. **Recompute dates** for all uncompleted sessions using `lib/cadence.md`. Completed sessions (with non-null `completed_on`) are not touched.

4. **Write** the updated `plan.yaml`.

5. **Regenerate `<module>/schedule/learning-plan.ics`** with new dates. Same UIDs.

6. **Regenerate `<module>/schedule/sessions.md`.**

7. **Surface to the user:**
   - Summary of changes (blackouts added/removed, cadence change, shift)
   - Date range affected
   - Total number of sessions whose dates moved
   - Re-import the `.ics` to sync

## Common reschedule scenarios

| Scenario | Command |
|---|---|
| Going on vacation | `reschedule <module> --add-blackout 2026-06-15..2026-06-22` |
| Taking a single day off | `reschedule <module> --add-blackout 2026-05-30` |
| Pause until a known restart date | `reschedule <module> --from 2026-07-01` |
| Switching from 5×/week to 3×/week | `reschedule <module> --cadence sessions_per_week=3` |
| Restoring a removed day | `reschedule <module> --remove-blackout 2026-05-30` |

## Notes

- `reschedule` never changes the session sequence — it only changes when sessions happen. The skill never adds, removes, or reorders sessions here. Use `refine` for structural changes.
- If a blackout range covers a completed session's date, that's fine — the completed session's date is preserved as-is.
- If `--from` is earlier than the latest completed session's date, refuse — that would require uncompleting work.
