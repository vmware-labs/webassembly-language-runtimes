#!/usr/bin/env bash

if [[ ! -v WASMLABS_ENV ]]
then
    echo "Wasmlabs environment is not set"
    exit 1
fi

# export CFLAGS_CONFIG="-O3 -g"
export CFLAGS_CONFIG="-O0"

export CFLAGS_WASI="--sysroot=${WASI_SYSROOT} -D_WASI_EMULATED_GETPID"
export LDFLAGS_WASI="-lwasi-emulated-getpid"

export CFLAGS_BUILD='-Werror -Wno-error=format'

export CFLAGS="${CFLAGS_CONFIG} ${CFLAGS_WASI} ${CFLAGS_BUILD}"
export LDFLAGS="${LDFLAGS_WASI}"

cd "${WASMLABS_SOURCE_PATH}"

source ${WASMLABS_REPO_ROOT}/scripts/build-helpers/pkg_config_tools.sh

if [[ -z "$WASMLABS_SKIP_CONFIGURE" ]]; then

    logStatus "Generating configure"
    ${WASMLABS_REPO_ROOT}/scripts/build-helpers/update_autoconf.sh || exit 1

    autoreconf --verbose --install

    export UUID_CONFIGURE="${PKG_CONFIG_CONFIGURE_PREFIXES}"
    logStatus "Configuring build with '${UUID_CONFIGURE}'... "
    ./configure --host=wasm32-wasi host_alias=wasm32-musl-wasi --target=wasm32-wasi target_alias=wasm32-musl-wasi ${UUID_CONFIGURE} || exit 1
else
    logStatus "Skipping configure..."
fi

logStatus "Building... "
make || exit 1

logStatus "Preparing artifacts... "
make install \
    prefix=${WASMLABS_OUTPUT} \
    libdir=${WASMLABS_OUTPUT}/lib/wasm32-wasi \
    pkgconfigdir=${WASMLABS_OUTPUT}/lib/wasm32-wasi/pkgconfig

add_pkg_config_Libs ${WASMLABS_OUTPUT}/lib/wasm32-wasi/pkgconfig/uuid.pc ${LDFLAGS_WASI}

logStatus "DONE. Artifacts in ${WASMLABS_OUTPUT}"
