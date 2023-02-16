#!/usr/bin/env bash

if [[ ! -v WASMLABS_ENV ]]
then
    echo "Wasmlabs environment is not set"
    exit 1
fi

# export CFLAGS_CONFIG="-O3 -g"
export CFLAGS_CONFIG="-O0"

export CFLAGS_WASI="--sysroot=${WASI_SYSROOT}"
export LDFLAGS_WASI="--sysroot=${WASI_SYSROOT}"

export CFLAGS_ONIGURUMA=''

logStatus "Using ONIGURUMA DEFINES: ${CFLAGS_ONIGURUMA}"

export CFLAGS_BUILD=''

# We need to add LDFLAGS ot CFLAGS because autoconf compiles(+links) to binary when checking stuff
export CFLAGS="${CFLAGS_CONFIG} ${CFLAGS_WASI} ${CFLAGS_ONIGURUMA} ${CFLAGS_BUILD} ${LDFLAGS_WASI}"
export LDFLAGS="${LDFLAGS_WASI}"

cd "${WASMLABS_SOURCE_PATH}"

if [[ -z "$WASMLABS_SKIP_CONFIGURE" ]]; then
    ./autogen.sh
    export ONIGURUMA_CONFIGURE="--prefix="${WASMLABS_OUTPUT}" --enable-static --disable-shared"
    logStatus "Configuring build with '${ONIGURUMA_CONFIGURE}'... "
    ./configure --config-cache --host=wasm32-wasi host_alias=wasm32-musl-wasi --target=wasm32-wasi target_alias=wasm32-musl-wasi ${ONIGURUMA_CONFIGURE} || exit 1
else
    logStatus "Skipping configure..."
fi

logStatus "Building..."
make -j || exit 1

logStatus "Preparing artifacts..."
make install || exit 1

logStatus "DONE. Artifacts in ${WASMLABS_OUTPUT}"
