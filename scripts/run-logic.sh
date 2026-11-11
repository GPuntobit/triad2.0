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
if [ "$size" -gt 65535 ]; then
    echo 'triad --logic: source limit is 65535 bytes in this S1 stage' >&2
    exit 1
fi
cat "$root/selfhost/logic/engine.td" "$root/selfhost/logic/init.td" > "$scratch/program.td"
# Compact 64-byte pages; no generated statement per input byte.
{
    printf 'lsize = %s\n' "$((size + 1))"
    od -An -v -tu1 "$scratch/input" | {
        count=0
        printf 'lv_add(ldata, ['
        while IFS= read -r row; do
            for byte in $row; do
                if [ "$count" = 64 ]; then
                    printf '])\nlv_add(ldata, ['
                    count=0
                fi
                [ "$count" = 0 ] || printf ','
                printf '%s' "$byte"
                count=$((count + 1))
            done
        done
        if [ "$count" = 64 ]; then
            printf '])\nlv_add(ldata, ['
            count=0
        fi
        [ "$count" = 0 ] || printf ','
        printf '0])\nlx_all()\nlrun()\n'
    }
} >> "$scratch/program.td"
"$seed" "$scratch/program.td"
