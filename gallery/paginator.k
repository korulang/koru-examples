// The paginator widget owns its own state.
//
// The store is declared beside the keys that mutate it. The entry file still
// READS these cells to paint the exhibit — a cross-module cell read, which
// lowers into this module's namespace.
import std/store

std/store:new(pager) { page: 0[i64], total: 7[i64] }

pub tor paginator-keys { ch: u8 }
paginator-keys = cond(ch)
| c x when x == 'l' and pager.page < pager.total - 1 |> std/store:stored { pager.page: pager.page + 1 }
| c x when x == 'h' and pager.page > 0 |> std/store:stored { pager.page: pager.page - 1 }
| c _ |> _
