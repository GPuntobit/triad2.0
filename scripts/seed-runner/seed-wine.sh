#!/bin/sh
# scripts/seed-runner/seed-wine.sh — esegue il seed PE Windows su Linux via wine.
#
# Uso:
#   scripts/seed-runner/seed-wine.sh FILE.td [ARG...]   esegue un programma Triad
#   scripts/seed-runner/seed-wine.sh --check            conformance Core + probe + golden S1
#   scripts/seed-runner/seed-wine.sh --help
#
# Come runtime per i runner Node (accettano la variabile TRIAD_SEED):
#   TRIAD_SEED="$PWD/scripts/seed-runner/seed-wine.sh" node conformance/run.mjs
#   TRIAD_SEED="$PWD/scripts/seed-runner/seed-wine.sh" node tests/probes/run_probes.mjs --strict
#
# Il PE si decodifica una sola volta nella cache
# (${XDG_CACHE_HOME:-$HOME/.cache}/triad2.0/seed-wine) e si rigenera quando
# cambia l'impronta SHA-256 di seed.hex. Strumento di SVILUPPO locale: la CI di
# Windows esegue il seed nativo; questa catena non entra nel bootstrap S0→S4.
set -e

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
HEX="$ROOT/seed/windows-x86_64/seed.hex"
CACHE="${XDG_CACHE_HOME:-$HOME/.cache}/triad2.0/seed-wine"
EXE="$CACHE/seed.exe"
SELF="$ROOT/scripts/seed-runner/seed-wine.sh"

die() { echo "seed-wine: $*" >&2; exit 2; }

case "${1:-}" in
  --help)
    cat <<'EOF'
Uso:
  seed-wine.sh FILE.td [ARG...]   esegue un programma Triad sul seed PE via wine
  seed-wine.sh --check            conformance Core + probe ok_*/test_* + golden S1
  seed-wine.sh --help             questo messaggio

Runtime per i runner Node:
  TRIAD_SEED="$PWD/scripts/seed-runner/seed-wine.sh" node conformance/run.mjs
  TRIAD_SEED="$PWD/scripts/seed-runner/seed-wine.sh" node tests/probes/run_probes.mjs --strict

Requisiti: wine, xxd, node (solo per --check). Il PE si decodifica in cache e
si rigenera quando cambia seed.hex.
EOF
    exit 0
    ;;
esac

command -v wine >/dev/null 2>&1 || die "wine non trovato: installa wine per eseguire il seed PE su questo sistema"
[ -f "$HEX" ] || die "dump non trovato: $HEX"

if [ ! -f "$EXE" ] || ! command -v sha256sum >/dev/null 2>&1 && ! command -v shasum >/dev/null 2>&1; then
  : # la cache si rigenera sotto
fi

hash=""
if command -v sha256sum >/dev/null 2>&1; then
  hash="$(sha256sum "$HEX" | cut -d' ' -f1)"
elif command -v shasum >/dev/null 2>&1; then
  hash="$(shasum -a 256 "$HEX" | cut -d' ' -f1)"
fi

mkdir -p "$CACHE"
if [ ! -f "$EXE" ] || [ -z "$hash" ] || [ "$(cat "$CACHE/seed.hex.sha256" 2>/dev/null)" != "$hash" ]; then
  command -v xxd >/dev/null 2>&1 || die "xxd non trovato (pacchetto xxd o vim-common)"
  xxd -r -p "$HEX" "$EXE"
  [ -n "$hash" ] && echo "$hash" > "$CACHE/seed.hex.sha256"
fi

if [ "${1:-}" = "--check" ]; then
  command -v node >/dev/null 2>&1 || die "node non trovato (serve per --check)"
  cd "$ROOT"
  echo "== conformance Core (PE via wine; 'liste' skippata: gap S0.2 noto) =="
  TRIAD_SEED="$SELF" node conformance/run.mjs --cases conformance/core/cases --skip liste
  echo "== probe ok_*/test_* (seed PE vs interprete JS) =="
  TRIAD_SEED="$SELF" node tests/probes/run_probes.mjs --strict
  echo "== front-end S1: golden selfhost/source.expected.out =="
  TRIAD_SEED="$SELF" node tests/probes/run_probes.mjs selfhost/source.td
  echo "seed-wine --check: OK"
  exit 0
fi

export WINEDEBUG=-all
exec wine "$EXE" "$@"
