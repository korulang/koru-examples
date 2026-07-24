// shader-toy — terminal fragment fill under dock chrome.
//
// Smallest pin of the hard detour: a window of cells is a fragment domain
// (uv × time → glyph + color), painted UNDER UI by layout slots — pulse
// owns `dock="fill"`, top/bottom chrome are separate Windows.
//
//   koruc run shader_toy.k
//
// Next rung: `koru/vaxis:shader(name) { frag = … }` + table samplers.
// q quits.

import std/io
import std/store
import koru/vaxis

std/store:new(ui) { ms: 0[i64] }

koru/vaxis:component(topbar) {
    <text>{{ title:s }}</text>
}

koru/vaxis:component(statusbar) {
    <text>{{ hint:s }}</text>
}

koru/vaxis:component(scene) {
    <dock>
        <topbar dock="top" h="1" title="shader-toy · pulse (uv × time) · under chrome"/>
        <statusbar dock="bottom" h="1" hint="fragment fill in the middle band · q quit"/>
        <pulse dock="fill" t={{ t:d }}/>
    </dock>
}

koru/vaxis:run(title: "shader-toy")
| err e |> std/io:print.ln("shader-toy failed: {{ e:s }}")

koru/vaxis(shader-toy)
! draw w |> scene(win: w, t: ui.ms)
! tick ms |> std/store:stored { ui.ms: ms }
! key k when k.ch == 'q' |> koru/vaxis:quit()
