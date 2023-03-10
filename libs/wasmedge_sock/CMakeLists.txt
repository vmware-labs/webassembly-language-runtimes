cmake_minimum_required(VERSION 3.16)

project(wasmedge_sock)

add_library(
    wasmedge_sock
    STATIC
    netdb.c
    wasi_socket_ext.c
)

target_include_directories(
    wasmedge_sock
    PUBLIC
    ${CMAKE_CURRENT_SOURCE_DIR}/include
)
