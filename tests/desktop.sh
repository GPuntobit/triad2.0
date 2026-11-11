#!/bin/sh
# Integration: actual install, seed success/failure, session remains usable.
set -eu
root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd -P)
tmp=$(mktemp -d)
# On failure, surface captured desktop output before deleting the fixtures.
cleanup() {
    rc=$?
    if [ "$rc" -ne 0 ]; then
        printf 'desktop: integration failed (exit %s)\n' "$rc" >&2
        for log in "$tmp"/*.log; do
            [ -f "$log" ] || continue
            printf '\n--- %s ---\n' "$log" >&2
            tail -n 14 "$log" >&2
        done
    fi
    rm -rf "$tmp"
}
trap cleanup EXIT
# Isolate both MIME data and default-app configuration from the real desktop.
XDG_DATA_HOME="$tmp/data"
XDG_CONFIG_HOME="$tmp/config"
export XDG_DATA_HOME XDG_CONFIG_HOME
sh "$root/install.sh" --prefix "$tmp/bin" --desktop > "$tmp/install.log"
entry="$tmp/data/applications/triad.desktop"
grep -Fqx "Exec=\"$root/bin/triad-desktop\" %f" "$entry"
grep -qx 'Terminal=true' "$entry"
grep -Fqx 'Icon=triad' "$entry"
cmp "$root/assets/icons/triad.png" "$tmp/data/icons/hicolor/256x256/apps/triad.png"
if command -v desktop-file-validate >/dev/null 2>&1; then
    desktop-file-validate "$entry"
fi
program="$tmp/program with spaces.triad"
printf 'println("desktop-pass")\n' > "$program"
# Files with other statements are never launched without a manual profile.
guarded="$tmp/guarded.triad"
printf 'x = 1\nprintln("guarded-pass")\n' > "$guarded"
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
# No file at startup: choose explicitly, then recover from a missing file.
printf ':core\n%s\n%s\n:quit\n' "$tmp/missing.triad" "$program" |
    "$root/bin/triad-desktop" > "$tmp/session.log" 2>&1
grep -q 'codice 1' "$tmp/session.log"
grep -q 'desktop-pass' "$tmp/session.log"
grep -q 'codice 0' "$tmp/session.log"
# Plain literal println programs execute immediately from the file manager.
printf ':quit\n' | "$root/bin/triad-desktop" "$program" > "$tmp/open.log" 2>&1
grep -q 'desktop-pass' "$tmp/open.log"
grep -q 'esecuzione automatica in Core' "$tmp/open.log"
if grep -q 'Scegli il profilo' "$tmp/open.log"; then
    echo 'FAIL: literal println requested a profile' >&2
    exit 1
fi
grep -q 'Percorso del programma' "$tmp/open.log"
# Multiple prints, literal arguments, comments, and a path with spaces.
multi="$tmp/multi print.td"
printf '# commento\nprintln("prima", 42)\nprintln("seconda")\n' > "$multi"
printf ':quit\n' | "$root/bin/triad-desktop" "$multi" > "$tmp/multi.log" 2>&1
grep -Fqx 'prima42' "$tmp/multi.log"
grep -Fqx 'seconda' "$tmp/multi.log"
grep -q 'codice 0, profilo core' "$tmp/multi.log"
# A single literal print can also be entered at the desktop prompt.
printf 'println("inline-pass")\n:quit\n' |
    "$root/bin/triad-desktop" > "$tmp/inline.log" 2>&1
grep -Fqx 'inline-pass' "$tmp/inline.log"
grep -q 'esecuzione automatica in Core' "$tmp/inline.log"
# Non-literal expressions and extra statements still need explicit selection.
printf 'println(readfile("/tmp/never-execute"))\n' > "$tmp/not-literal.triad"
printf ':quit\n' | "$root/bin/triad-desktop" "$tmp/not-literal.triad" > "$tmp/not-literal.log" 2>&1
grep -q 'Scegli il profilo' "$tmp/not-literal.log"
if grep -q 'Profilo selezionato: core' "$tmp/not-literal.log"; then
    echo 'FAIL: a non-literal println was executed automatically' >&2
    exit 1
fi
printf ':quit\n' | "$root/bin/triad-desktop" "$guarded" > "$tmp/guarded.log" 2>&1
grep -q 'Scegli il profilo' "$tmp/guarded.log"
if grep -q 'guarded-pass' "$tmp/guarded.log"; then
    echo 'FAIL: a non-print-only file was executed' >&2
    exit 1
fi
printf ':core\n:quit\n' | "$root/bin/triad-desktop" "$tmp/missing.triad" > "$tmp/error.log" 2>&1
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
# Opening a logic file from the file manager never executes before selection.
printf ':logic\n:quit\n' | "$root/bin/triad-desktop" "$logic_file" > "$tmp/manual-open.log" 2>&1
grep -q 'Scegli il profilo' "$tmp/manual-open.log"
grep -Fqx '[:dave]' "$tmp/manual-open.log"
grep -q 'codice 0, profilo logic' "$tmp/manual-open.log"
# Cancellation and EOF must never execute an associated file.
printf ':quit\n' | "$root/bin/triad-desktop" "$guarded" > "$tmp/cancel.log" 2>&1
grep -q 'Esecuzione annullata' "$tmp/cancel.log"
if grep -q 'guarded-pass' "$tmp/cancel.log"; then
    echo 'FAIL: cancelled file was executed' >&2
    exit 1
fi
"$root/bin/triad-desktop" "$guarded" < /dev/null > "$tmp/no-choice.log" 2>&1
grep -q 'file non eseguito' "$tmp/no-choice.log"
if grep -q 'guarded-pass' "$tmp/no-choice.log"; then
    echo 'FAIL: file was executed without a profile' >&2
    exit 1
fi
# :auto and --auto must not enable implicit detection.
printf ':auto\n:quit\n' | "$root/bin/triad-desktop" > "$tmp/no-auto.log" 2>&1
grep -q 'Profilo automatico non disponibile' "$tmp/no-auto.log"
if "$root/bin/triad-desktop" --auto "$guarded" > "$tmp/auto-flag.log" 2>&1; then
    echo 'FAIL: --auto was accepted' >&2
    exit 1
fi
grep -q 'Profilo automatico non disponibile' "$tmp/auto-flag.log"
# Manual Core does not trigger logic; explicitly switching to logic runs S1.
printf '%s\n:logic\n%s\n:quit\n' "$logic_file" "$logic_file" |
    "$root/bin/triad-desktop" --core > "$tmp/manual-switch.log" 2>&1
grep -q 'codice 1, profilo core' "$tmp/manual-switch.log"
grep -Fq '[:dave]' "$tmp/manual-switch.log"
grep -q 'codice 0, profilo logic' "$tmp/manual-switch.log"
printf ':logic\n:quit\n' | "$root/bin/triad-desktop" \
    "$root/conformance/logic/cases/typed_declarations/program.triad" > "$tmp/typed.log" 2>&1
grep -q 'codice 0, profilo logic' "$tmp/typed.log"
if command -v xdg-mime >/dev/null 2>&1; then
# KDE without qtpaths must still register the generic MIME default quietly.
mkdir -p "$tmp/kde-config"
printf '[Default Applications]\ntext/plain=example-editor.desktop;\n' > "$tmp/kde-config/mimeapps.list"
KDE_SESSION_VERSION=6 XDG_CURRENT_DESKTOP=KDE LC_ALL=C \
    XDG_CONFIG_HOME="$tmp/kde-config" \
    sh "$root/install.sh" --prefix "$tmp/bin" --desktop > "$tmp/kde-install.log" 2> "$tmp/kde-error.log"
if grep -E 'qtpaths.*(not found|command not found)' "$tmp/kde-error.log"; then
    echo 'FAIL: KDE MIME registration depends on missing qtpaths' >&2
    exit 1
fi
grep -q '^text/plain=example-editor.desktop;' "$tmp/kde-config/mimeapps.list"
[ "$(KDE_SESSION_VERSION=0 XDG_CURRENT_DESKTOP=X-Generic XDG_CONFIG_HOME="$tmp/kde-config" xdg-mime query default text/x-triad)" = triad.desktop ]
fi
echo 'desktop: PASS (install, MIME, println automatici, scelta esplicita Core/logic, annulla, switch, errori, EOF)'
