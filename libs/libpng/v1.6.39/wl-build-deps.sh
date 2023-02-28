#!/bin/bash

logStatus "Building dependencies for libpng 1.6.39..."

if [ "${BASH_SOURCE-}" = "$0" ]; then
    echo "You must source this script to add to CFLAGS and LDFLAGS: \$ source $0" >&2
    return
fi

source ${WASMLABS_REPO_ROOT}/scripts/build-helpers/wl_dependencies.sh

wl_dependencies_add "zlib" "libs/zlib/v1.2.13" "lib/wasm32-wasi/libz.a"
