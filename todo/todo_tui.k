// todo — reactive TUI. Dock chrome + sweep rows; j/k select, space toggle,
// a add, x delete selection, q quit. Battering ram: fix toolchain walls.
//
//   koruc run todo_tui.k
import std/io
import std/string
import std/store
import std/fmt
import koru/vaxis

std/store:new(todos, capacity: 16) {
    label: *std/string:String<instance!>,
    done: i64
}

// Selection cursor — singleton UI state (row index into todos).
std/store:new(ui) { sel: 0[i64] }

koru/vaxis:component(todo-row) {
    <text>{{ text:s }}</text>
}

koru/vaxis:component(topbar) {
    <text>{{ title:s }}</text>
}

koru/vaxis:component(statusbar) {
    <text>{{ hint:s }}</text>
}

koru/vaxis:component(app) {
    <Dock>
        <topbar dock="top" h="1" title="== todo =="/>
        <statusbar dock="bottom" h="1" hint="j/k move | space toggle | a add | x del | q quit"/>
    </Dock>
}

// seed
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
    ! sweep { entity.label, entity.done, row } |> std/string:read(s: label): text
        |> koru/vaxis:sub(parent: body, x: 0, y: @as(u16, @intCast(row)), w: 0, h: 1): rw
        |> if(row == ui.sel)
        | then |> if(done == 1)
            | then |> std/fmt:ln("> [x] {{ text:s }}"): line |> todo-row(win: rw, line.text)
            | else |> std/fmt:ln("> [ ] {{ text:s }}"): line |> todo-row(win: rw, line.text)
        | else |> if(done == 1)
            | then |> std/fmt:ln("  [x] {{ text:s }}"): line |> todo-row(win: rw, line.text)
            | else |> std/fmt:ln("  [ ] {{ text:s }}"): line |> todo-row(win: rw, line.text)
! key k when k.ch == 'q' |> koru/vaxis:quit()
! key k when k.ch == 'j' |> std/store:stored { ui.sel: ui.sel + 1 }
! key k when k.ch == 'k' and ui.sel > 0 |> std/store:stored { ui.sel: ui.sel - 1 }
! key k when k.ch == ' ' |> std/store:stored { todos[ui.sel].done: 1 - todos[ui.sel].done }
! key k when k.ch == 'a' |> std/string:from-page(text: "new task")
    | ok a |> std/string:take(s: a): m |> std/store:insert(todos) { label: m, done: 0 }
        | row _ |> _
    | err _ |> _
! key k when k.ch == 'x' |> std/store:take(todos[ui.sel])
    | item gone |> std/string:free(s: gone.label)
        |> if(ui.sel > 0)
        | then |> std/store:stored { ui.sel: ui.sel - 1 }
        | else |> _
    | empty |> _
| err e |> std/io:print.ln("vaxis failed: {{ e:s }}")
