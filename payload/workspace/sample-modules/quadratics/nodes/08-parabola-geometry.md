# 08 — Parabola Geometry (Focus and Directrix)

## Prereqs
- `05 vertex-form`
- `07 quadratic-formula` (helpful but not strictly required for the derivation)
- Pythagorean theorem / distance formula (outside this module)

## Enables
- Conic sections (next module)
- Optics and physics applications
- The schema-building peak of this module

## What this node is

The **geometric definition** of a parabola: the set of all points equidistant from a fixed point (the **focus**) and a fixed line (the **directrix**). Every algebraic property of the parabola — vertex, axis of symmetry, the role of `a` — falls out of this definition.

This is where algebra and geometry connect. The learner has already done a version of this derivation; this node makes it reproducible and extends it.

## Sources
- 3Blue1Brown: "Why are quadratic graphs called parabolas?"
- Any precalculus chapter on conic sections (focus on the parabola section)

## Fluency exercises

Fluency is light here — this node is mostly schema. But:

1. Given focus `(0, 1)` and directrix `y = -1`, plot 4 points on the parabola by hand using the distance condition.
2. Given vertex form `y = (1/4)(x - 2)² + 3`, identify the focus and directrix. (Requires the derived relationship.)

## Schema-building exercises

1. **Derive vertex form from the geometric definition.** Place the focus at `(0, p)` and the directrix at `y = -p`. For an arbitrary point `(x, y)` on the parabola:
   - Distance to focus: `√(x² + (y - p)²)`
   - Distance to directrix: `|y + p|`
   - Set them equal, square both sides, simplify.
   - Result: `y = x² / (4p)` — a parabola in vertex form with vertex at the origin and `a = 1/(4p)`.

2. **What does `a` mean, geometrically?** From the derivation, `a = 1/(4p)`. So `a` is determined by the **distance from vertex to focus**. Small `p` (focus close to vertex) → large `a` → narrow parabola. Explain why this matches your intuition.

3. **Shift the vertex.** Now place the vertex at `(h, k)` instead of the origin. Redo the derivation. Result: `y = a(x - h)² + k`. The general vertex form is now recovered from pure geometry.

4. **Connect to standard form.** Expand the vertex form you just derived. You now have a derivation of standard form `y = ax² + bx + c` from the geometric definition of a parabola, with `a, b, c` expressed in terms of `h, k`.

5. **Reflective property (stretch).** A ray traveling parallel to the axis of symmetry reflects off the parabola and passes through the focus. Look up or sketch why. This is why satellite dishes and headlights are parabolic.

## Metacog checks
- **Explanation**: Can you re-derive `y = x² / (4p)` from the focus/directrix definition without notes?
- **Transfer**: Given the focus and directrix of a parabola, can you produce its equation in standard form?
- **Connection**: This node connects all prior nodes. Trace the path from the geometric definition to standard form, naming the algebraic operations that bridge them.

## Why this is the peak

This derivation is the schema-building example from the philosophy doc (§6). It requires:
- Algebraic manipulation (`02, 03, 05`)
- Distance formula (external prereq)
- Symbolic completing-the-square moves (`06`)
- Connecting two different definitions of the same object

If you can do this cold, you have **extended encoding** on quadratics (§4) — knowledge that transfers across contexts, not just procedural fluency. This is the module's mastery goal.
