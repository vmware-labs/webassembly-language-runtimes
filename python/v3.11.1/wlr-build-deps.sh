#!/usr/bin/env bash

if [ "${BASH_SOURCE-}" = "$0" ]; then
    echo "You must source this script to add to CFLAGS and LDFLAGS: \$ source $0" >&2
    return
fi

source ${WLR_REPO_ROOT}/scripts/build-helpers/wlr_dependencies.sh

wlr_dependencies_add "uuid" "libs/uuid/libuuid-1.0.3" "lib/wasm32-wasi/libuuid.a" \
    "https://github.com/vmware-labs/webassembly-language-runtimes/releases/download/libs%2Flibuuid%2F1.0.3%2B20230310-c46e363/libuuid-1.0.3-wasi-sdk-19.0.tar.gz"

wlr_dependencies_add "zlib" "libs/zlib/v1.2.13" "lib/wasm32-wasi/libz.a" \
    "https://github.com/vmware-labs/webassembly-language-runtimes/releases/download/libs%2Fzlib%2F1.2.13%2B20230310-c46e363/libz-1.2.13-wasi-sdk-19.0.tar.gz"

wlr_dependencies_add "SQLite" "libs/sqlite/version-3.39.2" "lib/wasm32-wasi/libsqlite3.a" \
    "https://github.com/vmware-labs/webassembly-language-runtimes/releases/download/libs%2Fsqlite%2F3.39.2%2B20230310-c46e363/libsqlite-3.39.2-wasi-sdk-19.0.tar.gz"
