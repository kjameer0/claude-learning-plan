# .ics generation conventions

Emit the `.ics` file as plain text directly — no library, no script. Apple Calendar, Google Calendar, and Outlook all accept this format.

## File structure

```
BEGIN:VCALENDAR
VERSION:2.0
PRODID:-//learning-plan//EN
CALSCALE:GREGORIAN
METHOD:PUBLISH
X-WR-CALNAME:<module> — learning plan
X-WR-TIMEZONE:America/Los_Angeles
<VEVENT blocks>
END:VCALENDAR
```

Replace `America/Los_Angeles` with the appropriate timezone. If unknown, default to the user's system timezone or ask.

## One VEVENT per session

```
BEGIN:VEVENT
UID:<module>-session-<NN>@learning-plan
DTSTAMP:<YYYYMMDDTHHMMSSZ>
DTSTART;TZID=America/Los_Angeles:<YYYYMMDDTHHMMSS>
DTEND;TZID=America/Los_Angeles:<YYYYMMDDTHHMMSS>
SUMMARY:<module>: session <NN> — <type> — <node ids or "interleave">
DESCRIPTION:<escaped description>
END:VEVENT
```

### Field rules

- **UID** — `<module>-session-<NN>@learning-plan`. Zero-padded `NN`. This is what makes re-imports update in place rather than duplicate.
- **DTSTAMP** — current UTC time when the `.ics` is generated. Format: `YYYYMMDDTHHMMSSZ` (note the trailing `Z`).
- **DTSTART / DTEND** — local time with TZID. Format: `YYYYMMDDTHHMMSS` (no `Z`).
- **SUMMARY** — short, scannable. **Lead with the session number/type so calendar list views are useful** — the module name comes last in parentheses. Format: `Session NN — <type> — <node ids or "interleave"> (<module>)`. Example: `Session 04 — node-schema — 02-factoring (quadratics)`.
- **DESCRIPTION** — multi-line is allowed by folding (continuation lines start with a space). Use `\n` literal for newlines in the value. Include:
  - Activity checklist (copied from `schedule/sessions.md` for this session)
  - Path to the node file(s)
  - Path to the worksheet (if applicable)
  - Path to the session log template
  - Reminder: `When done, run /learning-plan finish-session <module> <NN>`

### Escaping in DESCRIPTION

- Backslash: `\\`
- Comma: `\,`
- Semicolon: `\;`
- Newline: `\n` (literal backslash-n, not a real newline)

Lines longer than 75 octets should be folded — break and continue with a leading space on the next line. If unsure, keep DESCRIPTION compact.

## Example VEVENT

```
BEGIN:VEVENT
UID:quadratics-session-04@learning-plan
DTSTAMP:20260521T160000Z
DTSTART;TZID=America/Los_Angeles:20260528T090000
DTEND;TZID=America/Los_Angeles:20260528T094500
SUMMARY:Session 04 — node-schema — 02-factoring (quadratics)
DESCRIPTION:Schema-building session for node 02-factoring.\n\nActivities:\n- Re-read nodes/02-factoring.md\n- Work through schema exercises 1-3\n- Attempt three metacog checks\n- Fill in schedule/logs/session-04.md\n\nReferences:\n- Node: nodes/02-factoring.md\n- Worksheet (already done in session 03): nodes/02-factoring/fluency-v1.md\n\nWhen done\, run /learning-plan finish-session quadratics 04
END:VEVENT
```

## When regenerating

- Always emit a fresh `DTSTAMP` (current time).
- Preserve `UID` exactly so calendar clients match and update.
- `SEQUENCE:<N>` can be included and incremented on each regen to signal "this is a newer version" — Apple Calendar uses this to resolve update conflicts. Start at 0 on initial generation, increment by 1 each regen.

```
BEGIN:VEVENT
UID:quadratics-session-04@learning-plan
SEQUENCE:2
DTSTAMP:20260605T120000Z
...
```

## Output path

`<module>/schedule/learning-plan.ics`. Single file containing all sessions. Overwrite on each regeneration.
