#!/usr/bin/env bash

if [[ ! -v WASMLABS_ENV ]]
then
    echo "Wasmlabs environment is not set"
    exit 1
fi

# export CFLAGS_CONFIG="-O3 -g"
export CFLAGS_CONFIG="-O0"

# export CFLAGS_WASI="--sysroot=${WASI_SYSROOT}"
# export LDFLAGS_WASI="--sysroot=${WASI_SYSROOT}"

# CFLAGS_LIBPNG="-I${WLR_DEPS_INCLUDE}"
# LDFLAGS_LIBPNG="-L${WLR_DEPS_LIBDIR}"

# logStatus "Using LIBPNG CFLAGS: ${CFLAGS_LIBPNG}"
# logStatus "Using LIBPNG LDFLAGS: ${LDFLAGS_LIBPNG}"

# Enabling private user build information from pngusr.h (see scripts/pnglibconf.dfa)
export CPPFLAGS='-DPNG_USER_CONFIG'
export CFLAGS_BUILD=''

# We need to add LDFLAGS ot CFLAGS because autoconf compiles(+links) to binary when checking stuff
export CFLAGS="${CFLAGS_CONFIG} ${CFLAGS_WASI} ${CFLAGS_LIBPNG} ${CFLAGS_BUILD} ${LDFLAGS_WASI}"
export LDFLAGS="${LDFLAGS_WASI} ${LDFLAGS_LIBPNG}"

cd "${WASMLABS_SOURCE_PATH}"

source ${WASMLABS_REPO_ROOT}/scripts/build-helpers/wlr_cmake.sh
source ${WASMLABS_REPO_ROOT}/scripts/build-helpers/wlr_pkg_config.sh

if [[ -z "$WASMLABS_SKIP_CONFIGURE" ]]; then

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

logStatus "DONE. Artifacts in ${WASMLABS_OUTPUT}"
