# chal-web-httpprobe

An HTTP JSON **probe**: fetch real endpoints over the wire, parse the responses,
accumulate results in a reactive store, and render a dashboard. Built for the
APP_CHALLENGE **network + parsing** region.

## What it demonstrates (the pristine, landed slice)

Four toolchain organs interoperating, all through the real `koruc`:

| File | Organs | What it shows |
|------|--------|---------------|
| `httpc.kz` | libcurl FFI + phantom obligation | A fresh, current-idiom HTTP GET binding: real `curl_easy_perform` over the wire, a `*Response<open!>` obligation the compiler forces you to discharge via `close`. |
| `step1_real_get.kz` | network | A real GET → `status 200`, bytes fetched, obligation discharged. |
| `step2_get_parse.kz` | network → parse | Feeds the live `r.body` (`[]u8`) straight into `std/json:get.string` (`json: string`) — the network→parse **type boundary holds**. (The parse itself surfaces hole 4.) |
| `step3_stream_parse.k` | network + streaming parse | `std/string:split` as an effect-stream (`! piece` / `| done`) tokenizes the live body line-by-line, whitespace-tolerant, obligation discharged in `done`. |
| `httpprobe.k` | **network + reactive state + render** | Probes 3 endpoints (200/404/500); each `insert` fires an `! inserted` interceptor that bumps a singleton counter via `stored`; a `watch` on the singleton prints reactively; a final `query` renders the dashboard. |

### Real output — `koruc run httpprobe.k`
```
  [reactive] probes recorded so far: 1
  [reactive] probes recorded so far: 2
  [reactive] probes recorded so far: 3
=== probe dashboard ===
  status 200  (222 bytes)
  status 404  (0 bytes)
  status 500  (0 bytes)
```

The chain that worked hardest: the **store reactive write path**
(`insert → inserted interceptor → stored → watch`, grounded in koru regression
690_016) fused with a **cross-module `open!` obligation** threaded out of the
libcurl binding and discharged inside each probe's `row` branch.

## Build / run

Needs `libcurl` (macOS: `brew install curl`) and network access to `httpbin.org`.
`koru.json` maps the `koru` alias to the koru-libs root; the app's own sources
resolve under the built-in `app` alias.

```bash
KORUC=/Users/larsde/src/koru/zig-out/bin/koruc
$KORUC run httpprobe.k          # the reactive dashboard
$KORUC run step1_real_get.kz    # a single real GET
$KORUC run step3_stream_parse.k # streaming parse of a live body
```

## Packages / surfaces exercised

- **A fresh libcurl binding** (`httpc.kz`) — real network. Authored in-app rather
  than consumed from `koru-libs/curl` because that package no longer compiles
  against the current `koruc` (see hole 1); the binding differs from curl's only
  by the `string` payload type the compiler's diagnostic prescribes, so it also
  proves curl's fix.
- **`std/store`** — container + singleton stores, `inserted` lifecycle interceptor,
  `stored` reactive write, `watch`, `query`.
- **`std/string:split`** — effect-stream parser over a raw byte slice.
- **`std/json`** — flat `get.string` (surfaced hole 4).
- **`std/io`** — `print.ln` / `print.blk` with `{{ }}` interpolation.

## Holes surfaced (floated + pinned in `holes/`, not fixed, not routed around)

The whole off-the-shelf network surface of this region is down against current
`koruc` — that map is the primary deliverable:

1. **`holes/1_curl_payload_stale`** — `koru/curl` fails to compile: `[]const u8`
   event payloads rejected by PARSE003 (compiler now demands `string`). Package
   staleness with an *excellent* diagnostic — not a compiler defect, but a
   published "working" package that is red against HEAD.
2. **`holes/2_stdhttp_variant_zig_leak`** — `std/http:http.parse-request` emits
   non-compiling Zig (scalar `| invalid string` variant vs. record `.{ .msg }`
   return; plus an unused `allocator`). A raw-host leak with no koru-level wall.
   std/http has zero consumers in the regression suite.
3. **`holes/3_store_insert_usize_i64_leak`** — inserting a runtime `usize` (e.g.
   any slice `.len`) into an `i64` store column leaks a raw Zig width error. The
   store guards column *types* with a great koru-level message but not insert
   *value* width.
4. **`holes/4_stdjson_whitespace_naive`** — `std/json:get.string` searches
   `"key":"` (no space) and so fails on every pretty-printed real API response.
   A std robustness gap (`get.int` tolerates whitespace; `get.string` doesn't).

Each hole is a runnable repro + a `HOLE.md` (exact error, expected-vs-actual,
confidence, and whether it's a compiler defect vs. package/std staleness).
