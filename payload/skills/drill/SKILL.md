---
name: drill
description: Run an interactive drill session against a learning module (or any worksheet file). Delivers questions one at a time, verifies each answer against Wolfram Alpha, gives hints on wrong answers, and inserts schema-building follow-ups when the first attempt fails. Fluency questions come first, then interleaved schema-builders, then harder fluency. Use when the user wants to practice problems from a module, work through a worksheet interactively, or do a timed Q&A session with live answer checking.
---

# drill

Interactive Q&A session with Wolfram-verified answer checking. Designed for the node-based learning modules produced by `/learning-plan`, but works with any worksheet file.

## Invocation

```
/drill <module-path>            — session across all nodes in DAG order
/drill <module-path> --nodes 04,05,07   — specific nodes only
/drill <worksheet-file>         — free-form against a worksheet .md file
```

If invoked with no args, ask the user what they want to drill.

## Session structure

Follow the learning philosophy at `{{WORKSPACE}}/ai-resources/learning-philosophy.md` §6 (fluency floor before schema-building):

1. **Fluency block** — pull all fluency exercises from the target nodes in DAG order. Deliver one at a time.
2. **Interleaved schema-builders** — once fluency is exhausted (or user says "schema" / "harder"), pull schema-building exercises, mixing nodes.
3. **Harder fluency** — return to fluency with harder items or generated variants if the user wants more reps.

The user can jump phases by saying "schema", "harder", "back to basics", or "next section". Respect it without asking.

## Per-question rules

For every question:

1. **Deliver the question.** One at a time — do not reveal the next question.
2. **Wait for the user's answer.**
3. **Verify against Wolfram Alpha** using the direct bash call (not a subagent — cheaper):
   ```bash
   python3 {{SKILLS_DIR}}/math-worksheet/verify.py \
     --app-id-file ~/.config/wolfram/app_id \
     --llm "<wolfram-parseable expression>"
   ```
   Translate the question into a Wolfram-parseable expression before verifying. For factoring problems use `factor ...`; for solve problems use `solve ... for x`; for discriminant problems use `discriminant of ...`.

4. **If correct:** confirm and move to the next question. Keep it brief.
5. **If wrong:** give a hint drawn from the Wolfram answer. One hint only — do not give the full answer unprompted.
6. **If the user asks for the answer** after failing: give it, then move on.
7. **If wrong on the first attempt:** after resolving the question (via hint or answer), deliver one schema-building follow-up to build the underlying mental model. The follow-up is not graded — it is a prompt for the user to reason aloud. After they respond, acknowledge and continue.

## Sourcing questions

Priority order:
1. **Node files** — read the `## Fluency exercises` and `## Schema-building exercises` sections from each target node's `.md` file.
2. **Worksheet files** — if invoked against a worksheet, parse sections and questions directly.
3. **Generated** — if the node's exercise list is exhausted and the user wants more, generate additional problems consistent with the node's scope. Verify generated answers against Wolfram before presenting.

When generating problems, frame the Wolfram query first to get the answer, then write the problem statement — never write a problem without knowing the answer.

## Wolfram verification rules

- The `Result:` line from Wolfram is the canonical answer. Accept mathematically equivalent forms (`1/2` ↔ `0.5`, `x = ±2` ↔ `x = 2, x = -2`).
- For qualitative answers (discriminant sign, number of solutions, domain restrictions), verify the underlying computation and judge the user's conclusion.
- Schema questions often have no single numeric answer. For those, verify any computations embedded in the user's explanation, but grade the reasoning yourself based on the node's stated learning goals.
- If Wolfram returns an error or times out, note it and verify manually from the answer key if one is available. Do not silently skip — tell the user.

## Token discipline

- Use the direct `verify.py` bash call, not the `wolfram-runner` subagent. The subagent costs ~6k tokens per call; the direct call is much cheaper.
- Do not dump the full Wolfram response to the user. Extract only the `Result:` line and any directly relevant alternate forms.

## Session tracking

Keep a running tally in your working memory:
- Questions delivered
- First-attempt correct / incorrect
- Schema follow-ups triggered

Report the tally when the user ends the session or asks for it. No need to write files unless the user asks.

## What "schema-building follow-up" means

A schema follow-up is not another practice problem — it is a question that forces the user to articulate *why* the procedure works or *how* it connects to another concept. Examples:

- After a wrong factoring attempt: "What property of zero makes the factored form useful for finding roots?"
- After a wrong discriminant answer: "Where in the derivation of the quadratic formula does `b² - 4ac` appear, and why does its sign control the number of solutions?"
- After a wrong substitution attempt: "What structural feature in the original equation told you that a substitution would work?"

Draw these from the node's `## Metacog checks` and `## Schema-building exercises` sections when available. Generate analogues if not.
