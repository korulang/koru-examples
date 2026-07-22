// HOLE 1 repro — consuming koru-libs/curl fails to compile against current koruc.
// The published package declares event payloads as `[]const u8`; the compiler now
// rejects that in favor of `string`. Blocks the entire documented GET/POST path.
//
// Build (from an app dir with koru.json mapping "koru" -> koru-libs root):
//   koruc --check input.k
// Expected-vs-actual: expected a compiled GET; actual PARSE003 inside curl/index.kz.

~import koru/curl
~import std/io

~koru/curl:get(url: "https://httpbin.org/get")
| ok r |> std/io:print.ln("status {{ r.status:d }}")
| err e |> std/io:print.ln("err {{ e.msg:s }}")
