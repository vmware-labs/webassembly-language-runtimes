#!/usr/bin/env bash

if [ "${BASH_SOURCE-}" = "$0" ]; then
    echo "You must source this script: \$ source $0" >&2
    return
fi

if [[ ! -v WASMLABS_ENV ]]; then
    echo "Wasmlabs environment is not set"
    exit 1
fi

logStatus "Building dependencies... "

export PKG_CONFIG_PATH="${WASMLABS_DEPS_ROOT}/build-output/lib/wasm32-wasi/pkgconfig:"${PKG_CONFIG_PATH}

function wl_dependencies_add {
    _NAME=$1
    _BUILD_COMMAND=$2
    _TARGET=$3

    if [[ ! -e "${WASMLABS_DEPS_ROOT}/build-output/${_TARGET}" ]]; then
        logStatus "Building ${_NAME} dependency..."
        WASMLABS_DEPS_ROOT=${WASMLABS_DEPS_ROOT} WASMLABS_BUILD_TYPE=dependency $WASMLABS_MAKE "${WASMLABS_REPO_ROOT}/${_BUILD_COMMAND}" || exit 1
    else
        logStatus "Skipping building ${_NAME} dependency!"
    fi
}
