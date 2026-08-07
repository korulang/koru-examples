# HOLE 1 — koru-libs/curl does not compile against current koruc (`[]const u8` payload)

## Exact error
```
error[PARSE003]: '[]const u8' is not a Koru event-payload type. Use 'string' for text — it lowers to []const u8 for Zig
  --> /Users/larsde/src/koru-libs/curl/index.kz:73:1
    |
 73 | | ok *Response<open!>
    | ^
```
(three occurrences — the `get`, `post`, and `post.with-headers` events; each has `url: []const u8` / `headers: []const Header` payload params.)

## Expected vs actual
- Expected: `koru/curl:get(...)` compiles and performs a real HTTP GET.
- Actual: frontend PARSE003; the published package never reaches codegen.

## Diagnosis
Package staleness, NOT a compiler defect. The compiler's diagnostic is exemplary
(points at the exact line, names the fix). The `koru/curl` package predates the
`string`-canonical payload rule and was never migrated. The whole documented
network path (`get`/`post`/`post.with-headers`) is dead until the payloads are
migrated `[]const u8` -> `string`.

## Confidence
HIGH that this is real (reproduced under `--check`, error is inside the package,
not my app). The *classification* is package-staleness rather than a compiler bug:
the compiler is doing the right thing with a great message. The finding is that a
published, README-"working" koru-libs package is red against HEAD — exactly the
outside-in class of bug koru-examples exists to catch.

## Proof of the fix shape
`../../httpc.kz` in this app is a fresh, minimal libcurl GET binding identical in
spirit to curl's, differing only by `url: string` instead of `url: []const u8`.
It compiles and performs a real GET (see app README) — demonstrating the curl fix
is exactly the payload-type migration the diagnostic names.

## CLOSED 2026-08-07 — the migration landed, and this file could not see it
`koru/curl` took the payload migration this hole asked for. Every `tor` in
`koru-libs/curl/index.kz` now declares `string` (`:72`, `:130`, `:195`, `:377`,
and the rest); the four surviving `[]const u8` are Zig struct fields (`:44`,
`:191-192`, `:350`), which is the legal position. `koruc --check input.k` passes.

This entry claimed HIGH confidence in a live failure for longer than the failure
existed. `input.k` was the corpus's only pure-Koru file carrying a leading `~`,
so once the tilde wall landed (`koru/src/parser.zig:854-865`) the repro died at
its own line 9 with a PARSE003 about the tilde — the same diagnostic *code* the
hole was pinning, from a different cause, at a line inside this file rather than
inside the package. Re-running it re-confirmed "PARSE003, still broken" and the
subject was never reached.

The guard is now `input.k` itself: it is the only consumer in this repo that
compiles `koru/curl`'s documented GET path end to end, so a payload regression
takes it red again — for the right reason this time.
