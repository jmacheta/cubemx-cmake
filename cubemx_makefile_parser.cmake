cmake_minimum_required(VERSION 3.21)

function (parse_makefile MAKEFILE)
  file(READ "${MAKEFILE}" MAKEFILE_CONTENT)
  string(REGEX REPLACE "[\\]+[\n\r]" "" MAKEFILE_CONTENT ${MAKEFILE_CONTENT}) # Consolidate broken lines
  string(REGEX REPLACE "[\r\n]" ";" MAKEFILE_LINES ${MAKEFILE_CONTENT}) # Split string into list of separate lines
  list(FILTER MAKEFILE_LINES INCLUDE REGEX "^[A-Za-z0-9_]+[ \t]*(=|\\+=|:=)") # Filter out lines that does not resemble variable assignments (v_name = value) or (v_name := value) or (v_name += value)

  set(MAKEFILE_VARIABLES)

  foreach (LINE IN LISTS MAKEFILE_LINES)
    if (LINE MATCHES "^[A-Za-z0-9_]+:=")

    elseif (LINE MATCHES "^[A-Za-z0-9_]+[ \t]*=")
      # Handle recursive assignment case
      string(REGEX REPLACE "^([A-Za-z0-9_]+)[ \t]*=[ \t]*(.*$)" "\\1;\\2" LINE_SPLITTED ${LINE})
      list(GET LINE_SPLITTED 0 VAR_NAME)

      list(GET LINE_SPLITTED -1 VAR_VALUE)
      # string(STRIP VAR_VALUE "${VAR_VALUE}")

      list(APPEND MAKEFILE_VARIABLES ${VAR_NAME})
      string(REGEX REPLACE "[ \t]+" ";" VAR_VALUE_SPLITTED "${VAR_VALUE}")

      set(${VAR_NAME}_VALUE "${VAR_VALUE_SPLITTED}")

      message(DEBUG "VARIABLE ${VAR_NAME}   ${${VAR_NAME}_VALUE}")

    elseif (LINE MATCHES "^[A-Za-z0-9_]+[ \t]*\\+=")
      # Handle  appending case
      string(REGEX REPLACE "^([A-Za-z0-9_]+)[ \t]*\\+=[ \t]*(.*$)" "\\1;\\2" LINE_SPLITTED ${LINE})
      list(GET LINE_SPLITTED 0 VAR_NAME)

      list(GET LINE_SPLITTED -1 VAR_VALUE)
      # string(STRIP VAR_VALUE "${VAR_VALUE}")

      list(APPEND MAKEFILE_VARIABLES ${VAR_NAME})
      string(REGEX REPLACE "[ \t]+" ";" VAR_VALUE_SPLITTED "${VAR_VALUE}")

      set(${VAR_NAME}_VALUE "${VAR_VALUE_SPLITTED}")

      message(DEBUG "VARIABLE ${VAR_NAME}   ${${VAR_NAME}_VALUE}")

    endif ()
  endforeach ()

  list(REMOVE_DUPLICATES MAKEFILE_VARIABLES)
  foreach (VAR IN LISTS MAKEFILE_VARIABLES)
    set(${VAR}_VALUE
        ${${VAR}_VALUE}
        PARENT_SCOPE
    )
  endforeach ()
  set(MAKEFILE_VARIABLES
      ${MAKEFILE_VARIABLES}
      PARENT_SCOPE
  )

  message(DEBUG "VARIABLES: ${MAKEFILE_VARIABLES}")
endfunction ()
