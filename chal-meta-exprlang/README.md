# chal-meta-exprlang

A compile-time **expression DSL that lowers through a `[comptime|transform]`
event**, pushed across a module boundary and through phantom-obligation state.
Region: *comptime + language machinery*. The pretext is small; the point is to
force the front-and-middle of the chain — **parse → transform → phantom/
obligation → emit** — to interoperate until it breaks.

## What it does

`~calc-fold { 2 + 3 * 4 }` is a Source block. At **compile time**, the
transform's `|zig` body runs a recursive-descent arithmetic evaluator over
`source.text`, folds the expression to an `i64`, and **synthesizes a runtime
event + proc** (`| computed { value: i64 }`) plus a rewritten call-site flow —
then the folded program compiles and runs. Modeled on the passing pillar test
`koru/tests/regression/200_COMPILER_FEATURES/210_PARSER/210_026_template_interpolation`.

## Layers (all LAND — build through `koruc` and run)

| File | Layer | Output |
|------|-------|--------|
| `app.kz` | Single-module transform DSL | `2 + 3 * 4 = 14` |
| `cross.kz` + `calc_dsl.kz` | **Cross-module** transform (invoked qualified `~app/calc_dsl:calc-fold`) | `6 * 7 + 8 = 50` |
| `oblig.kz` + `calc_secure.kz` | **Phantom obligation** issued by transform-emitted code, discharged by the consumer | `checked 6*7+8 = 50` |

Run any of them:

```
cd chal-meta-exprlang
koruc run app.kz
koruc run cross.kz
koruc run oblig.kz
```

## Organs forced to interoperate

- **Parser / Source capture** — `Source` block text captured verbatim, parsed
  at comptime.
- **Comptime transform pass** — `[comptime|transform]event` dispatch, whole-
  program rewrite (`.transformed = .{ .whole_program = ... }`), `@pass_ran`
  re-fire guard.
- **AST emission** — hand-built `EventDecl` + `ProcDecl` + `Flow`/`Invocation`
  via `ast` + `ast_functional`.
- **Module system** — the transform lives in a separate `pub` lib module and is
  invoked cross-module; the runtime event is emitted into and the qualified call
  redirected to the consumer's module.
- **Phantom / obligation checker** — a transform-emitted branch-payload field
  carries an issued obligation (`.phantom = "checked!"`), enforced across the
  module boundary (KORU030 if undischarged).

The parts that worked hardest: the **cross-module emit** (the lib's comptime
decls are *invisible* to the transform — buried in `module_decl`s, not
rewritable items — so the qualified call must be redirected to the module where
the runtime event is emitted), and the **obligation-on-transform-emitted-field**
path (no passing suite test issues an obligation from a synthesized branch
payload).

## Negative proof

`negatives/oblig_nodischarge.kz` binds the obligation-carrying value and uses it
**without** discharging. It must fail loudly, and does:

```
error[KORU030]: Resource 'value' obligation <checked!> was not discharged.
                No event accepts <!checked>.
```

This proves the obligation is genuinely threaded through the transform-
synthesized code, not silently dropped.

## Hole surfaced

`holes/1_continuation_position_transform_panic/` — invoking the *same* proven
transform with its Source block in **continuation position**
(`~seed(): v |> calc-fold { ... }`) crashes the transform pass with a **raw host
panic** (`TRANSFORM ERROR: Invocation not replaced!` /
`panic: transform pass failed`, `transform_pass_runner.zig:1036`) instead of a
koru-level diagnostic. Top-level works; only continuation position breaks.
Corroborated by koru's own parked `TODO` at
`210_024_source_scope_capture`. See the dir's `HOLE.md` for the full
expected-vs-actual and a confidence split (diagnostic gap: HIGH real bug;
capability gap: MEDIUM, ~50% my transform not walking continuations).

## Grounding

Every koru construct used is grounded in a passing regression test (transform
shape: 210_026; cross-module obligation: 330_087; effect/branch grammar:
201_multiple_branches; bare-return proc: 020_022). The `|zig` transform bodies
are the intended authoring surface for transforms (every passing transform test
uses them); the AST field encodings are read from `koru/src/ast.zig`.
