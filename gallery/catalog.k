// The catalog widget owns its own state.
//
// The store is declared HERE, beside the keys that mutate it — the shape a
// library keeps private state in. The entry file still READS `catalog.selected`
// to paint the exhibit, which is a cross-module cell read; it lowers to the
// declaring module's namespace rather than being refused.
import std/store

std/store:new(catalog) { selected: 0[i64], count: 13[i64] }

pub tor catalog-keys { ch: u8 }
catalog-keys = cond(ch)
| c x when x == 'j' and catalog.selected < catalog.count - 1 |> std/store:stored { catalog.selected: catalog.selected + 1 }
| c x when x == 'k' and catalog.selected > 0 |> std/store:stored { catalog.selected: catalog.selected - 1 }
| c _ |> _
