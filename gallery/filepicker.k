// The filepicker widget owns its own state.
//
// The store is declared beside the keys that mutate it. The entry file still
// READS these cells to paint the exhibit — a cross-module cell read, which
// lowers into this module's namespace.
import std/store

std/store:new(fp) { selected: 0[i64], dir: 0[i64] }

pub tor filepicker-keys { ch: u8 }
filepicker-keys = cond(ch)
| c x when x == 'j' and fp.dir == 0 and fp.selected < 5 |> std/store:stored { fp.selected: fp.selected + 1 }
| c x when x == 'j' and fp.dir == 1 and fp.selected < 4 |> std/store:stored { fp.selected: fp.selected + 1 }
| c x when x == 'k' and fp.selected > 0 |> std/store:stored { fp.selected: fp.selected - 1 }
| c x when x == 'g' and fp.selected > 0 |> std/store:stored { fp.selected: 0 }
| c x when x == 'G' and fp.dir == 0 and fp.selected < 5 |> std/store:stored { fp.selected: 5 }
| c x when x == 'G' and fp.dir == 1 and fp.selected < 4 |> std/store:stored { fp.selected: 4 }
| c x when x == 'l' and fp.dir == 0 and fp.selected == 0 |> std/store:stored { fp.dir: 1, fp.selected: 0 }
| c x when x == 13 and fp.dir == 0 and fp.selected == 0 |> std/store:stored { fp.dir: 1, fp.selected: 0 }
| c x when x == 'l' and fp.dir == 1 and fp.selected == 0 |> std/store:stored { fp.dir: 0, fp.selected: 0 }
| c x when x == 13 and fp.dir == 1 and fp.selected == 0 |> std/store:stored { fp.dir: 0, fp.selected: 0 }
| c x when x == 'h' and fp.dir == 1 |> std/store:stored { fp.dir: 0, fp.selected: 0 }
| c _ |> _
