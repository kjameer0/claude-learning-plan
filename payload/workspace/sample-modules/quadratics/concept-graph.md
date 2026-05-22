# Concept Graph — Quadratics

A directed graph of the concept nodes in this module. Edges encode prerequisite dependencies (§12). The learner walks the graph, not a path.

## Assumed prerequisites (outside this module)

- Variables and expressions
- Distributive property: `a(b + c) = ab + ac`
- Solving linear equations
- Cartesian coordinates and graphing points
- The Pythagorean theorem (needed at node 08)

If any of these are weak, fix them before starting — a weak prereq node silently breaks everything downstream (§12).

## Nodes

```
01 expanding-foil ──────┐
                        ↓
02 factoring ────────► 03 standard-form ────► 04 roots-and-zeros
                              │                       │
                              ↓                       │
                       05 vertex-form ◄───────────────┤
                              │                       │
                              ↓                       │
                       06 completing-the-square ──────┤
                              │                       │
                              ↓                       ↓
                       07 quadratic-formula ◄─────────┘
                              │
                              ↓
                       08 parabola-geometry  (← the schema-building peak)
```

## Edge semantics

- `01 → 03`: you cannot recognize standard form as "an expanded product" without FOIL
- `02 → 03`: factoring is the inverse operation; understanding both directions stabilizes the form
- `03 → 04`: roots live on the graph of standard form
- `03 → 05`: vertex form is a rewrite of standard form
- `05 → 06`: completing the square is the algorithm that produces vertex form
- `04, 06 → 07`: the quadratic formula is completing the square applied symbolically, and outputs roots
- `05, 07 → 08`: parabola geometry uses both forms and connects algebra to the geometric definition

## Where fluency vs schema-building lives

- **Fluency-heavy nodes**: 01, 02, 03, 04 — these need automaticity so working memory is free at 06–08
- **Schema-heavy nodes**: 06, 07, 08 — these are where derivation and reorganization happen

## Interleaving opportunities (§10)

Once nodes 02–04 are stable, mix problem types in single sessions:
- Factor / solve by factoring / identify roots from a graph — same underlying schema, different surface
- Convert standard → vertex / vertex → standard / sketch from either — forces discrimination
