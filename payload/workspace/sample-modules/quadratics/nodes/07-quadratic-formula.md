# 07 — The Quadratic Formula

## Prereqs
- `04 roots-and-zeros`
- `06 completing-the-square`

## Enables
- `08 parabola-geometry` (lets you find vertex x-coordinate as `-b/(2a)` independently)

## What this node is

`x = (-b ± √(b² - 4ac)) / (2a)`

A closed-form expression for the roots of `ax² + bx + c = 0`. It is **not** a thing to memorize — it is the result of applying completing the square to the general form symbolically.

## Sources
- Any algebra textbook covering the quadratic formula derivation
- Patrick JMT or 3Blue1Brown video on the derivation

## Fluency exercises

1. Solve `x² - 5x + 6 = 0` using the formula. (Check: it should match factoring.)
2. Solve `2x² + 3x - 2 = 0`
3. Solve `x² + x + 1 = 0` — what happens? Why?
4. Solve `x² - 4x + 4 = 0` — how many distinct roots?

## Schema-building exercises

1. **Derive the formula.** Starting from `ax² + bx + c = 0`, apply completing the square symbolically until you isolate `x`. Show every step. (This is the central derivation of the module's first half.)
2. **What does the discriminant mean?** The expression `b² - 4ac` is the discriminant. Why does its sign determine the number of real roots? Connect this to the graph: when does the parabola cross, touch, or miss the x-axis?
3. **Why `-b/(2a)`?** Notice that `-b/(2a)` appears in both the formula and as the x-coordinate of the vertex. Why are they the same? (Hint: symmetry of the parabola.)
4. **When is the formula better than factoring? When is factoring better?** Give an example of each.

## Metacog checks
- **Explanation**: Can you derive the formula from `ax² + bx + c = 0` without referring to notes? If not, which step trips you up?
- **Transfer**: A projectile's height is `h(t) = -5t² + 30t + 2`. Use the formula to find when it lands. Interpret the negative root, if there is one.
- **Connection**: How does the discriminant connect to the question raised in `04` ("how many roots can a quadratic have")?

## Note

If you can only use the formula but cannot derive it, you have surface encoding (§4). The ideal bar requires you can derive it on demand. Flag this node and return if you skip the derivation.
