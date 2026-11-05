#!/bin/sh
# =====================================================================
#  seed/linux-x86_64/check_e1.sh — verifica del seed Linux E1
#
#  E1: runner ELF di un file .td (argv + I/O nativo) — caricamento +
#  echo del sorgente, errori con exit code e messaggio su stderr.
#  Accettazione N15 (TASK.md): `./seed file.td` legge il file; senza
#  argomenti o con file inesistente -> exit != 0 con messaggio su
#  stderr. Gli exit code seguono il contratto os_* (issue 03):
#  2 = usage, 1 = open/read fail/sorgente >= 0xF000.
#
#  Uso: sh seed/linux-x86_64/check_e1.sh [percorso-seed]
#  (default: il seed affiancato allo script). Exit 0 = tutti i casi OK.
#  Confronti byte-esatti con `cmp` (nessuna normalizzazione).
# =====================================================================
set -u
dir=$(dirname "$0")
seed=${1:-"$dir/seed"}
tmp=${TMPDIR:-/tmp}/triad-e1-$$
mkdir -p "$tmp" || exit 1
trap 'rm -rf "$tmp"' EXIT

fail() { echo "FAIL: $1" >&2; exit 1; }

test -x "$seed" || fail "seed non eseguibile: $seed"

# 1. caricamento + echo byte-exatto, exit 0, stderr vuoto
printf 'x :: Int\nx = 42\nprint(x)\n' > "$tmp/prog.td"
"$seed" "$tmp/prog.td" > "$tmp/out" 2> "$tmp/err" || fail "echo: exit != 0"
cmp "$tmp/out" "$tmp/prog.td" >/dev/null 2>&1 || fail "echo: stdout != sorgente (byte-exatto)"
test ! -s "$tmp/err" || fail "echo: stderr non vuoto"

# 2. file vuoto: echo vuoto, exit 0
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
dd if=/dev/zero of="$tmp/edge.td" bs=1 count=61439 2>/dev/null
"$seed" "$tmp/edge.td" > "$tmp/out" 2> "$tmp/err" || fail "0xEFFF: exit != 0"
cmp "$tmp/out" "$tmp/edge.td" >/dev/null 2>&1 || fail "0xEFFF: echo non byte-exatto"

# 7. sorgente 0xF000 byte: troppo grande, exit 1, stdout vuoto
dd if=/dev/zero of="$tmp/big.td" bs=1 count=61440 2>/dev/null
"$seed" "$tmp/big.td" > "$tmp/out" 2> "$tmp/err"; rc=$?
test "$rc" = 1 || fail "0xF000: exit $rc (atteso 1)"
test ! -s "$tmp/out" || fail "0xF000: stdout non vuoto"
test -s "$tmp/err" || fail "0xF000: stderr vuoto (atteso messaggio)"

echo "check E1: OK (7 casi)"
