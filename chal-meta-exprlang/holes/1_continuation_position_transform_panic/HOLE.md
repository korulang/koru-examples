# HOLE 1 — continuation-position transform invocation panics the compiler

## What breaks

A `[comptime|transform]` event whose `Source` block is invoked in
**continuation position** (downstream of a pipeline binding, `~seed(): v |> tag { ... }`)
crashes the transform pass with a **raw host-level panic**, no koru-level
diagnostic, no source location:

```
╔══════════════════════════════════════════════════════════════════╗
║  TRANSFORM ERROR: Invocation not replaced!                       ║
╚══════════════════════════════════════════════════════════════════╝
thread N panic: transform pass failed — see error above
  /Users/larsde/src/koru/src/transform_pass_runner.zig:1036:9  applyTransform
  /Users/larsde/src/koru/src/transform_pass_runner.zig:803     walkNode
  ...
```

## Reproduce

```
cd holes/1_continuation_position_transform_panic
koruc run input.kz
```

`input.kz` invokes `app/calc_dsl:calc-fold` (a proven transform) in continuation
position. `calc_dsl.kz` is the exact same transform that compiles and runs
cleanly at **top level** in the parent app (`../../app.kz` → `2 + 3 * 4 = 14`,
`../../cross.kz` → `6 * 7 + 8 = 50`). The only variable changed is the position
of the transform's Source block: top-level works, continuation panics.

## Expected vs actual

- **Expected:** either the continuation-position transform lowers like the
  top-level one, OR — if it is genuinely unsupported today — a koru-level
  diagnostic pointing at `input.kz:<line>` that names the unsupported position
  ("transform `calc-fold` invoked in continuation position is not yet
  supported"), the way koru catches other mistakes at its own boundary.
- **Actual:** `panic: transform pass failed` — a raw Zig panic with a stack
  trace into `transform_pass_runner.zig`, no `.kz` source location, no guidance.

## Two facets

1. **Capability gap (MEDIUM confidence it is a compiler gap, not just me):**
   continuation-position source-block transforms may be genuinely unsupported.
   Koru's own suite corroborates this independently: `210_024_source_scope_capture`
   is parked `TODO` (Lars, 2026-06-03) documenting this exact frontier —
   *"continuation-body source-block invocations were dropped … the emitter panics
   on a source-block invocation in continuation position … the transform
   re-assembles the continuations and mis-attaches the handler."* My own
   whole-program transform only rewrites the **root** `flow.inv()`, not
   invocations nested inside another flow's continuation list — so part of the
   "not replaced" is my transform being incomplete for that position. That half
   is plausibly me (~50%).

2. **Diagnostic gap (HIGH confidence it is a real defect, regardless of facet 1):**
   when a transform leaves an invocation unreplaced, the compiler answers with a
   raw host **panic + Zig stack trace** instead of a koru-level diagnostic
   carrying the source location. By koru's own stated standard (a raw-host leak
   where a koru-level wall should be = a bad error message / missing
   pit-of-success wall), this is the pinnable defect: the panic gives the user
   nothing actionable and no `.kz` location.

## Confidence summary

- Raw-panic-instead-of-diagnostic on unreplaced invocation: **HIGH real bug.**
- Continuation-position transforms being unsupported: **MEDIUM real gap**
  (corroborated by 210_024 TODO), with a ~50% chance the non-replacement is my
  transform not walking continuations rather than a compiler defect.
