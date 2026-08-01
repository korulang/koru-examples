// todo — the store half of the reactive to-do TUI (our north star).
//
// This is the DATA layer: an owned-string todo store with the full CRUD we
// landed as owned-column rungs (insert/stored/take + interceptors). The vaxis
// session owns the RENDER half; the two converge at the reactive-attach bridge
// (write-driven projection — the renderer keeps a paint-list fed by these
// interceptors, `! draw` reads the projection, never the store).
//
// The interceptors below ARE that reactive feed: `! inserted` fires on add,
// `! removed` fires on delete. A real renderer projects its paint-list off them
// instead of print.ln. Everything here builds + runs through koruc today.
import std/io
import std/string
import std/store

std/store:new(todos, capacity: 16) {
    label: *std/string:String<instance!>,
    done: i64
}
! inserted { label } |> std/string:read(s: label): t |> std/io:print.ln("  + {{ t:s }}")
! removed  { label } |> std/string:read(s: label): t |> std/io:print.ln("  - {{ t:s }}")

// add "buy milk", then "write koru"; toggle "buy milk" done; drop "write koru".
std/string:from-page(text: "buy milk")
| ok a |> std/string:take(s: a): milk |> std/store:insert(todos) { label: milk, done: 0 }
    | row r1 |> std/string:from-page(text: "write koru")
        | ok b |> std/string:take(s: b): koru |> std/store:insert(todos) { label: koru, done: 0 }
            | row r2 |> std/store:stored { todos[r1].done: 1 }
                |> std/store:take(todos[r2])
                    | item gone |> std/string:free(s: gone.label)
        | err _ |> _
| err _ |> _

std/io:print.ln("--- list ---")
std/store:rule(todos)
! row e |> std/string:read(s: e.label): t |> std/io:print.ln("{{ t:s }} [{{ e.done:d }}]")
