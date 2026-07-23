# todo — koru-examples flagship

The first *real app*: store-backed reactive TUI. State in `std/store`, paint
via vaxis components (`Dock`, row components), `sweep` as the render read.
Showcase charter: awkwardness is a toolchain finding — fix koru, never dodge
in the app (`../CLAUDE.md`).

## Surfaces

| File | Role |
|------|------|
| `todo_store.k` | Data half — owned-column CRUD + `! inserted` / `! removed` |
| `todo_tui.k` | Convergence — Dock chrome + `sweep` → `todo-row` under `! draw` |

Run either with `koruc run <file>` from this directory (see `koru.json` paths).

## The loop (intent, not status)

```
store write → interceptor / key damage → ! draw → sweep(store) → paint
```

`sweep` reads live rows for a full repaint; interceptors and the key→redraw
path in `vaxis:run` are the damage signal. They are not competitors.
