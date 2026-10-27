#!/usr/bin/env bash
# Configures and builds one of the Clang presets (POSIX shell / Git Bash).
#
# usage: ./scripts/build.sh [debug|release] [--reconfigure] [--run] [--target NAME]
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

CONFIG="debug"
RECONFIGURE=0
RUN=0
TARGET=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    debug|release) CONFIG="$1"; shift ;;
    --reconfigure) RECONFIGURE=1; shift ;;
    --run)         RUN=1; shift ;;
    --target)      TARGET="${2:-}"; shift 2 ;;
    -h|--help)     sed -n '2,4p' "${BASH_SOURCE[0]}"; exit 0 ;;
    *) echo "unknown argument: $1" >&2; exit 2 ;;
  esac
done

PRESET="clang-${CONFIG}"
BUILD_DIR="$ROOT/build-${PRESET}"

cd "$ROOT"

if [[ "$RECONFIGURE" -eq 1 || ! -f "$BUILD_DIR/CMakeCache.txt" ]]; then
  printf '==> configure (%s)\n' "$PRESET"
  cmake --preset "$PRESET"
else
  printf '==> configure skipped (build-%s exists)\n' "$PRESET"
fi

printf '==> build (%s)\n' "$PRESET"
if [[ -n "$TARGET" ]]; then
  cmake --build --preset "$PRESET" --target "$TARGET"
else
  cmake --build --preset "$PRESET"
fi

EXE="$BUILD_DIR/Sinyue.exe"
[[ -f "$EXE" ]] || EXE="$BUILD_DIR/Sinyue"
printf '==> binary: %s\n' "$EXE"

if [[ "$RUN" -eq 1 ]]; then
  printf '==> run\n'
  "$EXE"
fi
