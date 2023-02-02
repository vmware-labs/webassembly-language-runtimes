#!/usr/bin/env bash

if [[ ! -v WASMLABS_ENV ]]
then
    echo "Wasmlabs environment is not set"
    exit 1
fi

# export CFLAGS_CONFIG="-O3 -g"
export CFLAGS_CONFIG="-O0"

export CFLAGS_WASI="--sysroot=${WASI_SYSROOT}"

export CFLAGS_BUILD='-Werror -Wno-error=format -Wno-error=deprecated-non-prototype -Wno-error=unknown-warning-option'

export CFLAGS="${CFLAGS_CONFIG} ${CFLAGS_WASI} ${CFLAGS_BUILD}"

cd "${WASMLABS_SOURCE_PATH}"

if [[ -z "$WASMLABS_SKIP_CONFIGURE" ]]; then
    export ZLIB_CONFIGURE=''
    logStatus "Configuring build with '${ZLIB_CONFIGURE}'... "
    ./configure ${ZLIB_CONFIGURE} || exit 1
else
    logStatus "Skipping configure..."
fi

logStatus "Building... "
make libz.a || exit 1

logStatus "Preparing artifacts... "
make install \
    prefix=${WASMLABS_OUTPUT} \
    libdir=${WASMLABS_OUTPUT}/lib \
    pkgconfigdir=${WASMLABS_OUTPUT}/lib/pkgconfig

logStatus "DONE. Artifacts in ${WASMLABS_OUTPUT}"
