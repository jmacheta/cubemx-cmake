cmake_minimum_required(VERSION 3.21)

project(cubemx_cmake_tests)

include(ExternalProject)

ExternalProject_Add(
  basic_usage
  SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/basic_usage
  CMAKE_ARGS --toolchain=${CMAKE_CURRENT_SOURCE_DIR}/stm32l476_toolchain.cmake
)


ExternalProject_Add(
  persistent_project_part
  SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/persistent_project_part
  CMAKE_ARGS --toolchain=${CMAKE_CURRENT_SOURCE_DIR}/stm32l476_toolchain.cmake

)


ExternalProject_Add(
  generation_caching
  SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/generation_caching
  CMAKE_ARGS --toolchain=${CMAKE_CURRENT_SOURCE_DIR}/stm32l476_toolchain.cmake
)
