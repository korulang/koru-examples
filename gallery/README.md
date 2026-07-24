# gallery — sit and look

The eyes for `koru-libs` COMPONENT_CHALLENGE polish. **You** cast out the bad
stuff — no pre-merge taste gate.

Landing page is an informational `<list/>` of the catalog (j/k only moves the
highlight — it does **not** jump exhibits). `n` / `p` page the tour.

```bash
cd gallery && koruc run gallery.k
```

| Key | Action |
|-----|--------|
| `n` / `p` | next / prev exhibit |
| `j` / `k` | peek on **catalog** / **list** / **table**; line on **viewport** |
| `space` | poke progress (+10, wraps); pause/resume **clocks** |
| `s` / `r` | pause/resume / reset on **clocks** |
| type / backspace | edit on **text-input** / **textarea** |
| enter | newline on **textarea** |
| `d` / `u` / `g` / `G` | viewport half-page / ends; `g`/`G` also **table** |
| `h` / `l` | **paginator**; back / open on **filepicker** |
| `?` | **help** short/full |
| `q` (or `esc` on text-input) | quit |

## Exhibits

| Page | What you see |
|------|----------------|
| **catalog** | informational `<list/>` of every exhibit |
| **progress** | `<progress-bar/>` |
| **spinner** | `<spinner/>` |
| **text-input** | `<text-input/>` |
| **list** | dinner-menu `<list/>` |
| **viewport** | `<viewport/>` |
| **paginator** | `<paginator/>` Dots + Arabic |
| **help** | `<help/>` |
| **table** | `<table/>` |
| **textarea** | `<textarea/>` — multi-line ┃ gutter + blink |
| **clocks** | `<timer/>` + `<stopwatch/>` — countdown + count-up |
| **filepicker** | `<filepicker/>` — path header, `>` pink, purple dirs |
| **style** | Style swatches |
