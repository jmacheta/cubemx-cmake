cmake_minimum_required(VERSION 3.21)

set(CMAKE_TOOLCHAIN_FILE
    ${CMAKE_CURRENT_SOURCE_DIR}/stm32l476_toolchain.cmake
    CACHE INTERNAL "" FORCE
) # Hardcoded toolchain file to ease generation using CLI

project(cubemx_cmake_basic_usage LANGUAGES CXX C ASM)

list(APPEND CMAKE_MODULE_PATH ${PROJECT_SOURCE_DIR}/../..) # This is not necessary when using FetchContent

find_package(cubemx_cmake REQUIRED)
include(cubemx_utils)
cubemx_addlibrary(basic_usage) # Adds "basic_usage" OBJECT library using implicit config file name "basic_usage.ioc". The code will be generated once and all sources will be added. The library
# has
# dependency to generated LDSCRIPT which is used on link-time with example_app. The library provides configured C_DEFS as public interface

add_executable(example_app main.cpp)
target_link_libraries(example_app PRIVATE basic_usage)
