# /image read

Transcribe an image and answer / explain what's shown.

## Signature

`/image read [source]`

- `source` — see SKILL.md "Input sources". Defaults to clipboard.

## Steps

1. **Resolve source → image path(s).** Follow SKILL.md resolution rules. For PDFs, you may have multiple paths.
2. **Pick a `mode` for image-reader** based on a quick heuristic:
   - User mentioned math, equations, worksheet, problem → `math`
   - User mentioned code, error, stack trace, terminal → `code`
   - User asked "what does this say" / "transcribe" → `transcribe`
   - Otherwise → `describe`
   If unsure, default to `transcribe` — it's the most general.
3. **Invoke `image-reader`** once per resolved path. Pass `context:` explaining what you'll do (e.g. "answer the math problem shown", "explain this error").
4. **Parse the reply.** Read the items between the `---` fences.
5. **Act on the content:**
   - If it's a question with no shown answer → answer it. For math, call `/wolfram` to verify your answer before replying.
   - If it's an error / log → diagnose it.
   - If it's a passage of text → answer the user's prompt about it; if no prompt, summarize.
6. **Reply to the user** with:
   - Verdict line (the answer / diagnosis / summary).
   - 1–3 line transcription preview so user can confirm OCR.
   - If `[low]` confidence anywhere → the warning footer.
7. **Session-attached mode** (see SKILL.md): append a `## Image artifacts` line to the open session log if one exists.

## Failure modes

- `pngpaste` not installed → tell user `brew install pngpaste` and stop.
- `pdftoppm` not installed → tell user `brew install poppler` and stop.
- image-reader returns `Confidence: low` overall → reply with what was extracted and ask the user to retake the photo / increase contrast rather than acting on a guess.
- Empty / unreadable image → say so; do not fabricate content.

## Example

User: `/image read` (with a screenshot of `2/∛24` on the clipboard)

Steps:
1. Resolve clipboard → `/tmp/clip.png`.
2. mode = `math` (math heuristic).
3. Call `image-reader` with `path=/tmp/clip.png mode=math context="simplify and explain"`.
4. Subagent returns `2 / cbrt(24)  [high]`.
5. Compute: `2/∛24 = 2/(2∛3) = 1/∛3 = ∛9/3`. Call `/wolfram` to verify.
6. Reply:
   > **∛9 / 3** (≈ 1.0).
   > Read as: `2 / ∛24`. Simplifies via ∛24 = 2∛3, then rationalize.
   > Verified with Wolfram.
