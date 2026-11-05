#!/bin/sh
# scripts/seed-runner/seed-wine.sh — esegue il seed PE Windows su Linux via wine.
#
# Uso:
#   scripts/seed-runner/seed-wine.sh FILE.td [ARG...]   esegue un programma Triad
#   scripts/seed-runner/seed-wine.sh --check            conformance Core + probe + golden S1
#   scripts/seed-runner/seed-wine.sh --help
#
# Come runtime per gli harness POSIX (accettano la variabile TRIAD_SEED):
#   TRIAD_SEED="$PWD/scripts/seed-runner/seed-wine.sh" sh conformance/run.sh
#   TRIAD_SEED="$PWD/scripts/seed-runner/seed-wine.sh" sh tests/probes/run_probes.sh
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
  seed-wine.sh --check            conformance Core + probe + golden S1 + smoke
  seed-wine.sh --help             questo messaggio

Runtime per gli harness POSIX:
  TRIAD_SEED="$PWD/scripts/seed-runner/seed-wine.sh" sh conformance/run.sh
  TRIAD_SEED="$PWD/scripts/seed-runner/seed-wine.sh" sh tests/probes/run_probes.sh

Requisiti: wine, xxd. Il PE si decodifica in cache e si rigenera quando
cambia seed.hex.
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
  cd "$ROOT"
  echo "== conformance Core (PE via wine; gap 'liste' registrato nell'harness) =="
  TRIAD_SEED="$SELF" sh conformance/run.sh
  echo "== probe ok_*/test_* + bad_* + golden S1 + smoke (sidecar committati) =="
  TRIAD_SEED="$SELF" sh tests/probes/run_probes.sh
  echo "seed-wine --check: OK"
  exit 0
fi

export WINEDEBUG=-all
exec wine "$EXE" "$@"
