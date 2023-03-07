#!/usr/bin/env bash

if [[ ! -v WASMLABS_ENV ]]
then
    echo "Wasmlabs environment is not set"
    exit 1
fi

export CFLAGS_CONFIG="-O0"

logStatus "Configuring CMake for '${WASMLABS_SOURCE_PATH}' at '${WASMLABS_STAGING}'..."

cmake -B${WASMLABS_STAGING} \
    -DWASI_SDK_PREFIX=${WASI_SDK_PATH} \
    -DCMAKE_TOOLCHAIN_FILE=${WASI_SDK_PATH}/share/cmake/wasi-sdk.cmake \
    ${WASMLABS_SOURCE_PATH}

logStatus "Building CMake at '${WASMLABS_STAGING}'..."

cmake --build ${WASMLABS_STAGING}

logStatus "Preparing artifacts... "
cp ${WASMLABS_SOURCE_PATH}/include/* ${WASMLABS_OUTPUT}/include/ || exit 1
cp ${WASMLABS_STAGING}/libwasmedge_sock.a ${WASMLABS_OUTPUT}/lib/ || exit 1

logStatus "DONE. Artifacts in ${WASMLABS_OUTPUT}"
