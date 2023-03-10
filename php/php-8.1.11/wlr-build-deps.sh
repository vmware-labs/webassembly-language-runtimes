#!/usr/bin/env bash

if [ "${BASH_SOURCE-}" = "$0" ]; then
    echo "You must source this script to add to CFLAGS and LDFLAGS: \$ source $0" >&2
    return
fi

source ${WLR_REPO_ROOT}/scripts/build-helpers/wlr_dependencies.sh

wlr_dependencies_add "SQLite" "libs/sqlite/version-3.39.2" "lib/wasm32-wasi/libsqlite3.a" \
    "https://github.com/assambar/webassembly-language-runtimes/releases/download/libs%2Fsqlite%2F3.39.2%2B20230306-764c74d/libsqlite-3.39.2-wasi-sdk-19.0.tar.gz"
