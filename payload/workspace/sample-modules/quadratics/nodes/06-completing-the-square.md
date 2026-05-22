# 06 — Completing the Square

## Prereqs
- `03 standard-form`
- `05 vertex-form`
- Perfect square trinomials: `(x + p)² = x² + 2px + p²`

## Enables
- `07 quadratic-formula` (this is the engine of the derivation)

## What this node is

A procedure for rewriting `ax² + bx + c` as `a(x - h)² + k`. It is the algebraic bridge between standard form and vertex form, and the technique that produces the quadratic formula.

This is the first heavily schema-building node.

## Sources
- Khan Academy: "Completing the square"
- 3Blue1Brown or similar video showing the geometric interpretation (literally completing a geometric square)

## Fluency exercises

1. Complete the square: `x² + 6x` → `(x + ?)² - ?`
2. Complete the square: `x² - 10x + 7`
3. Complete the square (leading coefficient ≠ 1): `2x² + 8x + 5`
4. Use completing the square to rewrite `y = x² - 4x + 1` in vertex form. Identify the vertex.

## Schema-building exercises

1. **Geometric derivation.** Draw a square of side `x`. Attach a rectangle of width `x` and height `b/2` to each of two adjacent sides. To "complete the square" — what side length must the missing corner piece have? What's its area? Connect this to the algebraic step "add `(b/2)²`."
2. **Why does this always work for `a = 1`?** Show symbolically: starting from `x² + bx + c`, the move `add and subtract (b/2)²` produces `(x + b/2)² + (c - b²/4)`. Convince yourself this is an identity, not an approximation.
3. **The `a ≠ 1` case.** Why do you factor `a` out of the first two terms first, instead of out of all three? What goes wrong if you don't?
4. **Bridge to the next node.** Apply completing the square to the general form `ax² + bx + c = 0` symbolically (don't plug in numbers). Don't finish — just get as far as you can. (This is the setup for `07`.)

## Metacog checks
- **Explanation**: Can you explain *why* `(b/2)²` is the magic number, both algebraically and geometrically?
- **Transfer**: Use completing the square to find the maximum value of `-x² + 6x - 5` without graphing.
- **Connection**: This node connects backward to perfect square trinomials (a prereq concept) and forward to `07 quadratic-formula` and `08 parabola-geometry`. Explain each connection.

## Note on difficulty

This node is where productive struggle begins (§3, §6). If it feels hard, that is the mechanism working — do not skip past it. The minimum bar to advance: you can complete the square on any quadratic with `a = 1` without prompting.
