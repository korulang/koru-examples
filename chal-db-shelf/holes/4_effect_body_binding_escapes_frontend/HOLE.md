# HOLE 4 — a `! effect`-body binding used in a sibling terminal branch passes `--check` but leaks a raw Zig error

## What
A binding introduced inside an effect-branch body (`! row r |> ... : title`) is
referenced from a **sibling** terminal branch (`| done |> ... title ...`), where
it is out of scope (the `! row` body runs per-row; `| done` runs once, after
finalize). Two failures stack:

1. `koruc --check` reports **`✓ Shape checking passed`** — a false positive. The
   frontend/flow gate does not catch the out-of-scope (and, for `col.text`,
   lifetime-escaping) reference.
2. The full build then fails at stage D with a **raw host-Zig leak**:
   `output_emitted.zig:...: error: use of undeclared identifier 'title'`.

The koru-level wall that should say "`title` is bound in the `! row` body and does
not escape to `| done`" is missing, so the mistake surfaces as generated-Zig
garbage instead of a koru diagnostic.

## Repro (`input.kz` — pure stdlib, self-contained, runs from anywhere)
```koru
~import std/io
~import std/fs
~std/fs:read-lines(path: "nope.txt")
! line l |> std/io:print.ln("line {{ l:s }}")
| done _ |> std/io:print.ln("escaped line = {{ l:s }}")
| failed _ |> _
```
```
koruc --check input.kz     # => ✓ Shape checking passed          (WRONG)
koruc run    input.kz      # => output_emitted.zig:85: error: use of
                           #    undeclared identifier 'l'
```
`l` is bound in the `! line` effect-branch body and referenced in the sibling
`| done` branch. (The same shape holds for sqlite3's `! row` binding used in
`| done` — first found there while building `bridge.kz`; the stdlib
`read-lines` version above proves it is a general effect-branch scope gap, not
sqlite-specific.)

## Expected vs actual
- Expected: `--check` REJECTS with a koru-level diagnostic — the binding `l`
  from the `! line` effect body is not in scope in the `| done` branch (and, for
  a borrow like `col.text`/`! line`'s row/line-scoped string, would dangle even
  if it were).
- Actual: `--check` passes; the build later dies inside generated Zig with
  `use of undeclared identifier 'l'`.

## Why this is the interesting half
This is the pit-of-success wall that isn't built yet (cf. koru CLAUDE.md's
consequence hierarchy: a raw host-Zig leak = "the koru-level guarantee isn't
lifted here"). The escape SHOULD be a clean koru error; instead the frontend
green-lights it and the user is dropped into generated-Zig land. It also connects
to HOLE 3: `col.text`'s `-> string` is a row-scoped borrow typed as a bare
`string`, so nothing marks it as non-escaping — the same missing-lifetime-phantom
root, here caught (accidentally, and badly) only because the Zig identifier
happens not to exist in the sibling branch.

## Confidence
- That `--check` passing here is a real frontend gap: HIGH. A program that cannot
  compile should not pass the shape/flow gate; and referencing an effect-body
  binding from a sibling branch is unambiguously out of scope.
- That the raw-Zig leak is a "bad error message" defect: HIGH (by koru's own
  stated standard).
- Might-be-me: LOW. This is not idiom I misused — it is the gate accepting an
  invalid program.

## Not routed around
This file is a probe, not app code. `shelf.kz` and `bridge.kz` never escape a
row binding — they copy (`from-page`) inside the row body before use. The hole is
floated, not worked around.
