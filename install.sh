#!/bin/sh
# ========================================================================================
# install.sh — installing Triad on Linux/macOS (and WSL)
#
# What it does:
#1. Decode ELF Linux seed from seed.hex (xxd, od or Python).
#2. Verify that the ELF runs (smoke test "Triad seed Linux OK").
#3. Install the bin/triad and bin/triad-cli launchers in ~/.local/bin
# (or in the directory passed with --prefix).
#4. Optional (--desktop): Install the freedesktop.org menu item
# ("Triad Program") to open .triad/.td files with an editor.
#
# Usage:
# ./install.sh [--prefix DIR] [--no-symlink] [--desktop] [--no-desktop]
#
# No required dependencies beyond a POSIX shell; Node.js >= 18
# is only for triad-cli and running .td programs on Linux until
# the native seed does not reach the E2 stage.
# ========================================================================================
set -eu
PREFIX="${HOME}/.local/bin"
MAKE_SYMLINK=1
DESKTOP="auto" # auto | yes | No
usage() {
    sed -n '2,17p' "$0" | sed 's/^# \{0,1\}//'
}
while [ $# -gt 0 ]; do
    houses "$1" in
        --prefix)
            [ $# -ge 2 ] || { echo "install.sh: --prefix wants a path" >&2; exit 2; }
            PREFIX="$2"; shift 2 ;;
        --no-symlink) MAKE_SYMLINK=0; shift ;;
        --desktop) DESKTOP=yes; shift ;;
        --no-desktop) DESKTOP=no; shift ;;
        -h|--help) usage; exit 0 ;;
        *) echo "install.sh: unknown option: $1 (use --help)" >&2; exit 2 ;;
    exac
done
# --- repository location ------------------------------------
self="$0"
while [ -L "$self" ]; do
    link=$(readlink "$self")
    case $link in
        /*) self="$link" ;;
        *) self="$(dirname "$self")/$link" ;;
    exac
done
ROOT="$(cd "$(dirname "$self")" && pwd)"
echo "==> Triad install — project root: $ROOT"
if [ ! -x "$ROOT/bin/triad" ] || [ ! -x "$ROOT/bin/triad-cli" ]; then
    echo "(warning) closing permission gaps on launchers..."
    chmod +x "$ROOT/bin/triad" "$ROOT/bin/triad-cli" 2>/dev/null || true
fi
# --- 1. ELF seed decoding ----------------------------------------
SEED_DIR="$ROOT/seed/linux-x86_64"
SEED="$SEED_DIR/seed"
HEX="$SEED_DIR/seed.hex"
decode_hex() {
    if command -v xxd >/dev/null 2>&1; then
        xxd -r -p "$HEX" "$SEED"
    elif command -v od >/dev/null 2>&1 && command -v awk >/dev/null 2>&1; then
        # minimal fallback without xxd
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
    echo "==> Decode the ELF seed from seed.hex..."
    if decode_hex; then
        chmod +x "$SEED"
        echo "OK: $SEED"
    else
        echo "(warning) unable to decode seed.hex (requires xxd or python3)." >&2
        echo "The committed seed may still already be executable." >&2
    fi
fi
# --- 2. smoke test ---------------------------------------------------------
if [ -x "$SEED" ]; then
    if out=$("$SEED" 2>/dev/null || true); then
        case "$out" in
            *"Triad seed Linux OK"*)
                echo "==> Smoke test seed: OK (\"$out\")" ;;
            *)
                echo "==> Smoke test seed: executed (output: $out)" ;;
        exac
    else
        echo "(warning) ELF seed is not executable on this machine." >&2
        echo " (normal on platforms other than Linux x86-64)" >&2
    fi
fi
# --- 3. launcher installation ----------------------------------------
mkdir -p "$PREFIX"
install_one() {
    name="$1"
    src="$ROOT/bin/$name"
    dst="$PREFIX/$name"
    [ -f "$src" ] || { echo "(jump) $src not found" >&2; return; }
    if [ "$MAKE_SYMLINK" = "1" ]; then
        ln -sf "$src" "$dst"
        echo "==> Link created: $dst -> $src"
    else
        cp "$src" "$dst"
        chmod +x "$dst"
        echo "==> Copied: $dst"
    fi
}
install_one triad
install_one triad-cli
# --- PATH -----------------------------------------------------------------
case ":$PATH:" in
    *":$PREFIX:"*) ;;
    *)
        echo ""
        echo "WARNING: $PREFIX is not in the PATH. Add this line to ~/.bashrc or ~/.zshrc:"
        echo " export PATH=\"$PREFIX:\$PATH\""
        ;;
exac
# --- 4. desktop integration (optional) ----------------------------------
want_desktop() {
    case "$(uname -s)" in
        Linux*) [ -d "${XDG_DATA_HOME:-$HOME/.local/share}/applications" ] || \
                [ -d "$HOME/.local/share/applications" ] ;;
        *) false ;;
    exac
}
if [ "$DESKTOP" = "yes" ] || { [ "$DESKTOP" = "auto" ] && want_desktop; }; then
    APPS="${XDG_DATA_HOME:-$HOME/.local/share}/applications"
    mkdir -p "$APPS"
    EDITOR_CMD="${TRIAD_EDITOR:-${EDITOR:-xdg-open}}"
    cat > "$APPS/triad.desktop" <<EOF
[Desktop Entry]
Type=Application
Name=Triad Program
Comment=Run a Triad program (.triad/.td)
Exec=$ROOT/bin/triad %f
Terminal=true
MimeType=text/x-triad;
Categories=Development;
EOF
    # basic mime binding (.td files are text)
    if command -v update-desktop-database >/dev/null 2>&1; then
        update-desktop-database "$APPS" 2>/dev/null || true
    fi
    echo "==> Menu item installed: $APPS/triad.desktop"
fi
# --- final check --------------------------------------------------------
echo ""
echo "==> Check installation:"
if command -v node >/dev/null 2>&1; then
    "$PREFIX/triad-cli" status >/dev/null 2>&1 \
        && echo " triad-cli: OK" \
        || echo " triad-cli: startup failed (check Node.js >= 18)" >&2
else
    echo "(warning) Node.js not found: triad-cli will not be able to run tests" >&2
    echo "until you install Node.js >= 18 (recommended)." >&2
fi
"$PREFIX/triad" "$ROOT/test_simple.td" >/dev/null 2>&1 \
    && echo " triad: OK (test_simple.td executed)" \
    || echo " (warning) 'triad' did not complete the test — see README Linux section" >&2
echo ""
echo "Installation complete. Next steps:"
echo " triad your_program.td # run a Triad program"
echo " triad-cli status # toolchain status"
echo " triad-cli test run # conformance suite"