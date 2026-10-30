#!/bin/sh
# =====================================================================
#  install.sh — installazione di Triad su Linux / macOS (e WSL)
#
#  Cosa fa:
#    1. Decodifica il seed ELF Linux da seed.hex (xxd, od o Python).
#    2. Verifica che l'ELF venga eseguito (smoke test "Triad seed Linux OK").
#    3. Installa i launcher bin/triad e bin/triad-cli in ~/.local/bin
#       (o nella directory passata con --prefix).
#    4. Opzionale (--desktop): installa la voce menu freedesktop.org
#       ("Triad Program") per aprire i file .triad/.td con un editor.
#
#  Uso:
#    ./install.sh [--prefix DIR] [--no-symlink] [--desktop] [--no-desktop]
#
#  Nessuna dipendenza obbligatoria oltre a una shell POSIX; Node.js >= 18
#  serve solo per triad-cli e per eseguire programmi .td su Linux finché
#  il seed nativo non raggiunge lo stadio E2.
# =====================================================================

set -eu

PREFIX="${HOME}/.local/bin"
MAKE_SYMLINK=1
DESKTOP="auto"   # auto | yes | no

usage() {
    sed -n '3,18p' "$0" | sed 's/^# \{0,1\}//'
}

while [ $# -gt 0 ]; do
    case "$1" in
        --prefix)
            [ $# -ge 2 ] || { echo "install.sh: --prefix vuole un percorso" >&2; exit 2; }
            PREFIX="$2"; shift 2 ;;
        --no-symlink)  MAKE_SYMLINK=0; shift ;;
        --desktop)     DESKTOP=yes; shift ;;
        --no-desktop)  DESKTOP=no; shift ;;
        -h|--help)     usage; exit 0 ;;
        *) echo "install.sh: opzione sconosciuta: $1 (usa --help)" >&2; exit 2 ;;
    esac
done

# --- localizzazione del repository ------------------------------------
self="$0"
while [ -L "$self" ]; do
    link=$(readlink "$self")
    case $link in
        /*) self="$link" ;;
        *)  self="$(dirname "$self")/$link" ;;
    esac
done
ROOT="$(cd "$(dirname "$self")" && pwd)"

echo "==> Triad install — radice progetto: $ROOT"

if [ ! -x "$ROOT/bin/triad" ] || [ ! -x "$ROOT/bin/triad-cli" ]; then
    echo "    (avviso) chiudo i gap di permessi sui launcher..."
    chmod +x "$ROOT/bin/triad" "$ROOT/bin/triad-cli" 2>/dev/null || true
fi

# --- 1. decodifica del seed ELF ----------------------------------------
SEED_DIR="$ROOT/seed/linux-x86_64"
SEED="$SEED_DIR/seed"
HEX="$SEED_DIR/seed.hex"

decode_hex() {
    if command -v xxd >/dev/null 2>&1; then
        xxd -r -p "$HEX" "$SEED"
    elif command -v od >/dev/null 2>&1 && command -v awk >/dev/null 2>&1; then
        # fallback minimale senza xxd
        od -An -tx1 "$HEX" >/dev/null 2>&1 || true
        python3_decode
    elif command -v python3 >/dev/null 2>&1; then
        python3_decode
    else
        return 1
    fi
}

python3_decode() {
    python3 - "$HEX" "$SEED" <<'PY'
import sys, re
src, dst = sys.argv[1], sys.argv[2]
data = bytes.fromhex(re.sub(r'\s+', '', open(src).read()))
open(dst, 'wb').write(data)
PY
}

if [ -f "$HEX" ]; then
    echo "==> Decodifico il seed ELF da seed.hex..."
    if decode_hex; then
        chmod +x "$SEED"
        echo "    OK: $SEED"
    else
        echo "    (avviso) impossibile decodificare seed.hex (servono xxd o python3)." >&2
        echo "    Il seed committato potrebbe comunque essere già eseguibile." >&2
    fi
fi

# --- 2. smoke test -------------------------------------------------------
if [ -x "$SEED" ]; then
    if out=$("$SEED" 2>/dev/null || true); then
        case "$out" in
            *"Triad seed Linux OK"*)
                echo "==> Smoke test seed: OK (\"$out\")" ;;
            *)
                echo "==> Smoke test seed: eseguito (output: $out)" ;;
        esac
    else
        echo "    (avviso) il seed ELF non è eseguibile su questa macchina." >&2
        echo "    (normale su piattaforme diverse da Linux x86-64)" >&2
    fi
fi

# --- 3. installazione dei launcher --------------------------------------
mkdir -p "$PREFIX"

install_one() {
    name="$1"
    src="$ROOT/bin/$name"
    dst="$PREFIX/$name"
    [ -f "$src" ] || { echo "    (salto) $src non trovato" >&2; return; }
    if [ "$MAKE_SYMLINK" = "1" ]; then
        ln -sf "$src" "$dst"
        echo "==> Link creato: $dst -> $src"
    else
        cp "$src" "$dst"
        chmod +x "$dst"
        echo "==> Copiato: $dst"
    fi
}

install_one triad
install_one triad-cli

# --- PATH -----------------------------------------------------------------
case ":$PATH:" in
    *":$PREFIX:"*) ;;
    *)
        echo ""
        echo "ATTENZIONE: $PREFIX non è nel PATH. Aggiungi questa riga a ~/.bashrc o ~/.zshrc:"
        echo "    export PATH=\"$PREFIX:\$PATH\""
        ;;
esac

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
    EDITOR_CMD="${TRIAD_EDITOR:-${EDITOR:-xdg-open}}"
    cat > "$APPS/triad.desktop" <<EOF
[Desktop Entry]
Type=Application
Name=Triad Program
Comment=Esegui un programma Triad (.triad/.td)
Exec=$ROOT/bin/triad %f
Terminal=true
MimeType=text/x-triad;
Categories=Development;
EOF
    # associazione mime di base (i file .td sono testo)
    if command -v update-desktop-database >/dev/null 2>&1; then
        update-desktop-database "$APPS" 2>/dev/null || true
    fi
    echo "==> Voce menu installata: $APPS/triad.desktop"
fi

# --- verifica finale --------------------------------------------------------
echo ""
echo "==> Verifica installazione:"
if command -v node >/dev/null 2>&1; then
    "$PREFIX/triad-cli" status >/dev/null 2>&1 \
        && echo "    triad-cli: OK" \
        || echo "    triad-cli: avvio fallito (controlla Node.js >= 18)" >&2
else
    echo "    (avviso) Node.js non trovato: triad-cli non potrà eseguire i test" >&2
    echo "    finché non installi Node.js >= 18 (consigliato)." >&2
fi
"$PREFIX/triad" "$ROOT/probes/test_simple.td" >/dev/null 2>&1 \
    && echo "    triad: OK (test_simple.td eseguito)" \
    || echo "    (avviso) 'triad' non ha completato il test — vedi README sezione Linux" >&2

echo ""
echo "Installazione completata. Prossimi passi:"
echo "  triad tuo_programma.td        # esegue un programma Triad"
echo "  triad-cli status              # stato della toolchain"
echo "  triad-cli test run            # suite di conformità"
