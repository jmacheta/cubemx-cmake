cmake_minimum_required(VERSION 3.21)

set(CMAKE_TOOLCHAIN_FILE ${CMAKE_CURRENT_SOURCE_DIR}/../stm32l476_toolchain.cmake CACHE INTERNAL "" FORCE) # Hardcoded toolchain file to ease generation using CLI

# This shows that the user may modify part of generated sources, and, upon next generation, the modified bits will persist
project(persistent_project_part LANGUAGES CXX C ASM)

cubemx_addlibrary(bsp CONFIG_FILE config.ioc) 

add_executable(persistent_project_part_app main.cpp)
target_link_libraries(persistent_project_part_app PRIVATE bsp)
