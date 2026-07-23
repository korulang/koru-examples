# todo — koru-examples flagship

The first *real app*: store-backed reactive TUI. State in `std/store`, paint
via vaxis components (`Dock`, row components), `sweep` as the render read,
live `stack` / `stack-row` for store-driven row windows (children never pass
`y:`). Showcase charter: awkwardness is a toolchain finding — fix koru, never
dodge in the app (`../CLAUDE.md`).

## Surfaces

| File | Role |
|------|------|
| `todo_store.k` | Data half — owned-column CRUD + `! inserted` / `! removed` |
| `todo_tui.k` | Convergence — Dock chrome + live stack + `sweep` → `todo-row` |

Run either with `koruc run <file>` from this directory (see `koru.json` paths).

## The loop (intent, not status)

```
store write → interceptor / key damage → ! draw → stack(body) → sweep → stack-row → paint
```

`stack` / `stack-row` are the draw-time twin of markup `<StackPanel>`: the
container owns y; `sweep` only supplies row data. Static StackPanel remains
for fixed children (`koru-libs/examples/component_stack.k`).
