# Audit — quadratics — 2026-05-21

## Summary
- **3 errors**, **2 warnings**, **3 info**
- `plan.yaml` is missing — required by skill conventions. Several scheduling-related checks could not run as a result.

## Errors

- **[plan.yaml]** File is missing. The skill treats `plan.yaml` as the source of truth for nodes/cadence/sessions. Without it, `schedule`, `complete`, and `reschedule` cannot operate. Action: generate it from the existing module files (the node IDs, prereqs/enables, and goal node can be derived from the markdown). YAML-integrity, fluency-spec, and tier-coverage checks were skipped because of this.

- **[concept-graph.md vs nodes/02-factoring.md]** DAG inconsistency. `nodes/02-factoring.md` lists `01 expanding-foil` as a prereq ("factoring is the inverse"), but the ASCII diagram in `concept-graph.md` shows no `01 → 02` edge — the only arrow from `01` lands on `03 standard-form`. Either the diagram is missing the edge or the node file overstates the dependency. Most natural fix: add `01 → 02` to the diagram (factoring is the inverse of FOIL — that *is* a prerequisite relationship).

- **[concept-graph.md vs nodes/04-roots-and-zeros.md and nodes/05-vertex-form.md]** DAG inconsistency. The ASCII diagram has a vertical arrow from the `04` column down through `05`, suggesting an edge. But `nodes/04-roots-and-zeros.md` enables only `07 quadratic-formula`, and `nodes/05-vertex-form.md` lists prereqs as only `03 standard-form`. Either the diagram is conveying something other than a prereq edge here, or one of the node files is missing the relationship. Resolve by either dropping that arrow from the diagram or adding `04 → 05` to both node files.

## Warnings

- **[concept-graph.md]** The ASCII DAG is hard to read unambiguously. Vertical pipes and angled arrows make it unclear which arrows are prereq edges vs. layout connectors. Recommend supplementing the ASCII with an explicit edge list (e.g. a Markdown table or YAML block listing every `<from> → <to>` pair). The forthcoming `plan.yaml` would serve this purpose.

- **[nodes/08-parabola-geometry.md]** Has only 2 fluency exercises; the audit threshold is ≥3 unless the node is explicitly marked "fluency-light, schema-heavy." Node 08 does say "Fluency is light here — this node is mostly schema" in prose, which satisfies the intent. Minor — adjust wording to match the spec's flag, or accept as-is.

## Info / suggestions

- **[all nodes — Sources sections]** Sources are uniformly vague. Most read "Khan Academy: '<section name>'" without a URL, or "any Algebra 1 textbook chapter." Concrete sources are a multiplier on encoding quality (philosophy §3). Recommend tightening: specific Khan Academy URLs, named textbook + chapter, named YouTube videos with creator. Non-blocking, but worth a refinement pass.

- **[nodes/01-expanding-foil.md]** `Enables` lists `02-factoring`. The relationship is real but soft — FOIL doesn't *block* learning factoring; it makes factoring easier to motivate. Consider whether the DAG should encode this as a hard prereq or label it as an associative edge. (This is the same edge flagged in Errors above — once you decide, document the choice.)

- **[concept-graph.md and nodes/08-parabola-geometry.md]** Node 08 lists "Pythagorean theorem / distance formula" as a prereq "(outside this module)" but `concept-graph.md` only lists generic external prereqs (variables, distributive property, linear equations, Cartesian coordinates, Pythagorean theorem). Worth making this explicit at the module level — Pythagorean/distance is critical for node 08's central derivation, not a generic assumption.

---

## Checks that ran clean

- Every node has Prereqs, Enables, Sources, Fluency exercises, Schema-building exercises, Metacog checks (explanation + transfer + connection)
- Every node referenced in any Prereqs or Enables list exists as a `nodes/NN-<slug>.md` file
- DAG has no cycles (walked from `01` to `08`)
- `08-parabola-geometry` (goal node, per `goals.md`) is reachable from entry nodes
- `goals.md` mastery target matches the schema exercises in node 08
- Minimum-bar items in `goals.md` are all backed by content in the module (no implicit prereqs uncovered)
- Cross-link sanity: every node's Connection metacog check references at least one other node by name

## Recommended next steps

1. Generate `plan.yaml` from the existing module (this is the biggest blocker — every downstream subcommand depends on it).
2. Resolve the two DAG inconsistencies (Errors 2 and 3) by editing `concept-graph.md` and/or the affected node files.
3. Run `/learning-plan refine ~/claude-workspace/sample-modules/quadratics` to act on the auto-fixable items, then re-audit.
4. Optionally do a sources pass — replace vague references with URLs.
5. Once audit is clean: `/learning-plan diagnose` then `/learning-plan schedule`.
