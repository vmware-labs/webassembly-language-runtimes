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
if [[ ! -e "${WASMLABS_OUTPUT_BASE}/icu/release-72-1/include/unicode/utf.h" ]]; then
    logStatus "Building ICU dependency..."
    $WASMLABS_MAKE ${WASMLABS_REPO_ROOT}/libs/icu/release-72-1 || exit 1
else
    logStatus "Skipping building ICU dependency!"
fi
# export CFLAGS_DEPENDENCIES="-I${WASMLABS_OUTPUT_BASE}/icu/release-72-1/include ${CFLAGS_DEPENDENCIES}"
# export LDFLAGS_DEPENDENCIES="-L${WASMLABS_OUTPUT_BASE}/icu/release-72-1/lib ${LDFLAGS_DEPENDENCIES}"


### libxml2
export PKG_CONFIG_PATH=${WASMLABS_OUTPUT_BASE}/libxml2/v2.10.3/lib/pkgconfig:${PKG_CONFIG_PATH}

if [[ ! -e "${WASMLABS_OUTPUT_BASE}/libxml2/v2.10.3/lib/libxml2.a" ]]; then
    logStatus "Building LibXML dependency..."
    $WASMLABS_MAKE ${WASMLABS_REPO_ROOT}/libs/libxml2/v2.10.3 || exit 1
 else
     logStatus "Skipping building LibXML dependency!"
 fi


### oniguruma
export PKG_CONFIG_PATH=${WASMLABS_OUTPUT_BASE}/oniguruma/v6.9.8/lib/pkgconfig:${PKG_CONFIG_PATH}

if [[ ! -e "${WASMLABS_OUTPUT_BASE}/oniguruma/v6.9.8/lib/libonig.a" ]]; then
    logStatus "Building Oniguruma dependency..."
    $WASMLABS_MAKE ${WASMLABS_REPO_ROOT}/libs/oniguruma/v6.9.8 || exit 1
 else
     logStatus "Skipping building Oniguruma dependency!"
fi


### sqlite3
export PKG_CONFIG_PATH=${WASMLABS_OUTPUT_BASE}/sqlite/version-3.39.2/lib/pkgconfig:${PKG_CONFIG_PATH}

if [[ ! -e ${WASMLABS_OUTPUT_BASE}/sqlite/version-3.39.2/lib/libsqlite3.a ]]; then
    logStatus "Building SQLite dependency..."
    $WASMLABS_MAKE ${WASMLABS_REPO_ROOT}/libs/sqlite/version-3.39.2 || exit 1
else
    logStatus "Skipping building SQLite dependency!"
fi

