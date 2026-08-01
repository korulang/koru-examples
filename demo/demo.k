import std/io
import std/store
import koru/vaxis
import koru/curl

std/store:new(my_store) {
    count: i64
}

koru/vaxis:run(title: "My app")
! key k when k.ch == 'q' |> koru/vaxis:quit()
| err _ |> _

std/io:print.ln("Hello world!")
