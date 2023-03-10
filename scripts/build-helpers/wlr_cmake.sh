#!/usr/bin/env bash

if [ "${BASH_SOURCE-}" = "$0" ]; then
    echo "You must source this script: \$ source $0" >&2
    return 1
fi

if [[ -v WLR_CMAKE_TARGET_DIR ]]; then
    echo "WLR_CMAKE_TARGET_DIR is already defined as '${WLR_CMAKE_TARGET_DIR}'"
    return 1
fi

export WLR_CMAKE_TARGET_DIR=${WLR_STAGING}/target

function wlr_cmake_configure {
    local CMAKE_WASI_ARGS="-DWASI_SDK_PREFIX=${WASI_SDK_PATH} -DCMAKE_TOOLCHAIN_FILE=${WASI_SDK_PATH}/share/cmake/wasi-sdk.cmake"
    local CMAKE_WLR_ARGS="-DCMAKE_INSTALL_PREFIX=${WLR_OUTPUT} -DCMAKE_INSTALL_LIBDIR=${WLR_OUTPUT}/lib/wasm32-wasi"
    if [[ ! -d $WLR_CMAKE_TARGET_DIR ]]; then
        mkdir -p $WLR_CMAKE_TARGET_DIR
    fi
    cmake -B${WLR_CMAKE_TARGET_DIR} ${CMAKE_WASI_ARGS} ${CMAKE_WLR_ARGS} $@ .
}

function wlr_cmake_build {
    cmake --build ${WLR_CMAKE_TARGET_DIR} $@
}

function wlr_cmake_install {
    cmake --install ${WLR_CMAKE_TARGET_DIR} ${CMAKE_WLR_ARGS} $@
}
