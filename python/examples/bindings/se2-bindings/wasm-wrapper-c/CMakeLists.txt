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

target_link_libraries(wasm-wrapper-c
    $ENV{LINK_FLAGS}
)

target_include_directories(wasm-wrapper-c PUBLIC
    $ENV{INCLUDE_DIRS}
)

