// The book widget owns its own state.
//
// The store is declared beside the keys that mutate it. The entry file still
// READS these cells to paint the exhibit — a cross-module cell read, which
// lowers into this module's namespace.
import std/store

std/store:new(book) { page: 0[i64], total: 3[i64], offset: 0[i64] }

pub tor pager-keys { ch: u8 }
pager-keys = cond(ch)
| c x when x == 'l' and book.page < book.total - 1 |> std/store:stored { book.page: book.page + 1, book.offset: book.offset + 12 }
| c x when x == 'h' and book.page > 0 |> std/store:stored { book.page: book.page - 1, book.offset: book.offset - 12 }
| c _ |> _
