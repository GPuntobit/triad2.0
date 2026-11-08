#!/bin/sh
# Development oracle for S1, never a launcher fallback.
root=$(CDPATH= cd "$(dirname "$0")/../.." && pwd) || exit 2
exec node "$root/seed/dev/triad_core.cjs" "$@"
