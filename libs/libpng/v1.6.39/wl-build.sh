#!/usr/bin/env bash

if [[ ! -v WASMLABS_ENV ]]
then
    echo "Wasmlabs environment is not set"
    exit 1
fi

# export CFLAGS_CONFIG="-O3 -g"
export CFLAGS_CONFIG="-O0"

export CFLAGS_WASI="--sysroot=${WASI_SYSROOT}"
export LDFLAGS_WASI="--sysroot=${WASI_SYSROOT}"

CFLAGS_LIBPNG="-I"${WLR_DEPS_INCLUDE}
LDFLAGS_LIBPNG="-L"${WLR_DEPS_LIBDIR}

logStatus "Using LIBPNG CFLAGS: ${CFLAGS_LIBPNG}"
logStatus "Using LIBPNG LDFLAGS: ${LDFLAGS_LIBPNG}"

# Enabling private user build information from pngusr.h (see scripts/pnglibconf.dfa)
export CPPFLAGS='-DPNG_USER_CONFIG'
export CFLAGS_BUILD=''

# We need to add LDFLAGS ot CFLAGS because autoconf compiles(+links) to binary when checking stuff
export CFLAGS="${CFLAGS_CONFIG} ${CFLAGS_WASI} ${CFLAGS_LIBPNG} ${CFLAGS_BUILD} ${LDFLAGS_WASI}"
export LDFLAGS="${LDFLAGS_WASI} ${LDFLAGS_LIBPNG}"

cd "${WASMLABS_SOURCE_PATH}"

source ${WASMLABS_REPO_ROOT}/scripts/build-helpers/pkg_config_tools.sh

if [[ -z "$WASMLABS_SKIP_CONFIGURE" ]]; then
    echo -e "\n\n\n"
    env | grep PKG
    env | grep zlib
    env | grep ZLIB
    echo -e "\n"
    export LIBPNG_CONFIGURE="${PKG_CONFIG_CONFIGURE_PREFIXES} --enable-static --disable-shared"
    logStatus "Configuring build with '${LIBPNG_CONFIGURE}'... "
    ./configure --config-cache --host=wasm32-wasi host_alias=wasm32-musl-wasi --target=wasm32-wasi target_alias=wasm32-musl-wasi ${LIBPNG_CONFIGURE} || exit 1
else
    logStatus "Skipping configure..."
fi

logStatus "Building..."
INCLUDES=${CFLAGS_LIBPNG} make -j libpng16.la || exit 1

logStatus "Preparing artifacts..."
make install-pkgincludeHEADERS ${PKG_CONFIG_INSTALL_PREFIXES} || exit 1
make install-nodist_pkgincludeHEADERS ${PKG_CONFIG_INSTALL_PREFIXES} || exit 1
make install-libLTLIBRARIES ${PKG_CONFIG_INSTALL_PREFIXES} || exit 1
make install-pkgconfigDATA ${PKG_CONFIG_INSTALL_PREFIXES} || exit 1
make install-header-links ${PKG_CONFIG_INSTALL_PREFIXES} || exit 1
make install-libpng-pc ${PKG_CONFIG_INSTALL_PREFIXES} || exit 1
make install-library-links ${PKG_CONFIG_INSTALL_PREFIXES} || exit 1

logStatus "DONE. Artifacts in ${WASMLABS_OUTPUT}"
