// The viewport widget owns its own state.
//
// The store is declared beside the keys that mutate it. The entry file still
// READS these cells to paint the exhibit — a cross-module cell read, which
// lowers into this module's namespace.
import std/store

std/store:new(scroll) { y: 0[i64], count: 41[i64] }

pub tor viewport-keys { ch: u8 }
viewport-keys = cond(ch)
| c x when x == 'j' and scroll.y < scroll.count - 1 |> std/store:stored { scroll.y: scroll.y + 1 }
| c x when x == 'k' and scroll.y > 0 |> std/store:stored { scroll.y: scroll.y - 1 }
| c x when x == 'd' and scroll.y < scroll.count - 12 |> std/store:stored { scroll.y: scroll.y + 12 }
| c x when x == 'd' and scroll.y >= scroll.count - 12 and scroll.y < scroll.count - 1 |> std/store:stored { scroll.y: scroll.count - 1 }
| c x when x == 'u' and scroll.y >= 12 |> std/store:stored { scroll.y: scroll.y - 12 }
| c x when x == 'u' and scroll.y > 0 and scroll.y < 12 |> std/store:stored { scroll.y: 0 }
| c x when x == 'g' and scroll.y > 0 |> std/store:stored { scroll.y: 0 }
| c x when x == 'G' and scroll.y < scroll.count - 1 |> std/store:stored { scroll.y: scroll.count - 1 }
| c _ |> _
