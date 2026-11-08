#!/bin/sh
# Integration: actual install, seed success/failure, session remains usable.
set -eu
root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd -P)
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT HUP INT TERM
# Isolate both MIME data and default-app configuration from the real desktop.
XDG_DATA_HOME="$tmp/data"
XDG_CONFIG_HOME="$tmp/config"
export XDG_DATA_HOME XDG_CONFIG_HOME
sh "$root/install.sh" --prefix "$tmp/bin" --desktop > "$tmp/install.log"
entry="$tmp/data/applications/triad.desktop"
grep -Fqx "Exec=\"$root/bin/triad-desktop\" %f" "$entry"
grep -qx 'Terminal=true' "$entry"
if command -v desktop-file-validate >/dev/null 2>&1; then
    desktop-file-validate "$entry"
fi
program="$tmp/program with spaces.triad"
printf 'println("desktop-pass")\n' > "$program"
# Use the same system MIME resolver/default-app lookup as a file manager.
if command -v update-mime-database >/dev/null 2>&1 &&
   command -v xdg-mime >/dev/null 2>&1; then
    [ "$(xdg-mime query default text/x-triad)" = triad.desktop ]
    # Headless xdg-mime falls back to file(1), which ignores shared-mime-info.
    # Exercise the GIO backend used by GNOME/Xfce file managers when available.
    if command -v gio >/dev/null 2>&1; then
        [ "$(XDG_CURRENT_DESKTOP=GNOME xdg-mime query filetype "$program")" = text/x-triad ]
        cp "$program" "$tmp/program.td"
        [ "$(XDG_CURRENT_DESKTOP=GNOME xdg-mime query filetype "$tmp/program.td")" = text/x-triad ]
    fi
fi
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
# Explicit logic selection must reach S1 through the real desktop launcher.
logic_file="$tmp/logic with spaces.triad"
cat > "$logic_file" <<'LOGIC'
fact parent(:alice, :bob)
fact parent(:bob, :dave)
rule grandparent(?x, ?z) :- parent(?x, ?y), parent(?y, ?z)
println([s.z for s in solve grandparent(:alice, ?z)])
LOGIC
printf ':quit\n' | "$root/bin/triad-desktop" --logic "$logic_file" > "$tmp/logic-open.log" 2>&1
grep -Fqx '[:dave]' "$tmp/logic-open.log"
grep -q 'codice 0, profilo logic' "$tmp/logic-open.log"
# Switching profiles persists, failures remain recoverable, EOF still exits.
printf ':logic\n%s\n%s\n:core\n%s\n:quit\n' \
    "$tmp/missing.triad" "$logic_file" "$program" |
    "$root/bin/triad-desktop" > "$tmp/profiles.log" 2>&1
grep -Fq '[:dave]' "$tmp/profiles.log"
grep -q 'desktop-pass' "$tmp/profiles.log"
grep -q 'codice 0, profilo logic' "$tmp/profiles.log"
grep -q 'codice 0, profilo core' "$tmp/profiles.log"
echo 'desktop: PASS (install, MIME, file con spazi, Core/logic, switch, errori, EOF)'
