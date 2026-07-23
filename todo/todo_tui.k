// todo — the reactive to-do TUI. Flagship convergence: std/store + vaxis
// components. Dock chrome, todo-row components, sweep as the render READ.
// Key-handler loop already full-repaints (! draw after every key) — so
// insert/take are the redraw trigger for free. Break the toolchain, fix it.
//
//   koruc run todo_tui.k
import std/io
import std/string
import std/store
import koru/vaxis

std/store:new(todos, capacity: 16) {
    label: *std/string:String<instance!>,
    done: i64
}

koru/vaxis:component(todo-row) {
    <text>{{ text:s }}</text>
}

koru/vaxis:component(topbar) {
    <text>{{ title:s }}</text>
}

koru/vaxis:component(statusbar) {
    <text>{{ hint:s }}</text>
}

// Chrome — live rows paint into the fill band on the same ! draw (one scene).
koru/vaxis:component(app) {
    <Dock>
        <topbar dock="top" h="1" title="== todo =="/>
        <statusbar dock="bottom" h="1" hint="q quit | a add | x delete first"/>
    </Dock>
}

// seed two todos
std/string:from-page(text: "buy milk")
| ok a |> std/string:take(s: a): m |> std/store:insert(todos) { label: m, done: 0 }
    | row _ |> std/string:from-page(text: "write koru")
        | ok b |> std/string:take(s: b): label
            |> std/store:insert(todos) { label, done: 0 }
                | row _ |> _
| err _ |> _

koru/vaxis:run(title: "todo")
! draw w |> app(win: w)
    |> koru/vaxis:sub-fill(parent: w, top: 1, bottom: 1): body
    |> std/store:sweep(todos)
    ! sweep { entity.label, row } |> std/string:read(s: label): text
        |> koru/vaxis:sub(parent: body, x: 0, y: @as(u16, @intCast(row)), w: 0, h: 1): rw
            |> todo-row(win: rw, text)
! key k when k.ch == 'q' |> koru/vaxis:quit()
! key k when k.ch == 'a' |> std/string:from-page(text: "new task")
    | ok a |> std/string:take(s: a): m |> std/store:insert(todos) { label: m, done: 0 }
        | row _ |> _
    | err _ |> _
! key k when k.ch == 'x' |> std/store:take(todos[0])
    | item gone |> std/string:free(s: gone.label)
    | empty |> _
| err e |> std/io:print.ln("vaxis failed: {{ e:s }}")
