// The honest board owns its own scroll state.
//
// Same shape as viewport.k: the store is declared beside the keys that
// mutate it; the entry file reads `board.y` to paint the exhibit — a
// cross-module cell read that lowers into this module's namespace.
import std/store

std/store:new(board) { y: 0[i64], count: 60[i64] }

pub tor honest-keys { ch: u8 }
honest-keys = cond(ch)
| c x when x == 'j' and board.y < board.count - 1 |> std/store:stored { board.y: board.y + 1 }
| c x when x == 'k' and board.y > 0 |> std/store:stored { board.y: board.y - 1 }
| c x when x == 'd' and board.y < board.count - 12 |> std/store:stored { board.y: board.y + 12 }
| c x when x == 'd' and board.y >= board.count - 12 and board.y < board.count - 1 |> std/store:stored { board.y: board.count - 1 }
| c x when x == 'u' and board.y >= 12 |> std/store:stored { board.y: board.y - 12 }
| c x when x == 'u' and board.y > 0 and board.y < 12 |> std/store:stored { board.y: 0 }
| c x when x == 'g' and board.y > 0 |> std/store:stored { board.y: 0 }
| c x when x == 'G' and board.y < board.count - 1 |> std/store:stored { board.y: board.count - 1 }
| c _ |> _
