# =============================================================================
# Sccache.cmake - compiler launcher (sccache, with ccache fallback)
#
# Sets CMAKE_<LANG>_COMPILER_LAUNCHER so object files are served from a shared
# cache instead of being recompiled. Works with Ninja, Makefiles and MSBuild.
#
# Include this BEFORE project() so the launcher is picked up by the very first
# compiler feature detection run.
#
# Options / cache variables:
#   SINYUE_USE_SCCACHE  ON|OFF  master switch (default ON)
#   SCCACHE_PROGRAM     path    explicit launcher; auto-detected when empty
# =============================================================================

include_guard(GLOBAL)

option(SINYUE_USE_SCCACHE "Use a compiler cache launcher (sccache/ccache)" ON)
set(SCCACHE_PROGRAM "" CACHE FILEPATH "Explicit path to sccache/ccache (auto-detected when empty)")

function(_sinyue_set_launcher LAUNCHER)
  set(CMAKE_C_COMPILER_LAUNCHER   "${LAUNCHER}" CACHE STRING "C compiler launcher"   FORCE)
  set(CMAKE_CXX_COMPILER_LAUNCHER "${LAUNCHER}" CACHE STRING "C++ compiler launcher" FORCE)
  set(CMAKE_OBJC_COMPILER_LAUNCHER "${LAUNCHER}" CACHE STRING "" FORCE)
  set(CMAKE_OBJCXX_COMPILER_LAUNCHER "${LAUNCHER}" CACHE STRING "" FORCE)
  message(STATUS "[cache] compiler launcher: ${LAUNCHER}")
endfunction()

if(NOT SINYUE_USE_SCCACHE)
  message(STATUS "[cache] compiler launcher disabled (SINYUE_USE_SCCACHE=OFF)")
  return()
endif()

set(_sinyue_launcher "")

if(SCCACHE_PROGRAM AND EXISTS "${SCCACHE_PROGRAM}")
  set(_sinyue_launcher "${SCCACHE_PROGRAM}")
else()
  # sccache first, ccache second - both accept the launcher protocol.
  find_program(_sinyue_cache_program NAMES sccache ccache)
  if(_sinyue_cache_program)
    set(_sinyue_launcher "${_sinyue_cache_program}")
    set(SCCACHE_PROGRAM "${_sinyue_cache_program}" CACHE FILEPATH
        "Explicit path to sccache/ccache (auto-detected when empty)" FORCE)
  endif()
  unset(_sinyue_cache_program)
endif()

if(_sinyue_launcher)
  _sinyue_set_launcher("${_sinyue_launcher}")

  # Keep the server alive between builds so the first compile is not penalised.
  execute_process(
    COMMAND "${_sinyue_launcher}" --version
    OUTPUT_VARIABLE _sinyue_cache_version
    OUTPUT_STRIP_TRAILING_WHITESPACE
    ERROR_QUIET)

  if(_sinyue_cache_version)
    message(STATUS "[cache] ${_sinyue_cache_version}")
  endif()

  if(NOT DEFINED ENV{SCCACHE_DIR} AND NOT DEFINED ENV{CCACHE_DIR})
    message(STATUS "[cache] stats: run `sccache --show-stats` (or scripts/sccache-stats.ps1)")
  endif()
  unset(_sinyue_cache_version)
else()
  message(WARNING
    "[cache] sccache/ccache not found on PATH - building without a compiler cache.\n"
    "        Install with: winget install Mozilla.sccache\n"
    "        or point SCCACHE_PROGRAM at the executable.")
endif()

unset(_sinyue_launcher)
