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
# $WASMLABS_MAKE ${WASMLABS_REPO_ROOT}/libs/sqlite/version-3.39.2 || exit 1

export CFLAGS_DEPENDENCIES="-I${WASMLABS_OUTPUT_BASE}/sqlite/version-3.39.2/include ${CFLAGS_DEPENDENCIES}"
export LDFLAGS_DEPENDENCIES="-L${WASMLABS_OUTPUT_BASE}/sqlite/version-3.39.2/lib ${LDFLAGS_DEPENDENCIES}"
