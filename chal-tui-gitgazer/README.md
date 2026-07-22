# gitgazer — a git-status TUI (subprocess + reactive store + vaxis)

An APP_CHALLENGE increment in the **subprocess + terminal UI** region. It runs
real `git` as a subprocess, streams its output through a reactive `std/store`,
and paints it with `vaxis` — the store↔vaxis convergence, driven by a live
process.

## What it demonstrates

Three organs of the toolchain interoperating in one program:

- **Subprocess** — `git status --porcelain` via `std.process.Child.run` inside a
  `~proc|zig` FFI block, modelled as an effect that fires `! line` per output
  line (the `std/fs:read-lines` shape). There is no `std/process`, so this is the
  only way to shell out (see `holes/2_no_std_process`).
- **Reactive store** — each line moves into a plural `std/store` as a MIXED row
  `{ name: owned-string, y: scalar }` (the 690_064 owned+scalar shape). The
  owned-string obligation is threaded through the store boundary
  (from-page → take → insert).
- **vaxis** — `run` owns the terminal; `! draw` hands the root window; the
  store's reactive `query` fires per insert and paints each row at its own line.

The chain that worked hardest: an owned-string obligation flow **nested inside a
vaxis effect handler**, feeding a plural store, whose reactive query bridges
store writes to terminal paints — three effect sources (`vaxis:run`, the store
`query`, the `git-lines` FFI effect) coexisting in one flow.

## The increment ladder (each builds through `koruc` and runs)

| File | What it lands |
|------|---------------|
| `a_git_lines.kz` | subprocess as a koru effect — `git` output streamed as `! line` |
| `b_git_store.kz` | subprocess → owned-string store → reactive query prints each row |
| `c_gitgazer.kz`  | full TUI: subprocess → store → vaxis paint, `q` to quit |

## Build & run

```
koruc run a_git_lines.kz          # prints each git-status line + count
koruc run b_git_store.kz          # inserts each line as a store row, query prints it
koruc run c_gitgazer.kz           # the TUI — needs a real terminal (q quits)
```

`koruc` = `/Users/larsde/src/koru/zig-out/bin/koruc`. Wiring: `koru.json` maps
`koru`/`libs` → `../../koru-libs` (so `import koru/vaxis` resolves; `std/*` is
built in). Packages exercised: `koru/vaxis`, plus `std/store`, `std/string`,
`std/fmt`, `std/io`.

`c_gitgazer` was verified rendering under an 80x24 pseudo-tty: the header and all
four `git status` rows paint from the live subprocess.

## The wall it reached (holes surfaced)

- **`holes/1_store_no_ondemand_iteration`** — `std/store:query` is a
  top-level-only comptime transform; nested in a handler/loop body it fails with
  "unknown store" (misleading — the store IS declared). So a plural store's rows
  cannot be iterated on demand, and a retained-mode renderer (vaxis, repaint on
  every `! draw`/resize) cannot repaint retained rows on a non-mutating event
  (selection highlight, resize, refresh). `c_gitgazer` renders the initial status
  only by re-running the inserts inside `! draw`. This is the store↔vaxis wall.
- **`holes/2_no_std_process`** — no `std/process`/`exec`/`subprocess` module
  exists; every consumer reinvents `std.process.Child.run` in raw Zig, stepping
  onto the already-pinned `term.Exited` panic (400_141) that `git` triggers on a
  nonzero+stderr exit. This app dodges it with the safe term-check idiom.

Both are floated (repro + `HOLE.md`), not fixed and not routed around.
