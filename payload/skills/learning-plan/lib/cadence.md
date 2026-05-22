# Cadence — computing session dates

Sessions live in `plan.yaml` as a sequence with `target_offset` (sessions-after-previous) and optional `completed_on`. This file specifies how to compute concrete calendar dates from that sequence.

## Inputs to the calculation

From `plan.yaml`:
- `cadence.start_date` — anchor date for the first uncompleted session
- `cadence.sessions_per_week`
- `cadence.minutes_per_session`
- `cadence.standing_constraints` — `weekdays_only`, `earliest_time`, allowed weekdays
- `cadence.blackouts` — list of dates and date ranges to skip
- For each session: `id`, `target_offset`, `completed_on`

## Algorithm

Walk sessions in id order, tracking a `next_available_date` cursor.

```
next_available = start_date

for each session in sequence:
    if session.completed_on is not null:
        # Completed sessions keep their actual completion date; that's
        # where the cursor restarts from for downstream sessions.
        cursor = completed_on + 1 day
        continue

    # Find the next valid date for this session.
    candidate = cursor
    for _ in range(some-max-iterations):
        if is_valid_session_date(candidate):
            session.computed_date = candidate
            cursor = candidate + 1 day  # advance for next session
            break
        candidate = candidate + 1 day
    else:
        error: could not find valid date within bounds
```

`target_offset` is normally `1` (next available session day). If a session has `target_offset > 1` (e.g. a review session set to 3 sessions after the original), insert that many additional "no-op skip" days OR equivalently treat the offset as the number of cadence slots to skip past the completed reference session — see "Review sessions" below.

## `is_valid_session_date(d)`

Returns true if:
1. `d` is not in any blackout entry (date or range)
2. If `standing_constraints.weekdays_only` is true, `d` is Mon–Fri
3. If `standing_constraints.allowed_weekdays` is set, `d.weekday()` is in the list
4. The cadence allows another session this week:
   - Count how many sessions have been scheduled in the calendar week containing `d`
   - If count ≥ `cadence.sessions_per_week`, return false
   - Otherwise true

The weekly count must include any session already scheduled this week (whether completed or computed for an upcoming session). This is what makes `sessions_per_week` an actual rate cap.

## Time of day

Once a date is chosen, the session start time is `cadence.standing_constraints.earliest_time` (default `09:00`). Duration = `cadence.minutes_per_session`. End time = start + duration.

If multiple sessions need to land on the same day (rare but possible with high cadence), space them by at least 60 minutes. Prefer not to stack — the philosophy doc favors spacing for retrieval.

## Review session offsets

Review sessions specify `review_of_session: <id>` and ride the `review_policy.spacing` array. Example: spacing `[1, 3, 7, 14]` means a node studied in session 04 gets reviewed in sessions 05, 07, 11, 18 (relative to completion). The spacing is in **sessions** not days, by design (offsets from completion, not calendar dates).

So when building the session sequence in `schedule`:
- For each non-review session that has a primary node, schedule its reviews at `[+1, +3, +7, +14]` positions in the future sequence.
- These review sessions get their own ids (the next available NN) and ride the cadence like any other session.

When a session `completed_on` is set, downstream review sessions for the same node don't need their offsets recomputed — they already exist in the sequence and their dates just slide forward with everyone else's.

## Edge cases

- **Blackout swallows the entire week:** the cursor advances day by day until it lands on a valid week. Cap iterations at ~365 days to prevent infinite loops.
- **`sessions_per_week` set to 0:** invalid; refuse and ask the user to set a positive cadence.
- **Completion date earlier than the session's previous target:** allowed; downstream sessions slide earlier accordingly.
- **Completion date much later than target:** allowed; downstream sessions slide later. This is the "life happened" case.
- **All weekdays blackedout for a long range:** if `weekdays_only` is true and the next ~14 days are all blackout, surface a warning — likely a configuration error.

## Timezone

All dates are computed in the user's local timezone (default `America/Los_Angeles`; otherwise from system or asked). The `.ics` uses `TZID=` for local-time events. See `lib/ics.md`.
