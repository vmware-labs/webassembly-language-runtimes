#!/usr/bin/env bash

if [[ ! -v WASMLABS_ENV ]]
then
    echo "Wasmlabs environment is not set"
    exit 1
fi

# export CFLAGS_CONFIG="-O3 -g"
export CFLAGS_CONFIG="-O0"

export CFLAGS_WASI="--sysroot=${WASI_SYSROOT} -I./wasmlabs-stubs -D_WASI_EMULATED_MMAN -D_WASI_EMULATED_GETPID -D_WASI_EMULATED_SIGNAL -D_WASI_EMULATED_PROCESS_CLOCKS"
export LDFLAGS_WASI="--sysroot=${WASI_SYSROOT} -lwasi-emulated-mman -lwasi-emulated-getpid -lwasi-emulated-signal -lwasi-emulated-process-clocks"

export CFLAGS_LIBXML2=''

logStatus "Using LIBXML2 DEFINES: ${CFLAGS_LIBXML2}"

export CFLAGS_BUILD='-D_POSIX_SOURCE=1 -D_GNU_SOURCE=1 -DHAVE_FORK=0 -DWASM_WASI'

# We need to add LDFLAGS ot CFLAGS because autoconf compiles(+links) to binary when checking stuff
export CFLAGS="${CFLAGS_CONFIG} ${CFLAGS_WASI} ${CFLAGS_LIBXML2} ${CFLAGS_BUILD} ${LDFLAGS_WASI}"
export LDFLAGS="${LDFLAGS_WASI}"

cd "${WASMLABS_SOURCE_PATH}"

if [[ -z "$WASMLABS_SKIP_CONFIGURE" ]]; then
    ./autogen.sh
    export LIBXML2_CONFIGURE='--enable-static --disable-shared --with-minimum=yes'
    logStatus "Configuring build with '${LIBXML2_CONFIGURE}'... "
    ./configure --host=wasm32-wasi host_alias=wasm32-musl-wasi --target=wasm32-wasi target_alias=wasm32-musl-wasi ${LIBXML2_CONFIGURE} || exit 1
else
    logStatus "Skipping configure..."
fi

logStatus "Building... "
make || exit 1

logStatus "Preparing artifacts... "
cp libxml.h ${WASMLABS_OUTPUT}/include/ || exit 1
cp .libs/libxml2.a ${WASMLABS_OUTPUT}/lib/ || exit 1

logStatus "DONE. Artifacts in ${WASMLABS_OUTPUT}"
