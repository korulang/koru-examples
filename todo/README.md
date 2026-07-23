# todo — koru-examples flagship

The first *real app*: store-backed reactive TUI. State in `std/store`, paint
via vaxis components — Dock chrome with a live `<StackPanel dock="fill"/>`
(returns a Stack cursor; `sweep` → `stack-row` pushes rows). Showcase charter:
awkwardness is a toolchain finding — fix koru, never dodge in the app
(`../CLAUDE.md`).

## Surfaces

| File | Role |
|------|------|
| `todo_store.k` | Data half — owned-column CRUD + `! inserted` / `! removed` |
| `todo_tui.k` | Convergence — Dock + live StackPanel fill + rename |

Run either with `koruc run <file>` from this directory (see `koru.json` paths).

## The loop (intent, not status)

```
store write → key damage → ! draw → app(): panel → sweep → stack-row → paint
```

`app`'s markup owns chrome + fill region; empty StackPanel-as-fill returns the
live stack cursor. Static StackPanel-in-Dock: `koru-libs/examples/component_dock_stack.k`.
