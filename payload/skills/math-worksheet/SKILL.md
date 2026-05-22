---
name: math-worksheet
description: Generate a math practice worksheet. Creates N problems at a given topic/difficulty, verifies each answer against Wolfram Alpha, and writes a question sheet plus answer key. Use when the user asks for a math worksheet, practice problems, or a problem set.
---

# Math worksheet generator

## Inputs to confirm with the user
- Topic (e.g. "single-variable derivatives", "two-step linear equations")
- Difficulty / grade level
- Number of problems (default: 10)
- Output directory (default: current working directory)

## Steps

Wolfram is the source of truth for answers. Do not generate the answer yourself and compare — Wolfram's `Result:` is the answer.

1. Generate `N` problems for the topic. For each, produce:
   - `problem`: human-readable statement (what the student sees)
   - `wolfram_expr`: a Wolfram-Alpha-parseable expression that asks the same question (e.g. `derivative of x^3 + 2x`, `solve 3x + 5 = 17 for x`)

2. Call the script with `--llm` (Wolfram's LLM API):
   ```bash
   python3 {{SKILLS_DIR}}/math-worksheet/verify.py \
     --app-id-file ~/.config/wolfram/app_id \
     --llm \
     "<wolfram_expr>"
   ```

3. From the multi-section response:
   - Read the **`Query:`** echo. Confirm Wolfram interpreted `wolfram_expr` as the same question `problem` asks. If interpretation drifts, fix `wolfram_expr` and retry. Cap retries at 3 per slot; drop the problem if it can't be phrased to parse.
   - Take the primary answer section (**`Result:` / `Derivative:` / `Solution:` / etc.**) as the canonical answer for the answer key. Prefer the simplest alternate form when several are listed (e.g. `1/2` over `0.5000...`).

4. Write two files to the output directory:
   - `worksheet.md` — numbered problems only
   - `answer_key.md` — same numbering with the answers from step 3

Drop `--llm` only for quick ad-hoc checks where you just need a one-liner; the worksheet flow should always use `--llm`.

## Notes
- The App ID file is `chmod 600`. Do not print its contents, copy it elsewhere, or commit it.
- The LLM API response is several hundred to a few thousand characters — don't dump full responses into the worksheet; extract the relevant section.
- Treat mathematically-equivalent results as matches (`1/2` ↔ `0.5`, `2x` ↔ `2*x`, etc.). The LLM API's alternate-forms section usually surfaces these directly.
- If `verify.py` errors with "app id file not found" or "placeholder", tell the user to write their App ID into `~/.config/wolfram/app_id`.
