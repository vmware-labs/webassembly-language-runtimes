#!/usr/bin/env bash

if [ "${BASH_SOURCE-}" = "$0" ]; then
    echo "You must source this script: \$ source $0" >&2
    return
fi

if [[ ! -v WLR_ENV ]]; then
    echo "WLR build environment is not set"
    exit 1
fi

function wlr_package_lib {
    local _PACKAGE=${WLR_OUTPUT_BASE}/lib${WLR_PACKAGE_NAME}-${WLR_PACKAGE_VERSION}-${WASI_SDK_ASSET_NAME}.tar
    logStatus "Packaging... ${_PACKAGE}"
    tar -cvf ${_PACKAGE} \
        -C ${WLR_OUTPUT}/ \
        --exclude=*.la \
        --exclude=lib/wasm32-wasi/cmake \
        include \
        lib
    gzip -f ${_PACKAGE}
}

function wlr_package_bin {
    local _PACKAGE=${WLR_OUTPUT_BASE}/${WLR_PACKAGE_NAME}-bin-${WLR_PACKAGE_VERSION}-${WASI_SDK_ASSET_NAME}.tar
    logStatus "Packaging... ${_PACKAGE}"
    tar -cvf ${_PACKAGE} \
        -C ${WLR_OUTPUT}/ \
        bin
    gzip -f ${_PACKAGE}
}
