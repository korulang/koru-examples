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

## The convergence — the render bridge (option A: write-driven projection)

The renderer does **not** scan the store. It keeps a **projection** — a paint-list
— maintained by the very interceptors above: `! inserted` appends, `! removed`
drops, `stored`/`watch` update. `! draw` reads the projection and paints. This is
the only bridge consistent with the store's soul (reactivity compiled into the
write path, no reconciliation scan — `690_041`, ruling O13). An on-demand "read
all rows" verb was considered and rejected: it's a scan, which the store refuses.

## Division of labor

| Half | Owner | State |
|------|-------|-------|
| store / data (`todo_store.k`) | store thread | **done & runnable** |
| render / layout (StackPanel · Dock · `! draw`) | vaxis thread | in progress |
| the projection bridge (paint-list off the interceptors) | convergence | the seam |

The store half is complete. What remains is the vaxis renderer maintaining its
projection off these interceptors — then the north star is lit.
