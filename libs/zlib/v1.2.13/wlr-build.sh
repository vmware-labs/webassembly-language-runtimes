#!/usr/bin/env bash

if [[ ! -v WLR_ENV ]]
then
    echo "Wasmlabs environment is not set"
    exit 1
fi

# export CFLAGS_CONFIG="-O3 -g"
export CFLAGS_CONFIG="-O0"

export CFLAGS_WASI="--sysroot=${WASI_SYSROOT}"

export CFLAGS_BUILD='-Werror -Wno-error=format -Wno-error=deprecated-non-prototype -Wno-error=unknown-warning-option'

export CFLAGS="${CFLAGS_CONFIG} ${CFLAGS_WASI} ${CFLAGS_BUILD}"

cd "${WLR_SOURCE_PATH}"

source ${WLR_REPO_ROOT}/scripts/build-helpers/wlr_pkg_config.sh

if [[ -z "$WLR_SKIP_CONFIGURE" ]]; then
    export ZLIB_CONFIGURE="${WLR_CONFIGURE_PREFIXES}"
    logStatus "Configuring build with '${ZLIB_CONFIGURE}'... "
    ./configure ${ZLIB_CONFIGURE} || exit 1
else
    logStatus "Skipping configure..."
fi

logStatus "Building... "
make -j || exit 1

logStatus "Preparing artifacts... "
make install ${WLR_INSTALL_PREFIXES} || exit 1

wlr_package_lib

logStatus "DONE. Artifacts in ${WLR_OUTPUT}"
