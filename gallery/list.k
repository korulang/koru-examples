// The list widget owns its own state.
//
// The store is declared beside the keys that mutate it. The entry file still
// READS these cells to paint the exhibit — a cross-module cell read, which
// lowers into this module's namespace.
import std/store

std/store:new(list) { selected: 0[i64], count: 28[i64] }

pub tor list-keys { ch: u8 }
list-keys = cond(ch)
| c x when x == 'j' and list.selected < list.count - 1 |> std/store:stored { list.selected: list.selected + 1 }
| c x when x == 'k' and list.selected > 0 |> std/store:stored { list.selected: list.selected - 1 }
| c _ |> _
