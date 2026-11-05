#!/bin/sh
# =====================================================================
#  seed/linux-x86_64/check_seed.sh — contratto errori/limiti del seed
#  Linux (sostituisce check_e1.sh di N15 con l'interprete E2 completo).
#
#  Comportamenti verificati (contratto os_*, issue 03; identici al PE):
#    2 = usage (nessun argomento o argv[1] vuoto), 1 = open/read fail o
#    sorgente >= 0xF000 byte, 0 = esecuzione riuscita (file vuoto incluso).
#  Il sorgente massimo ammesso e' 0xEFFF byte (slot maschera a +0xF000).
#
#  Uso: sh seed/linux-x86_64/check_seed.sh [percorso-seed]
#  (default: il seed affiancato allo script). Exit 0 = tutti i casi OK.
#  Confronti byte-esatti con `cmp` (nessuna normalizzazione).
# =====================================================================
set -u
LC_ALL=C
export LC_ALL
dir=$(dirname "$0")
seed=${1:-"$dir/seed"}
tmp=${TMPDIR:-/tmp}/triad-check-seed-$$
mkdir -p "$tmp" || exit 1
trap 'rm -rf "$tmp"' EXIT

fail() { echo "FAIL: $1" >&2; exit 1; }

test -x "$seed" || fail "seed non eseguibile: $seed"

# 1. esecuzione byte-exatta, exit 0, stderr vuoto
printf 'x = 42\nprintln(x)\n' > "$tmp/prog.td"
printf '42\n' > "$tmp/prog.want"
"$seed" "$tmp/prog.td" > "$tmp/out" 2> "$tmp/err" || fail "run: exit != 0"
cmp "$tmp/out" "$tmp/prog.want" >/dev/null 2>&1 || fail "run: stdout != atteso (byte-exatto)"
test ! -s "$tmp/err" || fail "run: stderr non vuoto"

# 2. file vuoto: programma vuoto, exit 0, stdout vuoto
: > "$tmp/empty.td"
"$seed" "$tmp/empty.td" > "$tmp/out" 2> "$tmp/err" || fail "vuoto: exit != 0"
test ! -s "$tmp/out" || fail "vuoto: stdout non vuoto"

# 3. nessun argomento: exit 2 (usage) + messaggio su stderr
"$seed" > "$tmp/out" 2> "$tmp/err"; rc=$?
test "$rc" = 2 || fail "usage: exit $rc (atteso 2)"
test ! -s "$tmp/out" || fail "usage: stdout non vuoto"
test -s "$tmp/err" || fail "usage: stderr vuoto (atteso messaggio)"

# 4. argv[1] vuoto: usage come nel PE, exit 2
"$seed" "" > "$tmp/out" 2> "$tmp/err"; rc=$?
test "$rc" = 2 || fail "path vuoto: exit $rc (atteso 2)"
test -s "$tmp/err" || fail "path vuoto: stderr vuoto (atteso messaggio)"

# 5. file inesistente: exit 1 + messaggio su stderr
"$seed" "$tmp/nope.td" > "$tmp/out" 2> "$tmp/err"; rc=$?
test "$rc" = 1 || fail "apertura: exit $rc (atteso 1)"
test ! -s "$tmp/out" || fail "apertura: stdout non vuoto"
test -s "$tmp/err" || fail "apertura: stderr vuoto (atteso messaggio)"

# 6. sorgente 0xEFFF byte: limite ammesso (slot maschera a +0xF000)
{ printf 'println(42)\n'; dd if=/dev/zero bs=1 count=61427 2>/dev/null | tr '\0' '\n'; } > "$tmp/edge.td"
test "$(wc -c < "$tmp/edge.td")" = 61439 || fail "edge: dimensione sorgente != 61439"
printf '42\n' > "$tmp/edge.want"
"$seed" "$tmp/edge.td" > "$tmp/out" 2> "$tmp/err" || fail "0xEFFF: exit != 0"
cmp "$tmp/out" "$tmp/edge.want" >/dev/null 2>&1 || fail "0xEFFF: stdout != atteso (byte-exatto)"

# 7. sorgente 0xF000 byte: troppo grande, exit 1, stdout vuoto
{ printf 'println(43)\n'; dd if=/dev/zero bs=1 count=61428 2>/dev/null | tr '\0' '\n'; } > "$tmp/big.td"
test "$(wc -c < "$tmp/big.td")" = 61440 || fail "big: dimensione sorgente != 61440"
"$seed" "$tmp/big.td" > "$tmp/out" 2> "$tmp/err"; rc=$?
test "$rc" = 1 || fail "0xF000: exit $rc (atteso 1)"
test ! -s "$tmp/out" || fail "0xF000: stdout non vuoto"
test -s "$tmp/err" || fail "0xF000: stderr vuoto (atteso messaggio)"

echo "check seed: OK (7 casi)"
