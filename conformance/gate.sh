#!/bin/sh
# Gate completo Triad-Core: nessun caso escluso o fallimento tollerato.
# L'oracle confronta stdout byte per byte ed exit code di tutti i casi.
# Uso: sh conformance/gate.sh
# Exit code: 0 = tutti i casi passano, 1 = fallimento, 2 = ambiente invalido.
root=$(CDPATH= cd "$(dirname "$0")/.." && pwd) || exit 2
exec sh "$root/conformance/run.sh"
