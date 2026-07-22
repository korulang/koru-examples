# HOLE 3 — store insert: `usize` value into i64 column leaks raw Zig (no koru wall)

## Exact error (from the real app, httpprobe.k, before the workaround)
```
output_emitted.zig:56:116: error: expected type 'i64', found 'usize'
    const result_1 = main_module.__store_inserth_probes_event.handler(
        .{ .status = r.status, .bytes = r.body.len, .__site_line = 29 });
                              ^~~~~~~~~~ (r.body.len is usize)
output_emitted.zig:56:116: note: signed 64-bit int cannot represent all possible unsigned 64-bit values
```

## Expected vs actual
- Expected: a koru-level diagnostic at the store-insert boundary (the store ALREADY
  emits a great koru-level message for illegal column *types*), or an accepted coercion.
- Actual: the `usize` insert value leaks straight to Zig as a width error.

## The sharp contrast that makes this a real gap
The store DOES build a koru-level wall for column TYPES. Declaring a `usize` COLUMN
gives an exemplary pit-of-success message:
```
std/store:new(probes): field 'bytes' is usize — columns are scalars (i64/i32/f64/f32),
fixed-char (char[N], 690_052), or owned strings (...); vec/mat tiers are pinned at 690_020
```
But the INSERT-VALUE side has no matching guard: a `usize` expression (e.g. any
slice `.len`) into an i64 column bypasses the koru layer and fails only in Zig.
`i32 -> i64` coerces fine (the `status: r.status` field did not error); only the
unsigned-to-signed width leaks. Since `.len` is `usize` and ubiquitous, this
boundary is hit constantly.

## Confidence
HIGH the leak reproduces (hit organically building the app; isolated here).
MEDIUM that the "right" behavior is a koru diagnostic vs. a silent coercion — that's
a design call for the walk. Floating, not asserting. Workaround used in the app is
NOT a route-around of the compiler: the httpc binding exposes an `i64 size` field on
its own Response surface, so the stored value is genuinely i64 (no cast dodging a gap).
