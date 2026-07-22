# HOLE 2 — std/http:http.parse-request emits Zig that fails to compile (raw-host leak)

## Exact error
```
Error: output_emitted.zig:94:27: error: unused local constant
                    const allocator = koru_allocator();
                          ^~~~~~~~~
output_emitted.zig:98:59: error: type '[]const u8' does not support struct initialization syntax
                        return .{ .@"invalid" = .{ .msg = "No request line found" } };
                                                          ^~~~~~~~~~~~~~~~~~~~~~~
```
Frontend + analysis pass; failure is in stage D (`zig build` of the emitted output).

## Expected vs actual
- Expected: either a working parse, OR a koru-level diagnostic at the module boundary.
- Actual: two raw Zig errors leak straight to the user — no koru-level wall.

## Diagnosis
`koru_std/http.kz` declares `| invalid string` (a *scalar* string variant) but its
`~proc ...|zig` body constructs it as a *record*: `.{ .invalid = .{ .msg = ... } }`.
The emitter lowers the scalar variant payload to `[]const u8`, then the proc body's
`.{ .msg = ... }` struct-init doesn't fit a `[]const u8` — hence the leak. Secondly,
`const allocator = koru_allocator();` is unused on the no-request-line path, which
Zig treats as a hard error. std/http has NO regression test consuming it (grep of
tests/regression for `std/http:` is empty), so it is untested against the current
compiler + Zig 0.15 and has drifted.

Two distinct toolchain observations:
1. A variant-shape mismatch (scalar `| invalid string` vs record `.{ .msg }` return)
   is caught only by raw Zig, not by a koru-level check — the pit-of-success wall
   the CLAUDE.md doctrine calls for isn't built at this boundary.
2. std/http.kz is stale (unused-const, older `std.ArrayList(u8).init`/`std.mem.tokenize`
   idioms elsewhere in the same file) and unexercised.

## Confidence
HIGH that the raw-Zig leak reproduces. MEDIUM on the precise root: the scalar-vs-record
variant construction convention is the likely culprit, but I did not read the emitter
site that lowers scalar variant payloads — floating rather than asserting the fix.
