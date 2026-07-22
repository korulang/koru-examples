// Step 3 — stream-parse the live response body.
// std/string:split is an effect-stream (`! piece` per piece, `| done` at end)
// that runs directly over r.body ([]u8) with borrowed views — no wrapping. This
// tokenizes real network data line-by-line (whitespace-tolerant, unlike the
// flat std/json getters), and discharges the `open!` obligation in the done arm.
//
// Composes: httpc (network) + std/string:split (streaming parse) + std/io.

import app/httpc
import std/string
import std/io

app/httpc:get(url: "https://httpbin.org/get")
| ok r |> std/string:split(s: r.body, sep: "\n")
    ! piece line |> std/io:print.ln("  | {{ line:s }}")
    | done n |> std/io:print.ln("parsed {{ n:d }} line(s) from the response") |> app/httpc:close(resp: r)
| err e |> std/io:print.ln("transport error: {{ e.msg:s }}")
