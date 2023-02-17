cmake_minimum_required(VERSION 3.21)

project(cubemx_cmake_basic_usage LANGUAGES CXX C ASM)

include(${CMAKE_CURRENT_SOURCE_DIR}/../../cubemx_utils.cmake)

cubemx_addlibrary(basic_usage) # Adds "basic_usage" OBJECT library using implicit config file name "basic_usage.ioc". The code will be generated once and all sources will be added. The library
# has dependency to generated LDSCRIPT which is used on link-time with example_app. The library provides configured C_DEFS as public interface

add_executable(example_app main.cpp)
target_link_libraries(example_app PRIVATE basic_usage)
