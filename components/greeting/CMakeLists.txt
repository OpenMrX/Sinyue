cmake_minimum_required(VERSION 3.25)
project(greeting)

# abcmake resolves through the CMAKE_PREFIX_PATH set by the root project,
# so this folder also builds standalone once abcmake is installed.
find_package(abcmake REQUIRED)

add_component(${PROJECT_NAME})

if(TARGET sinyue_warnings)
  target_link_libraries(${PROJECT_NAME} PRIVATE sinyue_warnings)
endif()
