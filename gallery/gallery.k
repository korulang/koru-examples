// gallery — sit-and-look surface for Charm / vaxis catalog widgets.
//
// Eyes for COMPONENT_CHALLENGE polish. Page through exhibits; poke the active
// one. Awkwardness is a toolchain finding — never dodge in the app.
// Landing page is an informational <list/> of the catalog — j/k moves the
// highlight only; n/p changes exhibits (selection does NOT navigate).
//
//   koruc run gallery.k
//
// n/p next/prev · space poke progress · type on text-input ·
// j/k catalog|list|table|filepicker · type textarea · j/k/d/u/g/G viewport ·
// h/l paginator · ? help · space/s/r clocks · l/h filepicker · q quit

import std/io
import std/string
import std/store
import koru/vaxis

// page: 0 catalog · 1 progress · 2 spinner · 3 text-input · 4 list ·
//       5 viewport · 6 paginator · 7 help · 8 table · 9 textarea ·
//       10 clocks · 11 filepicker · 12 style
// Clocks live on `ui` (not a second store): a bare `! tick` installs alone and
// drops later `when` ticks — so remaining/elapsed/running share the one tick
// rail with spinner/text-input `ms`.
std/store:new(ui) {
    page: 0[i64],
    value: 40[i64],
    ms: 0[i64],
    remaining: 15000[i64],
    elapsed: 0[i64],
    running: 1[i64]
}
std/store:new(buf, capacity: 2) { text: *std/string:String<instance!> }
std/store:new(catalog) { selected: 0[i64], count: 12[i64] }
std/store:new(list) { selected: 0[i64], count: 28[i64] }
std/store:new(scroll) { y: 0[i64], count: 41[i64] }
std/store:new(pager) { page: 0[i64], total: 7[i64] }
std/store:new(help) { show: 0[i64] }
std/store:new(table) { selected: 0[i64], count: 20[i64] }
std/store:new(fp) { selected: 0[i64], dir: 0[i64] }

koru/vaxis:component(topbar) {
    <text>{{ title:s }}</text>
}

koru/vaxis:component(statusbar) {
    <text>{{ hint:s }}</text>
}

koru/vaxis:component(blurb) {
    <text>{{ text:s }}</text>
}

koru/vaxis:component(cap) {
    <text>{{ text:s }}</text>
}

// Informational index — not a navigator. j/k only moves the pink cursor.
koru/vaxis:component(catalog-exhibit) {
    <dock>
        <topbar dock="top" h="1" title="gallery · catalog"/>
        <statusbar dock="bottom" h="1" hint="informational list · j/k peek · n next exhibit · q"/>
        <list dock="fill" title={{ title:s }} items={{ items:s }} selected={{ selected:d }}/>
    </dock>
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

koru/vaxis:component(paginator-exhibit) {
    <dock>
        <topbar dock="top" h="1" title="gallery · paginator"/>
        <cap dock="top" h="1" text="  Dots"/>
        <paginator dock="top" h="1" kind="dots" page={{ page:d }} total={{ total:d }}/>
        <cap dock="top" h="2" text="  Arabic"/>
        <paginator dock="top" h="1" kind="arabic" page={{ page:d }} total={{ total:d }}/>
        <statusbar dock="bottom" h="1" hint="h/l page · n/p exhibits · q"/>
    </dock>
}

koru/vaxis:component(help-exhibit) {
    <dock>
        <topbar dock="top" h="1" title="gallery · help"/>
        <statusbar dock="bottom" h="1" hint="? short/full · n/p exhibits · q"/>
        <help dock="fill" bindings={{ bindings:s }} mode={{ show:d }}/>
    </dock>
}

koru/vaxis:component(table-exhibit) {
    <dock>
        <topbar dock="top" h="1" title="gallery · table"/>
        <statusbar dock="bottom" h="1" hint="j/k move · g/G ends · n/p · q"/>
        <table dock="fill" headers={{ headers:s }} widths={{ widths:s }} rows={{ rows:s }} selected={{ selected:d }}/>
    </dock>
}


koru/vaxis:component(textarea-exhibit) {
    <dock>
        <topbar dock="top" h="1" title="gallery · textarea"/>
        <statusbar dock="bottom" h="1" hint="type · enter newline · backspace · n/p · esc quit"/>
        <textarea dock="fill" value={{ value:s }} ms={{ ms:d }}/>
    </dock>
}

koru/vaxis:component(clocks-exhibit) {
    <dock>
        <topbar dock="top" h="1" title="gallery · timer / stopwatch"/>
        <statusbar dock="bottom" h="1" hint="space/s pause · r reset · n/p · q"/>
        <stack-panel dock="fill">
            <cap text="timer"/>
            <timer remaining_ms={{ remaining:d }} running={{ t_running:d }}/>
            <cap text="stopwatch"/>
            <stopwatch elapsed_ms={{ elapsed:d }} running={{ s_running:d }}/>
        </stack-panel>
    </dock>
}

koru/vaxis:component(filepicker-exhibit) {
    <dock>
        <topbar dock="top" h="1" title="gallery · filepicker"/>
        <statusbar dock="bottom" h="1" hint="j/k move · g/G ends · l/enter open · h back · n/p · q"/>
        <filepicker dock="fill" path={{ path:s }} entries={{ entries:s }} selected={{ selected:d }}/>
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
    | then |> catalog-exhibit(win: w,
        title: "Charm / vaxis catalog",
        items: "progress — ▌/░ meter, purple→pink\nspinner — MiniDot braille + tick\ntext-input — prompt, placeholder, blink\nlist — selection + ●/○ paginator\nviewport — scrollable content slice\npaginator — Dots + Arabic status chrome\nhelp — short • line / full column\ntable — header, pink row, … truncate\ntextarea — multi-line ┃ gutter + blink\ntimer / stopwatch — countdown + count-up\nfilepicker — path header, > pink, purple dirs\nstyle — Style fg/bg + UTF-8 runes",
        catalog.selected)
    | else |> if(ui.page == 1)
        | then |> progress-exhibit(win: w, ui.value, max: 100)
        | else |> if(ui.page == 2)
            | then |> spinner-exhibit(win: w, ui.ms)
            | else |> if(ui.page == 3)
                | then |> koru/vaxis:sub(parent: w, x: 0, y: 0, w: 0, h: 0): root
                    |> std/store:sweep(buf)
                    ! sweep { buf: entity.text } |> std/string:read(s: buf): value
                        |> field-exhibit(win: root, value, ui.ms)
                | else |> if(ui.page == 4)
                    | then |> list-exhibit(win: w,
                        title: "What do you want for dinner?",
                        items: "Ramen\nTomato Soup\nHamburgers\nCheeseburgers\nCurrywurst\nOkonomiyaki\nPasta\nFillet Mignon\nCaviar\nJust Wine\nTacos\nSushi\nPizza\nPho\nBibimbap\nPad Thai\nGyoza\nCroissant\nPaella\nFalafel\nBiryani\nSchnitzel\nEmpanadas\nKimchi Jjigae\nJollof Rice\nPierogi\nShakshuka\nMapo Tofu",
                        list.selected)
                    | else |> if(ui.page == 5)
                        | then |> viewport-exhibit(win: w,
                            content: "The Viewport\n============\n\nA viewport is the simplest honest widget: a window onto\ncontent that does not fit. Everything else in a pager —\nthe title, the scroll position, the key hints — is chrome\naround this one idea: paint the slice, skip the rest.\n\n 1. The store owns the offset.\n 2. The widget owns the paint.\n 3. The keys mutate state, never pixels.\n\nThat separation is the whole design. When j bumps the\noffset, the next draw hands the viewport a new number and\nthe visible slice moves down one line. Nothing scrolls;\nthe world is repainted from state, every frame, and it is\nfast because the widget touches only the rows it shows.\n\nScrolling\n---------\n\nj or k moves one line. d and u jump half a page. g goes\nhome; G rides to the end — the last line parked at the\ntop of the window, the way less and vim leave it.\n\nLines longer than the window clip at the right edge rather than wrapping, which keeps columns honest and scanning calm — this line is deliberately long to prove it.\n\nClipping is not a compromise. Hard edges are what make a\nterminal feel solid: text never re-flows under your eyes,\nnever shifts a column while you read. Soft-wrap is a real\nfeature and it is deferred, not faked.\n\nThe End of the Content\n----------------------\n\nYou are near the bottom now. Past this point the window\nsimply runs out of lines to show, and the empty rows stay\nempty — no tildes, no filler, just the quiet edge of the\ncontent, which is the terminal's version of a margin.\n\n            · fin ·",
                            scroll.y)
                        | else |> if(ui.page == 6)
                            | then |> paginator-exhibit(win: w, pager.page, pager.total)
                            | else |> if(ui.page == 7)
                                | then |> help-exhibit(win: w,
                                    bindings: "↑/k:up\n↓/j:down\n←/h:prev page\n→/l:next page\ng:go to start\nG:go to end\n/:filter\n?:toggle help\nq:quit",
                                    help.show)
                                | else |> if(ui.page == 8)
                                    | then |> table-exhibit(win: w,
                                        headers: "Rank|City|Country|Population",
                                        widths: "4|16|8|10",
                                        rows: "1|Tokyo|Japan|37,274,000\n2|Delhi|India|32,065,760\n3|Shanghai|China|28,516,904\n4|Dhaka|Bangladesh|22,478,116\n5|São Paulo|Brazil|22,429,800\n6|Mexico City|Mexico|22,085,140\n7|Cairo|Egypt|21,750,020\n8|Beijing|China|21,333,332\n9|Mumbai|India|20,961,472\n10|Osaka|Japan|19,059,856\n11|Chongqing|China|16,874,740\n12|Karachi|Pakistan|16,839,950\n13|Istanbul|Turkey|15,636,243\n14|Kinshasa|DR Congo|15,628,085\n15|Lagos|Nigeria|15,387,639\n16|Buenos Aires|Argentina|15,369,919\n17|Kolkata|India|15,133,888\n18|Manila|Philippines|14,406,059\n19|Tianjin|China|13,589,078\n20|Guangzhou|China|13,301,532",
                                        table.selected)
                                    | else |> if(ui.page == 9)
                                        | then |> koru/vaxis:sub(parent: w, x: 0, y: 0, w: 0, h: 0): root
                                            |> std/store:sweep(buf)
                                            ! sweep { buf: entity.text } |> std/string:read(s: buf): value
                                                |> textarea-exhibit(win: root, value, ui.ms)
                                        | else |> if(ui.page == 10)
                                            | then |> clocks-exhibit(win: w,
                                                ui.remaining, t_running: ui.running,
                                                ui.elapsed, s_running: ui.running)
                                            | else |> if(ui.page == 11)
                                                | then |> if(fp.dir == 0)
                                                    | then |> filepicker-exhibit(win: w,
                                                        path: "~/charm",
                                                        entries: "D\tdocuments\nF\tREADME.md\nF\tgo.mod\nF\tgo.sum\nF\tLICENSE\nF\t.gitignore",
                                                        fp.selected)
                                                    | else |> filepicker-exhibit(win: w,
                                                        path: "~/charm/documents",
                                                        entries: "D\t..\nF\tresume.pdf\nF\tbudget.xlsx\nF\tnotes.md\nF\tcover-letter.md",
                                                        fp.selected)
                                                | else |> style-exhibit(win: w)
                                                    |> koru/vaxis:write-styled(x: 2, y: 3, text: "▌▌▌▌▌▌░░░░░░  half-block  #5A56E0", style: { fg: 0x5A56E0 })
                                                    |> koru/vaxis:write-styled(x: 2, y: 5, text: "████████░░░░  block  pink on slate", style: { fg: 0xEE6FF8, bg: 0x606060 })
! tick ms when ui.ms == 0 |> std/store:stored { ui.ms: ms }
! tick ms when ui.ms > 0 and ui.running == 1 and ui.remaining > 0 |> std/store:stored {
    ui.remaining: ui.remaining - (ms - ui.ms),
    ui.elapsed: ui.elapsed + (ms - ui.ms),
    ui.ms: ms
}
! tick ms when ui.ms > 0 and ui.running == 1 and ui.remaining <= 0 |> std/store:stored {
    ui.elapsed: ui.elapsed + (ms - ui.ms),
    ui.ms: ms
}
! tick ms when ui.ms > 0 and ui.running == 0 |> std/store:stored { ui.ms: ms }
! key k when k.ch == 'q' and ui.page != 3 and ui.page != 9 |> koru/vaxis:quit()
! key k when k.ch == 27 and ui.page == 3 |> koru/vaxis:quit()
! key k when k.ch == 27 and ui.page == 9 |> koru/vaxis:quit()
! key k when k.ch == 'n' and ui.page < 12 |> std/store:stored { ui.page: ui.page + 1 }
! key k when k.ch == 'p' and ui.page > 0 |> std/store:stored { ui.page: ui.page - 1 }
! key k when ui.page == 10 and k.ch == ' ' and ui.running == 1 |> std/store:stored { ui.running: 0 }
! key k when ui.page == 10 and k.ch == ' ' and ui.running == 0 |> std/store:stored { ui.running: 1 }
! key k when ui.page == 10 and k.ch == 's' and ui.running == 1 |> std/store:stored { ui.running: 0 }
! key k when ui.page == 10 and k.ch == 's' and ui.running == 0 |> std/store:stored { ui.running: 1 }
! key k when ui.page == 10 and k.ch == 'r' |> std/store:stored { ui.remaining: 15000, ui.elapsed: 0 }
! key k when ui.page == 11 and k.ch == 'j' and fp.dir == 0 and fp.selected < 5 |> std/store:stored { fp.selected: fp.selected + 1 }
! key k when ui.page == 11 and k.ch == 'j' and fp.dir == 1 and fp.selected < 4 |> std/store:stored { fp.selected: fp.selected + 1 }
! key k when ui.page == 11 and k.ch == 'k' and fp.selected > 0 |> std/store:stored { fp.selected: fp.selected - 1 }
! key k when ui.page == 11 and k.ch == 'g' and fp.selected > 0 |> std/store:stored { fp.selected: 0 }
! key k when ui.page == 11 and k.ch == 'G' and fp.dir == 0 and fp.selected < 5 |> std/store:stored { fp.selected: 5 }
! key k when ui.page == 11 and k.ch == 'G' and fp.dir == 1 and fp.selected < 4 |> std/store:stored { fp.selected: 4 }
! key k when ui.page == 11 and k.ch == 'l' and fp.dir == 0 and fp.selected == 0 |> std/store:stored { fp.dir: 1, fp.selected: 0 }
! key k when ui.page == 11 and k.ch == 13 and fp.dir == 0 and fp.selected == 0 |> std/store:stored { fp.dir: 1, fp.selected: 0 }
! key k when ui.page == 11 and k.ch == 'l' and fp.dir == 1 and fp.selected == 0 |> std/store:stored { fp.dir: 0, fp.selected: 0 }
! key k when ui.page == 11 and k.ch == 13 and fp.dir == 1 and fp.selected == 0 |> std/store:stored { fp.dir: 0, fp.selected: 0 }
! key k when ui.page == 11 and k.ch == 'h' and fp.dir == 1 |> std/store:stored { fp.dir: 0, fp.selected: 0 }
! key k when ui.page == 0 and k.ch == 'j' and catalog.selected < catalog.count - 1 |> std/store:stored { catalog.selected: catalog.selected + 1 }
! key k when ui.page == 0 and k.ch == 'k' and catalog.selected > 0 |> std/store:stored { catalog.selected: catalog.selected - 1 }
! key k when k.ch == ' ' and ui.page == 1 and ui.value < 100 |> std/store:stored { ui.value: ui.value + 10 }
! key k when k.ch == ' ' and ui.page == 1 and ui.value >= 100 |> std/store:stored { ui.value: 0 }
! key k when ui.page == 4 and k.ch == 'j' and list.selected < list.count - 1 |> std/store:stored { list.selected: list.selected + 1 }
! key k when ui.page == 4 and k.ch == 'k' and list.selected > 0 |> std/store:stored { list.selected: list.selected - 1 }
! key k when ui.page == 5 and k.ch == 'j' and scroll.y < scroll.count - 1 |> std/store:stored { scroll.y: scroll.y + 1 }
! key k when ui.page == 5 and k.ch == 'k' and scroll.y > 0 |> std/store:stored { scroll.y: scroll.y - 1 }
! key k when ui.page == 5 and k.ch == 'd' and scroll.y < scroll.count - 12 |> std/store:stored { scroll.y: scroll.y + 12 }
! key k when ui.page == 5 and k.ch == 'd' and scroll.y >= scroll.count - 12 and scroll.y < scroll.count - 1 |> std/store:stored { scroll.y: scroll.count - 1 }
! key k when ui.page == 5 and k.ch == 'u' and scroll.y >= 12 |> std/store:stored { scroll.y: scroll.y - 12 }
! key k when ui.page == 5 and k.ch == 'u' and scroll.y > 0 and scroll.y < 12 |> std/store:stored { scroll.y: 0 }
! key k when ui.page == 5 and k.ch == 'g' and scroll.y > 0 |> std/store:stored { scroll.y: 0 }
! key k when ui.page == 5 and k.ch == 'G' and scroll.y < scroll.count - 1 |> std/store:stored { scroll.y: scroll.count - 1 }
! key k when ui.page == 6 and k.ch == 'l' and pager.page < pager.total - 1 |> std/store:stored { pager.page: pager.page + 1 }
! key k when ui.page == 6 and k.ch == 'h' and pager.page > 0 |> std/store:stored { pager.page: pager.page - 1 }
! key k when ui.page == 8 and k.ch == 'j' and table.selected < table.count - 1 |> std/store:stored { table.selected: table.selected + 1 }
! key k when ui.page == 8 and k.ch == 'k' and table.selected > 0 |> std/store:stored { table.selected: table.selected - 1 }
! key k when ui.page == 8 and k.ch == 'g' and table.selected > 0 |> std/store:stored { table.selected: 0 }
! key k when ui.page == 8 and k.ch == 'G' and table.selected < table.count - 1 |> std/store:stored { table.selected: table.count - 1 }
! key k when ui.page == 7 and k.ch == '?' and help.show == 0 |> std/store:stored { help.show: 1 }
! key k when ui.page == 7 and k.ch == '?' and help.show == 1 |> std/store:stored { help.show: 0 }
! key k when ui.page == 3 and k.ch == 127 |> std/store:take(buf[0])
    | item d |> std/string:pop-char(s: d.text) |> std/store:insert(buf) { d.text }
        | row _ |> _
        | full f |> std/string:free(s: f.text)
    | empty |> _
! key k when ui.page == 3 and k.ch == 8 |> std/store:take(buf[0])
    | item d |> std/string:pop-char(s: d.text) |> std/store:insert(buf) { d.text }
        | row _ |> _
        | full f |> std/string:free(s: f.text)
    | empty |> _
! key k when ui.page == 3 and k.ch >= 32 and k.ch < 127 |> std/store:take(buf[0])
    | item d |> std/string:append-char(s: d.text, k.ch)
        | ok |> std/store:insert(buf) { d.text }
            | row _ |> _
            | full f |> std/string:free(s: f.text)
        | err _ |> std/store:insert(buf) { d.text }
            | row _ |> _
            | full f |> std/string:free(s: f.text)
    | empty |> _
! key k when ui.page == 9 and k.ch == 127 |> std/store:take(buf[0])
    | item d |> std/string:pop-char(s: d.text) |> std/store:insert(buf) { d.text }
        | row _ |> _
        | full f |> std/string:free(s: f.text)
    | empty |> _
! key k when ui.page == 9 and k.ch == 8 |> std/store:take(buf[0])
    | item d |> std/string:pop-char(s: d.text) |> std/store:insert(buf) { d.text }
        | row _ |> _
        | full f |> std/string:free(s: f.text)
    | empty |> _
! key k when ui.page == 9 and k.ch == 13 |> std/store:take(buf[0])
    | item d |> std/string:append-char(s: d.text, k.ch)
        | ok |> std/store:insert(buf) { d.text }
            | row _ |> _
            | full f |> std/string:free(s: f.text)
        | err _ |> std/store:insert(buf) { d.text }
            | row _ |> _
            | full f |> std/string:free(s: f.text)
    | empty |> _
! key k when ui.page == 9 and k.ch >= 32 and k.ch < 127 |> std/store:take(buf[0])
    | item d |> std/string:append-char(s: d.text, k.ch)
        | ok |> std/store:insert(buf) { d.text }
            | row _ |> _
            | full f |> std/string:free(s: f.text)
        | err _ |> std/store:insert(buf) { d.text }
            | row _ |> _
            | full f |> std/string:free(s: f.text)
    | empty |> _
| err e |> std/io:print.ln("gallery failed: {{ e:s }}")
