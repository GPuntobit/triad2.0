#!/bin/sh
# =====================================================================
#  tests/probes/run_probes.sh — gate dei probe (harness POSIX, senza
#  Node). Sostituisce tests/probes/run_probes.mjs in un colpo solo
#  (ticket .scratch/seed-linux-nativo/issues/08-harness-verifica-senza-node.md,
#  Q1/Q4/Q9/Q11).
#
#  Suite cablate (nessun flag):
#    - selfhost: source.td (front-end S1) + main.td (smoke), golden
#      <file>.expected.out + <file>.expected.code;
#    - probe ok_*/test_*: golden sidecar committati (Q1), confronto
#      byte-exatto con `cmp` (Q2);
#    - probe bad_*: exit != 0 + stdout vuoto (Q5) — nessun vincolo sui
#      testi d'errore ne' sul codice specifico: il PE e' muto per
#      contratto, il stderr dell'ELF e' fuori parita'.
#
#  Eccezioni misurate ai `bad_*` (registrazione, non semantica nuova):
#    - bad_confronto_stringa, bad_escape_stringa, bad_scope_dinamico,
#      bad_separatore_newline, bad_intero_64bit: esito deterministico ma
#      FUORI dalla regola Q5 (exit 0 e/o stdout non vuoto): congelati come
#      golden sidecar, meccanismo unico di verita' (Q1/Q11);
#    - bad_stringa_plus_equals: `+=` su stringhe e' spazzatura
#      non deterministica (puntatori leakati, ASLR): nessun confronto di
#      stdout possibile, si registra solo "exit 0" (il programma non
#      crasha). Vedere tests/probes/README.md, matrice dei limiti.
#
#  Runtime: seed ELF del repo, override TRIAD_SEED; nessun fallback JS
#  (Q3); seed mancante/non eseguibile -> exit 2 con errore chiaro.
#
#  Uso: sh tests/probes/run_probes.sh        (invocabile da qualunque cwd)
#  Exit: 0 = gate verde, 1 = probe falliti, 2 = ambiente non valido.
# =====================================================================
set -u
LC_ALL=C
export LC_ALL

root=$(CDPATH= cd "$(dirname "$0")/../.." && pwd) || exit 2
seed=${TRIAD_SEED:-$root/seed/linux-x86_64/seed}

if [ "$#" -gt 0 ]; then
  echo "uso: sh tests/probes/run_probes.sh (nessun flag, suite cablate)" >&2
  exit 2
fi

if [ ! -f "$seed" ]; then
  echo "run_probes: seed non trovato: $seed" >&2
  echo "  (decodifica seed.hex oppure imposta TRIAD_SEED)" >&2
  exit 2
fi
if [ ! -x "$seed" ]; then
  echo "run_probes: seed non eseguibile: $seed (chmod +x)" >&2
  exit 2
fi

tmp=${TMPDIR:-/tmp}/triad-probes-$$
mkdir -p "$tmp" || exit 2
trap 'rm -rf "$tmp"' EXIT

cd "$root" || exit 2

total=0; failed=0

# esegue il seed su un file e registra out/err/rc nei file di $tmp.
# Il sottoguscio redirige il proprio stderr: i messaggi del shell sui
# crash (es. bad_lista_alloc, limite noto dell'heap) non inquinano il
# report, mentre il stderr del seed resta catturato in $tmp/err.
run_seed() {
  ( exec "$seed" "$1" > "$tmp/out" 2> "$tmp/err" ) 2>/dev/null
  rc=$?
}

# confronto byte-exatto col golden sidecar <base>.expected.out/.expected.code
check_sidecar() {
  base=$1
  if [ ! -f "$base.expected.out" ] || [ ! -f "$base.expected.code" ]; then
    echo "FAIL  ${base##*/}  (golden mancante: $base.expected.out/.expected.code)"
    failed=$((failed + 1))
    return
  fi
  exp_code=$(cat "$base.expected.code")
  if [ "$exp_code" = "$rc" ] && cmp -s "$tmp/out" "$base.expected.out"; then
    echo "PASS  ${base##*/}"
    return
  fi
  echo "FAIL  ${base##*/}  (exit: atteso $exp_code, ottenuto $rc)"
  if ! cmp -s "$tmp/out" "$base.expected.out"; then
    diff -u "$base.expected.out" "$tmp/out" | sed 's/^/      /'
  fi
  failed=$((failed + 1))
}

# regola Q5 dei bad_*: exit != 0 + stdout vuoto, nessun vincolo su
# codice specifico o testi d'errore
check_bad() {
  base=$1
  if [ "$rc" != 0 ] && [ ! -s "$tmp/out" ]; then
    echo "PASS  ${base##*/}  (exit $rc, stdout vuoto)"
    return
  fi
  echo "FAIL  ${base##*/}  (atteso exit != 0 + stdout vuoto, ottenuto exit $rc + $(wc -c < "$tmp/out") byte)"
  failed=$((failed + 1))
}

# ---- 1. selfhost: front-end S1 + smoke ---------------------------------
for f in selfhost/source.td selfhost/main.td; do
  total=$((total + 1))
  run_seed "$f"
  check_sidecar "${f%.td}"
done

# ---- 2. probe ok_*/test_*: golden sidecar (Q1/Q11) ---------------------
for f in tests/probes/ok_*.td tests/probes/test_*.td; do
  total=$((total + 1))
  run_seed "$f"
  check_sidecar "${f%.td}"
done

# ---- 3. probe bad_*: Q5 con le eccezioni misurate ----------------------
for f in tests/probes/bad_*.td; do
  total=$((total + 1))
  base=${f%.td}
  run_seed "$f"
  case "${f##*/}" in
    bad_confronto_stringa.td|bad_escape_stringa.td|bad_scope_dinamico.td|bad_separatore_newline.td|bad_intero_64bit.td)
      check_sidecar "$base" ;;
    bad_stringa_plus_equals.td)
      # spazzatura non deterministica (ASLR): solo "non crasha"
      if [ "$rc" = 0 ]; then
        echo "PASS  ${base##*/}  (exit 0; stdout non deterministico, non confrontato)"
      else
        echo "FAIL  ${base##*/}  (atteso exit 0, ottenuto $rc)"
        failed=$((failed + 1))
      fi ;;
    *)
      check_bad "$base" ;;
  esac
done

if [ "$failed" = 0 ]; then
  echo "probes: $total probe, OK"
  exit 0
fi
echo "probes: $failed probe falliti su $total"
exit 1
