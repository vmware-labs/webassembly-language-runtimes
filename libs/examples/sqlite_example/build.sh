#!/usr/bin/env bash

export TARGET_NAME=sqlite_example

function run_build {
    echo Building  ${TARGET_DIR} ...

    if [[ -v CMAKE_EXTRA_ARGS ]]
    then
        echo "Preparing '${TARGET_DIR}' with additional CMake args: '${CMAKE_EXTRA_ARGS}'"
    fi

    mkdir -p ${TARGET_DIR} 2>/dev/null
    rm ${TARGET_DIR}/CMakeCache.txt 2>/dev/null
    cmake -B${TARGET_DIR} ${CMAKE_EXTRA_ARGS} . || exit 1
    cmake --build ${TARGET_DIR} || exit 1
}

function run_tests {
    echo Testing ${TARGET_DIR} ...

    export TEST_DIR=${TARGET_DIR}/test

    mkdir -p ${TEST_DIR}

    $PRG ${TEST_DIR}/test.db
}

# Traditional flow
if [[ "$1" == "--local" ]]
then
    export TARGET_DIR=target/local
    run_build

    export PRG=$TARGET_DIR/$TARGET_NAME
    run_tests

    exit 0
fi

# wasm32-wasi
if [[ ! -v WASI_SDK_PATH ]]
then
    echo "WASI_SDK_PATH is required"
    exit 1
fi

function get_wasm_dependency {
    local DEP_FILE=$1
    local DEP_URL=$2
    mkdir -p ${TARGET_DIR}/deps 2>/dev/null

    if [[ -f ${TARGET_DIR}/deps/lib/wasm32-wasi/$DEP_FILE ]]
    then
        echo "Nothing to download. Dependency exists at '${TARGET_DIR}/deps/$DEP_FILE'"
        return
    fi

    echo "Getting ${TARGET_DIR}/deps/lib/wasm32-wasi/$DEP_FILE from $DEP_URL..."

    curl -sL "${DEP_URL}" | tar xzv -C "${TARGET_DIR}/deps"
}

export TARGET_DIR=target/wasm32-wasi

get_wasm_dependency libsqlite3.a https://github.com/vmware-labs/webassembly-language-runtimes/releases/download/libs%2Fsqlite%2F3.41.2%2B20230329-43f9aea/libsqlite-3.41.2-wasi-sdk-19.0.tar.gz

export FULL_TARGET_DIR=$(realpath ${TARGET_DIR})

export PKG_CONFIG_ALLOW_SYSTEM_CFLAGS=1
export PKG_CONFIG_ALLOW_SYSTEM_LIBS=1
export PKG_CONFIG_PATH=""
export PKG_CONFIG_SYSROOT_DIR=${FULL_TARGET_DIR}/deps
export PKG_CONFIG_LIBDIR=${FULL_TARGET_DIR}/deps/lib/wasm32-wasi/pkgconfig
export CMAKE_EXTRA_ARGS="-DWASI_SDK_PREFIX=${WASI_SDK_PATH} -DCMAKE_TOOLCHAIN_FILE=${WASI_SDK_PATH}/share/cmake/wasi-sdk.cmake"

run_build

export PRG="wasmtime run --mapdir /::. $TARGET_DIR/$TARGET_NAME.wasm --"
run_tests

# PKG_CONFIG_ALLOW_SYSTEM_CFLAGS=1 PKG_CONFIG_ALLOW_SYSTEM_LIBS=1 PKG_CONFIG_PATH="" PKG_CONFIG_SYSROOT_DIR=${PWD}/target/wasm32-wasi/deps