#!/usr/bin/env bash

if [[ ! -v WLR_ENV ]]
then
    echo "WLR build environment is not set"
    exit 1
fi

# export CFLAGS_CONFIG="-O3 -g"
export CFLAGS_CONFIG="-O0"

export CFLAGS_WASI="--sysroot=${WASI_SYSROOT} -D_WASI_EMULATED_GETPID"
export LDFLAGS_WASI="-lwasi-emulated-getpid"

export CFLAGS_BUILD='-Werror -Wno-error=format'

export CFLAGS="${CFLAGS_CONFIG} ${CFLAGS_WASI} ${CFLAGS_BUILD}"
export LDFLAGS="${LDFLAGS_WASI}"

cd "${WLR_SOURCE_PATH}"

source ${WLR_REPO_ROOT}/scripts/build-helpers/wlr_pkg_config.sh

if [[ -z "$WLR_SKIP_CONFIGURE" ]]; then

    logStatus "Generating configure"
    source ${WLR_REPO_ROOT}/scripts/build-helpers/wlr_autoconf.sh
    wlr_update_autoconf || exit 1

    autoreconf --verbose --install

    export UUID_CONFIGURE="${WLR_CONFIGURE_PREFIXES}"
    logStatus "Configuring build with '${UUID_CONFIGURE}'... "
    ./configure --host=wasm32-wasi host_alias=wasm32-musl-wasi --target=wasm32-wasi target_alias=wasm32-musl-wasi ${UUID_CONFIGURE} || exit 1
else
    logStatus "Skipping configure..."
fi

logStatus "Building... "
make || exit 1

logStatus "Preparing artifacts... "
make install ${WLR_INSTALL_PREFIXES} || exit 1

add_pkg_config_Libs ${WLR_OUTPUT}/lib/wasm32-wasi/pkgconfig/uuid.pc ${LDFLAGS_WASI}

wlr_package_lib

logStatus "DONE. Artifacts in ${WLR_OUTPUT}"
