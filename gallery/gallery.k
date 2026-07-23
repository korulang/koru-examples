// gallery — sit-and-look surface for Charm / vaxis catalog widgets.
//
// Eyes for COMPONENT_CHALLENGE polish. Page through exhibits; poke the active
// one. Awkwardness is a toolchain finding — never dodge in the app.
//
//   koruc run gallery.k
//
// n/p next/prev · space poke progress · type on text-input ·
// j/k list · j/k/d/u/g/G viewport · q quit

import std/io
import std/string
import std/store
import koru/vaxis

// page: 0 progress · 1 spinner · 2 text-input · 3 list · 4 viewport · 5 style
std/store:new(ui) { page: 0[i64], value: 40[i64], ms: 0[i64] }
std/store:new(buf, capacity: 2) { text: *std/string:String<instance!> }
std/store:new(list) { selected: 0[i64], count: 28[i64] }
std/store:new(scroll) { y: 0[i64], count: 41[i64] }

koru/vaxis:component(topbar) {
    <text>{{ title:s }}</text>
}

koru/vaxis:component(statusbar) {
    <text>{{ hint:s }}</text>
}

koru/vaxis:component(blurb) {
    <text>{{ text:s }}</text>
}

koru/vaxis:component(progress-exhibit) {
    <dock>
        <topbar dock="top" h="1" title="gallery · progress"/>
        <statusbar dock="bottom" h="1" hint="n/p exhibits · space +10 · q"/>
        <progress-bar dock="fill" value={{ value:d }} max={{ max:d }}/>
    </dock>
}

koru/vaxis:component(spinner-exhibit) {
    <dock>
        <topbar dock="top" h="1" title="gallery · spinner"/>
        <statusbar dock="bottom" h="1" hint="n/p exhibits · q"/>
        <spinner dock="fill" ms={{ ms:d }}/>
    </dock>
}

koru/vaxis:component(field-exhibit) {
    <dock>
        <topbar dock="top" h="1" title="gallery · text-input"/>
        <statusbar dock="bottom" h="1" hint="type · backspace · n/p · esc quit"/>
        <text-input dock="fill" value={{ value:s }} ms={{ ms:d }}/>
    </dock>
}

koru/vaxis:component(list-exhibit) {
    <dock>
        <topbar dock="top" h="1" title="gallery · list"/>
        <statusbar dock="bottom" h="1" hint="j/k select · n/p exhibits · q"/>
        <list dock="fill" title={{ title:s }} items={{ items:s }} selected={{ selected:d }}/>
    </dock>
}

koru/vaxis:component(viewport-exhibit) {
    <dock>
        <topbar dock="top" h="1" title="gallery · viewport"/>
        <statusbar dock="bottom" h="1" hint="j/k line · d/u half · g/G ends · n/p · q"/>
        <viewport dock="fill" content={{ content:s }} offset={{ y:d }}/>
    </dock>
}

koru/vaxis:component(style-exhibit) {
    <dock>
        <topbar dock="top" h="1" title="gallery · style"/>
        <statusbar dock="bottom" h="1" hint="n/p exhibits · q"/>
        <blurb dock="fill" text="swatches below (Style fg/bg + UTF-8 runes)"/>
    </dock>
}

std/string:from-page(text: "")
| ok a |> std/string:take(s: a): text |> std/store:insert(buf) { text }
    | row _ |> _
    | full f |> std/string:free(s: f.text)
| err _ |> _

koru/vaxis:run(title: "gallery")
! draw w |> if(ui.page == 0)
    | then |> progress-exhibit(win: w, ui.value, max: 100)
    | else |> if(ui.page == 1)
        | then |> spinner-exhibit(win: w, ui.ms)
        | else |> if(ui.page == 2)
            | then |> koru/vaxis:sub(parent: w, x: 0, y: 0, w: 0, h: 0): root
                |> std/store:sweep(buf)
                ! sweep { buf: entity.text } |> std/string:read(s: buf): value
                    |> field-exhibit(win: root, value, ui.ms)
            | else |> if(ui.page == 3)
                | then |> list-exhibit(win: w,
                    title: "What do you want for dinner?",
                    items: "Ramen\nTomato Soup\nHamburgers\nCheeseburgers\nCurrywurst\nOkonomiyaki\nPasta\nFillet Mignon\nCaviar\nJust Wine\nTacos\nSushi\nPizza\nPho\nBibimbap\nPad Thai\nGyoza\nCroissant\nPaella\nFalafel\nBiryani\nSchnitzel\nEmpanadas\nKimchi Jjigae\nJollof Rice\nPierogi\nShakshuka\nMapo Tofu",
                    list.selected)
                | else |> if(ui.page == 4)
                    | then |> viewport-exhibit(win: w,
                        content: "The Viewport\n============\n\nA viewport is the simplest honest widget: a window onto\ncontent that does not fit. Everything else in a pager —\nthe title, the scroll position, the key hints — is chrome\naround this one idea: paint the slice, skip the rest.\n\n 1. The store owns the offset.\n 2. The widget owns the paint.\n 3. The keys mutate state, never pixels.\n\nThat separation is the whole design. When j bumps the\noffset, the next draw hands the viewport a new number and\nthe visible slice moves down one line. Nothing scrolls;\nthe world is repainted from state, every frame, and it is\nfast because the widget touches only the rows it shows.\n\nScrolling\n---------\n\nj or k moves one line. d and u jump half a page. g goes\nhome; G rides to the end — the last line parked at the\ntop of the window, the way less and vim leave it.\n\nLines longer than the window clip at the right edge rather than wrapping, which keeps columns honest and scanning calm — this line is deliberately long to prove it.\n\nClipping is not a compromise. Hard edges are what make a\nterminal feel solid: text never re-flows under your eyes,\nnever shifts a column while you read. Soft-wrap is a real\nfeature and it is deferred, not faked.\n\nThe End of the Content\n----------------------\n\nYou are near the bottom now. Past this point the window\nsimply runs out of lines to show, and the empty rows stay\nempty — no tildes, no filler, just the quiet edge of the\ncontent, which is the terminal's version of a margin.\n\n            · fin ·",
                        scroll.y)
                    | else |> style-exhibit(win: w)
                        |> koru/vaxis:write-styled(x: 2, y: 3, text: "▌▌▌▌▌▌░░░░░░  half-block  #5A56E0", style: { fg: 0x5A56E0 })
                        |> koru/vaxis:write-styled(x: 2, y: 5, text: "████████░░░░  block  pink on slate", style: { fg: 0xEE6FF8, bg: 0x606060 })
! tick ms |> std/store:stored { ui.ms: ms }
! key k when k.ch == 'q' and ui.page != 2 |> koru/vaxis:quit()
! key k when k.ch == 27 and ui.page == 2 |> koru/vaxis:quit()
! key k when k.ch == 'n' and ui.page < 5 |> std/store:stored { ui.page: ui.page + 1 }
! key k when k.ch == 'p' and ui.page > 0 |> std/store:stored { ui.page: ui.page - 1 }
! key k when k.ch == ' ' and ui.page == 0 and ui.value < 100 |> std/store:stored { ui.value: ui.value + 10 }
! key k when k.ch == ' ' and ui.page == 0 and ui.value >= 100 |> std/store:stored { ui.value: 0 }
! key k when ui.page == 3 and k.ch == 'j' and list.selected < list.count - 1 |> std/store:stored { list.selected: list.selected + 1 }
! key k when ui.page == 3 and k.ch == 'k' and list.selected > 0 |> std/store:stored { list.selected: list.selected - 1 }
! key k when ui.page == 4 and k.ch == 'j' and scroll.y < scroll.count - 1 |> std/store:stored { scroll.y: scroll.y + 1 }
! key k when ui.page == 4 and k.ch == 'k' and scroll.y > 0 |> std/store:stored { scroll.y: scroll.y - 1 }
! key k when ui.page == 4 and k.ch == 'd' and scroll.y < scroll.count - 12 |> std/store:stored { scroll.y: scroll.y + 12 }
! key k when ui.page == 4 and k.ch == 'd' and scroll.y >= scroll.count - 12 and scroll.y < scroll.count - 1 |> std/store:stored { scroll.y: scroll.count - 1 }
! key k when ui.page == 4 and k.ch == 'u' and scroll.y >= 12 |> std/store:stored { scroll.y: scroll.y - 12 }
! key k when ui.page == 4 and k.ch == 'u' and scroll.y > 0 and scroll.y < 12 |> std/store:stored { scroll.y: 0 }
! key k when ui.page == 4 and k.ch == 'g' and scroll.y > 0 |> std/store:stored { scroll.y: 0 }
! key k when ui.page == 4 and k.ch == 'G' and scroll.y < scroll.count - 1 |> std/store:stored { scroll.y: scroll.count - 1 }
! key k when ui.page == 2 and k.ch == 127 |> std/store:take(buf[0])
    | item d |> std/string:pop-char(s: d.text) |> std/store:insert(buf) { d.text }
        | row _ |> _
        | full f |> std/string:free(s: f.text)
    | empty |> _
! key k when ui.page == 2 and k.ch == 8 |> std/store:take(buf[0])
    | item d |> std/string:pop-char(s: d.text) |> std/store:insert(buf) { d.text }
        | row _ |> _
        | full f |> std/string:free(s: f.text)
    | empty |> _
! key k when ui.page == 2 and k.ch >= 32 and k.ch < 127 |> std/store:take(buf[0])
    | item d |> std/string:append-char(s: d.text, k.ch)
        | ok |> std/store:insert(buf) { d.text }
            | row _ |> _
            | full f |> std/string:free(s: f.text)
        | err _ |> std/store:insert(buf) { d.text }
            | row _ |> _
            | full f |> std/string:free(s: f.text)
    | empty |> _
| err e |> std/io:print.ln("gallery failed: {{ e:s }}")
