#!/bin/sh
# Integration: actual install, seed success/failure, session remains usable.
set -eu
root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd -P)
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT HUP INT TERM
XDG_DATA_HOME="$tmp/data" sh "$root/install.sh" --prefix "$tmp/bin" --desktop > "$tmp/install.log"
entry="$tmp/data/applications/triad.desktop"
grep -Fqx "Exec=\"$root/bin/triad-desktop\" %f" "$entry"
grep -qx 'Terminal=true' "$entry"
if command -v desktop-file-validate >/dev/null 2>&1; then
    desktop-file-validate "$entry"
fi
program="$tmp/program with spaces.triad"
printf 'println("desktop-pass")\n' > "$program"
# No file at startup: prompt, missing-file error, then successful execution.
printf '%s\n%s\n:quit\n' "$tmp/missing.triad" "$program" |
    "$root/bin/triad-desktop" > "$tmp/session.log" 2>&1
grep -q 'codice 1' "$tmp/session.log"
grep -q 'desktop-pass' "$tmp/session.log"
grep -q 'codice 0' "$tmp/session.log"
# Associated file: success and failure both return to the prompt.
printf ':quit\n' | "$root/bin/triad-desktop" "$program" > "$tmp/open.log" 2>&1
grep -q 'desktop-pass' "$tmp/open.log"
grep -q 'Percorso del programma' "$tmp/open.log"
printf ':quit\n' | "$root/bin/triad-desktop" "$tmp/missing.triad" > "$tmp/error.log" 2>&1
grep -q 'codice 1' "$tmp/error.log"
grep -q 'Percorso del programma' "$tmp/error.log"
"$root/bin/triad-desktop" < /dev/null > "$tmp/eof.log"
grep -q 'Percorso del programma' "$tmp/eof.log"
echo 'desktop: PASS (install, menu, file con spazi, errori, EOF)'
