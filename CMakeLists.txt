cmake_minimum_required(VERSION 3.25)

project(luma LANGUAGES CXX)

# Optimized builds by default (single-config generators like MinGW Makefiles).
if(NOT CMAKE_BUILD_TYPE AND NOT CMAKE_CONFIGURATION_TYPES)
    set(CMAKE_BUILD_TYPE Release CACHE STRING "Build type" FORCE)
endif()

set(CMAKE_CXX_STANDARD 23)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/out")
foreach(config DEBUG RELEASE RELWITHDEBINFO MINSIZEREL)
    set(CMAKE_RUNTIME_OUTPUT_DIRECTORY_${config} "${CMAKE_CURRENT_SOURCE_DIR}/out")
endforeach()

file(GLOB_RECURSE LUMA_SOURCES "${CMAKE_CURRENT_SOURCE_DIR}/src/*.cpp")
list(FILTER LUMA_SOURCES EXCLUDE REGEX ".*/app/main\\.cpp$")
list(FILTER LUMA_SOURCES EXCLUDE REGEX ".*/app/editor_main\\.cpp$")
# v0.3: Remove the old C++ codegen backend — replaced by bytecode bundler.
list(FILTER LUMA_SOURCES EXCLUDE REGEX ".*/app/cpp_backend\\.cpp$")

# --- Optional SDL2 windowing/rendering support ---------------------------
# Enables the `window_*` built-ins for real windows. Falls back to a
# no-op stub (programs still compile/run, just without visible windows) when
# SDL2 development files are not installed. Install SDL2 with, e.g., MSYS2:
#   pacman -S mingw-w64-x86_64-SDL2
find_package(SDL2 CONFIG QUIET)
if(NOT SDL2_FOUND)
    find_package(SDL2 QUIET)
endif()

set(LUMA_HAVE_SDL2_BOOL "false")
set(LUMA_SDL2_COMPILE_FLAGS "")
set(LUMA_SDL2_LINK_FLAGS "")
set(LUMA_INCLUDE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/include")
set(LUMA_SOURCE_DIR "${CMAKE_CURRENT_SOURCE_DIR}")

if(TARGET SDL2::SDL2)
    set(LUMA_HAVE_SDL2_BOOL "true")
elseif(SDL2_FOUND)
    set(LUMA_HAVE_SDL2_BOOL "true")
    foreach(dir IN LISTS SDL2_INCLUDE_DIRS)
        string(APPEND LUMA_SDL2_COMPILE_FLAGS "-I${dir} ")
    endforeach()
    foreach(lib IN LISTS SDL2_LIBRARIES)
        string(APPEND LUMA_SDL2_LINK_FLAGS "${lib} ")
    endforeach()
endif()

configure_file(
    "${CMAKE_CURRENT_SOURCE_DIR}/include/luma/build_config.hpp.in"
    "${CMAKE_CURRENT_BINARY_DIR}/generated/luma/build_config.hpp"
    @ONLY
)

add_library(luma_runtime STATIC ${LUMA_SOURCES})
target_include_directories(luma_runtime PUBLIC
    "${CMAKE_CURRENT_SOURCE_DIR}/include"
    "${CMAKE_CURRENT_BINARY_DIR}/generated"
)

if(TARGET SDL2::SDL2)
    target_compile_definitions(luma_runtime PUBLIC LUMA_HAVE_SDL2=1)
    target_link_libraries(luma_runtime PUBLIC SDL2::SDL2)
    if(TARGET SDL2::SDL2main)
        target_link_libraries(luma_runtime PUBLIC SDL2::SDL2main)
    endif()
elseif(SDL2_FOUND)
    target_compile_definitions(luma_runtime PUBLIC LUMA_HAVE_SDL2=1)
    target_include_directories(luma_runtime PUBLIC ${SDL2_INCLUDE_DIRS})
    target_link_libraries(luma_runtime PUBLIC ${SDL2_LIBRARIES})
endif()

add_executable(luma "${CMAKE_CURRENT_SOURCE_DIR}/src/app/main.cpp")
target_link_libraries(luma PRIVATE luma_runtime)

# --- Luma VM Stub: pre-compiled VM for self-extracting executables -----------
# This is the VM that gets bundled into standalone .exe files.
# When `luma build` runs, it appends bytecode to this executable.
add_executable(luma_vm "${CMAKE_CURRENT_SOURCE_DIR}/src/app/vm_stub.cpp")
target_link_libraries(luma_vm PRIVATE luma_runtime)
set_target_properties(luma_vm PROPERTIES OUTPUT_NAME "luma_vm")
# Auto-copy luma_vm.exe to out/ so luma build can find it
add_custom_command(TARGET luma_vm POST_BUILD
    COMMAND ${CMAKE_COMMAND} -E copy_if_different
        $<TARGET_FILE:luma_vm> "${CMAKE_CURRENT_SOURCE_DIR}/out/luma_vm.exe"
    COMMENT "Copying luma_vm.exe to out/"
)

# --- Luma Editor: a small GUI code editor dedicated to Luma (Windows) -----
if(WIN32)
    add_executable(luma_edit WIN32 "${CMAKE_CURRENT_SOURCE_DIR}/src/app/editor_main.cpp")
    set_target_properties(luma_edit PROPERTIES OUTPUT_NAME "luma-edit")
    target_compile_definitions(luma_edit PRIVATE UNICODE _UNICODE)
    target_link_libraries(luma_edit PRIVATE comctl32 comdlg32 gdi32 shell32 user32)
endif()

if(MSVC)
    target_compile_options(luma_runtime PRIVATE /W4 /permissive-)
else()
    target_compile_options(luma_runtime PRIVATE -Wall -Wextra -Wpedantic -Wconversion -Wshadow)
endif()

include(CTest)
if(BUILD_TESTING)
    file(GLOB_RECURSE LUMA_TEST_SOURCES "${CMAKE_CURRENT_SOURCE_DIR}/tests/*.cpp")
    add_executable(luma_tests ${LUMA_TEST_SOURCES})
    target_link_libraries(luma_tests PRIVATE luma_runtime)
    add_test(NAME luma_tests COMMAND luma_tests)
endif()

# ── Convenience custom targets ────────────────────────────────────────────────
# These let you run common tasks without remembering the full cmake syntax:
#   cmake --build build --target run FILE=examples/welcome.luma
#   cmake --build build --target compile FILE=examples/welcome.luma
#   cmake --build build --target compile-run FILE=examples/welcome.luma

if(NOT DEFINED CMAKE_RUNTIME_OUTPUT_DIRECTORY)
    set(_LUMA_OUT_DIR "${CMAKE_CURRENT_SOURCE_DIR}/out")
else()
    set(_LUMA_OUT_DIR "${CMAKE_RUNTIME_OUTPUT_DIRECTORY}")
endif()

# Run a .luma file: cmake --build build --target run FILE=examples/welcome.luma
add_custom_target(run
    COMMAND "${_LUMA_OUT_DIR}/luma.exe" run "$<IF:$<BOOL:${FILE}>,${FILE},examples/welcome.luma>"
    WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}"
    DEPENDS luma
    COMMENT "Running Luma program..."
)

# Compile to native .exe: cmake --build build --target compile FILE=examples/welcome.luma
add_custom_target(compile
    COMMAND "${_LUMA_OUT_DIR}/luma.exe" build "$<IF:$<BOOL:${FILE}>,${FILE},examples/welcome.luma>"
    WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}"
    DEPENDS luma luma_vm
    COMMENT "Compiling Luma program to standalone executable..."
)

# Compile then run: cmake --build build --target compile-run FILE=examples/welcome.luma
add_custom_target(compile-run
    COMMAND "${CMAKE_COMMAND}" -E echo "=== Compiling ==="
    COMMAND "${_LUMA_OUT_DIR}/luma.exe" build "$<IF:$<BOOL:${FILE}>,${FILE},examples/welcome.luma>"
    WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}"
    DEPENDS luma luma_vm
    COMMENT "Compiling and running Luma program..."
)