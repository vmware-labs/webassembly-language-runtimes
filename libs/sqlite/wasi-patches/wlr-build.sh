#!/usr/bin/env bash

if [[ ! -v WLR_ENV ]]
then
    echo "WLR build environment is not set"
    exit 1
fi

export CFLAGS_CONFIG="-O2"

export CFLAGS_WASI="--sysroot=${WASI_SYSROOT} -I./wlr-stubs -D_WASI_EMULATED_MMAN -D_WASI_EMULATED_GETPID -D_WASI_EMULATED_SIGNAL -D_WASI_EMULATED_PROCESS_CLOCKS"
export LDFLAGS_WASI="--sysroot=${WASI_SYSROOT} -lwasi-emulated-mman -lwasi-emulated-getpid -lwasi-emulated-signal -lwasi-emulated-process-clocks"

export CFLAGS_SQLITE=''

logStatus "Using SQLITE DEFINES: ${CFLAGS_SQLITE}"

export SQLITE_CONFIGURE='--enable-all --disable-threadsafe'

export CFLAGS_BUILD=''

# We need to add LDFLAGS ot CFLAGS because autoconf compiles(+links) to binary when checking stuff
export CFLAGS="${CFLAGS_CONFIG} ${CFLAGS_WASI} ${CFLAGS_SQLITE} ${CFLAGS_BUILD} ${LDFLAGS_WASI}"
export LDFLAGS="${LDFLAGS_WASI}"

cd "${WLR_SOURCE_PATH}"

logStatus "Configuring build with '${SQLITE_CONFIGURE}'... "
./configure --host=wasm32-wasi host_alias=wasm32-musl-wasi --target=wasm32-wasi target_alias=wasm32-musl-wasi ${SQLITE_CONFIGURE} || exit 1

logStatus "Building... "
make -j libsqlite3.la || exit 1

logStatus "Preparing artifacts... "
cp sqlite3.h sqlite3ext.h sqlite3session.h ${WLR_OUTPUT}/include/ || exit 1
cp .libs/libsqlite3.a ${WLR_OUTPUT}/lib/ || exit 1

logStatus "DONE. Artifacts in ${WLR_OUTPUT}"
