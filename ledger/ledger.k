// ledger — a koru program that spans MULTIPLE FILES with real structure.
//
//   ledger.k          entry
//   money/index.kz    directory module, auto-indexed
//   report/index.kz   directory module importing app/money (transitive hop)
//
// Every import is `app/<name>` — the entry's own package namespace. money began
// life as a flat `money.kz` sibling and was promoted to `money/index.kz` with
// NO change to any import.
//
//   koruc run ledger.k

import std/io
import app/report

app/report:balance(opening: 5000, debit: 1250, credit: 300): b
|> std/io:print.ln("closing balance: {{ b:d }} minor units")
