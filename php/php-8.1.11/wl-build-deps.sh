#!/bin/bash

if [ "${BASH_SOURCE-}" = "$0" ]; then
    echo "You must source this script to add to CFLAGS and LDFLAGS: \$ source $0" >&2
    return
fi

source ${WASMLABS_REPO_ROOT}/scripts/build-helpers/wl_dependencies.sh

wl_dependencies_add "SQLite" "libs/sqlite/version-3.39.2" "lib/wasm32-wasi/libsqlite3.a"
