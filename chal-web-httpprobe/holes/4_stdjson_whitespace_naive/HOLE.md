# HOLE 4 — std/json:get.string is whitespace-naive; fails on real pretty-printed JSON

## Observed (against live httpbin.org/get, and the network-free repro here)
`get.string(json: body, key: "url")` returns `not-found` for a body containing
`"url": "https://httpbin.org/get"` (space after the colon). The raw body confirmed
over the wire:
```
  "origin": "84.208.209.168",
  "url": "https://httpbin.org/get"
```

## Root (koru_std/json.kz:179-190)
```zig
const search_key = std.fmt.bufPrint(&search_buf, "\"{s}\":\"", .{key}) catch { ... };
const key_pos = std.mem.indexOf(u8, json, search_key) orelse { return .not_found; };
```
The search string is `"key":"` with NO space between `:` and `"`. Any JSON that
pretty-prints (`"key": "value"`) never matches. `get.int` (json.kz:229-231) *does*
skip whitespace after the colon, so the two accessors are inconsistent.

## Expected vs actual
- Expected: tolerate optional whitespace after `:` (the norm for real APIs).
- Actual: silent `not-found` on any pretty-printed object.

## Diagnosis / confidence
HIGH this is real and reproduces deterministically. Classification: a std-library
robustness gap (correctness on real input), NOT a compiler codegen defect — it
compiles and runs, it just can't parse the JSON the network actually returns. It is
the reason this app parses response bodies with the whitespace-tolerant
`std/string:split` stream (step3) instead of the flat json getters. Lower-severity
than the codegen leaks (holes 2, 3), but it makes std/json unusable against live
APIs, which is squarely this region's concern.
