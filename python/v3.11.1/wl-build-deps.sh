#!/usr/bin/env bash

if [[ ! -v WASMLABS_ENV ]]
then
    echo "Wasmlabs environment is not set"
    exit 1
fi

if [ "${BASH_SOURCE-}" = "$0" ]; then
    echo "You must source this script to add to CFLAGS and LDFLAGS: \$ source $0" >&2
    return
fi

source ${WASMLABS_REPO_ROOT}/scripts/build-helpers/wl_dependencies.sh

wl_dependencies_add "uuid" "libs/uuid/libuuid-1.0.3" "lib/wasm32-wasi/libuuid.a"
wl_dependencies_add "zlib" "libs/zlib/v1.2.13" "lib/wasm32-wasi/libz.a"
wl_dependencies_add "SQLite" "libs/sqlite/version-3.39.2" "lib/wasm32-wasi/libsqlite3.a"
