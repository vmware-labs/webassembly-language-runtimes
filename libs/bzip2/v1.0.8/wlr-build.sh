#!/usr/bin/env bash

if [[ ! -v WLR_ENV ]]
then
    echo "WLR build environment is not set"
    exit 1
fi

export CFLAGS_CONFIG="-O0"

export CFLAGS_WASI="--sysroot=${WASI_SYSROOT}"

export CFLAGS_BUILD='-Werror -Wno-error=format -Wno-error=deprecated-non-prototype -Wno-error=unknown-warning-option'

export CFLAGS="${CFLAGS_CONFIG} ${CFLAGS_WASI} ${CFLAGS_BUILD}"

cd "${WLR_SOURCE_PATH}"

source ${WLR_REPO_ROOT}/scripts/build-helpers/wlr_pkg_config.sh

BZIP2_MAKE_ARGS="CC=${CC} AR=${AR} RANLIB=${RANLIB} PREFIX=${WLR_OUTPUT} LIBDIR=${WLR_OUTPUT}/lib/wasm32-wasi"

logStatus "Building... "
make ${BZIP2_MAKE_ARGS} -j libbz2.a || exit 1

logStatus "Preparing artifacts... "
make ${BZIP2_MAKE_ARGS} libinstall || exit 1

logStatus "Generating pkg-config file for libbz2.a"
DESCRIPTION="libbzip2 is a library for lossless, block-sorting data compression"
EXTRA_LINK_FLAGS="-lbz2"

wlr_pkg_config_create_pc_file "bzip2" "${WLR_PACKAGE_VERSION}" "${DESCRIPTION}" "${EXTRA_LINK_FLAGS}" || exit 1

wlr_package_lib

logStatus "DONE. Artifacts in ${WLR_OUTPUT}"
