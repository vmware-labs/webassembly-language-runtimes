#!/usr/bin/env bash

if [[ ! -v WLR_ENV ]]
then
    echo "WLR build environment is not set"
    exit 1
fi

export CFLAGS_CONFIG="-O0"


# We need to add LDFLAGS ot CFLAGS because autoconf compiles(+links) to binary when checking stuff
export CFLAGS="${CFLAGS_CONFIG}"

cd "${WLR_SOURCE_PATH}"

source ${WLR_REPO_ROOT}/scripts/build-helpers/wlr_pkg_config.sh

unset WASI_SYSROOT
unset CC
unset LD
unset CXX
unset NM
unset AR
unset RANLIB

if [[ -z "$WLR_SKIP_CONFIGURE" ]]; then
    export SQLITE_CONFIGURE="${WLR_CONFIGURE_PREFIXES} --enable-all --with-wasi-sdk=${WASI_SDK_PATH}"
    logStatus "Configuring build with '${SQLITE_CONFIGURE}'..."
    ./configure --config-cache ${SQLITE_CONFIGURE} || exit 1
else
    logStatus "Skipping configure..."
fi

logStatus "Building... "
make -j || exit 1

logStatus "Preparing artifacts... "
make lib_install ${WLR_INSTALL_PREFIXES} || exit 1

wlr_package_lib

logStatus "DONE. Artifacts in ${WLR_OUTPUT}"
