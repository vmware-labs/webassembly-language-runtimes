#!/usr/bin/env bash

if [[ ! -v WLR_ENV ]]
then
    echo "WLR build environment is not set"
    exit 1
fi

export CFLAGS_CONFIG="-O0"

# export CFLAGS_CONFIG="-O3 -g"
export CFLAGS_CONFIG="-O0"

export CFLAGS="${CFLAGS_CONFIG}"

cd "${WLR_SOURCE_PATH}"

source ${WLR_REPO_ROOT}/scripts/build-helpers/wlr_cmake.sh
source ${WLR_REPO_ROOT}/scripts/build-helpers/wlr_pkg_config.sh

if [[ -z "$WLR_SKIP_CONFIGURE" ]]; then

    logStatus "Configuring with cmake..."
    wlr_cmake_configure ${LIBJPEG_CONFIGURE}

else
    logStatus "Skipping configure..."
fi

logStatus "Building..."
wlr_cmake_build || exit 1

logStatus "Preparing artifacts..."

# wlr_cmake_install || exit 1
cp -TRv ${WLR_SOURCE_PATH}/include ${WLR_OUTPUT}/include || exit 1
mkdir ${WLR_OUTPUT}/lib/ 2>/dev/null
cp -v ${WLR_CMAKE_TARGET_DIR}/libwasmedge_sock.a ${WLR_OUTPUT}/lib/ || exit 1
wlr_package_lib || exit 1

logStatus "DONE. Artifacts in ${WLR_OUTPUT}"
