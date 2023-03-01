cmake_minimum_required(VERSION 3.21)

# This shows that the user may modify part of generated sources, and, upon next generation, the modified bits will persist
project(persistent_project_part LANGUAGES CXX C ASM)

include(${CMAKE_CURRENT_SOURCE_DIR}/../../cubemx_utils.cmake)

cubemx_add_library(bsp CONFIG_FILE config.ioc)

add_executable(persistent_project_part_app main.cpp)
target_link_libraries(persistent_project_part_app PRIVATE bsp)
