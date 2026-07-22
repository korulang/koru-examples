# HOLE 2 — `//` inside a string arg is mis-lexed as a comment by the invocation-arg paren-balancer (continuation position)

## What
A call in **continuation position** (`| branch |> path:event(...)`) whose string
argument contains `//` **and** parentheses is rejected with a false
"unbalanced parentheses" error. The `//` — legal string data (a URL, a filesystem
path, a literal comment marker) — is treated as a line-comment start by the
paren-balancer that validates invocation arguments, so it stops counting at `//`
and never sees the closing `)`.

## Repro (pure stdlib, self-contained — `input.kz`)
```koru
~import std/io
~import std/string
~std/string:from-page(text: "hi")
| ok s |> std/io:print.ln("(a//b)")
| err _ |> _
```
```
/Users/larsde/src/koru/zig-out/bin/koruc --check input.kz
```

## Expected vs actual
- Expected: shape-checks. `"(a//b)"` is ordinary string data.
- Actual:
```
error[PARSE003]: unbalanced parentheses in invocation arguments
  --> input.kz:15:1
```

## Minimization / bisection (all run this session)
- `("(a:b)")`  (colon, no slashes) in the same spot -> **passes**. Isolates `//`.
- `("(a//b)")` with **no** parens in the string -> **passes**. The bug needs BOTH
  a `//` and a `(` in the same string arg (the balancer only counts when a paren
  is open).
- Top-level `~std/io:print.ln("(a//b)")` (NOT in a continuation) -> **passes**.
  Also `~print.ln("(a//b)") |> print.ln("(c)")` -> **passes**. The faulty
  balancer path runs only for calls parsed in **continuation** position
  (`| branch |> ...`), not for top-level `~`-invocations.
- `/* ... */` block-comment markers inside the string do NOT trip it — only `//`.

## Diagnosis
The continuation-position invocation-argument parser has a paren-balance
pre-scan that strips `//` line-comments **without respecting string-literal
boundaries**. A `//` inside a `"..."` literal must be treated as data, not a
comment. The top-level invocation parser handles this correctly, so the two
paths disagree — a good sign the fix is localized to the continuation
arg-scanner's comment handling.

## Confidence
Real compiler bug: HIGH. `//` in a string literal is unambiguously data; the
top-level path already accepts it; only the continuation path fails, and only
when a paren is also present. This is not plausibly my misunderstanding — it is
a lexer-context bug in one of two parallel parse paths.

## Impact on this app (named, not routed around)
A bookmark store's natural data is `https://...` URLs. Any INSERT of a full-scheme
URL — `INSERT ... VALUES ('https://korulang.org', ...)` — combines the SQL
`VALUES (...)` parens with the URL's `//` in one string arg in a continuation,
so it hits this hole. `shelf.kz` therefore stores bare hosts (`korulang.org`)
today and says so at the call site; `shelf_full_urls.kz` in this dir is the
scheme-URL variant that demonstrably fails, kept as an app-level repro. The app
is NOT rewritten to a non-idiomatic shape to dodge the bug — the gap is named.
