#!/usr/bin/env bash

if [[ ! -v WLR_ENV ]]
then
    echo "Wasmlabs environment is not set"
    exit 1
fi

export CFLAGS_CONFIG="-O0"

export CFLAGS_WASI="--sysroot=${WASI_SYSROOT}"
export LDFLAGS_WASI="--sysroot=${WASI_SYSROOT}"

export CFLAGS_LIBXML2=''

logStatus "Using LIBXML2 DEFINES: ${CFLAGS_LIBXML2}"

export CFLAGS_BUILD=''

# We need to add LDFLAGS ot CFLAGS because autoconf compiles(+links) to binary when checking stuff
export CFLAGS="${CFLAGS_CONFIG} ${CFLAGS_WASI} ${CFLAGS_LIBXML2} ${CFLAGS_BUILD} ${LDFLAGS_WASI}"
export LDFLAGS="${LDFLAGS_WASI}"

cd "${WLR_SOURCE_PATH}"

source ${WLR_REPO_ROOT}/scripts/build-helpers/wlr_pkg_config.sh

if [[ -z "$WLR_SKIP_CONFIGURE" ]]; then
    ./autogen.sh
    export LIBXML2_CONFIGURE="${WLR_CONFIGURE_PREFIXES} --enable-static --disable-shared --with-minimum=yes --with-output=yes --with-schemas=yes --with-tree=yes --with-valid=yes --with-html=yes --with-xpath=yes --with-reader=yes --with-writer=yes --with-xinclude=yes --with-c14n=yes --with-sax1=yes"
    logStatus "Configuring build with '${LIBXML2_CONFIGURE}'..."
    ./configure --config-cache --host=wasm32-wasi host_alias=wasm32-musl-wasi --target=wasm32-wasi target_alias=wasm32-musl-wasi ${LIBXML2_CONFIGURE} || exit 1
else
    logStatus "Skipping configure..."
fi

logStatus "Building..."
make -j || exit 1

logStatus "Preparing artifacts..."
make install ${WLR_INSTALL_PREFIXES} || exit 1

wlr_package_lib

logStatus "DONE. Artifacts in ${WLR_OUTPUT}"
