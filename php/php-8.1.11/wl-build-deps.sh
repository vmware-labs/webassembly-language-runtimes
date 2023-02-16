#!/bin/bash

if [[ ! -v WASMLABS_ENV ]]
then
    echo "Wasmlabs environment is not set"
    exit 1
fi

if [ "${BASH_SOURCE-}" = "$0" ]; then
    echo "You must source this script to add to CFLAGS and LDFLAGS: \$ source $0" >&2
    return
fi

logStatus "Building dependencies... "

### sqlite3
export PKG_CONFIG_PATH=${WASMLABS_OUTPUT_BASE}"/sqlite/version-3.39.2/lib/pkgconfig:"${PKG_CONFIG_PATH}

if [[ ! -e ${WASMLABS_OUTPUT_BASE}"/sqlite/version-3.39.2/lib/libsqlite3.a" ]]; then
    logStatus "Building SQLite dependency..."
    $WASMLABS_MAKE ${WASMLABS_REPO_ROOT}"/libs/sqlite/version-3.39.2" || exit 1
else
    logStatus "Skipping building SQLite dependency!"
fi
