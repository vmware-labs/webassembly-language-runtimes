#!/usr/bin/env bash

export TARGET_NAME=zlib_cmake

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
    [ $($PRG genuuid | wc -c) -ge 32 ] && echo genuuid OK. || echo genuuid FAIL.

    # Test compress-decompress
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

function get_dependency {
    DEP_FILE=$1
    DEP_URL=$2
    test -f ${DEP_FILE} || wget -T 5 ${DEP_URL} || exit 1
    unzip -u ${DEP_FILE} || exit 1
}

export TARGET_DIR=target/wasm32-wasi

mkdir -p ${TARGET_DIR}/deps
pushd ${TARGET_DIR}/deps
get_dependency zlib-1.2.13.zip https://github.com/assambar/webassembly-language-runtimes/releases/download/libs%2Fzlib%2F1.2.13%2B20230203-3b1b27c/zlib-1.2.13.zip
get_dependency libuuid-1.0.3.zip https://github.com/assambar/webassembly-language-runtimes/releases/download/libs%2Fuuid%2F1.0.3%2B20230203-236edf4/libuuid-1.0.3.zip
popd

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