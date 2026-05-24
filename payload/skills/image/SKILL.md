---
name: image
description: Read screenshots, photos, scanned pages, or PDF pages and either explain/answer (`read`), verify a shown answer against Wolfram (`grade`), or start a persistent image-handling mode (`session`) that auto-routes every subsequent image through Haiku subagents. Vision tokens stay on Haiku via `image-reader`; math verification runs on Haiku via `grade-runner` / `wolfram-runner`. Use when the user attaches a screenshot, references an image/PDF, says "from my clipboard", wants a worksheet graded, or wants to set up persistent image handling for the conversation. Subcommands - read, grade, session.
---

# image

Composable image-handling skill. The actual vision work runs on Haiku via the `image-reader` subagent. The parent session orchestrates: prepare the input → call the subagent → act on the structured result.

## Dispatch

`/image <subcommand> [args]`

| Subcommand | File | Purpose |
|---|---|---|
| `read [source]` | `subcommands/read.md` | Transcribe + answer/explain whatever the image shows |
| `grade [source]` | `subcommands/grade.md` | Verify a shown Q/A (and optional work) against Wolfram via `grade-runner` (Haiku) |
| `session [on\|off\|status]` | `subcommands/session.md` | Persistent mode: auto-route every subsequent image through Haiku |

If the user invokes `/image` with no subcommand, ask which they want. If they describe intent ("grade this worksheet", "what does this say"), pick the matching subcommand without re-asking.

**If `$CLAUDE_JOB_DIR/image-session.on` (or `/tmp/image-session-*.on`) exists, session mode is active** — follow the session-mode contract in `subcommands/session.md` for every image-bearing user turn, even without an explicit `/image` invocation.

## Input sources (shared across subcommands)

A subcommand's `[source]` argument can be any of:

1. **Absolute file path** — `.png`, `.jpg`, `.jpeg`, `.webp`, `.pdf`. Used as-is for images; PDFs are rasterized first (see below).
2. **Clipboard** — pass `clipboard` (or omit `source` entirely). Resolves via `pngpaste $CLAUDE_JOB_DIR/clip.png` on macOS.
3. **PDF page range** — append `:pages=1-3` or `:pages=2` to a `.pdf` path. Default is all pages.

Resolution rules (apply in order):
- If `source` is a path ending in `.pdf`, rasterize: `pdftoppm -r 300 -png <pdf> <tmpdir>/page` → produces `page-1.png`, `page-2.png`, …. Use `$CLAUDE_JOB_DIR` if set, else `/tmp/image-skill-<pid>`.
- If `source` is `clipboard` or omitted: `pngpaste <tmpdir>/clip.png`. If `pngpaste` fails or returns empty, tell the user how to install it (`brew install pngpaste`) and stop.
- Otherwise treat `source` as a single image path.

After resolution, you have one or more absolute PNG paths. Call `image-reader` once per path.

## Calling image-reader (the contract)

Use the Agent tool with `subagent_type: image-reader`. Pass a prompt of the form:

```
path: <absolute path>
mode: <transcribe|math|code|describe>
context: <one line on what you'll do with the result>
```

`image-reader` replies in this exact shape:

```
Mode: <mode>
Confidence: <high|medium|low>
---
<one transcribed item per line, each tagged [high|medium|low]>
---
Notes: <one-line caveat or "none">
```

Parse the `---`-fenced middle block as your data. Honor the confidence tags — see subcommand files for how each acts on `low`.

## Learning-plan integration

If the current working directory is inside a `claude-learning-plan` module folder (detect by looking for `plan.yaml` in cwd or any parent up to `claude-workspace/`), **and** there is an open session log (a file under `<module>/schedule/sessions/` whose marginal-gains table is unfilled), this skill operates in **session-attached mode**:

- After producing its result, append a one-line entry to the open session log under a `## Image artifacts` heading (create the heading if absent). Example:
  ```
  - 2026-05-24 14:32 — grade — `/path/to/screenshot.png` — ✓ Matches: sqrt(3)
  ```
- Do **not** modify the marginal-gains table or any other section — that's the user's job.

If no module / open session is found, run standalone (just reply to the user, write nothing).

## Output conventions (for both subcommands)

- Lead with the **verdict line** (the single most useful sentence).
- Then a short structured block with the transcription and any verification result.
- If any item is `[low]` confidence, end with: `⚠ Low-confidence OCR — confirm before acting.`
- Cost reminder: vision tokens stayed on Haiku. Do not paste the full subagent reply back to the user — summarize.

## Examples

`/image read` (no source) → reads clipboard, transcribes, answers any question shown.

`/image grade ~/Downloads/hw.pdf:pages=1-2` → rasterizes pages 1–2, finds Q/A pairs, verifies each via `/wolfram`, emits a grade table.

`/image read /tmp/error.png` → transcribes the stack trace and offers a diagnosis.

## See also

- `image-reader` agent: `{{AGENTS_DIR}}/image-reader.md` — the contract for what the subagent returns.
- `/wolfram` skill: used by `grade` for math verification.
- `/learning-plan`: session-attached mode integrates with its session logs.
