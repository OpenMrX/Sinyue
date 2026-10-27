cmake_minimum_required(VERSION 3.25)
project(Logger)

# abcmake resolves through the CMAKE_PREFIX_PATH set by the root project,
# so this folder also builds standalone once abcmake is installed.
find_package(abcmake REQUIRED)

# Flat layout: headers and sources live directly in this directory
# (no include/ or src/ subfolder), so point both dirs at ".".
add_component(${PROJECT_NAME} SOURCE_DIR . INCLUDE_DIR .)

# Demonstrates inter-component dependency: link the Core module by its
# namespaced alias (abcmake registers <name>::<name> for every component).
# This pulls Core's PUBLIC include path into Logger automatically.
target_link_libraries(${PROJECT_NAME} PRIVATE Core::Core)

if(TARGET sinyue_warnings)
  target_link_libraries(${PROJECT_NAME} PRIVATE sinyue_warnings)
endif()
