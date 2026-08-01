// httpprobe — probe real HTTP endpoints, accumulate results in a reactive store,
// render a dashboard.
//
// Composes four organs at once:
//   - httpc         real libcurl network (GET over the wire, `open!` obligation)
//   - std/store     reactive state: a container of probe rows + a singleton
//                   counter kept live by an `inserted` lifecycle interceptor
//   - std/store     watch on the singleton -> reactive output as each probe lands
//   - std/io        dashboard render via query
//
// Pure-koru entry (.k) so the store's comptime transform runs; it imports the
// zig-backed httpc.kz binding as a sibling module. Each GET's `open!` obligation
// is discharged inside its own branch (auto-checked by the compiler).
//
// Reactive pattern grounded in koru regression 690_016 (inserted -> stored ->
// watch). Network binding grounded in koru-libs/curl's GET proc.

import app/httpc
import std/store
import std/io

// Live count of probes recorded so far (singleton store).
std/store:new(stats) { recorded: 0[i64] }

// The probe table. Each `inserted` row bumps the singleton counter — the
// reactive write path: insert -> interceptor -> stored -> watch.
std/store:new(probes, capacity: 8) { status: i64, bytes: i64 }
! inserted _ |> std/store:stored { stats.recorded: stats.recorded + 1 }

// Watch fires reactively every time the counter changes.
std/store:watch(stats)
! recorded n |> std/io:print.ln("  [reactive] probes recorded so far: {{ n:d }}")

// Probe 1 — a healthy JSON endpoint.
app/httpc:get(url: "https://httpbin.org/get")
| ok r |> std/store:insert(probes) { status: r.status, bytes: r.size }
    | row _ |> app/httpc:close(resp: r)
| err e |> std/io:print.ln("probe1 transport error: {{ e.msg:s }}")

// Probe 2 — a 404 (transport still succeeds; the status carries the code).
app/httpc:get(url: "https://httpbin.org/status/404")
| ok r |> std/store:insert(probes) { status: r.status, bytes: r.size }
    | row _ |> app/httpc:close(resp: r)
| err e |> std/io:print.ln("probe2 transport error: {{ e.msg:s }}")

// Probe 3 — a 500.
app/httpc:get(url: "https://httpbin.org/status/500")
| ok r |> std/store:insert(probes) { status: r.status, bytes: r.size }
    | row _ |> app/httpc:close(resp: r)
| err e |> std/io:print.ln("probe3 transport error: {{ e.msg:s }}")

// Render the accumulated dashboard from the store.
std/io:print.ln("=== probe dashboard ===")
std/store:query(probes)
! query e |> std/io:print.ln("  status {{ e.status:d }}  ({{ e.bytes:d }} bytes)")
