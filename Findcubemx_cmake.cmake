cmake_minimum_required(VERSION 3.21)

include(FindPackageHandleStandardArgs)


set(CUBEMX_CMAKE_DIR ${CMAKE_CURRENT_LIST_DIR})

include(${CUBEMX_CMAKE_DIR}/cubemx_makefile_parser.cmake)

if (DEFINED ENV{CUBEMX_DIR})
  set(CUBEMX_DIR "$ENV{CUBEMX_DIR}")
endif ()

set(CUBEMX_DEFAULT_DIR "C:/Program Files/STMicroelectronics/STM32Cube/STM32CubeMX")
find_path(CUBEMX_ROOT_DIR STM32CubeMX.exe HINTS ${CUBEMX_DIR} ${CUBEMX_DEFAULT_DIR})

set(CUBEMX ${CUBEMX_ROOT_DIR}/STM32CubeMX.exe)
set(CUBEMX_JRE ${CUBEMX_ROOT_DIR}/jre/bin/java)


find_package_handle_standard_args(cubemx_cmake DEFAULT_MSG CUBEMX CUBEMX_JRE)

if(NOT CMAKE_MODULE_PATH)
  set(CMAKE_MODULE_PATH)
endif()

list(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_LIST_DIR})