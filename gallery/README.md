# gallery — sit and look

The eyes for `koru-libs` COMPONENT_CHALLENGE polish. Page through catalog
exhibits in a real TTY instead of compiling probes into the void.

```bash
cd gallery && koruc run gallery.k
```

| Key | Action |
|-----|--------|
| `n` / `p` | next / prev exhibit |
| `space` | poke (progress +10, wraps at 100) |
| `q` | quit |

## Exhibits (grows with the Charm queue)

| Page | What you see |
|------|----------------|
| **progress** | Charm-class `<progress-bar/>` — ▌/░, purple→pink blend, `%` |
| **spinner** | Charm MiniDot `<spinner/>` — braille cycle, purple, `! tick` |
| **style** | `Style` fg/bg swatches + UTF-8 meter runes |

New Charm widgets land here when they clear the taste-gate.
