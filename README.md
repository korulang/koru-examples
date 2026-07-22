# koru-examples

Involved, idiomatic, **best-practices** applications built with koru and its
extended ecosystem — the reactive to-do TUI, web apps for Orisha, and other
real programs that show how to *write koru well*.

## What this repo is (and is not)

This is the **outside-in** showcase. Every app here is built the way a **user**
builds one: consuming the koru toolchain and the `koru-libs` packages
(`std/store`, `vaxis`, `sqlite3`, `curl`, …) through their public surfaces, with
their own build wiring — not from inside koru's test harness.

- **`koru-libs` packages are instruments** — they exist to exercise the compiler
  and surface its gaps. Their internals are nothing; the toolchain is everything.
- **`koru-examples` apps are showcases** — they exist to demonstrate the good,
  idiomatic way to build a real program, and to test the toolchain the way it's
  actually consumed.

The distinction matters because the two shake different bugs loose. koru's
regression suite tests the compiler from the **inside** (`koruc` on in-tree test
files). These apps test it from the **outside** — packaging, imports, build
integration, published-API ergonomics — a whole class of bug the in-tree suite
structurally cannot reach.

## Layout

One directory per app. Each is self-contained with its own build wiring and a
short README stating what it demonstrates and which packages it exercises.

- `todo/` — the flagship: a reactive to-do TUI over `std/store` + `vaxis`
  (store owns the state, watch/removed fuse reactivity into the write path, vaxis
  renders). Lands when the store and vaxis threads converge.

(More apps as they're built.)
