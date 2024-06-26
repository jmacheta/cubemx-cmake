# CMake instrumentation for STM32 CubeMX

This package provides CMake cross-platform instrumentation STM32 CubeMX application.
Its main intent is to automate CMake library generation from CubeMX project files (.ioc), to reduce unnecessary clutter in repositories that simply use STM32HAL.

The package provides flexible way of defining, which components of generated code to use (start code, compiler definitions, linker script).

## Installation

The easiest way is to use built-in CMake FetchContent:

```cmake
include(FetchContent)
FetchContent_Declare(cubemx_cmake URL https://github.com/jmacheta/cubemx-cmake/tarball/latest)
FetchContent_MakeAvailable(cubemx_cmake)
```

Alternatively, you can add this repo as a submodule, and simply use ```add_subdirectory(<path_to_cubemx_cmake_in_your_tree>)```

## Example Usage

> **NOTE**
> This script will look for CubeMX executable in PATH, and default install directories.
> If you have installed CubeMX in different directory, set either environment variable CUBEMX_DIR, or cmake variable BEFORE FetchContent_MakeAvailable

```cmake
cubemx_add_library(<path_to_ioc_file>) ## eg. C:/my_hardware.ioc, my_hardware.ioc (assuming it exists in current source dir), or simply my_hardware (.ioc file extension is assumed)

# Add some application to link with.
add_executable(my_app main.cpp) 

# Link application with generated files from CubeMX. The generated library will have the same name as the .ioc file (unless you use advanced options. See API reference).
# my_hardware target has public dependency to generated LDSCRIPT, and provides generated C defines (unless you use advanced options. See API reference again).
target_link_libraries(my_app PRIVATE my_hardware)

```

## API Reference

```
Generate CubeMX project from .ioc file, then add a library target

    cubemx_add_library(<name>)

Add a library target from existing CubeMX-generated Makefile

    cubemx_add_library_from(<name> <makefile_path>)

Generate CubeMX project

    cubemx_generate(<generate_script_path>)
```

Basic signature:

```cmake
cubemx_add_library(<TargetName>)
```

The basic signature assumes that the name of the target to generate is the same as the name of CubeMX configuration file, and it exists in current source directory. If so, The function will generate the code using CubeMX, and create Cmake OBJECT library with all sources, compile definitions, and LDSCRIPT.

Regardless of the mode used, a .cmake_generated file will be created in the destination directory, that allows skipping generation step when both .ioc file and generated Makefile did not change.

Full signature:

```cmake
cubemx_add_library(<TargetName> [CONFIG_FILE <path>] [DESTINATION <path>]
    [NO_STARTUP]
    [NO_LDSCRIPT]
    [FORCE]
    [ADDITIONAL_COMMANDS command1 [command2 ...]]
)
```

The ```CONFIG_FILE``` option specifies path to .ioc file. It is useful when you want to specify ```TargetName``` that differs from the config file name.
If relative path is used, it is assumed that it is relative to ```CMAKE_CURRENT_SOURCE_DIR```

The code will be generated in <config_file_directory> directory. If different destination is needed, ```DESTINATION``` option should specify required directory. If relative path is used, it is assumed that it is relative to ```CMAKE_CURRENT_SOURCE_DIR```

Generated target will enforce linking with generated LDSCRIPT unless ```NO_LDSCRIPT``` option is provided.

If it is desired to execute code generation every time CMake is configures, use ```FORCE``` option.

By using ```ADDITIONAL_COMMANDS``` it is possible to customize CubeMX generation script: pass command sequence as consecutive arguments


```cmake
cubemx_add_library_from(<name> <makefile_path> [NO_LDSCRIPT] [NO_STARTUP] [NO_DEFS])
```
Adds a library target from existing Makefile. This function Does Not look for CubeMX instance, so might be useful when none is present.
The other options do the same as in ```cubemx_add_library```



## Limitations

By desing I only support CubeMX Makefile projects. If provided .ioc file uses different generator, it will be overriden (see cubemx_generate_script)

Currently I don't see a need to support generating executable targets - If you need to create exec, create a dummy file and link with the generated library:

```cmake
file(TOUCH dummy.c)
add_executable(my_exec dummy.c)
target_link_libraries(my_exec my_generated_library)
```

If you think, that separate executable function should be implemented, feel free to contact me ;)

## Non-Affiliation Disclaimer

This package is not endorsed by, directly affiliated with, maintained, authorized, or sponsored by STMicroelectronics. All product and company names are the registered trademarks of their original owners. The use of any trade name or trademark is for identification and reference purposes only and does not imply any association with the trademark holder of their product brand.
