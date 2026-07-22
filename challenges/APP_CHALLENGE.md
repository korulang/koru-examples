# APP_CHALLENGE — stress the toolchain, grow a pristine corpus

A **replayable generator**, not a task and not a backlog. You run it from zero,
it hands back one increment of pristine koru plus a map of where the toolchain
broke, and it is never used up.

## Purpose — explicit, and it is NOT the app

Read this first, because the app is a **vehicle**, never the goal. This challenge
exists for exactly two things, always:

1. **Stress the toolchain to expose holes.** We reach *deliberately beyond* what
   koru can do today. Where it breaks is the deliverable — a well-characterized,
   pinned hole is worth more than a feature that compiled. Right now we *want* to
   fail often; the failures are the map of what to fix next.
2. **Grow a corpus of pristine koru** — idiomatic, exemplary code that future
   sessions load as **context-candy**: the reference for how koru is *actually*
   written well. This is why every surviving line has to be exemplary.

We are **not building lazygit** or any clone (it exists; we're not chasing it —
even if something like it is an eventual outcome). A real, ambitious app is the
**pretext** — big enough to force many organs of the toolchain to work at once —
and nothing more. The aspiration this whole model serves: that a challenger can
one-shot apps like this in a couple of months. To get there we have to fail our
way through the holes now.

## The two consequences that follow from purpose

**Failure is a valid — often the best — outcome of a replay.** "It builds" is NOT
the gate. A replay succeeds when it yields *pristine code that landed* and/or *a
precise pinned hole where the toolchain stopped you*. Aim high enough that you
hit a wall; then characterize the wall exactly.

**Route-around is doubly banned.** A change to the *app* to dodge a toolchain
limitation — a wrapper, a rename, a scope hack, a qualified import, "just avoid
that shape" — doesn't only lie about the toolchain; it **poisons the corpus**,
teaching the next session the wrong idiom as truth. The clean code that CAN'T be
written yet becomes a pinned hole. Never a hack. A precedent elsewhere does not
sanction it.

---

## You are the contestant

You ARE the contestant. Do not ask which app, which packages, which direction.
Read the catalog, pick a slice nobody has taken, name it, reach past what you
think the toolchain can do, and ship what lands + what broke. A replay that
pauses to ask has negated its own design.

## The charge

Build one **ambitious, idiomatic** increment of a real koru application in
`/Users/larsde/src/koru-examples/`, in its own directory, **through the real
toolchain** (`koruc` + the `koru-libs` packages consumed as a user consumes them),
that forces a **large slice of the chain** to work at once — and pushes it until
something breaks.

The ambition bar is a hole-finder, so aim past comfort:

- **Compose multiple subsystems**, never one — persistence + rendering + network
  + reactive state + subprocess. The more organs forced to interoperate, the more
  boundary holes surface.
- **Hit real I/O and real error surfaces** — files, sockets, a database, a
  terminal, a subprocess.
- **Make the hard machinery work hard** — obligations/phantom state across module
  boundaries, the store's reactive write path, effect branches, comptime
  transforms composing.
- **Reach past today's toolchain.** If everything you tried compiled first try,
  you aimed too low — go further until you find the wall.

Targets are **standing and iterable**, not finishable: a git TUI (vaxis
components over a reactive `std/store`, driving real `git` subprocesses — the
store↔vaxis convergence, aimed high), a DB explorer, an Orisha web service. Each
replay adds one **working, divergent slice** to a target (a diff view, branch
management, a request handler) — the app stays green and iterable between
replays; you never leave it half-wired. The unit of a replay is *the increment
that landed + the holes it hit*, not a finished app.

## Variance is the metric — cover different holes, harvest different idioms

Before building, **read the catalog** (`challenges/CATALOG.md` + the app
directories) and take a slice it doesn't have. Diverge on the axes that matter:
which subsystem mix, which composition shape, which target, which corner of the
language. Contestants deepen a target on *different* organs so they surface
*different* holes and *different* idioms — never converge on one file.

## Self-ground — never invent

- **Koru syntax ground truth is the test suite**
  (`/Users/larsde/src/koru/tests/regression`). Read a passing test before you use
  a construct, or label it a guess. Synthesizing koru from analogy produces a
  plausible lie — and a lie in the corpus is the exact poison purpose (2) forbids.
- **The packages** live in `/Users/larsde/src/koru-libs` — read their public
  surfaces before composing them.
- **The compiler** is `/Users/larsde/src/koru` (`zig build` → `zig-out/bin/koruc`).

## Holes — float and pin, never fix, never route around

On a suspected hole, assume ~50% chance it's your own misunderstanding. **Float
it**: write the exact program that fails, the koru-level error (or the raw-host
leak — itself a defect), and "this might be me." **Pin it as a failing koru
regression** (`/Users/larsde/src/koru/tests/regression/...`, MUST_RUN or
MUST_FAIL as fits) so it lands on the board. Then stop — do **not** solo-fix the
compiler, do **not** route around. The pinned hole is a first-class deliverable,
ranked above the app compiling. We decide which holes to fix on the walk.

## Done-gates — self-checked before you ship

1. **What landed builds through `koruc`** — no route-around, no hand-edited
   emission — and **runs** (show real output). Zero lines of surviving code that
   aren't pristine and grounded.
2. **You reached a wall** — the hole(s) you hit are floated + pinned with ids, or
   an explicit "hit no wall" (which means you aimed too low — say so).
3. **It stresses a large slice** — name which subsystems/organs interoperated and
   which parts of the chain worked hardest.
4. **Self-contained directory + short README** — what it demonstrates, packages
   exercised, how to build/run, and the holes it surfaced.

## The taste-gate — Lars

Objective gates make the surviving code pristine-by-construction and the holes
real-by-construction. The final call — "yes, that's corpus-worthy AND it shook
real holes" — is Lars's, on the walk. Survivors append to the catalog; the rest
evaporate with their worktrees.

## Slow-clock: this brief is re-cut as the toolchain matures

Today's "reach past what it can do" becomes tomorrow's "compiles first try." When
a class of hole is closed, **raise the ask** — re-cut this brief to demand more.
The brief is governed like `SCENE.md`: read-many, write-rarely, deliberate,
logged. Tuning the generator improves every future replay at once.

## Zero-friction append

One directory per app/increment, self-contained. Adding one costs no integration
work: drop the dir, add a one-line entry to `challenges/CATALOG.md`.
