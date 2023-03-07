#!/usr/bin/env bash

if [ "${BASH_SOURCE-}" = "$0" ]; then
    echo "You must source this script to add to CFLAGS and LDFLAGS: \$ source $0" >&2
    return
fi

source ${WASMLABS_REPO_ROOT}/scripts/build-helpers/wlr_dependencies.sh

wlr_dependencies_add "uuid" "libs/uuid/libuuid-1.0.3" "lib/wasm32-wasi/libuuid.a" \
    "https://github.com/assambar/webassembly-language-runtimes/releases/download/libs%2Fuuid%2F1.0.3%2B20230306-764c74d/libuuid-1.0.3-wasi-sdk-19.0.tar.gz"

wlr_dependencies_add "zlib" "libs/zlib/v1.2.13" "lib/wasm32-wasi/libz.a" \
    "https://github.com/assambar/webassembly-language-runtimes/releases/download/libs%2Fzlib%2F1.2.13%2B20230306-764c74d/libz-1.2.13-wasi-sdk-19.0.tar.gz"

wlr_dependencies_add "SQLite" "libs/sqlite/version-3.39.2" "lib/wasm32-wasi/libsqlite3.a" \
    "https://github.com/assambar/webassembly-language-runtimes/releases/download/libs%2Fsqlite%2F3.39.2%2B20230306-764c74d/libsqlite-3.39.2-wasi-sdk-19.0.tar.gz"
