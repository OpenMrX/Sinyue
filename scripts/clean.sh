#!/usr/bin/env bash
# Removes generated build directories (POSIX shell / Git Bash).
#
# usage: ./scripts/clean.sh [--cache]
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
WITH_CACHE=0

for arg in "$@"; do
  case "$arg" in
    --cache) WITH_CACHE=1 ;;
    -h|--help) sed -n '2,4p' "${BASH_SOURCE[0]}"; exit 0 ;;
    *) echo "unknown argument: $arg" >&2; exit 2 ;;
  esac
done

targets=(
  "$ROOT/build-clang-debug"
  "$ROOT/build-clang-release"
  "$ROOT/install"
  "$ROOT/compile_commands.json"
)
[[ "$WITH_CACHE" -eq 1 ]] && targets+=("$ROOT/.cpmcache")

for target in "${targets[@]}"; do
  if [[ -e "$target" ]]; then
    rm -rf "$target"
    printf '    removed  %s\n' "$target"
  fi
done

printf 'Clean finished.\n'
