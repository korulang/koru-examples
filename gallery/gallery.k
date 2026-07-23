// gallery — sit-and-look surface for Charm / vaxis catalog widgets.
//
// Eyes for COMPONENT_CHALLENGE polish. Page through exhibits; poke the active
// one. Awkwardness is a toolchain finding — never dodge in the app.
//
//   koruc run gallery.k
//
// n/p  next/prev exhibit · space  poke (progress) · q  quit

import std/io
import std/store
import koru/vaxis

// page: 0 = progress, 1 = style swatches
std/store:new(ui) { page: 0[i64], value: 40[i64] }

koru/vaxis:component(topbar) {
    <text>{{ title:s }}</text>
}

koru/vaxis:component(statusbar) {
    <text>{{ hint:s }}</text>
}

koru/vaxis:component(blurb) {
    <text>{{ text:s }}</text>
}

// Exhibit 0 — Charm progress (purple→pink ▌/░ + %)
koru/vaxis:component(progress-exhibit) {
    <dock>
        <topbar dock="top" h="1" title="gallery · progress"/>
        <statusbar dock="bottom" h="1" hint="n/p exhibits · space +10 · q"/>
        <progress-bar dock="fill" value={{ value:d }} max={{ max:d }}/>
    </dock>
}

// Exhibit 1 — chrome only; colored swatches painted in ! draw (Style.fg/bg)
koru/vaxis:component(style-exhibit) {
    <dock>
        <topbar dock="top" h="1" title="gallery · style"/>
        <statusbar dock="bottom" h="1" hint="n/p exhibits · q"/>
        <blurb dock="fill" text="swatches below (Style fg/bg + UTF-8 runes)"/>
    </dock>
}

koru/vaxis:run(title: "gallery")
! draw w |> if(ui.page == 0)
    | then |> progress-exhibit(win: w, ui.value, max: 100)
    | else |> style-exhibit(win: w)
        |> koru/vaxis:write-styled(x: 2, y: 3, text: "▌▌▌▌▌▌░░░░░░  half-block  #5A56E0", style: { fg: 0x5A56E0 })
        |> koru/vaxis:write-styled(x: 2, y: 5, text: "████████░░░░  block  pink on slate", style: { fg: 0xEE6FF8, bg: 0x606060 })
! key k when k.ch == 'q' |> koru/vaxis:quit()
! key k when k.ch == 'n' and ui.page < 1 |> std/store:stored { ui.page: ui.page + 1 }
! key k when k.ch == 'p' and ui.page > 0 |> std/store:stored { ui.page: ui.page - 1 }
! key k when k.ch == ' ' and ui.page == 0 and ui.value < 100 |> std/store:stored { ui.value: ui.value + 10 }
! key k when k.ch == ' ' and ui.page == 0 and ui.value >= 100 |> std/store:stored { ui.value: 0 }
| err e |> std/io:print.ln("gallery failed: {{ e:s }}")
