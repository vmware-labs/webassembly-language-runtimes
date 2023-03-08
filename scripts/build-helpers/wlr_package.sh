#!/usr/bin/env bash

if [ "${BASH_SOURCE-}" = "$0" ]; then
    echo "You must source this script: \$ source $0" >&2
    return
fi

if [[ ! -v WASMLABS_ENV ]]; then
    echo "Wasmlabs environment is not set"
    exit 1
fi

function wlr_package_lib {
    local _PACKAGE=${WASMLABS_OUTPUT_BASE}/${WASMLABS_PACKAGE_NAME}-${WASMLABS_PACKAGE_VERSION}-${WASI_SDK_ASSET_NAME}.tar
    logStatus "Packaging... ${_PACKAGE}"
    tar -cvf ${_PACKAGE} \
        -C ${WASMLABS_OUTPUT}/ \
        --exclude=*.la \
        --exclude=lib/wasm32-wasi/cmake \
        include \
        lib
    gzip -f ${_PACKAGE}
}

function wlr_package_bin {
    local _PACKAGE=${WASMLABS_OUTPUT_BASE}/${WASMLABS_PACKAGE_NAME}-bin-${WASMLABS_PACKAGE_VERSION}-${WASI_SDK_ASSET_NAME}.tar
    logStatus "Packaging... ${_PACKAGE}"
    tar -cvf ${_PACKAGE} \
        -C ${WASMLABS_OUTPUT}/ \
        --exclude=*.la \
        --exclude=lib/wasm32-wasi/cmake \
        bin
    gzip -f ${_PACKAGE}
}
