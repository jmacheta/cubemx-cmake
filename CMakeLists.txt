cmake_minimum_required(VERSION 3.21)

project(cubemx_cmake)

option(CUBEMX_CMAKE_BUILD_TESTS "Forces building test cases" OFF)

include(${CMAKE_CURRENT_SOURCE_DIR}/cubemx_utils.cmake)

if (PROJECT_IS_TOP_LEVEL OR CUBEMX_CMAKE_BUILD_TESTS)
  enable_testing()
  add_subdirectory(tests)
endif ()
