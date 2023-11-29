################################################################################
# Looks for standalone CubeMX executable
################################################################################
macro (find_cubemx_standalone)
  message(STATUS "Looking for CubeMX executable")
  if (DEFINED ENV{CUBEMX_DIR})
    set(CUBEMX_DIR "$ENV{CUBEMX_DIR}")
  endif ()
  if (${CMAKE_HOST_SYSTEM_NAME} STREQUAL "Windows")
    set(CUBEMX_DEFAULT_DIR_WINDOWS "C:/Program Files/STMicroelectronics/STM32Cube/STM32CubeMX")
    set(CUBEMX_REGISTRY_PATH "[HKLM/SOFTWARE/WOW6432Node/Microsoft/Windows/CurrentVersion/App Paths/STM32CubeMX.exe;Path]")
    # Query registry when CMake supports it
    if (${CMAKE_VERSION} VERSION_GREATER_EQUAL "3.24.0")
      find_file(CUBEMX STM32CubeMX.exe HINTS ${CUBEMX_DIR} ${CUBEMX_DEFAULT_DIR_WINDOWS} ${CUBEMX_REGISTRY_PATH})
    else ()
      find_file(CUBEMX STM32CubeMX.exe HINTS ${CUBEMX_DIR} ${CUBEMX_DEFAULT_DIR_WINDOWS})
    endif ()

  elseif (${CMAKE_HOST_SYSTEM_NAME} STREQUAL "Linux")
    set(CUBEMX_DEFAULT_DIR_LINUX "$ENV{HOME}/STM32CubeMX")
    find_file(CUBEMX STM32CubeMX HINTS ${CUBEMX_DIR} ${CUBEMX_DEFAULT_DIR_LINUX})

  else ()
    message(WARNING "Unsupported host system: ${CMAKE_HOST_SYSTEM_NAME}")
  endif ()

  if (CUBEMX)
    get_filename_component(CUBEMX_HOME "${CUBEMX}" DIRECTORY)
    message(TRACE "CubeMX home directory: ${CUBEMX_HOME}")
    set(CUBEMX_JRE "${CUBEMX_HOME}/jre/bin/java" CACHE PATH "CubeMX Java instance")
  endif ()
endmacro ()

# ######################################################################################################################################################################################################
# Looks for CubeMX integrated in CubeIDE
# ######################################################################################################################################################################################################
macro (find_cubemx_cubeide)

endmacro ()

# ######################################################################################################################################################################################################
# Looks for CubeMX
# ######################################################################################################################################################################################################
macro (find_cubemx)
  find_cubemx_standalone()
  find_cubemx_cubeide()
  if (NOT CUBEMX)
    message(FATAL_ERROR "CubeMX not found")
  endif ()
endmacro ()
