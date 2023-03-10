#!/usr/bin/env bash

if [[ ! -v WLR_ENV ]]
then
    echo "WLR build environment is not set"
    exit 1
fi

# export CFLAGS_CONFIG="-O3 -g"
export CFLAGS_CONFIG="-O0"

export CFLAGS="${CFLAGS_CONFIG}"

cd "${WLR_SOURCE_PATH}"

source ${WLR_REPO_ROOT}/scripts/build-helpers/wlr_cmake.sh
source ${WLR_REPO_ROOT}/scripts/build-helpers/wlr_pkg_config.sh

if [[ -z "$WLR_SKIP_CONFIGURE" ]]; then

    export LIBJPEG_CONFIGURE="-DENABLE_SHARED=0 -DWITH_TURBOJPEG=0"
    logStatus "Configuring with cmake with '${LIBJPEG_CONFIGURE}' ..."
    wlr_cmake_configure ${LIBJPEG_CONFIGURE}

else
    logStatus "Skipping configure..."
fi

logStatus "Building..."
wlr_cmake_build || exit 1
wlr_pkg_config_reset_pc_prefix ${WLR_CMAKE_TARGET_DIR}/pkgscripts/libjpeg.pc || exit 1

logStatus "Preparing artifacts..."

wlr_cmake_install || exit 1
wlr_package_lib || exit 1
wlr_package_bin || exit 1

logStatus "DONE. Artifacts in ${WLR_OUTPUT}"
