cmake_minimum_required(VERSION 3.21)

set(CUBEMX_CMAKE_DIR ${CMAKE_CURRENT_LIST_DIR})

include(${CUBEMX_CMAKE_DIR}/cubemx_makefile_parser.cmake)

if (DEFINED ENV{CUBEMX_DIR})
  set(CUBEMX_DIR "$ENV{CUBEMX_DIR}")
endif ()

set(CUBEMX_DEFAULT_DIR "C:/Program Files/STMicroelectronics/STM32Cube/STM32CubeMX")
find_path(CUBEMX_ROOT_DIR STM32CubeMX.exe HINTS ${CUBEMX_DIR} ${CUBEMX_DEFAULT_DIR})

set(CUBEMX ${CUBEMX_ROOT_DIR}/STM32CubeMX.exe)
set(CUBEMX_JRE ${CUBEMX_ROOT_DIR}/jre/bin/java)

function (CubeMX_AddLibrary NAME)
  set(FLAGS FORCE)
  set(SINGLE_ARGS CONFIG_FILE)
  set(MULTI_ARGS ADDITIONAL_COMMANDS)
  cmake_parse_arguments(OPT "${FLAGS}" "${SINGLE_ARGS}" "${MULTI_ARGS}" ${ARGN})

  if (NOT OPT_CONFIG_FILE)
    file(GLOB_RECURSE OPT_CONFIG_FILE "${CMAKE_CURRENT_SOURCE_DIR}/*/${NAME}.ioc")
    message(DEBUG "CONFIG_FILE not specified. Looking for ${NAME}.ioc")
  endif ()

  if (NOT EXISTS "${OPT_CONFIG_FILE}")
    message(FATAL_ERROR "CubeMX Configuration for target ${NAME} not found - \"${OPT_CONFIG_FILE}\" does not exist")
  endif ()

  get_filename_component(DESTINATION ${OPT_CONFIG_FILE} DIRECTORY)

  set(ADDITIONAL_COMMANDS)
  foreach (CMD IN LISTS OPT_ADDITIONAL_COMMANDS)
    string(APPEND ADDITIONAL_COMMANDS "${CMD}\n")
  endforeach ()

  set(DO_GENERATE_SOURCES TRUE)
  if (NOT OPT_FORCE AND ${NAME}_CUBEMX_GENERATED_CHECKSUM)
    file(SHA1 ${OPT_CONFIG_FILE} CONFIG_FILE_CHECKSUM)
    if (${NAME}_CUBEMX_GENERATED_CHECKSUM EQUAL CONFIG_FILE_CHECKSUM)
      set(DO_GENERATE_SOURCES FALSE)
    endif ()
  endif ()

  if (DO_GENERATE_SOURCES)
    set(GENERATE_SCRIPT ${CMAKE_CURRENT_BINARY_DIR}/${NAME}_generate_script.txt)
    configure_file(${CUBEMX_CMAKE_DIR}/cubemx_generate_script.txt.in ${GENERATE_SCRIPT} @ONLY)
    execute_process(COMMAND ${CUBEMX_JRE} -jar ${CUBEMX} -q ${GENERATE_SCRIPT})
    file(REMOVE ${GENERATE_SCRIPT})

    file(SHA1 ${OPT_CONFIG_FILE} CONFIG_FILE_CHECKSUM)
    set(${NAME}_CUBEMX_GENERATED_CHECKSUM
        ${CONFIG_FILE_CHECKSUM}
        CACHE INTERNAL "" FORCE
    )
  endif ()

  parse_makefile(${DESTINATION}/Makefile)
  set(C_SOURCES ${C_SOURCES_VALUE})
  set(ASM_SOURCES ${ASM_SOURCES_VALUE})
  set(C_INCLUDES ${C_INCLUDES_VALUE})
  set(C_DEFINES ${C_DEFS_VALUE})

  set(LDSCRIPT ${DESTINATION}/${LDSCRIPT_VALUE})

  list(TRANSFORM C_SOURCES PREPEND "${DESTINATION}/")

  list(TRANSFORM ASM_SOURCES PREPEND "${DESTINATION}/")

  list(TRANSFORM C_INCLUDES REPLACE "-I" "")
  list(TRANSFORM C_INCLUDES PREPEND "${DESTINATION}/")

  list(TRANSFORM C_DEFINES REPLACE "-D" "")

  add_library(${NAME} OBJECT ${C_SOURCES} ${ASM_SOURCES})
  target_include_directories(${NAME} PUBLIC ${C_INCLUDES})
  target_compile_definitions(${NAME} PUBLIC ${C_DEFINES})
  # target_link_libraries(${NAME} INTERFACE $<TARGET_OBJECTS:${NAME}>)
   target_link_options(${NAME} PUBLIC -T ${LDSCRIPT})
endfunction ()
