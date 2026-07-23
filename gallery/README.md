# gallery — sit and look

The eyes for `koru-libs` COMPONENT_CHALLENGE polish. Page through catalog
exhibits in a real TTY instead of compiling probes into the void.

```bash
cd gallery && koruc run gallery.k
```

| Key | Action |
|-----|--------|
| `n` / `p` | next / prev exhibit |
| `space` | poke progress (+10, wraps) |
| type / backspace | edit on **text-input** page |
| `q` (or `esc` on text-input) | quit |

## Exhibits

| Page | What you see |
|------|----------------|
| **progress** | `<progress-bar/>` — ▌/░, purple→pink, `%` |
| **spinner** | `<spinner/>` — MiniDot braille, purple, tick |
| **text-input** | `<text-input/>` — prompt, placeholder, blink cursor, scroll |
| **style** | `Style` fg/bg swatches + UTF-8 runes |
