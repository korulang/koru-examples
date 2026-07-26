// The table widget owns its own state.
//
// The store is declared beside the keys that mutate it. The entry file still
// READS these cells to paint the exhibit — a cross-module cell read, which
// lowers into this module's namespace.
import std/store

std/store:new(table) { selected: 0[i64], count: 20[i64] }

pub tor table-keys { ch: u8 }
table-keys = cond(ch)
| c x when x == 'j' and table.selected < table.count - 1 |> std/store:stored { table.selected: table.selected + 1 }
| c x when x == 'k' and table.selected > 0 |> std/store:stored { table.selected: table.selected - 1 }
| c x when x == 'g' and table.selected > 0 |> std/store:stored { table.selected: 0 }
| c x when x == 'G' and table.selected < table.count - 1 |> std/store:stored { table.selected: table.count - 1 }
| c _ |> _
