#!/bin/sh
# =====================================================================
#  verify.sh — entry point unico di verifica (ticket
#  .scratch/seed-linux-nativo/issues/08-harness-verifica-senza-node.md,
#  Q7): esegue i soli entry point sh — conformance/gate.sh +
#  tests/probes/run_probes.sh + conformance/logic/run.sh. Exit 0 = gate verde.
#
#  conformance/gate.sh esegue l'oracle conformance/run.sh senza
#  esclusioni: ogni fallimento Core fa fallire il gate.
#
#  L'anti-drift del dump (seed/dev/gen_seed.js && cmp) resta step
#  separato CI/dev (Q7), come il check del contratto errori/limiti
#  (seed/linux-x86_64/check_seed.sh).
#
#  Uso: sh verify.sh        (invocabile da qualunque cwd)
# =====================================================================
set -u
root=$(CDPATH= cd "$(dirname "$0")" && pwd) || exit 2

sh "$root/conformance/gate.sh" || exit 1
sh "$root/tests/probes/run_probes.sh" || exit 1
sh "$root/conformance/logic/run.sh" || exit 1
echo "verify: OK"
