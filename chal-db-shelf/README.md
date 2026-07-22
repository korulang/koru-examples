# shelf — a file-backed sqlite3 bookmark store (APP_CHALLENGE replay)

Region: **persistence + query**. A real, on-disk SQLite tool written the way a
user consumes the koru ecosystem, pushed until the toolchain broke.

## What it is
`shelf.kz` opens an on-disk `shelf.db`, creates a schema with real constraints
(PRIMARY KEY / UNIQUE / NOT NULL), seeds bookmarks, exercises a UNIQUE-constraint
rejection, lists rows via the `! row` effect branch, and reads an aggregate
COUNT — all while threading the connection's `opened!` phantom obligation through
the whole flow to a single `close`.

`bridge.kz` is the aimed-past increment: a **DB → reactive store** bridge. It
iterates sqlite rows and moves each title into a reactive `std/store`
owned-string column, where an `! inserted` lifecycle interceptor reacts per row.

## Build / run
```
koruc run shelf.kz     # => schema, seed, dup-rejection, list, count, close
sqlite3 shelf.db 'SELECT * FROM bookmarks;'   # proves real on-disk persistence
koruc run bridge.kz    # reads shelf.db, mirrors titles into a reactive store
```
`koruc` = `/Users/larsde/src/koru/zig-out/bin/koruc` (do not rebuild it).

## Subsystems / organs exercised (which worked hardest)
- **sqlite3 binding** — open/exec/query.literal/col.int/col.text/close, phantom
  `Connection<opened!>` threading, the `! row` effect-branch **inliner** (`$mod.`
  module-scope spelling), per-row `<row!>` borrow.
- **std/store** — owned-string column, insert write path, `! inserted` reactive
  interceptor (the freshly-landed react-over-owned rung, exercised outside-in).
- **std/string** — ownership transitions (`from-page` copy → `take` → move into
  store).
- **std/io + fmt** — `{{ x:d }}` / `{{ x:s }}` interpolation.
- Hardest chain: the four-machinery nest in `bridge.kz` — sqlite `! row` ⟶
  string ownership ⟶ store insert ⟶ reactive interceptor, all composing.

## Vendored binding — why (see holes/1)
`shelf_sqlite.kz` is a payload-migrated subset of `koru-libs/sqlite3`. The
committed package does not build against the current `koruc` (its event payloads
use raw Zig `[]const u8`, rejected by PARSE003). I cannot edit the committed
package, so I vendored the organs used, applying the ONE migration the compiler's
own error dictates (`[]const u8` → `string`). This is conformance to a compiler
requirement, not a route-around; the drift itself is HOLE 1.

## Holes surfaced (the real deliverable)
1. **`holes/1_sqlite3_payload_drift`** — the committed `koru-libs/sqlite3` is
   stale; `[]const u8` payloads are rejected by current `koruc`. Package
   unbuildable by any outside-in consumer. (compiler-right / package-stale; HIGH)
2. **`holes/2_comment_marker_in_string_arg`** — real parser bug: `//` inside a
   string arg in **continuation** position is mis-lexed as a comment by the
   invocation-arg paren-balancer → false "unbalanced parentheses". Blocks
   `https://` URLs. Pure-stdlib repro. (real compiler bug; HIGH)
3. **`holes/3_errmsg_borrow_escapes_unprotected`** — sqlite `err.msg: string` is
   a borrow into freed/foreign memory (use-after-free in `exec`), invisible to
   koru because it's synthesized in a `|zig` proc. Runtime-confirmed garbage.
   (library bug + real boundary-limitation; MED)
4. **`holes/4_effect_body_binding_escapes_frontend`** — a `! row`-body binding
   referenced in a sibling `| done` branch passes `koruc --check` (false
   positive) but leaks a raw Zig `use of undeclared identifier` at build. Missing
   koru-level scope/borrow wall. (real frontend diagnostic gap; HIGH)

`shelf_full_urls.kz` is the scheme-URL variant of `shelf.kz` that demonstrably
fails at HOLE 2 — kept as the app-level manifestation.
