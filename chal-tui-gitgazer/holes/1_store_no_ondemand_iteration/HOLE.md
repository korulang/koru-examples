# HOLE 1 — no on-demand iteration over a plural store's rows

## Repro
`koruc run input.kz` (from an app dir whose `koru.json` resolves `std/*`; this
one needs no `libs`/`koru` alias).

## What was attempted
Sweep all current rows of a `capacity: 8` store from inside a repeatable handler
body (`! each`), the way a retained-mode TUI must repaint its list on a
non-mutating event (selection highlight, resize repaint, refresh).

## Expected vs actual
- **Expected:** `v 10` / `v 20` printed on each of the 2 iterations — or a clear
  koru-level diagnostic stating the real constraint.
- **Actual:** `BACKEND_COMPILE_ERROR`:
  `std/store:query(items): unknown store - no std/store:new(items) found (or the
  store is a capacity-1 value - queries need a container, declare capacity: N at
  create)` — surfaced through generated Zig (`output_emitted.zig`) as an embedded
  `@compileError`.

## Two findings bundled
1. **Capability gap.** `std/store:query` (the only row-iteration primitive) is a
   top-level-only comptime transform — it scans TOP-LEVEL program items for
   `std/store:new`. Nested inside a handler/loop body it cannot resolve the store,
   so **a plural store's rows cannot be iterated on demand.** The store is
   reactive-incremental by design ("No reconciliation pass, no scan: the aggregate
   rides the write paths" — 690_041). A retained-mode renderer (vaxis, which fires
   `! draw` on mount AND every resize and expects an idempotent full repaint) has
   no way to read retained rows to repaint them. The public store surface
   (`new/stored/default/watch/insert/query/preorder/take/stripe`) has no
   `get`/`each`/`rows`/`count`/`len` on-demand read; `stripe`/`preorder` are also
   top-level comptime transforms.
2. **Misleading diagnostic.** The message says the store "is not found" when it is
   declared `capacity: 8` on the line above. The real constraint is *"query cannot
   be nested inside a handler/loop body — it must be a top-level declaration."*
   The koru-level wall isn't built here; the message points at the wrong cause and
   leaks at the Zig-compile stage.

## Confidence: real bug vs might-be-me
**~75% a real gap, 25% me.** The failing repro and the top-level-only resolution
are concrete (SHOWN). The *framing* is the design question for the walk: maybe the
intended idiom is "don't iterate the store to render — maintain a projection via
reactive interceptors and drive the renderer off writes," in which case the fix is
a diagnostic that teaches that, plus possibly an on-demand `query`/scan verb for
the retained-render case. Either way the misleading message (finding 2) is a real
defect.

## Where it bit the app
`../../c_gitgazer.kz` renders the initial `git status` by re-running the inserts
inside `! draw` (which re-fires the reactive query). It therefore CANNOT add a
selection highlight or a resize-safe repaint without either re-inserting rows
(duplicate/grow toward capacity) or leaving the list blank on resize — the two
horns of this hole.
