#!/usr/bin/env bash
# Verifies the toolchain and prepares the CPM cache (POSIX shell / Git Bash).
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CONFIG="${1:-debug}"
PRESET="clang-${CONFIG}"

step() { printf '==> %s\n' "$1"; }
ok()   { printf '    [ok]   %s\n' "$1"; }
note() { printf '    [note] %s\n' "$1"; }
bad()  { printf '    [fail] %s\n' "$1"; }

missing=0

step "Toolchain"
for tool in cmake ninja sccache; do
  if command -v "$tool" >/dev/null 2>&1; then
    ok "$(printf '%-9s' "$tool") $(command -v "$tool")"
  else
    bad "$(printf '%-9s' "$tool") not found"
    missing=1
  fi
done

# LLVM is not always on PATH - fall back to the standard Windows install.
if ! command -v clang++ >/dev/null 2>&1 && [[ -n "${PROGRAMFILES:-}" ]]; then
  llvm_win="$PROGRAMFILES\\LLVM\\bin"
  if command -v cygpath >/dev/null 2>&1; then
    llvm_bin="$(cygpath -u "$llvm_win")"
  else
    llvm_bin="$llvm_win"
  fi
  if [[ -x "$llvm_bin/clang++.exe" ]]; then
    export PATH="$llvm_bin:$PATH"
    note "added $llvm_bin to PATH for this session"
  fi
fi

if command -v clang++ >/dev/null 2>&1; then
  ok "$(printf '%-9s' 'clang++') $(command -v clang++)"
else
  bad "$(printf '%-9s' 'clang++') not found (add the LLVM bin directory to PATH)"
  missing=1
fi

step "CPM bootstrap file"
if [[ -f "$ROOT/cmake/CPM.cmake" ]]; then
  ok "cmake/CPM.cmake present"
else
  url="https://github.com/cpm-cmake/CPM.cmake/releases/download/v0.43.2/CPM.cmake"
  note "cmake/CPM.cmake missing - downloading"
  mkdir -p "$ROOT/cmake"
  curl -fsSL "$url" -o "$ROOT/cmake/CPM.cmake"
  ok "cmake/CPM.cmake restored"
fi

step "CPM source cache"
mkdir -p "$ROOT/.cpmcache"
if [[ -d "$ROOT/.cpmcache/abcmake" ]]; then
  ok "cache hit  - abcmake reused from .cpmcache/abcmake"
else
  note "cache miss - abcmake will be cloned into .cpmcache/abcmake"
  if [[ "$missing" -ne 0 ]]; then
    bad "missing tools, cannot warm up the cache"
    exit 1
  fi
  step "Warming up the cache with preset '$PRESET'"
  cmake --preset "$PRESET"
  ok "cache populated"
fi

if [[ "$missing" -ne 0 ]]; then
  exit 1
fi

step "Summary"
printf '    Toolchain ready. Next: ./scripts/build.sh %s --run\n' "$CONFIG"
