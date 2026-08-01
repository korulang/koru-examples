// downloads — three concurrent HTTP transfers, each with its own live bar.
//
// The point of the program: `curl:poll` is NON-BLOCKING and it BORROWS the
// promise. One pass per call, advance every transfer as far as it can go
// without waiting, hand nothing back. That is exactly the shape a frame loop
// wants, so the batch can be pumped from `! tick` and the screen redrawn from
// `! draw` — one thread, no callbacks, no executor.
//
// The batch lives in a store between frames, and it is never TAKEN out: `poll`
// wants `*Pending<open>`, a borrow, so the store keeps the `<open!>` for the
// whole run. That is what is actually true — polling a batch never made it stop
// being the store's. Ending it is a different act, and a consuming one:
// `finish` takes `<!open>`, because a phantom obligation can only be consumed
// on an INPUT, never on a branch.
//
// One row per transfer, so `! progress` writes the row it names instead of
// three transfers stomping one cell — and the rows are SEEDED BY `! started-multi`,
// the arm `multi.start` pulses once per transfer. That matters more than it
// looks: the row is created by the same act that creates the transfer, so the
// two cannot drift. Add a fourth URL and a fourth bar appears. The earlier
// spelling was three literal `insert(xfers)` rows hand-counted to agree with
// three literal URLs, and forgetting one lost a bar with no error at all.
//
// A sweep arm BINDS its row, so the two nested sweeps below name two different
// rows — `b.p` is the batch's promise and `x.pct` is a transfer's percentage,
// in the same arm, with nothing ambient deciding which store either belongs to
// (690_086 / 690_087).
//
//   koruc run downloads.k
//
// q quit

import std/io
import std/store
import koru/vaxis
import koru/curl

std/store:new(ui) { done: 0[i64], live: 1[i64] }
std/store:new(xfers, capacity: 8) { idx: i64, pct: 0[i64] }

std/store:new(batch, capacity: 2) { *koru/curl:Pending<open!> }
! discharge p |> koru/curl:cancel(p) |> koru/curl:multi.close()

koru/vaxis:component(topbar) {
    <text>{{ title:s }}</text>
}

koru/vaxis:component(statusbar) {
    <text>{{ hint:s }}</text>
}

koru/vaxis:component(frame) {
    <dock>
        <topbar dock="top" h="1" title="downloads · three transfers, one thread"/>
        <statusbar dock="bottom" h="1" hint="q quit"/>
    </dock>
}

// Start the batch once, at load. The obligation chain is the whole story:
// `multi.new` issues an EMPTY batch, `multi.add` moves it to `open`,
// `multi.start` accepts only `open` and converts it into a promise. Skip a step
// and it does not compile. Nothing threads `m` by hand — the thread fills the
// one unfilled parameter whose type it matches.
koru/curl:multi.new()
|> koru/curl:multi.add(url: "https://speed.cloudflare.com/__down?bytes=10000000")
|> koru/curl:multi.add(url: "http://speedtest.tele2.net/10MB.zip")
|> koru/curl:multi.add(url: "https://proof.ovh.net/files/10Mb.dat")
|> koru/curl:multi.start()
! started-multi t |> std/store:insert(xfers) { idx: t.index, pct: 0 }
| started p |> std/store:insert(batch) { p }
    | full f |> koru/curl:cancel(p: f): m |> koru/curl:multi.close(m)
| failed e |> std/io:print.ln("could not start: {{ e.msg:s }}")

// One frame's worth of transfer. The promise is BORROWED, never taken, so
// there is no remove-and-reinsert per tick and no swap-remove shuffling rows
// behind an index.
tor pump {}
pump = std/store:query(batch)
! query p |> koru/curl:poll(p)
    ! progress pr |> std/store:query(xfers)
        ! query x when x.idx == pr.index |> std/store:stored { x.pct: pr.percent }
    ! finished r |> std/store:stored { ui.done: ui.done + 1 }
    | running |> _
    | complete |> std/store:stored { ui.live: 0 }

koru/vaxis:run(title: "downloads")
| err e |> std/io:print.ln("downloads failed: {{ e:s }}")

koru/vaxis(downloads)
! draw w |> frame(win: w)
    |> koru/vaxis:sub-fill(parent: w, top: 1, bottom: 1): body
    |> koru/vaxis:stack(parent: body): st
    |> std/store:query(xfers)
    ! query x |> koru/vaxis:stack-row(stack: st): bar
        |> koru/vaxis:progress-bar(win: bar, value: x.pct, max: 100)
! tick _ when ui.live == 1 |> pump()
! key k when k.ch == 'q' |> koru/vaxis:quit()
