#!/usr/bin/env bash
logStatus "Building libs 'icu/release-72-1'"

if [[ ! -v WASMLABS_ENV ]]
then
    echo "Wasmlabs environment is not set"
    exit 1
fi

# export CFLAGS_CONFIG="-O3 -g"
export CFLAGS_CONFIG="-O0"

export CFLAGS_WASI="--sysroot=${WASI_SYSROOT}"
export LDFLAGS_WASI="--sysroot=${WASI_SYSROOT}"

export CFLAGS_ICU=''

logStatus "Using ICU DEFINES: ${CFLAGS_ICU}"

export CFLAGS_BUILD=''

# We need to add LDFLAGS ot CFLAGS because autoconf compiles(+links) to binary when checking stuff
export CFLAGS="${CFLAGS_CONFIG} ${CFLAGS_WASI} ${CFLAGS_ICU} ${CFLAGS_BUILD} ${LDFLAGS_WASI}"
export LDFLAGS="${LDFLAGS_WASI}"

cd "${WASMLABS_SOURCE_PATH}"/icu4c/source

if [[ -z "$WASMLABS_SKIP_CONFIGURE" ]]; then
    export ICU_CONFIGURE='--enable-static --disable-shared'
    logStatus "Configuring build with '${ICU_CONFIGURE}'... "
    # ICU headers are enough for some builds (e.g.: PHP).
    # Uncomment for executing ./configure and generte the Makefile
    # ./runConfigureICU Linux --host=wasm32-wasi host_alias=wasm32-musl-wasi --target=wasm32-wasi target_alias=wasm32-musl-wasi ${ICU_CONFIGURE} || exit 1
else
    logStatus "Skipping configure..."
fi

# ICU headers are enough for some builds (e.g.: PHP).
# Uncomment for executing make and get the static libraries (lib/libicuXXXX.a)
# logStatus "Building... "
# make -j || exit 1

logStatus "Preparing artifacts... "
mkdir -p ${WASMLABS_OUTPUT}/include/unicode
cp -v common/unicode/*.h ${WASMLABS_OUTPUT}/include/unicode || exit 1

logStatus "DONE. Artifacts in ${WASMLABS_OUTPUT}"
