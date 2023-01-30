#!/bin/bash

logStatus "Building dependencies..."

if [[ ! -v WASMLABS_ENV ]]
then
    echo "Wasmlabs environment is not set"
    exit 1
fi

if [ "${BASH_SOURCE-}" = "$0" ]; then
    echo "You must source this script to add to CFLAGS and LDFLAGS: \$ source $0" >&2
    return
fi

### icu
$WASMLABS_MAKE ${WASMLABS_REPO_ROOT}/libs/icu/release-72-1 || exit 1
export CFLAGS_DEPENDENCIES="-I${WASMLABS_OUTPUT_BASE}/icu/release-72-1/include ${CFLAGS_DEPENDENCIES}"
export LDFLAGS_DEPENDENCIES="-L${WASMLABS_OUTPUT_BASE}/icu/release-72-1/lib ${LDFLAGS_DEPENDENCIES}"

### libxml2
$WASMLABS_MAKE ${WASMLABS_REPO_ROOT}/libs/libxml2/v2.10.3 || exit 1
export CFLAGS_DEPENDENCIES="-I${WASMLABS_OUTPUT_BASE}/libxml2/v2.10.3/include ${CFLAGS_DEPENDENCIES}"
export LDFLAGS_DEPENDENCIES="-L${WASMLABS_OUTPUT_BASE}/libxml2/v2.10.3/lib ${LDFLAGS_DEPENDENCIES}"

### sqlite3
$WASMLABS_MAKE ${WASMLABS_REPO_ROOT}/libs/sqlite/version-3.39.2 || exit 1
export CFLAGS_DEPENDENCIES="-I${WASMLABS_OUTPUT_BASE}/sqlite/version-3.39.2/include ${CFLAGS_DEPENDENCIES}"
export LDFLAGS_DEPENDENCIES="-L${WASMLABS_OUTPUT_BASE}/sqlite/version-3.39.2/lib ${LDFLAGS_DEPENDENCIES}"
