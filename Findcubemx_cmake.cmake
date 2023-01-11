cmake_minimum_required(VERSION 3.21)

include(FindPackageHandleStandardArgs)

find_package_handle_standard_args(cubemx_cmake DEFAULT_MSG)

if(NOT CMAKE_MODULE_PATH)
  set(CMAKE_MODULE_PATH)
endif()

list(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_LIST_DIR}/cmake)