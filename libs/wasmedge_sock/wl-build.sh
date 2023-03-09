#!/usr/bin/env bash

if [[ ! -v WASMLABS_ENV ]]
then
    echo "Wasmlabs environment is not set"
    exit 1
fi

export CFLAGS_CONFIG="-O0"

# export CFLAGS_CONFIG="-O3 -g"
export CFLAGS_CONFIG="-O0"

export CFLAGS="${CFLAGS_CONFIG}"

cd "${WASMLABS_SOURCE_PATH}"

source ${WASMLABS_REPO_ROOT}/scripts/build-helpers/wlr_cmake.sh
source ${WASMLABS_REPO_ROOT}/scripts/build-helpers/wlr_pkg_config.sh

if [[ -z "$WASMLABS_SKIP_CONFIGURE" ]]; then

    logStatus "Configuring with cmake..."
    wlr_cmake_configure ${LIBJPEG_CONFIGURE}

else
    logStatus "Skipping configure..."
fi

logStatus "Building..."
wlr_cmake_build || exit 1

logStatus "Preparing artifacts..."

# wlr_cmake_install || exit 1
cp -TRv ${WASMLABS_SOURCE_PATH}/include ${WASMLABS_OUTPUT}/include || exit 1
mkdir ${WASMLABS_OUTPUT}/lib/ 2>/dev/null
cp -v ${WLR_CMAKE_TARGET_DIR}/libwasmedge_sock.a ${WASMLABS_OUTPUT}/lib/ || exit 1
wlr_package_lib || exit 1

logStatus "DONE. Artifacts in ${WASMLABS_OUTPUT}"
