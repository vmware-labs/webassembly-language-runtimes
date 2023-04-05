#!/usr/bin/env bash

if [ "${BASH_SOURCE-}" = "$0" ]; then
    echo "You must source this script to add to CFLAGS and LDFLAGS: \$ source $0" >&2
    return
fi

source ${WLR_REPO_ROOT}/scripts/build-helpers/wlr_dependencies.sh

wlr_dependencies_add "SQLite" "libs/sqlite/version-3.41.2" "lib/wasm32-wasi/libsqlite3.a" \
    "https://github.com/vmware-labs/webassembly-language-runtimes/releases/download/libs%2Fsqlite%2F3.41.2%2B20230329-43f9aea/libsqlite-3.41.2-wasi-sdk-19.0.tar.gz"
