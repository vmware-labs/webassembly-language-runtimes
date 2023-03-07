#!/usr/bin/env bash

if [ "${BASH_SOURCE-}" = "$0" ]; then
    echo "You must source this script: \$ source $0" >&2
    return
fi

export WLR_CONFIGURE_PREFIXES="--prefix= --libdir=\${exec_prefix}/lib/wasm32-wasi"
export WLR_INSTALL_PREFIXES="\
    prefix=${WASMLABS_OUTPUT} \
    libdir=${WASMLABS_OUTPUT}/lib/wasm32-wasi \
    pkgconfigdir=${WASMLABS_OUTPUT}/lib/wasm32-wasi/pkgconfig"

function add_pkg_config_Libs {
    TARGET_FILE="$1"
    EXTRA_LIBS="$2"

    sed -i "s/\(^Libs:.*$\)/\1 ${EXTRA_LIBS}/g" ${TARGET_FILE}
}

function wlr_pkg_config_reset_pc_prefix {
    TARGET_FILE="$1"

    sed -i "s/\(^prefix=\).*$/\1/g" ${TARGET_FILE}
    sed -i "s|${WASMLABS_OUTPUT}|\$\{prefix\}|g" ${TARGET_FILE}
}
