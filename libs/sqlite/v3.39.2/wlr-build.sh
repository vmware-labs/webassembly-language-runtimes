#!/usr/bin/env bash

if [[ ! -v WLR_ENV ]]
then
    echo "WLR build environment is not set"
    exit 1
fi

export CFLAGS_CONFIG="-O0"

export CFLAGS_WASI="--sysroot=${WASI_SYSROOT} -I./wlr-stubs -D_WASI_EMULATED_MMAN -D_WASI_EMULATED_GETPID -D_WASI_EMULATED_SIGNAL -D_WASI_EMULATED_PROCESS_CLOCKS"
export LDFLAGS_WASI="--sysroot=${WASI_SYSROOT} -lwasi-emulated-mman -lwasi-emulated-getpid -lwasi-emulated-signal -lwasi-emulated-process-clocks"

export CFLAGS_SQLITE='-DSQLITE_OMIT_WAL=1 -DSQLITE_DEFAULT_SYNCHRONOUS=0 -DSQLITE_OMIT_RANDOMNESS  -DLONGDOUBLE_TYPE=double -DSQLITE_BYTEORDER=1234 -DNDEBUG=1 -DSQLITE_OS_UNIX=1 -DSQLITE_DISABLE_LFS=1 -DSQLITE_ENABLE_JSON1=1 -DSQLITE_HAVE_ISNAN=1 -DSQLITE_HAVE_MALLOC_USABLE_SIZE=1 -DSQLITE_HAVE_STRCHRNUL=1 -DSQLITE_LIKE_DOESNT_MATCH_BLOBS=1 -DSQLITE_OMIT_DEPRECATED=1 -DSQLITE_OMIT_LOAD_EXTENSION=1 -DSQLITE_TEMP_STORE=2 -DSQLITE_THREADSAFE=0 -DSQLITE_USE_URI=1 -DSQLITE_ENABLE_RTREE=1 -DSQLITE_ENABLE_FTS5=1 -DSQLITE_HAVE_USLEEP=1 -DSQLITE_ENABLE_EXPLAIN_COMMENTS=1 -DSQLITE_NOHAVE_SYSTEM=1'

logStatus "Using SQLITE DEFINES: ${CFLAGS_SQLITE}"

export CFLAGS_BUILD='-D_POSIX_SOURCE=1 -D_GNU_SOURCE=1 -DHAVE_FORK=0 -DWASM_WASI'

# We need to add LDFLAGS ot CFLAGS because autoconf compiles(+links) to binary when checking stuff
export CFLAGS="${CFLAGS_CONFIG} ${CFLAGS_WASI} ${CFLAGS_SQLITE} ${CFLAGS_BUILD} ${LDFLAGS_WASI}"
export LDFLAGS="${LDFLAGS_WASI}"

cd "${WLR_SOURCE_PATH}"

source ${WLR_REPO_ROOT}/scripts/build-helpers/wlr_pkg_config.sh

if [[ -z "$WLR_SKIP_CONFIGURE" ]]; then
    export SQLITE_CONFIGURE="${WLR_CONFIGURE_PREFIXES} --disable-threadsafe --enable-tempstore=yes"
    logStatus "Configuring build with '${SQLITE_CONFIGURE}'..."
    ./configure --config-cache --host=wasm32-wasi host_alias=wasm32-musl-wasi --target=wasm32-wasi target_alias=wasm32-musl-wasi ${SQLITE_CONFIGURE} || exit 1
else
    logStatus "Skipping configure..."
fi

logStatus "Building..."
make -j libsqlite3.la || exit 1

logStatus "Preparing artifacts..."
make lib_install ${WLR_INSTALL_PREFIXES} || exit 1

wlr_package_lib

logStatus "DONE. Artifacts in ${WLR_OUTPUT}"
