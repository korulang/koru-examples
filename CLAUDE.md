# koru-examples — read this before you touch anything

**These apps are the OUTSIDE-IN showcase of the koru ecosystem.** Each one is a
real, idiomatic program built the way a *user* builds it — consuming the koru
toolchain (`/Users/larsde/src/koru`) and the `koru-libs` packages
(`/Users/larsde/src/koru-libs`: `std/store`, `vaxis`, `sqlite3`, `curl`, …)
through their public surfaces, with the app's own build wiring.

## The charter (what makes this repo different)

`koru-libs` packages are **instruments** — they exist to surface compiler gaps;
their internals don't matter. The apps here are **showcases** — they exist to
demonstrate how to write koru *well*, and to test the toolchain **as it is
actually consumed**.

That second job is the load-bearing one. koru's regression suite tests the
compiler from the **inside** (`koruc` on in-tree test files). These apps test it
from the **outside** — import resolution, package/build integration, the
published-API ergonomics a real user hits first. That is a whole class of bug the
in-tree suite cannot reach. **When an app is awkward to build or express, that
awkwardness IS a finding** — write it down, don't paper over it.

## The one law, inherited whole (non-negotiable)

**The koru compiler is the product. When you hit a compiler / toolchain / codegen
gap building an app here: FIX THE TOOLCHAIN. NEVER route around it in the app.**

- Renaming a binding, adding a wrapper, a scope hack, a qualified import, "just
  avoid that shape" — any change to the *app* to dodge a toolchain limitation is
  the banned route-around, even when it compiles. A precedent elsewhere does not
  sanction it.
- A green app earned by dodging the gap is a **lie** about the toolchain the app
  exists to exercise — worth less than the honest red.
- On finding a suspected gap, assume ~50% chance it's your own misunderstanding.
  **Float it — don't route around it and don't solo-fix it.** Surface → decide
  with Lars → fix in koru (`/Users/larsde/src/koru`), pin the regression first.
- The APP still ships (build the real artifact, through the real toolchain). "I
  can't express this yet" → the toolchain gap is the deliverable, named plainly.

## Where the truth lives

- Language ground truth: the koru test suite
  (`/Users/larsde/src/koru/tests/regression`) — never synthesize koru syntax from
  analogy; read a passing test or label it a guess.
- The compiler: `/Users/larsde/src/koru` (`zig build` → `zig-out/bin/koruc`).
- The packages: `/Users/larsde/src/koru-libs`.
- Cross-session work reconciles through **git on the shared repos** — verify on
  the merged tree before publishing (the optimistic-parallel discipline).
