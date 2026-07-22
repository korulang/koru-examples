# APP_CHALLENGE — grow the ecosystem-app catalog, shake the whole chain

This is a **replayable generator**, not a task. You run it from zero, it hands
back one finished app, and it is never used up. The catalog of apps is the
long-running artifact; each app is one slice through it. Every replay must
produce something the catalog does not already contain — **variance is the
single most important measure of success.**

The apps are showcases (how to write koru *well*). But the reason this challenge
exists is the side effect: an involved app, built the way a *user* builds it,
**stresses the koru toolchain across a large slice of the chain at once** —
parse → transform → phantom/obligation checking → emit → codegen → multi-package
build → run — and shakes loose bugs the in-tree regression suite cannot reach.
The app is the instrument; the toolchain is the product.

---

## You are the contestant

You ARE the contestant. Do **not** ask which app to build, which packages to use,
or which direction to take. Read the catalog, pick a slice nobody has taken,
name it, build it, ship it. A replay that pauses to ask has negated its own
design.

## The charge

Build one **involved, idiomatic, runnable** koru application in
`/Users/larsde/src/koru-examples/`, in its own directory, built **through the
real toolchain** (`koruc` + the `koru-libs` packages consumed as a user consumes
them — public surfaces, real build wiring), that **stresses a large slice of the
chain**.

"Large slice" is the ambition bar, and it is non-negotiable — aim HIGH:

- **Compose multiple subsystems**, not one. A single-package probe is too small.
  Reach for apps that thread several organs together — persistence + rendering,
  network + parsing + state, a reactive store + a real I/O source. The more
  organs one app forces to interoperate, the more of the chain it stresses and
  the more boundary bugs fall out.
- **Hit real I/O and real error surfaces** — files, sockets, a database, a
  terminal, a subprocess. Programs that only compute in memory stress the front
  of the chain but never the parts a real app lives or dies on.
- **Exercise the hard language machinery** — obligations/phantom state across
  module boundaries, the store's reactive write path, effect branches, comptime
  transforms composing. If the app never makes the phantom checker or the emitter
  work hard, aim higher.
- **Be a real program a person would actually run**, not a demo of a feature. The
  todo TUI, a web service, a log tailer, a small database explorer, a chat client,
  a build tool, an HTTP API with a persistence layer — things with a point.

## Variance is the metric — diverge from the catalog

Before you build, **read the existing catalog** (`challenges/CATALOG.md` and the
app directories) and bring something it does not have. Diverge on the axes that
matter for chain coverage:

- **Subsystem mix** — a network app if the catalog is DB-heavy; a persistence app
  if it's all rendering; pick the packages the catalog has exercised least.
- **Composition shape** — a pipeline, a reactive loop, a request/response server,
  a long-running daemon, a one-shot tool.
- **Domain** — Orisha web apps, developer tools, data explorers, games, TUIs.

If your app would stress the same slice as an existing one, pick a different
slice. The fleet's job is to *cover the toolchain*, not to converge on the best
todo app.

## Self-ground — never invent

- **Koru syntax ground truth is the test suite**
  (`/Users/larsde/src/koru/tests/regression`). Read a passing test for any
  construct before you use it, or label it a guess. Do not synthesize koru from
  analogy — that is how a replay produces a plausible lie.
- **The packages** live in `/Users/larsde/src/koru-libs` — read their public
  surfaces (events, types) before composing them.
- **The compiler** is `/Users/larsde/src/koru` (`zig build` → `zig-out/bin/koruc`).

## The one law — inherited whole, and it is the point

**When the app hits a compiler / toolchain / codegen gap: FIX THE TOOLCHAIN.
NEVER route around it in the app.**

- Renaming a binding, a wrapper, a scope hack, a qualified import, "just avoid
  that shape" — any change to the *app* to dodge a toolchain limitation is the
  banned route-around, even when it compiles. A precedent elsewhere does not
  sanction it.
- On a suspected gap, assume ~50% chance it's your own misunderstanding.
  **FLOAT it** — write down the exact program that fails, the koru-level error (or
  the raw-host leak, itself a defect), and "this might be me." Pin it as a failing
  koru regression (`tests/regression/...`, MUST_RUN or MUST_FAIL as fits) so it
  lands on the board. Then surface it — do NOT solo-fix the compiler and do NOT
  route around it. The floated, pinned gap **is a first-class deliverable of this
  challenge**, ranked above the app compiling.
- A green app earned by dodging a gap is a lie about the toolchain it exists to
  exercise — worth less than the honest red. Report the awkwardness; it is a
  finding.

## Done-gates — objective, self-checked before you ship

1. **It builds through `koruc`** — no route-around, no hand-edited emission.
2. **It runs and does something real** — not silent, not degenerate, not a stub.
   Show the actual output / behavior.
3. **It's idiomatic** — every non-trivial construct grounded in a real passing
   test; no invented syntax presented as fact.
4. **It stresses a large slice** — names, explicitly, which subsystems/organs it
   forces to interoperate and which parts of the chain it exercised hardest.
5. **Every toolchain gap hit is floated + pinned** — listed with its pin id, or
   an explicit "hit no gaps" (rare for an ambitious app; if you hit none, you
   probably aimed too low).
6. **Self-contained directory + a short README** — what it demonstrates, which
   packages it exercises, how to build/run it, and the gaps it surfaced.

## The taste-gate — Lars

The objective gates make each app releasable by construction. The final call —
"yes, that's a real showcase AND it shook real bugs" — is Lars's, on the walk.
Survivors append to the catalog; the rest evaporate with their worktrees.

## Zero-friction append

One directory per app, self-contained. Adding one costs no integration work:
drop the dir, add a one-line entry to `challenges/CATALOG.md`. The right move
(ship another) is the path of least resistance.
