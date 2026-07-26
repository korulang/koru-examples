// The help widget owns its own state.
//
// The store is declared beside the keys that mutate it. The entry file still
// READS these cells to paint the exhibit — a cross-module cell read, which
// lowers into this module's namespace.
import std/store

std/store:new(help) { show: 0[i64] }

pub tor help-keys { ch: u8 }
help-keys = cond(ch)
| c x when x == '?' and help.show == 0 |> std/store:stored { help.show: 1 }
| c x when x == '?' and help.show == 1 |> std/store:stored { help.show: 0 }
| c _ |> _
