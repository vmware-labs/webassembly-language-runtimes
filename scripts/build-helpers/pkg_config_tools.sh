#!/usr/bin/env bash

if [ "${BASH_SOURCE-}" = "$0" ]; then
    echo "You must source this script: \$ source $0" >&2
    return
fi

export PKG_CONFIG_CONFIGURE_PREFIXES="--prefix= --libdir=\${exec_prefix}/lib/wasm32-wasi"
export PKG_CONFIG_INSTALL_PREFIXES="\
    prefix=${WASMLABS_OUTPUT} \
    libdir=${WASMLABS_OUTPUT}/lib/wasm32-wasi \
    pkgconfigdir=${WASMLABS_OUTPUT}/lib/wasm32-wasi/pkgconfig"

function add_pkg_config_Libs {
    TARGET_FILE="$1"
    EXTRA_LIBS="$2"

    sed -i "s/\(^Libs:.*$\)/\1 ${EXTRA_LIBS}/g" ${TARGET_FILE}
}
