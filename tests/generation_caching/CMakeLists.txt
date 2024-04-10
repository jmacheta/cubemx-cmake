cmake_minimum_required(VERSION 3.21)

project(cubemx_cmake_basic_usage LANGUAGES CXX C ASM)

include(${CMAKE_CURRENT_SOURCE_DIR}/../../cubemx_utils.cmake)
find_cubemx()
# Ignore error that add_library is not scriptable
execute_process(ERROR_QUIET COMMAND ${CMAKE_COMMAND} -DCUBEMX:PATH=${CUBEMX} -DCUBEMX_JRE:PATH=${CUBEMX_JRE} -P ${CMAKE_CURRENT_LIST_DIR}/try_generate.cmake)
file(TIMESTAMP ${CMAKE_CURRENT_SOURCE_DIR}/my_library/Makefile MAKEFILE_MODIFICATION_TIME1)
message("Makefile modification timestamp after first generation attempt: ${MAKEFILE_MODIFICATION_TIME1}")

# Ignore error that add_library is not scriptable
execute_process(ERROR_QUIET COMMAND ${CMAKE_COMMAND} -DCUBEMX:PATH=${CUBEMX} -DCUBEMX_JRE:PATH=${CUBEMX_JRE} -P ${CMAKE_CURRENT_LIST_DIR}/try_generate.cmake)
file(TIMESTAMP ${CMAKE_CURRENT_SOURCE_DIR}/my_library/Makefile MAKEFILE_MODIFICATION_TIME2)
message("Makefile modification timestamp after second generation attempt: ${MAKEFILE_MODIFICATION_TIME2}")

if (NOT MAKEFILE_MODIFICATION_TIME1 STREQUAL MAKEFILE_MODIFICATION_TIME2)
  message(FATAL_ERROR "CubeMX project generated again where it shouldn't")
endif ()

# Ignore error that add_library is not scriptable
execute_process(ERROR_QUIET COMMAND ${CMAKE_COMMAND} -DCUBEMX:PATH=${CUBEMX} -DCUBEMX_JRE:PATH=${CUBEMX_JRE} -DFORCE:BOOL=ON -P ${CMAKE_CURRENT_LIST_DIR}/try_generate.cmake)
file(TIMESTAMP ${CMAKE_CURRENT_SOURCE_DIR}/my_library/Makefile MAKEFILE_MODIFICATION_TIME_FORCED)
message("Makefile modification timestamp after forced generation: ${MAKEFILE_MODIFICATION_TIME_FORCED}")

if (MAKEFILE_MODIFICATION_TIME1 STREQUAL MAKEFILE_MODIFICATION_TIME_FORCED)
  message(FATAL_ERROR "CubeMX project not generated when forced")
endif ()
