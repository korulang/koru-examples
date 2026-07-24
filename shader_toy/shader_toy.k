// shader-toy — authored terminal fragment under dock chrome.
//
//   koru/vaxis:shader(ambient) {
//       frag = 0.28 + 0.12 * sin(u * 6.28318 + t) * cos(v * 6.28318 - t * 0.35)
//   }
//
// `frag` bindings: u,v ∈ [0,1], t = seconds. Ops: + - * / sin cos.
// Dock fill = shader window; top/bottom = chrome (bounds honored).
//
//   koruc run shader_toy.k
//
// q quits. Samplers / stacked frags = next grill.

import std/io
import std/store
import koru/vaxis

std/store:new(ui) { ms: 0[i64] }

koru/vaxis:shader(ambient) {
    frag = 0.28 + 0.12 * sin(u * 6.28318 + t) * cos(v * 6.28318 - t * 0.35)
}

koru/vaxis:component(topbar) {
    <text>{{ title:s }}</text>
}

koru/vaxis:component(statusbar) {
    <text>{{ hint:s }}</text>
}

koru/vaxis:component(scene) {
    <dock>
        <topbar dock="top" h="1" title="shader-toy · ambient { frag = … } · under chrome"/>
        <statusbar dock="bottom" h="1" hint="authored frag fill · q quit"/>
        <ambient dock="fill" t={{ t:d }}/>
    </dock>
}

koru/vaxis:run(title: "shader-toy")
| err e |> std/io:print.ln("shader-toy failed: {{ e:s }}")

koru/vaxis(shader-toy)
! draw w |> scene(win: w, t: ui.ms)
! tick ms |> std/store:stored { ui.ms: ms }
! key k when k.ch == 'q' |> koru/vaxis:quit()
