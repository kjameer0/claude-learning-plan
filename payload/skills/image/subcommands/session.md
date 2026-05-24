# /image session

Turn on **image session mode** for the remainder of the conversation. While on, the parent automatically routes any image the user attaches or references through Haiku subagents — vision tokens never enter the parent context, and follow-up tools (Wolfram, etc.) run on Haiku too.

## Signature

`/image session [on|off|status]` — default `on`.

## Effect of `on`

1. Create marker: `mkdir -p $CLAUDE_JOB_DIR && touch $CLAUDE_JOB_DIR/image-session.on` (fallback `/tmp/image-session-<pid>.on` if `CLAUDE_JOB_DIR` unset).
2. Commit to the **session-mode contract** below for the rest of the conversation. The contract is durable: it applies to every subsequent user turn until `/image session off`.
3. Reply: `Image session on. Paste, attach, or reference images and I'll route them through Haiku.`

## Effect of `off`

Remove the marker. Reply: `Image session off.` Subsequent images are handled normally (parent may read vision tokens directly).

## Effect of `status`

Report whether the marker exists and which agents are wired in.

---

## Session-mode contract (parent behavior while on)

**Trigger:** any user turn that includes an image attachment, a `[Image #N]` reference, a path ending in `.png|.jpg|.jpeg|.webp|.pdf`, or the word "clipboard" / "screenshot" in context of an image.

**Step 1 — transcribe.** Spawn `image-reader` (Haiku) with the appropriate `mode`:
- `math` if the user mentions solve/grade/check/simplify/verify, or the image obviously contains equations.
- `code` if the user mentions error/stack trace/debug, or the image looks like source/terminal.
- `transcribe` for plain text / handwriting.
- `describe` for diagrams, UI mockups, photos.

Never look at the raw image yourself. If a vision token slips in, still delegate — don't reason from it.

**Step 2 — dispatch follow-up based on intent.** Use this routing table:

| User intent (cues)                                            | Follow-up                                                                 |
|---------------------------------------------------------------|---------------------------------------------------------------------------|
| "grade", "check my answer", "is this right", "did I do this correctly" | Spawn `grade-runner` with the (Q, A, Work) triples from image-reader.     |
| "solve", "what's the answer", "simplify", "evaluate"          | Spawn `wolfram-runner` with the expression. Relay its answer.             |
| "explain", "what does this say", "what's going on", "help me understand" | Parent answers directly from the transcription. No further agent needed.  |
| "debug", "why is this failing", code/stack trace image        | Parent diagnoses directly from the transcription.                         |
| Ambiguous / no clear verb                                     | Ask the user in one short line: "Grade, solve, or explain?"               |

**Step 3 — reply.** Lead with the verdict / answer line, then a short structured block. Do not paste subagent replies verbatim — summarize.

**Step 4 — learning-plan integration.** Same as base SKILL.md: if inside a learning-plan module with an open session log, append a `## Image artifacts` line.

## Guarantees

- Opus never receives vision tokens.
- Opus never receives Wolfram response bodies (those stay on `wolfram-runner` / `grade-runner`).
- Opus only sees: transcribed text from `image-reader`, structured results from runners, and its own routing decisions.

## Failure modes

- Image-reader returns `[low]` confidence on all items → ask the user to re-share at higher resolution; don't dispatch follow-ups.
- `grade-runner` can't reach Wolfram → relay the error and offer a hand-check.
- User attaches a non-image file → fall out of session-mode handling for that turn and treat normally.
