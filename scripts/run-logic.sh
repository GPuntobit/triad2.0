#!/bin/sh
# Byte transport only: parsing, unification and search run in Triad-Core S1.
set -eu
root=$(CDPATH= cd "$(dirname "$0")/.." && pwd)
if [ "$#" != 1 ]; then
    echo 'usage: triad --logic FILE.triad (or - for stdin)' >&2
    exit 2
fi
seed=${TRIAD_SEED:-$root/seed/linux-x86_64/seed}
if [ ! -x "$seed" ]; then
    echo "triad: executable seed missing: $seed" >&2
    exit 2
fi
scratch=$(mktemp -d /tmp/triad-logic.XXXXXXXX)
trap 'rm -rf "$scratch"' EXIT HUP INT TERM
if [ "$1" = - ]; then
    cat > "$scratch/input"
else
    cat -- "$1" > "$scratch/input"
fi
# S1's bounded source vector is explicit, rather than silently truncating input.
size=$(wc -c < "$scratch/input")
if [ "$size" -gt 4094 ]; then
    echo 'triad --logic: source limit is 4094 bytes in this S1 stage' >&2
    exit 1
fi
cat "$root/selfhost/logic/engine.td" "$root/selfhost/logic/init.td" > "$scratch/program.td"
od -An -v -tu1 "$scratch/input" | while IFS= read -r row; do
    for byte in $row; do
        printf 'lv_add(ldata, %s)\n' "$byte"
    done
done >> "$scratch/program.td"
printf 'lv_add(ldata, 0)\nlx_all()\nlrun()\n' >> "$scratch/program.td"
"$seed" "$scratch/program.td"
