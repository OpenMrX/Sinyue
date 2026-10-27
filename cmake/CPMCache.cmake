# =============================================================================
# CPMCache.cmake - project-local CPM source cache bootstrap
#
# Every CPM dependency is checked out under <project-root>/.cpmcache instead of
# the default (which is "no cache", meaning a fresh clone for every build dir).
#
# Behaviour:
#   * If .cpmcache exists and already holds the requested dependency -> reuse it
#     (no network access at all).
#   * If it does not exist / is empty -> CPM clones the dependency on first
#     configure, and every later configure/build reuses that clone.
#
# Must be included BEFORE cmake/CPM.cmake and before any CPMAddPackage() call.
# =============================================================================

include_guard(GLOBAL)

if(NOT DEFINED CPM_SOURCE_CACHE OR CPM_SOURCE_CACHE STREQUAL "")
  set(CPM_SOURCE_CACHE "${CMAKE_CURRENT_LIST_DIR}/../.cpmcache"
      CACHE PATH "Directory holding every CPM dependency checkout")
endif()

get_filename_component(CPM_SOURCE_CACHE "${CPM_SOURCE_CACHE}" ABSOLUTE
                       BASE_DIR "${CMAKE_CURRENT_LIST_DIR}/..")

if(NOT EXISTS "${CPM_SOURCE_CACHE}")
  file(MAKE_DIRECTORY "${CPM_SOURCE_CACHE}")
  set(_cpm_cache_state "empty (created just now)")
else()
  file(GLOB _cpm_cache_entries LIST_DIRECTORIES true "${CPM_SOURCE_CACHE}/*")
  list(LENGTH _cpm_cache_entries _cpm_cache_count)
  if(_cpm_cache_count EQUAL 0)
    set(_cpm_cache_state "empty")
  elseif(_cpm_cache_count EQUAL 1)
    set(_cpm_cache_state "1 entry")
  else()
    set(_cpm_cache_state "${_cpm_cache_count} entries")
  endif()
endif()
unset(_cpm_cache_entries)
unset(_cpm_cache_count)

message(STATUS "[cpm] cache dir : ${CPM_SOURCE_CACHE}")
message(STATUS "[cpm] cache state: ${_cpm_cache_state}")

# -----------------------------------------------------------------------------
# cpm_cache_has(<package-name> <out-var>)
#
# Reports whether a dependency is already present in the local CPM cache, so the
# build can tell the user "using cache" vs "will download".
# -----------------------------------------------------------------------------
function(cpm_cache_has PACKAGE_NAME OUT_VAR)
  file(GLOB _hits LIST_DIRECTORIES true
       "${CPM_SOURCE_CACHE}/${PACKAGE_NAME}"
       "${CPM_SOURCE_CACHE}/${PACKAGE_NAME}-*")
  if(_hits)
    set(${OUT_VAR} TRUE PARENT_SCOPE)
    message(STATUS "[cpm] '${PACKAGE_NAME}' found in cache -> reuse")
  else()
    set(${OUT_VAR} FALSE PARENT_SCOPE)
    message(STATUS "[cpm] '${PACKAGE_NAME}' not in cache -> fetch on this configure")
  endif()
endfunction()
