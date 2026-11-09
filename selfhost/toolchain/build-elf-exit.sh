#!/bin/sh
# POSIX transport only: selects numeric exit status, runs Triad machine-code
# emitter on native S0, decodes its deterministic hex output into ELF binary.
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/../.." && pwd)
if [ "$#" -ne 2 ]; then
    echo 'usage: sh selfhost/toolchain/build-elf-exit.sh EXIT_STATUS OUTPUT_PATH' >&2
    exit 2
fi
status="$1"
output="$2"
case "$status" in
    ''|*[!0-9]*) echo 'status must be a decimal integer 0..255' >&2; exit 2 ;;
esac
[ "$status" -le 255 ] || { echo 'status out of range' >&2; exit 2; }
TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT HUP INT TERM
cat "$ROOT/selfhost/toolchain/elf64_exit.triad" > "$TMP/emit.triad"
printf '\nemit_elf_exit(%s)\n' "$status" >> "$TMP/emit.triad"
"$ROOT/bin/triad" "$TMP/emit.triad" > "$TMP/code.hex"
# Hex decoder is only an output transporter, never a code generator.
xxd -r -p "$TMP/code.hex" "$TMP/program"
[ "$(wc -c < "$TMP/program")" -eq 132 ] || {
    echo 'native Triad emitted an unexpected ELF length' >&2
    exit 1
}
chmod 755 "$TMP/program"
# Avoid replacing an existing output with an invalid partial build.
mv "$TMP/program" "$output"
