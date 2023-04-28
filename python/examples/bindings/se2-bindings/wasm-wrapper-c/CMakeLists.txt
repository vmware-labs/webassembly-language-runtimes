cmake_minimum_required(VERSION 3.16)

project(wasm-wrapper-c)

if(${CMAKE_SYSTEM_NAME} STREQUAL "WASI")
    set(CMAKE_EXECUTABLE_SUFFIX ".wasm")
endif()

add_executable(
    wasm-wrapper-c
    main.c
    sdk_module.c
    pyhost.c
    utils.c
    wasm_shim.c
)

find_package(PkgConfig REQUIRED)

pkg_search_module(LIBPYTHON REQUIRED IMPORTED_TARGET "libpython3.11>=3.11.0")

include_directories(AFTER
    ${LIBPYTHON_INCLUDE_DIRS}
)

target_link_libraries(wasm-wrapper-c PUBLIC
        PkgConfig::LIBPYTHON
)
