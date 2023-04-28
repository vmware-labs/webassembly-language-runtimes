#!/usr/bin/env bash

if [[ ! -v WASI_SDK_PATH ]]; then
    echo "WASI_SDK_PATH is required. Download wasi-sdk and set the variable"
    exit 1
fi

export TARGET_DIR=target/wasm32-wasi
if [[ "$1" == "--clean" ]]; then
    rm -rf ${TARGET_DIR}
fi

mkdir -p ${TARGET_DIR}/deps 2>/dev/null
if [ -f ${TARGET_DIR}/deps/include/python3.11/Python.h -a -f ${TARGET_DIR}/deps/lib/wasm32-wasi/libpython3.11.a ]; then
    echo "Dependencies already downloaded. Reusing..."
else
    curl -sL https://github.com/vmware-labs/webassembly-language-runtimes/releases/download/python%2F3.11.3%2B20230428-7d1b259/libpython-3.11.3-wasi-sdk-19.0.tar.gz | tar xzv -C ${TARGET_DIR}/deps
fi

export FULL_TARGET_DIR=$(realpath ${TARGET_DIR})

export PKG_CONFIG_ALLOW_SYSTEM_CFLAGS=1
export PKG_CONFIG_ALLOW_SYSTEM_LIBS=1
export PKG_CONFIG_PATH=""
export PKG_CONFIG_SYSROOT_DIR=${FULL_TARGET_DIR}/deps
export PKG_CONFIG_LIBDIR=${FULL_TARGET_DIR}/deps/lib/wasm32-wasi/pkgconfig

export CMAKE_EXTRA_ARGS="-DWASI_SDK_PREFIX=${WASI_SDK_PATH} -DCMAKE_TOOLCHAIN_FILE=${WASI_SDK_PATH}/share/cmake/wasi-sdk.cmake"

cmake -B${TARGET_DIR} ${CMAKE_EXTRA_ARGS} . || exit 1
cmake --build ${TARGET_DIR} --verbose || exit 1

echo "Module built in $(realpath ${TARGET_DIR}/wasm-wrapper-c.wasm)"
