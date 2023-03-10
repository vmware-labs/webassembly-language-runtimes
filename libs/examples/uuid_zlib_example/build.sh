#!/usr/bin/env bash

export TARGET_NAME=uuid_zlib_example

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

    # Test genuuid
    # - check that genuuid returns more than 32 symbols
    [ $($PRG genuuid | wc -c) -ge 32 ] && echo genuuid OK. || echo genuuid FAIL.

    # Test compress-decompress
    # - list current folder into original.txt
    # - compress original.txt into compressed.dat
    # - decompress compressed.dat into decompressed.txt
    # - check that size(original.txt) > size(compressed.dat)
    # - check that original.txt == decompressed.txt
    ls -lh > $TEST_DIR/original.txt &&
        $PRG compress $TEST_DIR/original.txt $TEST_DIR/compressed.dat &&
        $PRG decompress $TEST_DIR/compressed.dat $TEST_DIR/decompressed.txt &&
        [ $(cat $TEST_DIR/original.txt | wc -l) -gt $(cat $TEST_DIR/compressed.dat | wc -l) ] &&
        diff $TEST_DIR/original.txt $TEST_DIR/decompressed.txt &&
        echo compress/decompress OK. ||
        echo compress/decompress FAIL.
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

get_wasm_dependency libz.a https://github.com/vmware-labs/webassembly-language-runtimes/releases/download/libs%2Fzlib%2F1.2.13%2B20230310-c46e363/libz-1.2.13-wasi-sdk-19.0.tar.gz
get_wasm_dependency libuuid.a https://github.com/vmware-labs/webassembly-language-runtimes/releases/download/libs%2Flibuuid%2F1.0.3%2B20230310-c46e363/libuuid-1.0.3-wasi-sdk-19.0.tar.gz

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