# /image grade

Grade a shown Q/A (with optional work) against Wolfram. Returns ✓/✗ and, when wrong, the first incorrect step.

## Signature

`/image grade [source]`

- `source` — see SKILL.md "Input sources". Defaults to clipboard. For worksheets, pass a PDF.

## Required content in the image

For each problem, the image must show **both** a question and a proposed answer. Work-shown is optional but lets the skill locate the first error.

Layout cues that help OCR (mention to the user if results are poor):
- Boxed or labeled Q and A regions
- One problem per page or clearly separated blocks
- High contrast, ≥300 DPI

## Steps

1. **Resolve source → image path(s).** Follow SKILL.md resolution rules.
2. **For each path:** invoke `image-reader` (Haiku) with `mode=math` and `context="grade — extract Q, A, and Work labels"`.
3. **Parse** the `---`-fenced reply. Extract `Q:`, `A:`, optional `Work:` lines into a list of triples.
4. **Hand off to `grade-runner`** (Haiku, see `~/.claude/agents/grade-runner.md`). Pass the triples in the documented `problem N:` shape. `grade-runner` calls Wolfram per problem and returns a pre-formatted grade table.
5. **Relay** the grade-runner table verbatim. Do not re-call Wolfram in the parent.
6. **Session-attached mode** (see SKILL.md): append a `## Image artifacts` line per page with the verdict to the open session log.

The parent never calls Wolfram directly and never sees the Wolfram response body — that all stays on `grade-runner`.

## Confidence handling

- All items `[high]` → grade normally.
- Any `[medium]` on Q or A → grade but add `(OCR uncertain)` in Notes.
- Any `[low]` on Q or A → do not grade that problem; emit `?` in the Correct? column with `Notes: OCR unreadable — confirm and re-run.`

## Failure modes

- No (Q, A) pair detected → reply: "Couldn't find a question/answer pair. The image should show both — or use `/image read` if you just want a transcription."
- Wolfram returns ambiguous result (e.g. multiple valid forms like `√3` vs `3/√3`) → mark `✓ (equivalent forms)` rather than `✗`. Same for trivial cosmetic differences (decimal vs. exact, ordering of terms).
- PDF with many pages → process sequentially, emit one table section per page, then a totals line at the end.

## Example

User: `/image grade ~/Downloads/hw.pdf:pages=1`

Steps:
1. Rasterize page 1 → `/tmp/.../page-1.png`.
2. `image-reader` returns:
   ```
   Q: simplify 3/sqrt(3)  [high]
   A: sqrt(3)  [high]
   Work: 3/sqrt(3) = 3*sqrt(3)/3 = sqrt(3)  [high]
   ```
3. `/wolfram` confirms `sqrt(3)`.
4. Reply:
   > Graded 1 problem: 1 correct, 0 incorrect.
   >
   > | # | Q | Their A | Correct? | Notes |
   > |---|---|---------|----------|-------|
   > | 1 | simplify 3/√3 | √3 | ✓ | — |
