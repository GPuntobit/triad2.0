#!/bin/sh
# =====================================================================
#  conformance/run.sh — gate di conformita' Triad-Core (harness POSIX,
#  senza Node). Sostituisce conformance/run.mjs in un colpo solo
#  (decisione "Harness di verifica senza Node", ticket
#  .scratch/seed-linux-nativo/issues/08-harness-verifica-senza-node.md,
#  Q4 transizione + Q9 interfaccia).
#
#  Contratto:
#    - suite cablata: conformance/core/cases (40 casi); niente flag
#      --cases/--skip/--strict (Q9);
#    - oracle: golden committati expected.out + expected.code per ogni
#      caso, confronto byte-exatto con `cmp`, nessuna normalizzazione
#      CRLF (Q1/Q2, regola operativa 5);
#    - runtime: seed ELF del repo, override TRIAD_SEED; nessun fallback
#      JS e nessuna dipendenza da install.sh: il gate gira su checkout
#      nudo (Q3); seed mancante/non eseguibile -> exit 2 con errore chiaro;
#    - report di fallimento: diff -u (LC_ALL=C) fra golden e output reale
#      + riga "exit: atteso/ottenuto" (Q8); riassunto compatto finale;
#    - --update: rigenera i golden con avviso (Q6); scrittura sempre
#      rm + ricreazione, mai attraverso un symlink (protezione nota in
#      docs/security/SECURITY-REVIEW.md, ex run.mjs).
#

#  Uso: sh conformance/run.sh [--update]        (invocabile da qualunque cwd)
#  Exit: 0 = gate verde, 1 = casi falliti, 2 = ambiente non valido.
# =====================================================================
set -u
LC_ALL=C
export LC_ALL

root=$(CDPATH= cd "$(dirname "$0")/.." && pwd) || exit 2
cases="$root/conformance/core/cases"
seed=${TRIAD_SEED:-$root/seed/linux-x86_64/seed}

update=0
for a in "$@"; do
  case "$a" in
    --update) update=1 ;;
    *) echo "opzione sconosciuta: $a (uso: sh conformance/run.sh [--update])" >&2; exit 2 ;;
  esac
done

if [ ! -f "$seed" ]; then
  echo "conformance: seed non trovato: $seed" >&2
  echo "  (decodifica seed.hex oppure imposta TRIAD_SEED)" >&2
  exit 2
fi
if [ ! -x "$seed" ]; then
  echo "conformance: seed non eseguibile: $seed (chmod +x)" >&2
  exit 2
fi

tmp=${TMPDIR:-/tmp}/triad-conformance-$$
mkdir -p "$tmp" || exit 2
trap 'rm -rf "$tmp"' EXIT

if [ "$update" = 1 ]; then
  echo "ATTENZIONE: i golden si rigenerano solo per cambi semantici" >&2
  echo "           deliberati da SPEC-CORE.md (ticket 08, Q6)." >&2

fi

# confronto byte-exatto di un caso col suo golden; esito in $result
# (PASS | FAIL | GOLDEN-MANCANTE); $1 = dir del caso, $2 = nome
check_case() {
  dir=$1; name=$2
  gout="$dir/expected.out"; gcode="$dir/expected.code"
  if [ ! -f "$gout" ] || [ ! -f "$gcode" ]; then
    result=GOLDEN-MANCANTE
    return
  fi
  exp_code=$(cat "$gcode")
  if [ "$exp_code" != "$rc" ]; then
    result=FAIL
    return
  fi
  if cmp -s "$tmp/out" "$gout"; then
    result=PASS
  else
    result=FAIL
  fi
}

report_failure() {
  dir=$1; name=$2
  if [ ! -f "$dir/expected.out" ] || [ ! -f "$dir/expected.code" ]; then
    echo "FAIL  $name  (golden mancante: expected.out/expected.code)"
    return
  fi
  echo "FAIL  $name  (exit: atteso $(cat "$dir/expected.code"), ottenuto $rc)"
  if ! cmp -s "$tmp/out" "$dir/expected.out"; then
    diff -u "$dir/expected.out" "$tmp/out" | sed 's/^/      /'
  fi
  if [ -s "$tmp/err" ]; then
    echo "      stderr (informativo, non vincolante):"
    sed 's/^/      | /' "$tmp/err"
  fi
}

total=0; failed=0
for dir in "$cases"/*/; do
  [ -f "$dir/program.td" ] || continue
  name=$(basename "$dir")
  total=$((total + 1))

  # argomenti del programma: args.txt, un argomento per riga (come run.mjs)
  set -- "$dir/program.td"
  if [ -f "$dir/args.txt" ]; then
    while IFS= read -r line || [ -n "$line" ]; do
      [ -n "$line" ] && set -- "$@" "$line"
    done < "$dir/args.txt"
  fi

  if [ "$update" = 1 ]; then
    "$seed" "$@" > "$tmp/out" 2> "$tmp/err"
    rc=$?
    # rm prima della scrittura: un expected.out symlink non viene mai
    # scritto attraverso il link (SECURITY-REVIEW.md, ex run.mjs)
    rm -f "$dir/expected.out" "$dir/expected.code"
    cp "$tmp/out" "$dir/expected.out"
    echo "$rc" > "$dir/expected.code"
    echo "GOLDEN $name  (rigenerato: exit $rc)"
    continue
  fi

  "$seed" "$@" > "$tmp/out" 2> "$tmp/err"
  rc=$?

  check_case "$dir" "$name"
  case "$result" in
    PASS) echo "PASS  $name" ;;
    GOLDEN-MANCANTE)
      echo "FAIL  $name  (golden mancante: expected.out/expected.code)"
      failed=$((failed + 1)) ;;
    FAIL)
      report_failure "$dir" "$name"
      failed=$((failed + 1)) ;;
  esac
done

if [ "$failed" = 0 ]; then
  echo "conformance: $total casi, OK"
  exit 0
fi
echo "conformance: $failed casi falliti su $total"
exit 1
