---
name: wolfram
description: Run an ad-hoc Wolfram Alpha query to compute, solve, simplify, or verify a math expression. Use when the user asks to "check with Wolfram", "ask Wolfram", verify an answer, solve an equation, or evaluate any math expression where Wolfram should be the source of truth.
---

# wolfram

Thin wrapper around the Wolfram Alpha LLM API for one-off queries.

## Usage

```
python3 {{SKILLS_DIR}}/math-worksheet/verify.py \
  --app-id-file ~/.config/wolfram/app_id \
  --llm \
  "<wolfram-parseable expression>"
```

- The script lives in the `math-worksheet` skill; this skill reuses it rather than duplicating.
- Use `--llm` by default — it echoes Wolfram's input interpretation so you can catch misparses. Drop it only for cheap one-line answers.
- App ID is at `~/.config/wolfram/app_id` (chmod 600). If the script errors with "app id file not found" or "placeholder", tell the user to write their AppID there.

## How to phrase queries

Wolfram parses natural-ish math. Prefer explicit verbs:

- `solve x^2 - 5x + 4 + 4/(x^2 - 5x) = 8 for x`
- `derivative of x^3 sin(x)`
- `simplify (a^2 - b^2) / (a - b)`
- `integrate e^(-x^2) from -inf to inf`
- `factor x^4 - 16`

After running, **read the `Query:` and `Input interpretation:` lines** to confirm Wolfram understood the question. If the interpretation drifts, rephrase and retry (cap at ~3 tries).

## Reporting results

Quote the relevant section of the response (Results / Solutions / Plot) and tie it back to the user's question. Don't paste the whole response unless asked — the plot URL and Wolfram Language code are usually noise.

If the user gave a worked solution, compare Wolfram's answer to theirs and call out the specific step where they diverged.
