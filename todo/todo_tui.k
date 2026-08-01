// todo — reactive TUI. Dock chrome + live StackPanel fill; j/k select,
// space toggle, a add, x delete, r rename, q quit. Battering ram.
//
//   koruc run todo_tui.k
import std/io
import std/string
import std/store
import std/fmt
import koru/vaxis

std/store:new(todos, capacity: 16) {
    label: *std/string:String<instance!>
    done: i64
}

// Selection + edit mode. draft holds the rename buffer (owned string row).
std/store:new(ui) { sel: 0[i64], editing: 0[i64] }
std/store:new(draft, capacity: 2) { *std/string:String<instance!> }

// seed todos + empty draft buffer
std/string:from-page(text: "buy milk")
| ok a |> std/string:take(s: a): m |> std/store:insert(todos) { label: m, done: 0 }
    | row _ |> std/string:from-page(text: "write koru")
        | ok b |> std/string:take(s: b): label
            |> std/store:insert(todos) { label, done: 0 }
                | row _ |> std/string:from-page(text: "")
                    | ok c |> std/string:take(s: c): text |> std/store:insert(draft) { text }
                        | row _ |> _
                        | full f |> std/string:free(s: f.text)
                    | err _ |> _
                | full f |> std/string:free(s: f.label)
        | err _ |> _
    | full f |> std/string:free(s: f.label)
| err _ |> _

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
    <dock>
        <topbar dock="top" h="1" title="== todo =="/>
        <statusbar dock="bottom" h="1" hint="j/k | space | a add | r rename | x del | q"/>
        <stack-panel dock="fill"/>
    </dock>
}

koru/vaxis:run(title: "todo")
! draw w |> app(win: w): panel
    |> std/store:sweep(todos)
    ! sweep { entity.label, entity.done, row } |> std/string:read(s: label): text
        |> koru/vaxis:stack-row(stack: panel): rw
        |> if(ui.editing == 1 and row == ui.sel)
        | then |> std/store:sweep(draft)
            ! sweep { buf: entity.text } |> std/string:read(s: buf): draft_text
                |> std/fmt:ln("> _{{ draft_text:s }}_"): line
                |> todo-row(win: rw, line.text)
        | else |> if(row == ui.sel)
            | then |> if(done == 1)
                | then |> std/fmt:ln("> [x] {{ text:s }}"): line |> todo-row(win: rw, line.text)
                | else |> std/fmt:ln("> [ ] {{ text:s }}"): line |> todo-row(win: rw, line.text)
            | else |> if(done == 1)
                | then |> std/fmt:ln("  [x] {{ text:s }}"): line |> todo-row(win: rw, line.text)
                | else |> std/fmt:ln("  [ ] {{ text:s }}"): line |> todo-row(win: rw, line.text)
! key k when ui.editing == 0 and k.ch == 'q' |> koru/vaxis:quit()
! key k when ui.editing == 0 and k.ch == 'j' and ui.sel + 1 < todos.len |> std/store:stored { ui.sel: ui.sel + 1 }
! key k when ui.editing == 0 and k.ch == 'k' and ui.sel > 0 |> std/store:stored { ui.sel: ui.sel - 1 }
! key k when ui.editing == 0 and k.ch == ' ' and ui.sel < todos.len |> std/store:stored { todos[ui.sel].done: 1 - todos[ui.sel].done }
! key k when ui.editing == 0 and k.ch == 'a' |> std/string:from-page(text: "new task")
    | ok a |> std/string:take(s: a): m |> std/store:insert(todos) { label: m, done: 0 }
        | row _ |> _
        | full f |> std/string:free(s: f.label)
    | err _ |> _
! key k when ui.editing == 0 and k.ch == 'x' and ui.sel < todos.len |> std/store:take(todos[ui.sel])
    | item gone |> std/string:free(s: gone.label)
        |> if(ui.sel > 0)
        | then |> std/store:stored { ui.sel: ui.sel - 1 }
        | else |> _
    | empty |> _
! key k when ui.editing == 0 and k.ch == 'r' and ui.sel < todos.len |> std/store:take(draft[0])
    | item d |> std/string:clear(s: d.text) |> std/store:insert(draft) { d.text }
        | row _ |> std/store:stored { ui.editing: 1 }
        | full f |> std/string:free(s: f.text)
    | empty |> _
! key k when ui.editing == 1 and k.ch == 27 |> std/store:take(draft[0])
    | item d |> std/string:clear(s: d.text) |> std/store:insert(draft) { d.text }
        | row _ |> std/store:stored { ui.editing: 0 }
        | full f |> std/string:free(s: f.text)
    | empty |> std/store:stored { ui.editing: 0 }
! key k when ui.editing == 1 and k.ch == 13 and ui.sel < todos.len |> std/store:take(draft[0])
    | item d |> std/store:stored { todos[ui.sel].label: d.text }
        |> std/store:stored { ui.editing: 0 }
        |> std/string:from-page(text: "")
            | ok a |> std/string:take(s: a): text |> std/store:insert(draft) { text }
                | row _ |> _
                | full f |> std/string:free(s: f.text)
            | err _ |> _
    | empty |> std/store:stored { ui.editing: 0 }
! key k when ui.editing == 1 and k.ch == 127 |> std/store:take(draft[0])
    | item d |> std/string:pop-char(s: d.text) |> std/store:insert(draft) { d.text }
        | row _ |> _
        | full f |> std/string:free(s: f.text)
    | empty |> _
! key k when ui.editing == 1 and k.ch == 8 |> std/store:take(draft[0])
    | item d |> std/string:pop-char(s: d.text) |> std/store:insert(draft) { d.text }
        | row _ |> _
        | full f |> std/string:free(s: f.text)
    | empty |> _
! key k when ui.editing == 1 and k.ch >= 32 and k.ch < 127 |> std/store:take(draft[0])
    | item d |> std/string:append-char(s: d.text, k.ch)
        | ok |> std/store:insert(draft) { d.text }
            | row _ |> _
            | full f |> std/string:free(s: f.text)
        | err _ |> std/store:insert(draft) { d.text }
            | row _ |> _
            | full f |> std/string:free(s: f.text)
    | empty |> _
| err e |> std/io:print.ln("vaxis failed: {{ e:s }}")
