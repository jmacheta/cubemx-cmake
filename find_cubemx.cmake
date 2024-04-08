# ######################################################################################################################################################################################################
# Looks for standalone CubeMX executable
# ######################################################################################################################################################################################################
function (find_cubemx_standalone)
  message(CHECK_START "Checking standalone instances")
  set(CUBEMX_DEFAULT_DIR_LINUX "$ENV{HOME}/STM32CubeMX")
  set(CUBEMX_DEFAULT_DIR_WINDOWS "C:/Program Files/STMicroelectronics/STM32Cube/STM32CubeMX")
  set(CUBEMX_REGISTRY_PATH "[HKLM/SOFTWARE/WOW6432Node/Microsoft/Windows/CurrentVersion/App Paths/STM32CubeMX.exe;Path]")

  find_file(CUBEMX_I NAMES STM32CubeMX STM32CubeMX.exe STM32CubeMX.jar PATHS $ENV{CUBEMX_DIR} ${CUBEMX_DIR} ${CUBEMX_DEFAULT_DIR_LINUX} ${CUBEMX_DEFAULT_DIR_WINDOWS} ${CUBEMX_REGISTRY_PATH})

  if (NOT CUBEMX_I)
    message(CHECK_FAIL "not found")
    return()
  endif ()

  get_filename_component(CUBEMX_HOME "${CUBEMX_I}" DIRECTORY)
  message(CHECK_PASS "found at ${CUBEMX_HOME}")
  
  message(CHECK_START "Looking for JRE")
  message(TRACE "CubeMX home directory: ${CUBEMX_HOME}")
  
  find_file(JRE_EXE NAMES java java.exe HINTS "${CUBEMX_HOME}/jre/bin")
  if (NOT JRE_EXE)
    message(CHECK_FAIL "not found")
    return()
  endif ()
  message(CHECK_PASS "found")

  set(CUBEMX "${CUBEMX_I}" CACHE PATH "CubeMX instance")
  set(CUBEMX_JRE "${CUBEMX_HOME}/jre/bin/java" CACHE PATH "CubeMX Java instance")
endfunction ()

function (find_cubeide)
  message(CHECK_START "Looking for CubeIDE")
  set(CUBEIDE_PATHS)
  if ((${CMAKE_HOST_SYSTEM_NAME} STREQUAL "Windows") AND (${CMAKE_VERSION} VERSION_GREATER_EQUAL "3.24.0"))
    # Query windows registry for CubeIDE installation paths
    cmake_host_system_information(RESULT CUBEIDE_KEYS QUERY WINDOWS_REGISTRY "HKLM/SOFTWARE/WOW6432Node/STMicroelectronics/STM32CubeIDE" SUBKEYS)
    list(SORT CUBEIDE_KEYS ORDER DESCENDING)
    foreach (CUBEIDE_INST IN LISTS CUBEIDE_KEYS)
      cmake_host_system_information(RESULT CUBE_D QUERY WINDOWS_REGISTRY "HKLM/SOFTWARE/WOW6432Node/STMicroelectronics/STM32CubeIDE/${CUBEIDE_INST}" VALUE "Path")
      list(APPEND CUBEIDE_PATHS "${CUBE_D}")
    endforeach ()
  endif ()

  # Gather instances from Windows default installation path
  set(CUBEIDE_DEFAULT_DIR_WINDOWS "C:/ST")
  file(GLOB CUBEIDE_DIRS "${CUBEIDE_DEFAULT_DIR_WINDOWS}/STM32CubeIDE_*")
  list(SORT CUBEIDE_DIRS ORDER DESCENDING)
  list(APPEND CUBEIDE_PATHS "${CUBEIDE_DIRS}")

  list(REMOVE_DUPLICATES CUBEIDE_PATHS)
  list(TRANSFORM CUBEIDE_PATHS APPEND "/STM32CubeIDE")

  find_file(CUBEIDE NAMES stm32cubeide stm32cubeide.exe PATHS $ENV{CUBEIDE_DIR} ${CUBEIDE_PATHS})

  if (NOT CUBEIDE)
    message(CHECK_FAIL "not found")
  endif ()

  get_filename_component(CUBEIDE_DIR "${CUBEIDE}" DIRECTORY)
  message(CHECK_PASS "found at ${CUBEIDE_DIR}")

  set(CUBEIDE_DIR "${CUBEIDE_DIR}" CACHE PATH "CubeIDE directory")
endfunction ()

# ######################################################################################################################################################################################################
# Looks for CubeMX integrated in CubeIDE
# ######################################################################################################################################################################################################
function (find_cubemx_cubeide)
  message(CHECK_START "Checking CubeIDE instances")
  if (NOT CUBEIDE_DIR)
    find_cubeide()
  endif ()
  if (NOT CUBEIDE_DIR)
    message(CHECK_FAIL "CubeIDE not found")
    return()
  endif ()

  file(GLOB CUBEMX_DIRS "${CUBEIDE_DIR}/plugins/com.st.stm32cube.common.mx_*/")
  foreach (CUBEMX_D IN LISTS CUBEMX_DIRS)
    find_file(CUBEMX_I STM32CubeMX.jar PATHS "${CUBEMX_D}" NO_DEFAULT_PATH)
    if (CUBEMX_I)
      message(CHECK_PASS "found CubeMX at ${CUBEMX_D}")
      break()
    endif ()
  endforeach ()

  if (NOT CUBEMX_I)
    message(CHECK_FAIL "not found")
    return()
  endif ()

  message(CHECK_START "Looking for JRE")
  file(GLOB CUBEMX_JRE_DIRS "${CUBEIDE_DIR}/plugins/com.st.stm32cube.ide.jre.*/jre/bin")
  foreach (JRE_D IN LISTS CUBEMX_JRE_DIRS)
    find_file(JRE_EXE NAMES java.exe java PATHS "${JRE_D}")
    if (JRE_EXE)
      message(CHECK_PASS "found at ${JRE_D}")
      break()
    endif ()
  endforeach ()

  if (NOT JRE_EXE)
    message(CHECK_FAIL "JRE not found")
    return()
  endif ()

  set(CUBEMX "${CUBEMX_I}" CACHE PATH "CubeMX instance")
  set(CUBEMX_JRE "${JRE_EXE}" CACHE PATH "CubeMX Java instance")

endfunction ()

# ######################################################################################################################################################################################################
# Looks for CubeMX. If found, sets CUBEMX and CUBEMX_JRE cache variables
# ######################################################################################################################################################################################################
macro (find_cubemx)
  message(CHECK_START "Looking for CubeMX")
  list(APPEND CMAKE_MESSAGE_INDENT "  ")
  find_cubemx_standalone()

  if (NOT CUBEMX OR NOT CUBEMX_JRE)
    find_cubemx_cubeide()
  endif ()

  list(POP_BACK CMAKE_MESSAGE_INDENT)

  if (NOT CUBEMX OR NOT CUBEMX_JRE)
    message(CHECK_FAIL "not found")
    message(FATAL_ERROR "CubeMX not found")
  else ()
    message(CHECK_PASS "found")
  endif ()
endmacro ()
