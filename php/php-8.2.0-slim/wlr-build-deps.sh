#!/usr/bin/env bash

logStatus "Building dependencies..."

if [[ ! -v WLR_ENV ]]
then
    echo "WLR build environment is not set"
    exit 1
fi

if [ "${BASH_SOURCE-}" = "$0" ]; then
    echo "You must source this script to add to CFLAGS and LDFLAGS: \$ source $0" >&2
    return
fi

source ${WLR_REPO_ROOT}/scripts/build-helpers/wlr_dependencies.sh

wlr_dependencies_add "SQLite" "libs/sqlite/v3.41.2" "lib/wasm32-wasi/libsqlite3.a"

logStatus "Completed building dependencies for PHP 8.2.0-slim!"
logStatus " -> Exported PKG_CONFIG_PATH=${PKG_CONFIG_PATH}"
