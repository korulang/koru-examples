// HOLE 3 repro — inserting a RUNTIME `usize` value into an i64 store column
// leaks raw Zig. Uses std/string:len (returns usize) so no network is needed.
// Run:  koruc run input.k
// Expected: a koru-level width diagnostic (the store has an excellent one for
//           column TYPES), or a coercion.
// Actual:  raw Zig "expected type 'i64', found 'usize'" leaks from emitted code.
// Note: a string LITERAL's `.len` is comptime and coerces fine — the leak is
//       specific to a runtime usize, which is what every real payload produces.

import std/string
import std/store
import std/io

std/store:new(sizes, capacity: 4) { bytes: i64 }

std/string:from-page(text: "hello world")
| ok s |> std/string:len(s): n |> std/store:insert(sizes) { bytes: n }
    | row _ |> std/string:free(s)
| err _ |> _

std/store:query(sizes)
! query { entity.bytes } |> std/io:print.ln("{{ bytes:d }}")
