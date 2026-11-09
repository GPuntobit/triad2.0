#!/bin/sh
# Static website generator: native Triad programs + POSIX file transport.
# The Triad seed executes the source; no browser/Node interpreter is involved.
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/../.." && pwd)
mode=${1:---dry-run}
case "$mode" in --dry-run|--check|--write) ;; *) echo "usage: sh tools/site-gen/build.sh [--dry-run|--check|--write]" >&2; exit 2 ;; esac
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT HUP INT TERM
mkdir -p "$tmp/docs/pages" "$tmp/docs/assets/css"
count=0
for source in site_pages.td site_pages2.td site_playground.td site_style.td; do
  "$ROOT/bin/triad" "$ROOT/tools/site-gen/$source" > "$tmp/bundle"
  target=""
  while IFS= read -r line || [ -n "$line" ]; do
    case "$line" in
      '=== FILE: '*' ===')
        target=${line#'=== FILE: '}
        target=${target%' ==='}
        if ! printf '%s\n' "$target" | grep -Eq '^docs/pages/[a-zA-Z0-9_-]+\.html$|^docs/assets/css/triad-generated\.css$'; then
          echo "site-gen: unsafe file marker: $target" >&2
          exit 1
        fi
        : > "$tmp/$target"
        count=$((count + 1))
        ;;
      *)
        if [ -z "$target" ]; then
          [ -z "$line" ] || { echo "site-gen: output before first file marker" >&2; exit 1; }
        else
          printf '%s\n' "$line" >> "$tmp/$target"
        fi
        ;;
    esac
  done < "$tmp/bundle"
done
[ "$count" -ge 12 ] || { echo "site-gen: expected more output pages" >&2; exit 1; }
if grep -R -Ein '<script([[:space:]>])|javascript:|\bon(click|load|submit|input|change)[[:space:]]*=' "$tmp/docs" >/dev/null; then
  echo "site-gen: generated executable browser script rejected" >&2
  exit 1
fi
if [ "$mode" = --check ]; then
  find "$tmp/docs" -type f | while IFS= read -r path; do
    rel=${path#"$tmp/"}
    cmp -s "$path" "$ROOT/$rel" || { echo "site-gen: drift in $rel" >&2; exit 1; }
  done
elif [ "$mode" = --write ]; then
  find "$tmp/docs" -type f | while IFS= read -r path; do
    rel=${path#"$tmp/"}
    cp "$path" "$ROOT/$rel"
  done
fi
echo "site-gen: $mode PASS ($count static artifacts; Triad native source)"
