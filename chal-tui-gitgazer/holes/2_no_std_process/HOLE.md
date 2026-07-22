# HOLE 2 — no idiomatic subprocess surface (`std/process` absent)

## Repro
`koruc --check input.kz` → `error[KORU002]: module not found: 'std/process'`.
(`exec`, `subprocess`, `os` are equally absent.)

## What was attempted
Import a koru-level subprocess module to run `git` the way `std/fs:read-lines`
runs a file read — effect-shaped (`! line` / `| done` / `| failed`), phantom-typed.

## Expected vs actual
- **Expected:** an importable `std/process` (or `std/exec`) with a run/lines
  surface.
- **Actual:** `KORU002 module not found`. koru_std has `fs`, `io`, `net`, `http`,
  `threading` — but nothing that wraps process execution.

## The consequence (not a compile error — an ergonomic/consistency gap)
Every subprocess-driven app drops into raw-host Zig via
`~proc <verb>|zig { std.process.Child.run(.{ .argv = ... }) }`. This app does it
in `a_git_lines.kz` and `c_gitgazer.kz`; `koru-libs/docker/index.kz` does it for
`docker run/build/stop/...`. It works, but:
1. It leaks raw `std.process.Child.run` + manual `allocator.free(stdout/stderr)`
   into every consumer — no phantom-typed, effect-shaped koru surface.
2. It steps directly onto the **already-pinned** compiler bug
   `koru/tests/regression/400_RUNTIME_FEATURES/400_141_child_run_nonzero_exit_stderr_term`:
   reading `result.term.Exited` panics when a child exits nonzero WITH stderr —
   which `git` does routinely (not-a-repo → exit 128 + stderr). This app dodges it
   with the safe `result.term == .Exited and result.term.Exited == 0` idiom, but a
   `std/process` module is exactly where that guarantee should live so no consumer
   has to know the footgun. (That pin is NOT re-authored here — it already exists
   in koru's tree; noted only as the reason a std surface matters.)

## Confidence: real gap vs might-be-me
**~85% a real gap, 15% me.** The absence is SHOWN (KORU002). Whether koru *wants*
a `std/process` yet is the design question for the walk — the FFI escape hatch is
deliberate and works. But "the whole subprocess region has no koru-level surface,
and the one place it would centralize the term-union footgun is missing" is a real,
nameable gap, not a misuse.
