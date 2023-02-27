#!/bin/bash

logStatus "Building dependencies for libpng 1.6.39..."

if [[ ! -v WASMLABS_ENV ]]
then
    echo "Wasmlabs environment is not set"
    exit 1
fi

if [ "${BASH_SOURCE-}" = "$0" ]; then
    echo "You must source this script to add to CFLAGS and LDFLAGS: \$ source $0" >&2
    return
fi


### zlib
export PKG_CONFIG_PATH="${WASMLABS_OUTPUT_BASE}/zlib/v1.2.13/lib/wasm32-wasi/pkgconfig:"${PKG_CONFIG_PATH}

if [[ ! -e "${WASMLABS_OUTPUT_BASE}/zlib/v1.2.13/lib/wasm32-wasi/libz.a" ]]; then
    logStatus "Building zlib dependency..."
    WASMLABS_BUILD_TYPE=dependency $WASMLABS_MAKE "${WASMLABS_REPO_ROOT}/libs/zlib/v1.2.13" || exit 1
else
    logStatus "Skipping building zlib dependency!"
fi
