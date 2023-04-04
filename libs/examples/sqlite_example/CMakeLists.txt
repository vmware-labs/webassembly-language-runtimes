cmake_minimum_required(VERSION 3.16)

project(sqlite_example)

if(${CMAKE_SYSTEM_NAME} STREQUAL "WASI")
    set(CMAKE_EXECUTABLE_SUFFIX ".wasm")
endif()

add_executable(
    sqlite_example
    main.c
)

find_package(PkgConfig REQUIRED)

pkg_search_module(SQLITE3 REQUIRED IMPORTED_TARGET "sqlite3>=3")

include_directories(AFTER
    ${SQLITE3_INCLUDE_DIRS}
)

target_link_libraries(sqlite_example PUBLIC
        PkgConfig::SQLITE3
)
