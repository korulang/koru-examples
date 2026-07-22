// HOLE 4 repro — std/json:get.string cannot parse real-world (pretty-printed) JSON.
// Run:  koruc run input.k
// Expected: found "https://x".
// Actual:  NOT FOUND — get.string searches for `"key":"` (no space), but every
//          real API (httpbin, GitHub, ...) pretty-prints `"key": "value"` with a
//          space after the colon (exactly what httpbin.org/get returns on the wire).

import std/json
import std/io

std/json:get.string(json: "{ \"url\": \"https://x\" }", key: "url")
| ok u |> std/io:print.ln("found: {{ u:s }}")
| not-found |> std/io:print.ln("NOT FOUND (get.string is whitespace-naive)")
