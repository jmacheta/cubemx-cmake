cmake_minimum_required(VERSION 3.21)

set(CUBEMX_CMAKE_DIR ${CMAKE_CURRENT_LIST_DIR})

if (DEFINED ENV{CUBEMX_DIR})
  set(CUBEMX_DIR "$ENV{CUBEMX_DIR}")
endif ()
if (${CMAKE_HOST_SYSTEM_NAME} STREQUAL "Windows")
  set(CUBEMX_DEFAULT_DIR_WINDOWS "C:/Program Files/STMicroelectronics/STM32Cube/STM32CubeMX")
  find_file(CUBEMX STM32CubeMX.exe HINTS ${CUBEMX_DIR} ${CUBEMX_DEFAULT_DIR_WINDOWS})
else ()
  set(CUBEMX_DEFAULT_DIR_LINUX "$ENV{HOME}/STM32CubeMX")
  find_file(CUBEMX STM32CubeMX HINTS ${CUBEMX_DIR} ${CUBEMX_DEFAULT_DIR_LINUX})
endif ()

get_filename_component(CUBEMX_DIR "${CUBEMX}" DIRECTORY CACHE)

set(CUBEMX_JRE "${CUBEMX_DIR}/jre/bin/java" CACHE PATH "CubeMX Java instance")

include(${CUBEMX_CMAKE_DIR}/makefile_parser.cmake)

function (CubeMX_AddLibrary NAME)
  set(FLAGS FORCE NO_LDSCRIPT NO_STARTUP)
  set(SINGLE_ARGS CONFIG_FILE DESTINATION)
  set(MULTI_ARGS ADDITIONAL_COMMANDS)
  cmake_parse_arguments(OPT "${FLAGS}" "${SINGLE_ARGS}" "${MULTI_ARGS}" ${ARGN})
  message(STATUS "Configuring CubeMX target ${NAME}")
  list(APPEND CMAKE_MESSAGE_INDENT "  ")

  if (OPT_UNPARSED_ARGUMENTS)
    message(FATAL_ERROR "Unrecognized arguments: ${OPT_UNPARSED_ARGUMENTS}")
  endif ()

  if (OPT_KEYWORDS_MISSING_VALUES)
    message(FATAL_ERROR "Missing values for keywords: ${OPT_KEYWORDS_MISSING_VALUES}")
  endif ()

  if (NOT OPT_CONFIG_FILE)
    message(VERBOSE "CONFIG_FILE not specified. Using ${CMAKE_CURRENT_SOURCE_DIR}/${NAME}.ioc")
    set(OPT_CONFIG_FILE "${CMAKE_CURRENT_SOURCE_DIR}/${NAME}.ioc")
  endif ()

  if (NOT IS_ABSOLUTE ${OPT_CONFIG_FILE})
    message(DEBUG "CONFIG_FILE is not absolute path. Assuming it exists in current source directory")
    set(OPT_CONFIG_FILE ${CMAKE_CURRENT_SOURCE_DIR}/${OPT_CONFIG_FILE})
  endif ()

  message(DEBUG "Checking if ${OPT_CONFIG_FILE} exists")

  if (NOT EXISTS "${OPT_CONFIG_FILE}")
    message(FATAL_ERROR "Configuring CubeMX target ${NAME} failed - Configuration file \"${OPT_CONFIG_FILE}\" does not exist")
  endif ()

  if (TARGET ${NAME})
    message(FATAL_ERROR "Configuring CubeMX target \"${NAME}\" failed - Target with the same name already exists")
  endif ()

  if (NOT OPT_DESTINATION)
    get_filename_component(OPT_DESTINATION ${OPT_CONFIG_FILE} DIRECTORY)
  endif ()

  set(DESTINATION ${OPT_DESTINATION}/${NAME})
  message(VERBOSE "Using destination directory: ${DESTINATION}")

  set(ADDITIONAL_COMMANDS)
  message(VERBOSE "Using additional commands:${OPT_ADDITIONAL_COMMANDS}")
  foreach (CMD IN LISTS OPT_ADDITIONAL_COMMANDS)
    string(APPEND ADDITIONAL_COMMANDS "${CMD}\n")
  endforeach ()

  if (OPT_FORCE)
    message(DEBUG "FORCE option enabled. This will enforce CubeMX code generation.")
  endif ()

  set(MAKEFILE ${DESTINATION}/Makefile)
  set(METADATA_FILE ${DESTINATION}/.cmake_generated)

  _project_changed(PROJECT_CHANGED)

  if (PROJECT_CHANGED OR OPT_FORCE)
    if (PROJECT_CHANGED)
      message(STATUS "CubeMX project files changed. for target ${NAME}")
    endif ()
    set(GENERATE_SOURCES TRUE)
  else ()
    set(GENERATE_SOURCES FALSE)
    message(STATUS "Found existing project files and config file is unchanged. Skipping generation")
  endif ()

  if (GENERATE_SOURCES)
    message(STATUS "Generating CubeMX project files for target ${NAME}")
    set(GENERATE_SCRIPT ${CMAKE_CURRENT_BINARY_DIR}/cubemx_generate_script.txt)
    configure_file(${CUBEMX_CMAKE_DIR}/cubemx_generate_script.txt.in ${GENERATE_SCRIPT} @ONLY)
    execute_process(COMMAND ${CUBEMX_JRE} -jar ${CUBEMX} -q ${GENERATE_SCRIPT} OUTPUT_QUIET COMMAND_ERROR_IS_FATAL ANY)

    _generate_checksum_file("${METADATA_FILE}")

    # When destination or name differs from the one, stored in config file, CubeMX tends to generate new config in destination directory. Remove it to decrease mess
    if (EXISTS ${DESTINATION}/${NAME}.ioc)
      file(REMOVE ${DESTINATION}/${NAME}.ioc)
    endif ()
    file(REMOVE ${GENERATE_SCRIPT})

    message(STATUS "Generating CubeMX project files for target ${NAME} - done")
  endif ()

  parse_makefile(${MAKEFILE})
  _to_absolute("${DESTINATION}" "${C_SOURCES_VALUE}" C_SOURCES)
  _to_absolute("${DESTINATION}" "${ASM_SOURCES_VALUE}" ASM_SOURCES)

  set(C_INCLUDES ${C_INCLUDES_VALUE})
  list(TRANSFORM C_INCLUDES REPLACE "-I" "")
  _to_absolute("${DESTINATION}" "${C_INCLUDES}" C_INCLUDES)

  set(C_DEFINES ${C_DEFS_VALUE})
  list(TRANSFORM C_DEFINES REPLACE "-D" "")

  add_library(${NAME} OBJECT ${C_SOURCES})
  if (NOT OPT_NO_STARTUP)
    target_sources(${NAME} PRIVATE ${ASM_SOURCES})
    message(VERBOSE "CubeMX ${NAME} target will use startup code from: ${ASM_SOURCES}")
  endif ()

  target_include_directories(${NAME} PUBLIC ${C_INCLUDES})
  target_compile_definitions(${NAME} PUBLIC ${C_DEFINES})

  if (NOT OPT_NO_LDSCRIPT)
    set(LDSCRIPT ${DESTINATION}/${LDSCRIPT_VALUE})
    target_link_options(${NAME} PUBLIC -T ${LDSCRIPT})
    message(VERBOSE "CubeMX ${NAME} target will use LDSCRIPT: ${LDSCRIPT}")
  endif ()

  list(POP_BACK CMAKE_MESSAGE_INDENT)
  message(STATUS "Configuring CubeMX target ${NAME} - done")
endfunction ()

function (_to_absolute PREFIX PATHS OUT_VAR)
  set(OUT_LIST)
  foreach (ENTRY IN LISTS PATHS)
    if (IS_ABSOLUTE "${ENTRY}")
      list(APPEND OUT_LIST "${ENTRY}")
    else ()
      list(APPEND OUT_LIST "${PREFIX}/${ENTRY}")
    endif ()
  endforeach ()

  set(${OUT_VAR} "${OUT_LIST}" PARENT_SCOPE)
endfunction ()

function (_generate_checksum_file METADATA_FILE)
  message(DEBUG "Generating Metadata file ${METADATA_FILE}")
  file(SHA1 ${OPT_CONFIG_FILE} CONFIG_FILE_CHECKSUM)
  set(CONFIG_CHECKSUM_STRING "CONFIG_CHECKSUM: ${CONFIG_FILE_CHECKSUM}")

  file(SHA1 ${MAKEFILE} MAKEFILE_FILE_CHECKSUM)
  set(MAKEFILE_CHECKSUM_STRING "MAKEFILE_CHECKSUM: ${MAKEFILE_FILE_CHECKSUM}")

  file(WRITE "${METADATA_FILE}" "${CONFIG_CHECKSUM_STRING}\n${MAKEFILE_CHECKSUM_STRING}")
  message(TRACE "Metadata content: ${CONFIG_CHECKSUM_STRING}\n${MAKEFILE_CHECKSUM_STRING}")
endfunction ()

function (_project_changed HAS_CHANGED)
  if (EXISTS ${METADATA_FILE} AND EXISTS ${MAKEFILE})
    file(SHA1 ${OPT_CONFIG_FILE} CONFIG_FILE_CHECKSUM)
    set(CONFIG_CHECKSUM_STRING "CONFIG_CHECKSUM: ${CONFIG_FILE_CHECKSUM}")

    file(SHA1 ${MAKEFILE} MAKEFILE_FILE_CHECKSUM)
    set(MAKEFILE_CHECKSUM_STRING "MAKEFILE_CHECKSUM: ${MAKEFILE_FILE_CHECKSUM}")

    file(STRINGS ${METADATA_FILE} METADATA)

    if ((MAKEFILE_CHECKSUM_STRING IN_LIST METADATA) AND CONFIG_CHECKSUM_STRING IN_LIST METADATA)
      set(${HAS_CHANGED} FALSE PARENT_SCOPE)
      return()
    endif ()
  endif ()

  set(${HAS_CHANGED} TRUE PARENT_SCOPE)
endfunction ()
