# todo — the reactive to-do TUI  (koru-examples flagship · our north star)

The first *real app*: a reactive terminal to-do list where the state lives in a
`std/store`, reactivity is fused into the store's write path (no runtime
registry, no scan), and vaxis paints it. This is where the **store thread** and
the **vaxis thread** converge.

## What's here — the store half (runnable today)

`todo_store.k` is the **data layer**, built entirely on the owned-column store
rungs landed 2026-07-22 — and it builds + runs through koruc right now:

```
koruc run todo_store.k
  + buy milk          ← ! inserted fires on add
  + write koru        ← ! inserted fires on add
  - write koru        ← ! removed fires on delete
--- list ---
buy milk [1]          ← toggled done, "write koru" removed
```

It exercises the full CRUD over an owned `{ label: *String<instance!>, done: i64 }`
store: **add** (`from-page`→`take`→`insert`), **toggle** (`stored` the scalar
`done`), **delete** (`take` + `free`), **read** (`query`), and — the load-bearing
part — the **reactive feed**: `! inserted` and `! removed` interceptors that fire
from inside the write path.

## The convergence — the render bridge (`sweep` for the read, interceptors for the redraw)

Two primitives compose here; they are **not** competitors (an earlier version of
this file wrongly picked a "projection" and rejected the read verb — that was a
category error, corrected 2026-07-23):

- **`std/store:sweep` — the render READ.** vaxis `! draw` is *full-repaint-on-
  damage* (clear the buffer, repaint the whole retained scene on mount/resize),
  so the renderer needs every live row each draw. `sweep` is the **momentary**
  twin of `query`: "for each live row right now, project, run the body" — a
  runtime read, legal in the nested `! draw` body. `! draw win |> sweep(todos)
  ! sweep { label, done } |> write-at(…)`. (`690_067`, render-bridge session.)
- **The interceptors — the redraw TRIGGER.** `! inserted`/`! removed`/`watch`
  don't feed a paint-list; they signal *something changed, request a redraw*.

`sweep` is a render read, **orthogonal** to the store's no-reconciliation-scan
soul (that soul refuses scanning to compute *what changed* — reactivity is fused
into writes; it does not refuse reading current state to paint it). The full loop:

```
store write → interceptor fires → request redraw → vaxis ! draw → sweep(store) → paint
```

## Division of labor

| Half | Owner | State |
|------|-------|-------|
| store / data + interceptors (`todo_store.k`) | store thread | **done & runnable** |
| `std/store:sweep` (the render read verb) | render-bridge session | in flight (`690_067` RED) |
| render / layout (StackPanel · Dock · `! draw`) | vaxis thread | in progress |
| wiring the loop above | convergence, here | awaits `sweep` |

The store half is complete. The north star lights when `sweep` lands and the
renderer runs the loop above over this store.
