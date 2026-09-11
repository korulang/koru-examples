// kopium-demo — the headed kopium surface replayed against a CANNED agent.
// No model, no bridge, no spend: the "agent" is a tape of scripted turns the
// transcript consumes one row per submit. Everything else is the real thing —
// the chrome (topbar/statusbar, scrollview transcript, thinking strip, draft
// line) and the whole decoded input surface (chars, enter, backspace, escape,
// arrows, pages, wheel, ctrl chords, and bracketed paste into the draft).
//
//   koruc run agent.k
//
// type · enter runs a scripted turn · backspace · paste lands in the draft ·
// arrows/wheel scroll · pgup/pgdn pages · ^u/^d/^t/^b jumps · esc quit

import std/io
import std/string
import std/fmt
import std/store
import koru/vaxis

// ── state ───────────────────────────────────────────────────────────────────
// Same shape as headed.k: scroll geometry is a state machine the arms steer,
// and follow=1 is what keeps the transcript pinned while the tape appends.
std/store:new(scroll) { y: 0[i64], follow: 1[i64], h: 10[i64], ty: 1[i64], lines: 1[i64], w: 80[i64] }

std/store:new(transcript, capacity: 2) { *std/string:String<instance!> }
std/store:new(draft, capacity: 2) { *std/string:String<instance!> }
std/store:new(thinking, capacity: 2) { *std/string:String<instance!> }
std/store:new(ui) { turn: 0[i64] }

// ── transcript plumbing ─────────────────────────────────────────────────────
tor show { text: string }
show = std/store:query(transcript)
! query buf |> std/string:append(s: buf, text)
    | ok |> rescroll()
    | err _ |> _

tor rescroll {}
rescroll = std/store:query(transcript)
! query buf |> std/fmt:ln("{{ buf:S }}"): t |> koru/vaxis:wrap-lines(content: t.text, width: scroll.w): wrapped |> std/string:split(s: wrapped, sep: "\n")
    ! piece _ |> _
    | done n when scroll.follow == 1 and @as(i64, @intCast(n)) > scroll.h |> std/store:stored { scroll.lines: @as(i64, @intCast(n)), scroll.y: @as(i64, @intCast(n)) - scroll.h }
    | done n when scroll.follow == 1 |> std/store:stored { scroll.lines: @as(i64, @intCast(n)), scroll.y: 0 }
    | done n when scroll.y > @as(i64, @intCast(n)) - 1 |> std/store:stored { scroll.lines: @as(i64, @intCast(n)), scroll.y: @as(i64, @intCast(n)) - 1 }
    | done n |> std/store:stored { scroll.lines: @as(i64, @intCast(n)) }

// ── the canned agent ────────────────────────────────────────────────────────
// The "agent" is a fixed script picked by cond(ui.turn): one arm per scripted
// turn, the catchall is the honest script-out. Deterministic — no model, no
// bridge, no spend.
tor reply {}
reply = cond(ui.turn)
| c t when t == 0 |> show(text: "agent: no model is attached — this transcript is a script. It still scrolls, still wraps, still takes your paste.\n\n")
| c t when t == 1 |> show(text: "agent: · notes:create \"demo note\"\n· result: note id 7\n\nagent: made a note (pretend). the two lines above are the verdict chrome kopium prints around a real tool call.\n\n")
| c t when t == 2 |> show(text: "agent: · notes:open 99\n· dispatch-error: row absent — kopium says so; it does not cover it up\n\n")
| c t when t == 3 |> show(text: "agent: try pasting something long into the draft — bracketed paste lands as ONE chunk, not a key burst.\n\n")
| c _ |> show(text: "agent: that is the whole script — the draft still edits and the scroll still scrolls.\n\n")

tor submit {}
submit = std/store:query(draft)
! query d |> std/fmt:ln("{{ d:S }}"): u |> std/store:stored { scroll.follow: 1 }
    |> show(text: "you: ")
    |> show(u.text)
    |> show(text: "\n\n")
    |> std/string:clear(s: d)
    |> reply()
    |> std/store:stored { ui.turn: ui.turn + 1 }

// ── chrome ──────────────────────────────────────────────────────────────────
koru/vaxis:component(topbar) {
    <text>{{ title:s }}</text>
}

koru/vaxis:component(statusbar) {
    <text>{{ hint:s }}</text>
}

koru/vaxis:component(frame) {
    <dock>
        <topbar dock="top" h="1" title="kopium · canned agent tape — no model attached"/>
        <statusbar dock="bottom" h="1" hint="enter send · wheel/arrows/pgup/pgdn scroll · paste into draft · esc quit"/>
    </dock>
}

// ── seed ────────────────────────────────────────────────────────────────────
std/string:from-page(text: "kopium-demo — a canned agent lives here. type + enter to run a scripted turn; the wheel, the arrows and bracketed paste are all live.\n\n")
| ok a |> std/string:take(s: a): t |> std/store:insert(transcript) { t }
    | row _ |> _
    | full f |> std/string:free(s: f)
| err _ |> _

std/string:from-page(text: "")
| ok b |> std/string:take(s: b): d |> std/store:insert(draft) { d }
    | row _ |> _
    | full f |> std/string:free(s: f)
| err _ |> _

std/string:from-page(text: "")
| ok c |> std/string:take(s: c): v |> std/store:insert(thinking) { v }
    | row _ |> _
    | full f |> std/string:free(s: f)
| err _ |> _

// ── run ─────────────────────────────────────────────────────────────────────
// Decoded arms all the way down — no codepoints, no button numbers. `! paste`
// binding the arm is also what turns bracketed-paste mode on.
koru/vaxis:run(title: "kopium-demo")
| err e |> std/io:print.ln("vaxis failed: {{ e:s }}")

koru/vaxis(kopium-demo)
! draw w |> frame(win: w)
    |> koru/vaxis:sub-fill(parent: w, top: 1, bottom: 4): body
    |> koru/vaxis:sub-from-bottom(parent: w, up: 2, h: 1): iw
    |> std/store:query(draft)
    ! query d |> std/fmt:ln("> {{ d:S }}_"): line |> koru/vaxis:write-in(win: iw, x: 0, y: 0, line.text) |> std/store:query(transcript)
        ! query buf |> std/fmt:ln("{{ buf:S }}"): tline |> koru/vaxis:scrollview(win: body, content: tline.text, offset: scroll.y) |> std/store:query(thinking)
            ! query tk |> std/fmt:ln("{{ tk:S }}  — canned agent · the tape feeds one turn per enter                                                                                                    "): thl
                |> koru/vaxis:style(bold: false, dim: true, italic: true, strikethrough: false): st
                |> koru/vaxis:write-styled(x: 0, y: @as(u16, @intCast(scroll.ty)), thl.text, style: st)
! resize s |> std/store:stored { scroll.h: s.height - 5, scroll.ty: s.height - 4, scroll.w: s.width } |> rescroll()
! escape _ |> koru/vaxis:quit()
! ctrl k when k.ch == 'u' and scroll.y > scroll.h - 2 |> std/store:stored { scroll.y: scroll.y - (scroll.h - 2), scroll.follow: 0 }
! ctrl k when k.ch == 'u' |> std/store:stored { scroll.y: 0, scroll.follow: 0 }
! ctrl k when k.ch == 'd' and scroll.y + scroll.h - 2 < scroll.lines - scroll.h |> std/store:stored { scroll.y: scroll.y + (scroll.h - 2) }
! ctrl k when k.ch == 'd' and scroll.y + scroll.h - 2 >= scroll.lines - scroll.h and scroll.lines > scroll.h |> std/store:stored { scroll.y: scroll.lines - scroll.h, scroll.follow: 1 }
! ctrl k when k.ch == 't' |> std/store:stored { scroll.y: 0, scroll.follow: 0 }
! ctrl k when k.ch == 'b' and scroll.lines > scroll.h |> std/store:stored { scroll.y: scroll.lines - scroll.h, scroll.follow: 1 }
! ctrl k when k.ch == 'b' |> std/store:stored { scroll.y: 0, scroll.follow: 1 }
! up _ when scroll.y > 0 |> std/store:stored { scroll.y: scroll.y - 1, scroll.follow: 0 }
! down _ when scroll.lines > scroll.h and scroll.y + 1 >= scroll.lines - scroll.h |> std/store:stored { scroll.y: scroll.lines - scroll.h, scroll.follow: 1 }
! down _ when scroll.lines > scroll.h |> std/store:stored { scroll.y: scroll.y + 1, scroll.follow: 0 }
! page-up _ when scroll.y > scroll.h - 2 |> std/store:stored { scroll.y: scroll.y - (scroll.h - 2), scroll.follow: 0 }
! page-up _ |> std/store:stored { scroll.y: 0, scroll.follow: 0 }
! page-down _ when scroll.lines > scroll.h and scroll.y + scroll.h - 2 < scroll.lines - scroll.h |> std/store:stored { scroll.y: scroll.y + (scroll.h - 2), scroll.follow: 0 }
! page-down _ when scroll.lines > scroll.h |> std/store:stored { scroll.y: scroll.lines - scroll.h, scroll.follow: 1 }
! page-down _ |> std/store:stored { scroll.follow: 1 }
! wheel-up _ when scroll.y > 2 |> std/store:stored { scroll.y: scroll.y - 3, scroll.follow: 0 }
! wheel-up _ |> std/store:stored { scroll.y: 0, scroll.follow: 0 }
! wheel-down _ when scroll.lines > scroll.h and scroll.y + 3 >= scroll.lines - scroll.h |> std/store:stored { scroll.y: scroll.lines - scroll.h, scroll.follow: 1 }
! wheel-down _ when scroll.lines > scroll.h |> std/store:stored { scroll.y: scroll.y + 3, scroll.follow: 0 }
! wheel-down _ |> std/store:stored { scroll.follow: 1 }
! enter _ |> submit()
! backspace _ |> std/store:query(draft)
    ! query d |> std/string:pop-char(s: d)
! char k when k.ch >= 32 and k.ch < 127 |> std/store:query(draft)
    ! query d |> std/string:append-char(s: d, k.ch)
        | ok |> _
        | err _ |> _
! paste t |> std/store:query(draft)
    ! query d |> std/string:append(s: d, text: t)
        | ok |> _
        | err _ |> _
