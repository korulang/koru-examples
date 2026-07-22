# HOLE 1 — koru-libs/sqlite3 public surface is stale; unbuildable against current koruc

## What
The committed `koru-libs/sqlite3/index.kz` declares its public event payloads with
raw Zig `[]const u8`, e.g.:

```koru
~pub event open { path: []const u8 }
| db *Connection<opened!>
| err { code: i32, msg: []const u8 }
```

The current `koruc` binary (`/Users/larsde/src/koru/zig-out/bin/koruc`, dated
2026-07-22 07:37) rejects `[]const u8` in koru type positions (payload fields,
branch payloads, `-> ` return types).

## Repro
`input.kz` here is the package's own `basic.kz` (open+close on `:memory:`), the
simplest possible consumer.

```
/Users/larsde/src/koru/zig-out/bin/koruc run input.kz
```
(with a koru.json aliasing `libs` -> the koru-libs root)

## Expected vs actual
- Expected (per README / toolchain skill, which recorded `koruc run
  sqlite3/tests/basic.kz` -> "Opened and closed!" on 2026-07-02): the package
  builds and a consumer can open/close a DB.
- Actual: parse fails before any consumer code is reached —

```
error[PARSE003]: '[]const u8' is not a Koru event-payload type.
Use 'string' for text — it lowers to []const u8 for Zig
  --> /Users/larsde/src/koru-libs/sqlite3/index.kz:44:1
```
...repeated for index.kz:44, 76, 93, 162, 563, 583, 611.

## Diagnosis
Package drift, NOT a compiler bug. Between 2026-07-02 and 2026-07-22 the compiler
tightened: koru type positions must use `string`, not raw Zig `[]const u8`. This
is intentional, tested behavior (PARSE003 family; cf. koru
`tests/regression/200_COMPILER_FEATURES/210_PARSER/210_061_reject_zig_struct_syntax`),
and the error message is a good pit-of-success wall. The `sqlite3` package's
hand-written public surface simply predates the rule and was never migrated.

## Confidence
- That the compiler is RIGHT (not a bug): HIGH. The `string` rule is grounded in
  passing koru tests; `string` lowers to `[]const u8` for Zig anyway.
- That this is a REAL WALL blocking the whole persistence+query region for an
  outside-in consumer: HIGH — it is the first line every `~import libs/sqlite3`
  hits.

## Why it matters (outside-in class)
koru's in-tree regression suite compiles `koruc` on in-tree files and never
imports `koru-libs/sqlite3`, so it cannot catch this. A real user's very first
step (`~import libs/sqlite3`) is a hard stop. This is precisely the
published-API-drift class the koru-examples charter exists to surface.

## Not routed around in the app
I did not, and cannot, edit the committed package. To reach the *deeper* sqlite3
organs (the `! row` effect-branch inliner, `col.*` row-borrows, the `~query{{}}`
comptime transform) I vendored a payload-migrated copy of the binding INTO this
app dir (`shelf_sqlite.kz`) — following the compiler's own `string` instruction
verbatim, grounded in koru tests. That is conformance to a compiler requirement,
not a dodge of a compiler limitation. The migration itself is the fix this hole
names; the vendored copy is transparent and flagged, never a hidden hack.
