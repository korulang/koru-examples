# APP_CHALLENGE catalog

Finished apps from `APP_CHALLENGE.md`. Each is a self-contained directory; the
line here names what it demonstrates, which slice of the chain it stresses, and
the toolchain gaps it surfaced (pinned as koru regressions).

The catalog is the long-running artifact; each app is one slice through it.

## Replay 01 — 2026-07-22 (first sweep, four region-steered contestants)

| App | Slice stressed | Packages | Gaps surfaced |
|-----|----------------|----------|---------------|
| `chal-tui-gitgazer` | subprocess + reactive store + TUI render (under pty) | vaxis, std/store | nested `query` top-level-only (koru pin `690_066`); no `std/process` |
| `chal-db-shelf` | on-disk persistence + DB→reactive-store bridge | sqlite3, std/store, std/string | `//`-in-string-arg parser bug; effect-body binding→raw Zig leak; `[]const u8` payload staleness; `err.msg` use-after-free |
| `chal-web-httpprobe` | live HTTP + parse + reactive dashboard + `<open!>` obligation | curl, std/store, std/json | std/http emits non-compiling Zig; `usize`→`i64` insert leak; curl `[]const u8` staleness; std/json whitespace-naive |
| `chal-meta-exprlang` | compile-time DSL: transform → cross-module emit → obligation-through-synthesized-code | (none) | continuation-position transform → raw panic (koru pin `210_158`) |

**Verified on the walk:** all four apps build+run pristine through koruc; nine
holes floated, all reproduced by hand (zero misunderstandings). Two vendored
bindings (`shelf_sqlite.kz`, `httpc.kz`) ruled legit migrations, not
route-arounds — the packages are stale, the compiler is correct.

**Three seams, not eleven bugs:** (A) the nested-transform lowering gap — one
bug in transform-pass/store-discovery/emitter, own clean session; (B) raw-host
leaks — frontend passes, host code fails, no koru diagnostic; (C) stale packages
(`sqlite3`+`curl`, `[]const u8`→`string`). See the replay-01 report artifact.
