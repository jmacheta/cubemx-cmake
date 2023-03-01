include(${CMAKE_CURRENT_LIST_DIR}/../../cubemx_utils.cmake)

if (FORCE)
  message("Force generate CubeMX project")
  cubemx_add_library(my_library CONFIG_FILE ${CMAKE_CURRENT_LIST_DIR}/config.ioc FORCE)
else ()
  message("Generate CubeMX project if not changed")
  cubemx_add_library(my_library CONFIG_FILE ${CMAKE_CURRENT_LIST_DIR}/config.ioc)
endif ()
