cmake_minimum_required(VERSION 3.25)
project(Core)

# abcmake resolves through the CMAKE_PREFIX_PATH set by the root project,
# so this folder also builds standalone once abcmake is installed.
find_package(abcmake REQUIRED)

# Flat layout: headers and sources live directly in this directory
# (no include/ or src/ subfolder), so point both dirs at ".".
add_component(${PROJECT_NAME} SOURCE_DIR . INCLUDE_DIR .)

if(TARGET sinyue_warnings)
  target_link_libraries(${PROJECT_NAME} PRIVATE sinyue_warnings)
endif()
