cmake_minimum_required(VERSION 3.21)

project(cubemx_cmake_basic_usage LANGUAGES CXX C ASM)

# Ignore error that add_library is not scriptable
execute_process(ERROR_QUIET COMMAND ${CMAKE_COMMAND} -P ${CMAKE_CURRENT_LIST_DIR}/try_generate.cmake)
file(TIMESTAMP ${CMAKE_CURRENT_SOURCE_DIR}/my_library/Makefile MAKEFILE_MODIFICATION_TIME1)
message("Makefile modification timestamp after first generation attempt: ${MAKEFILE_MODIFICATION_TIME1}")

# Ignore error that add_library is not scriptable
execute_process(ERROR_QUIET COMMAND ${CMAKE_COMMAND} -P ${CMAKE_CURRENT_LIST_DIR}/try_generate.cmake)
file(TIMESTAMP ${CMAKE_CURRENT_SOURCE_DIR}/my_library/Makefile MAKEFILE_MODIFICATION_TIME2)
message("Makefile modification timestamp after second generation attempt: ${MAKEFILE_MODIFICATION_TIME2}")

if (NOT MAKEFILE_MODIFICATION_TIME1 STREQUAL MAKEFILE_MODIFICATION_TIME2)
  message(FATAL_ERROR "CubeMX project generated again where it shouln't")
endif ()

# Ignore error that add_library is not scriptable
execute_process(ERROR_QUIET COMMAND ${CMAKE_COMMAND} -DFORCE:BOOL=ON -P ${CMAKE_CURRENT_LIST_DIR}/try_generate.cmake)
file(TIMESTAMP ${CMAKE_CURRENT_SOURCE_DIR}/my_library/Makefile MAKEFILE_MODIFICATION_TIME_FORCED)
message("Makefile modification timestamp after forced generation: ${MAKEFILE_MODIFICATION_TIME_FORCED}")

if (MAKEFILE_MODIFICATION_TIME1 STREQUAL MAKEFILE_MODIFICATION_TIME_FORCED)
  message(FATAL_ERROR "CubeMX project not generated when forced")
endif ()
