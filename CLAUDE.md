# Personal preferences

These apply to every session on this machine. Project-level `CLAUDE.md` files and explicit user instructions override anything here.

## Code style

1. **Always type-annotate** every function argument and return value.
2. **Simple over clever.** A few extra readable lines beat a terse clever one-liner. Maintainability wins.
3. **No clever tricks unless the speedup is real.** If an optimization is necessary, add a comment that (a) explains what it does and (b) shows the equivalent simpler/slower code it replaces.
4. **Describe code in docstrings, not comments.** Comments are only for information that cannot be derived from the code itself — outside constraints, non-obvious invariants, references to a documented optimization.
5. **Composition over inheritance.** Prefer Protocols / dataclasses / plain functions wired together. Don't build class hierarchies.

Start with the simplest direct implementation. Only reach for vectorization, short-circuits, or custom data structures when profiling or obvious scale demands it — and document the naive version when you do.

## Git / commit style

- Subjects are a single line, imperative, present-tense verb first (`Add X`, `Replace Y with Z`, `Remove W`).
- No body, no `Co-Authored-By` trailer.
- Group logical operations into a few commits rather than one large one. Library code and its callers, for example, go in separate commits.

## Opt-in rule packs

- ML / training projects: add `@~/.claude/ml-projects.md` to the project's `CLAUDE.md`. See that file for the rule set.

## Review

Your code will be reviewed by Codex.
