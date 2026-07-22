# HOLE 3 — sqlite3 error `msg: string` is a borrow into freed/foreign memory, and koru cannot protect it

## What
Every error branch in the sqlite3 binding returns `msg: string` — but the string
points into memory the binding either frees immediately or that sqlite owns and
invalidates on the next call / on `close`. Because `msg` is typed as a plain
koru `string` (not a phantom-scoped borrow like `col.text`'s `<row>` and not an
owned copy), consumers freely read-after-free with **zero compiler diagnostic**.

Two concrete escapes, both in committed `koru-libs/sqlite3/index.kz` (and the
faithful vendored `shelf_sqlite.kz`):

1. `exec` (index.kz:79-88) — **immediate use-after-free**:
```zig
const msg = if (errmsg) |e| std.mem.span(e) else "unknown error"; // slice into e
if (errmsg) |e| c.sqlite3_free(e);                                // e is freed
return .{ .err = .{ .code = rc, .msg = msg } };                   // msg now dangles
```

2. `query.literal` / `open` — `msg = std.mem.span(sqlite3_errmsg(conn.handle))`
   is valid only until the connection is closed or the next sqlite call, yet the
   `| err` branch hands it back with no obligation, so a consumer that writes
   `| err e |> close(e.conn) |> print.ln("{{ e.msg:s }}")` (close BEFORE reading)
   reads freed memory.

## Repro (this dir: `input.kz` == `shelf.kz` with a duplicate-host insert)
Run `shelf.kz`. Its duplicate-URL insert hits `exec`'s err branch. Observed:
```
shelf: rejected duplicate host as expected -> x
```
The real sqlite message is `UNIQUE constraint failed: bookmarks.host`; instead we
print `x` + trailing garbage — the dangling slice read after `sqlite3_free`. The
CONTROL FLOW is correct (the insert is correctly rejected and routed to `| err`);
only the borrowed `msg` payload is corrupt. Confirmed this session: `sqlite3
shelf.db 'SELECT ...'` shows exactly 3 rows, so the duplicate was rejected — the
error text is the only casualty.

## Expected vs actual
- Expected: `-> UNIQUE constraint failed: bookmarks.host`
- Actual:   `-> x` (freed-buffer garbage)

## Diagnosis
The koru type `string` on an event payload gives NO lifetime/ownership
information, so a `string` synthesized from freed or foreign memory inside a Zig
`~proc` body escapes the proc as a plain value. Koru's phantom borrow-checker
governs koru-level obligations but does not — cannot, today — reach into a
`|zig` proc body to see the `sqlite3_free`/`sqlite3_close` that invalidates the
slice. So there is no wall where a real one is needed. The library's own
`col.text` comment already anticipates the OWNED-copy fix ("Pristine-later: hand
back an owned copy"); the same fix is owed to `err.msg`. The deeper toolchain
question: should a `string` returned from a Zig proc be forbidden unless it is
owned or carries an explicit borrow-scope phantom, so this class of escape is
caught at the boundary?

## Confidence
- That `exec`'s err path is a genuine use-after-free: HIGH (freed then returned;
  the garbage output confirms it at runtime).
- That this is a COMPILER hole vs a library bug: MEDIUM-LOW, and I flag it as
  "might be me / might be by-design." It is primarily a library correctness bug
  (the wrapper should copy or scope the message). Its toolchain-relevant half —
  "koru offers no way to mark/enforce that a Zig-proc-returned `string` is a
  scoped borrow, so this escape is invisible" — is a real boundary limitation
  worth a design call, not a definite bug.

## Not routed around
The vendored `shelf_sqlite.kz` keeps `exec` byte-faithful to the committed
package (only payload TYPES were migrated per HOLE 1). I did NOT silently fix the
free so the demo would look clean — the corrupt `x` in the output is honest
evidence of the escape. Fixing it (own the copy, or add a borrow phantom) is a
decision for the walk.
