// todo — the reactive to-do TUI. The RENDER half wired to the store half:
// the store owns the todos; `! draw` sweeps the live rows and paints each;
// `! inserted`/`! removed` (in todo_store.k's model) are the redraw trigger.
// This is the render bridge lit: store write -> interceptor -> redraw ->
// ! draw -> sweep(todos) -> paint. `q` to quit.
import std/io
import std/string
import std/store
import koru/vaxis

std/store:new(todos, capacity: 16) { label: *std/string:String<std/string:instance!>, done: i64 }

// seed two todos
std/string:from-page(text: "buy milk")
| ok a |> std/string:take(s: a): m |> std/store:insert(todos) { label: m, done: 0 }
    | row _ |> std/string:from-page(text: "write koru")
        | ok b |> std/string:take(s: b): k |> std/store:insert(todos) { label: k, done: 0 }
            | row _ |> _
        | err _ |> _
| err _ |> _

koru/vaxis:run(title: "todo")
! draw w |> std/store:sweep(todos)
    ! sweep { entity.label, row } |> std/string:read(s: label): t |> koru/vaxis:write-at(x: 2, y: @as(u16, @intCast(row)), text: t)
! key k when k.ch == 'q' |> koru/vaxis:quit()
! key k when k.ch == 'a' |> std/string:from-page(text: "new task")
    | ok a |> std/string:take(s: a): m |> std/store:insert(todos) { label: m, done: 0 }
        | row _ |> _
    | err _ |> _
! key k when k.ch == 'x' |> std/store:take(todos[0])
    | item gone |> std/string:free(s: gone.label)
    | empty |> _
| err e |> std/io:print.ln("vaxis failed: {{ e:s }}")
