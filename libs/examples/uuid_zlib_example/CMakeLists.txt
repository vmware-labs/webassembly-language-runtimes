cmake_minimum_required(VERSION 3.16)

project(uuid_zlib_example)

if(${CMAKE_SYSTEM_NAME} STREQUAL "WASI")
    set(CMAKE_EXECUTABLE_SUFFIX ".wasm")
endif()

add_executable(
    uuid_zlib_example
    main.c
)

find_package(PkgConfig REQUIRED)

pkg_search_module(UUID REQUIRED IMPORTED_TARGET "uuid>=1.0.0")
pkg_search_module(ZLIB REQUIRED IMPORTED_TARGET "zlib>=1.1.0")

include_directories(AFTER
    ${UUID_INCLUDE_DIRS}
    ${ZLIB_INCLUDE_DIRS}
)

target_link_libraries(uuid_zlib_example PUBLIC
        PkgConfig::UUID
        PkgConfig::ZLIB
)
