// shader-toy — C1 authored fragment under dock chrome.
//
//   koru/vaxis:shader(ambient) {
//       glyph = "░"
//       fg = rgb(...)
//       bg = rgb(...)   // omit bg to leave cell background (D3)
//   }
//
// Bindings: u,v ∈ [0,1]; x,y cells; w,h; t seconds.
// Builtins: sin cos clamp lerp noise rgb.
//
//   koruc run shader_toy.k
//
// q quits.

import std/io
import std/store
import koru/vaxis

std/store:new(ui) { ms: 0[i64] }

// Soft wash — readable motion, not seizure; a bit more drive than ambient hush.
koru/vaxis:shader(ambient) {
    glyph = "░"
    fg = rgb(
        clamp(0.35 + 0.3 * sin(u * 6.28318 + t * 1.0) * cos(v * 6.28318 - t * 0.4), 0.0, 1.0),
        lerp(0.18, 0.58, 0.5 + 0.5 * sin(t * 0.7 + v * 3.0)),
        clamp(0.6 + 0.28 * cos(t * 0.55 + u * 2.5) + 0.12 * noise(x, y), 0.0, 1.0)
    )
    bg = rgb(0.04, 0.02, 0.11 + 0.07 * sin(t * 0.45 + u))
}

koru/vaxis:component(topbar) {
    <text>{{ title:s }}</text>
}

koru/vaxis:component(statusbar) {
    <text>{{ hint:s }}</text>
}

koru/vaxis:component(scene) {
    <dock>
        <topbar dock="top" h="1" title="shader-toy · C1 glyph+rgb · under chrome"/>
        <statusbar dock="bottom" h="1" hint="calm wash · x/y noise · q quit"/>
        <ambient dock="fill" t={{ t:d }}/>
    </dock>
}

koru/vaxis:run(title: "shader-toy")
| err e |> std/io:print.ln("shader-toy failed: {{ e:s }}")

koru/vaxis(shader-toy)
! draw w |> scene(win: w, t: ui.ms)
! tick ms when ui.ms == 0 |> std/store:stored { ui.ms: ms }
! tick ms when ui.ms > 0 |> std/store:stored { ui.ms: ms }
! key k when k.ch == 'q' |> koru/vaxis:quit()
