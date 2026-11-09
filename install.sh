#!/bin/sh
# =====================================================================
#  install.sh — installazione di Triad su Linux (zero-install, ticket
#  .scratch/seed-linux-nativo/issues/07-installazione-launcher.md)
#
#  Cosa fa:
#    1. Decodifica il seed ELF Linux da seed.hex con il solo pavimento
#       garantito (printf POSIX con escape ottali — ticket 06); nessuna
#       dipendenza da xxd/python3. La decodifica è deterministica: il
#       confronto col binario committato è anche verifica anti-drift.
#    2. Installa i launcher triad e triad-cli come wrapper sh a percorso
#       assoluto in ~/.local/bin (o in --prefix DIR): niente symlink.
#    3. Smoke test byte-exatto: triad tests/probes/test_simple.td
#       confrontato con cmp col golden tests/probes/test_simple.expected.out;
#       un mismatch FA FALLIRE l'installazione (exit non-zero).
#    4. Opzionale (--desktop): voce menu freedesktop.org ("Triad Program")
#       per eseguire file .triad/.td in una sessione terminale persistente.
#
#  Uso:
#    ./install.sh [--prefix DIR] [--desktop] [--no-desktop]
#
#  Nessuna dipendenza oltre a una shell POSIX. Node.js NON serve al
#  percorso utente (triad / triad-cli run|test|status): serve solo per i
#  comandi di sviluppo (node cli/triad-cli.mjs), fuori dalla promessa
#  zero-install.
#
#  Fuori da Linux x86-64 l'installazione è parziale (soli launcher +
#  PATH): decodifica e smoke test saltati con avviso, exit 0 (07 Q6).
# =====================================================================

set -eu

PREFIX="${HOME}/.local/bin"
DESKTOP="auto"   # auto | yes | no

usage() {
    sed -n '3,27p' "$0" | sed 's/^# \{0,1\}//'
}

while [ $# -gt 0 ]; do
    case "$1" in
        --prefix)
            [ $# -ge 2 ] || { echo "install.sh: --prefix vuole un percorso" >&2; exit 2; }
            PREFIX="$2"; shift 2 ;;
        --desktop)     DESKTOP=yes; shift ;;
        --no-desktop)  DESKTOP=no; shift ;;
        -h|--help)     usage; exit 0 ;;
        *) echo "install.sh: opzione sconosciuta: $1 (usa --help)" >&2; exit 2 ;;
    esac
done

# --- localizzazione del repository ------------------------------------
self="$0"
while [ -L "$self" ]; do
    link=$(readlink "$self" 2>/dev/null) || break
    case $link in
        /*) self="$link" ;;
        *)  self="$(dirname "$self")/$link" ;;
    esac
done
ROOT="$(cd "$(dirname "$self")" && pwd)"

echo "==> Triad install — radice progetto: $ROOT"

# --- piattaforma -------------------------------------------------------
NATIVE=0
case "$(uname -s) $(uname -m)" in
    Linux*x86_64*) NATIVE=1 ;;
    *) echo "    (avviso) piattaforma non Linux x86-64: installazione PARZIALE" >&2
       echo "    (launcher + PATH; decodifica seed e smoke test saltati)" >&2 ;;
esac

if [ ! -x "$ROOT/bin/triad" ] || [ ! -x "$ROOT/bin/triad-cli" ]; then
    chmod +x "$ROOT/bin/triad" "$ROOT/bin/triad-cli" 2>/dev/null || true
fi

# --- 1. decodifica del seed ELF (printf POSIX puro, ticket 06) ---------
# Formato seed.hex: coppie hex minuscole, whitespace. Escape ottali \0NNN
# interpretati da `printf '%b'` (POSIX). Un solo decoder, nessun ramo.
decode_hex_pure() {
    # $1 = file hex sorgente, $2 = file binario di uscita
    hexfile="$1"
    out="$2"
    : > "$out" || return 1
    while IFS= read -r line || [ -n "$line" ]; do
        # word splitting sul whitespace: ogni parola è una catena hex
        set -- $line
        chunk=""
        for word in "$@"; do
            w="$word"
            while [ -n "$w" ]; do
                pair="${w%"${w#??}"}"          # primi 2 caratteri
                w="${w#??}"
                [ -n "$pair" ] || break
                hi="${pair%?}"
                lo="${pair#?}"
                case "$hi" in
                    0) hv=0;; 1) hv=1;; 2) hv=2;; 3) hv=3;; 4) hv=4;;
                    5) hv=5;; 6) hv=6;; 7) hv=7;; 8) hv=8;; 9) hv=9;;
                    a) hv=10;; b) hv=11;; c) hv=12;; d) hv=13;; e) hv=14;; f) hv=15;;
                    A) hv=10;; B) hv=11;; C) hv=12;; D) hv=13;; E) hv=14;; F) hv=15;;
                    *) echo "install.sh: hex non valido in $hexfile" >&2; return 1 ;;
                esac
                case "$lo" in
                    0) lv=0;; 1) lv=1;; 2) lv=2;; 3) lv=3;; 4) lv=4;;
                    5) lv=5;; 6) lv=6;; 7) lv=7;; 8) lv=8;; 9) lv=9;;
                    a) lv=10;; b) lv=11;; c) lv=12;; d) lv=13;; e) lv=14;; f) lv=15;;
                    A) lv=10;; B) lv=11;; C) lv=12;; D) lv=13;; E) lv=14;; F) lv=15;;
                    *) echo "install.sh: hex non valido in $hexfile" >&2; return 1 ;;
                esac
                b=$((hv * 16 + lv))
                oct="$((b / 64))$(( (b % 64) / 8 ))$((b % 8))"
                chunk="${chunk}\\0${oct}"
            done
        done
        if [ -n "$chunk" ]; then
            printf '%b' "$chunk" >> "$out" || return 1
        fi
    done < "$hexfile"
    return 0
}

SEED_DIR="$ROOT/seed/linux-x86_64"
SEED="$SEED_DIR/seed"
HEX="$SEED_DIR/seed.hex"

if [ "$NATIVE" = "1" ] && [ -f "$HEX" ]; then
    echo "==> Decodifico il seed ELF da seed.hex (printf POSIX puro)..."
    tmpdecode="$SEED_DIR/.seed.decode.$$"
    trap 'rm -f "$tmpdecode"' EXIT
    if decode_hex_pure "$HEX" "$tmpdecode"; then
        chmod +x "$tmpdecode"
        # Q2: la sovrascrittura del binario committato è un no-op
        # deterministico; il mismatch è un drift da segnalare.
        if [ -f "$SEED" ] && ! cmp -s "$tmpdecode" "$SEED"; then
            echo "    (avviso) anti-drift: seed.hex non corrisponde al binario" >&2
            echo "    committato $SEED — sovrascrivo con la decodifica fresca." >&2
        fi
        mv "$tmpdecode" "$SEED"
        chmod +x "$SEED"
        echo "    OK: $SEED"
    else
        echo "    ERRORE: decodifica di seed.hex fallita." >&2
        exit 1
    fi
fi

# --- 2. installazione dei launcher (wrapper a percorso assoluto, Q4) ---
mkdir -p "$PREFIX"

install_wrapper() {
    name="$1"
    src="$ROOT/bin/$name"
    dst="$PREFIX/$name"
    [ -f "$src" ] || { echo "    (salto) $src non trovato" >&2; return; }
    cat > "$dst" <<EOF
#!/bin/sh
exec "$src" "\$@"
EOF
    chmod +x "$dst"
    echo "==> Wrapper installato: $dst -> $src"
}

install_wrapper triad
install_wrapper triad-cli

# --- PATH -----------------------------------------------------------------
case ":$PATH:" in
    *":$PREFIX:"*) ;;
    *)
        echo ""
        echo "ATTENZIONE: $PREFIX non è nel PATH. Aggiungi questa riga a ~/.bashrc o ~/.zshrc:"
        echo "    export PATH=\"$PREFIX:\$PATH\""
        ;;
esac

# --- 3. smoke test byte-exatto (Q5/Q10: mismatch => installazione fallisce) ---
if [ "$NATIVE" = "1" ]; then
    echo "==> Smoke test byte-exatto (test_simple.td + golden sidecar)..."
    smokeout="${TMPDIR:-/tmp}/triad-smoke.$$"
    trap 'rm -f "$tmpdecode" "$smokeout"' EXIT
    if ! "$PREFIX/triad" "$ROOT/tests/probes/test_simple.td" > "$smokeout" 2>/dev/null; then
        echo "    ERRORE: il seed non ha eseguito test_simple.td." >&2
        exit 1
    fi
    if ! cmp -s "$smokeout" "$ROOT/tests/probes/test_simple.expected.out"; then
        echo "    ERRORE: smoke test non byte-exatto (atteso vs ottenuto):" >&2
        cmp "$ROOT/tests/probes/test_simple.expected.out" "$smokeout" >&2 || true
        exit 1
    fi
    echo "    OK: stdout byte-exatto col golden"
else
    echo "==> Smoke test saltato (piattaforma non Linux x86-64)."
fi

# --- 4. integrazione desktop (opzionale) ----------------------------------
want_desktop() {
    case "$(uname -s)" in
        Linux*) [ -d "${XDG_DATA_HOME:-$HOME/.local/share}/applications" ] || \
                [ -d "$HOME/.local/share/applications" ] ;;
        *) false ;;
    esac
}

if [ "$DESKTOP" = "yes" ] || { [ "$DESKTOP" = "auto" ] && want_desktop; }; then
    APPS="${XDG_DATA_HOME:-$HOME/.local/share}/applications"
    mkdir -p "$APPS"
    chmod +x "$ROOT/bin/triad-desktop"
    ICON_THEME="${XDG_DATA_HOME:-$HOME/.local/share}/icons/hicolor"
    ICON_APPS="$ICON_THEME/256x256/apps"
    mkdir -p "$ICON_APPS"
    cp "$ROOT/assets/icons/triad.png" "$ICON_APPS/triad.png"
    if command -v gtk-update-icon-cache >/dev/null 2>&1; then
        gtk-update-icon-cache -f -t "$ICON_THEME" >/dev/null 2>&1 || true
    fi
    # Exec ha due livelli di escaping freedesktop: stringa e argomento quotato.
    # % letterale va raddoppiato per non diventare un field code.
    desktop_exec=$(printf '%s' "$ROOT/bin/triad-desktop" |
        sed 's/\\/\\\\/g; s/["`$]/\\&/g; s/\\/\\\\/g; s/%/%%/g')
    cat > "$APPS/triad.desktop" <<EOF
[Desktop Entry]
Type=Application
Name=Triad Program
Icon=triad
Comment=Esegui un programma Triad (.triad/.td)
Exec="$desktop_exec" %f
Terminal=true
MimeType=text/x-triad;
Categories=Development;
EOF
    # MimeType nel .desktop non registra le estensioni: serve shared-mime-info.
    MIME_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/mime"
    mkdir -p "$MIME_DIR/packages"
    cat > "$MIME_DIR/packages/triad.xml" <<'EOF_MIME'
<?xml version="1.0" encoding="UTF-8"?>
<mime-info xmlns="http://www.freedesktop.org/standards/shared-mime-info">
  <mime-type type="text/x-triad">
    <comment>Triad program</comment>
    <sub-class-of type="text/plain"/>
    <glob pattern="*.triad"/>
    <glob pattern="*.td"/>
  </mime-type>
</mime-info>
EOF_MIME
    if command -v update-mime-database >/dev/null 2>&1; then
        update-mime-database "$MIME_DIR" ||
            echo "    (avviso) aggiornamento database MIME fallito" >&2
    else
        echo "    (avviso) esegui update-mime-database \"$MIME_DIR\" per riconoscere i file Triad" >&2
    fi
    if command -v update-desktop-database >/dev/null 2>&1; then
        update-desktop-database "$APPS" 2>/dev/null || true
    fi
    if command -v xdg-mime >/dev/null 2>&1; then
        mkdir -p "${XDG_CONFIG_HOME:-$HOME/.config}"
        # Some xdg-utils versions call qtpaths on KDE 5/6 before writing
        # the standard mimeapps.list, even when the helper is absent.
        # Use their generic backend only for this invocation in that case.
        mime_generic=no
        case "${KDE_SESSION_VERSION:-}" in
            [5-9]|[1-9][0-9]*)
                command -v qtpaths >/dev/null 2>&1 || mime_generic=yes ;;
        esac
        if [ "$mime_generic" = yes ]; then
            KDE_SESSION_VERSION=0 XDG_CURRENT_DESKTOP=X-Generic \
                xdg-mime default triad.desktop text/x-triad ||
                echo "    (avviso) associazione predefinita Triad non impostata" >&2
        else
            xdg-mime default triad.desktop text/x-triad ||
                echo "    (avviso) associazione predefinita Triad non impostata" >&2
        fi
    else
        echo "    (avviso) scegli Triad Program in Apri con per i file .triad/.td" >&2
    fi
    echo "==> Voce menu installata: $APPS/triad.desktop"
fi

# --- verifica finale (09 Q8: smoke + triad-cli status, senza Node) --------
echo ""
echo "==> Verifica installazione:"
if "$PREFIX/triad-cli" status >/dev/null 2>&1; then
    echo "    triad-cli: OK (status senza Node)"
else
    echo "    ERRORE: triad-cli status fallito." >&2
    exit 1
fi

echo ""
echo "Installazione completata. Prossimi passi:"
echo "  triad tuo_programma.td          # esegue un programma Triad"
echo "  triad-cli status                # stato della toolchain"
echo "  triad-cli test all              # gate completo (conformance + probe)"
echo ""
echo "Nota: i comandi di sviluppo avanzati saranno implementati in Triad nativo."\n