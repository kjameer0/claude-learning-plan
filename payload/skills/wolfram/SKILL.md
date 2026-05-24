---
name: wolfram
description: Run an ad-hoc Wolfram Alpha query to compute, solve, simplify, or verify a math expression. Use when the user asks to "check with Wolfram", "ask Wolfram", verify an answer, solve an equation, or evaluate any math expression where Wolfram should be the source of truth.
---

# wolfram

Thin wrapper around the Wolfram Alpha LLM API. **Delegate the actual query to the `wolfram-runner` subagent** (Sonnet) to keep verbose Wolfram output out of the main session's context.

## How to invoke

Call the Agent tool with `subagent_type: wolfram-runner`. The subagent has no conversation context, so pass everything it needs in the prompt:

- The Wolfram-parseable expression (use explicit verbs: `solve ... for x`, `derivative of ...`, `simplify ...`, `integrate ... from a to b`, `factor ...`).
- If the user provided a worked solution to check, include it and ask the subagent to compare.
- Add `verbose: true` **only** when you need the full Wolfram response — e.g., the user asked for steps, a plot, or you're following up and need detail you didn't get the first time.

Example prompt to the subagent:

```
Expression: solve x^2 - 5x + 4 + 4/(x^2 - 5x) = 8 for x
User's solution: x = 6, x = -1
Compare and report.
```

## Reporting back to the user

The subagent returns a tight summary (Input interpretation + Answer + optional comparison). Quote the relevant lines and tie them to the user's question. Re-invoke with `verbose: true` for follow-ups that need more detail.

If the subagent reports "app id file not found" or "placeholder", tell the user to write their AppID to `~/.config/wolfram/app_id` (chmod 600).

## Fallback: direct invocation

If the `wolfram-runner` subagent is unavailable, you can run the script directly:

```
python3 {{SKILLS_DIR}}/math-worksheet/verify.py \
  --app-id-file ~/.config/wolfram/app_id \
  --llm \
  "<wolfram-parseable expression>"
```
