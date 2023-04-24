#!/usr/bin/env bash

if [ "${BASH_SOURCE-}" = "$0" ]; then
    echo "You must source this script: \$ source $0" >&2
    return
fi

export WLR_CONFIGURE_PREFIXES="--prefix= --libdir=\${exec_prefix}/lib/wasm32-wasi"
export WLR_INSTALL_PREFIXES="\
    prefix=${WLR_OUTPUT} \
    libdir=${WLR_OUTPUT}/lib/wasm32-wasi \
    pkgconfigdir=${WLR_OUTPUT}/lib/wasm32-wasi/pkgconfig"

function add_pkg_config_Libs {
    local TARGET_FILE="$1"
    local EXTRA_LIBS="$2"

    sed -i "s/\(^Libs:.*$\)/\1 ${EXTRA_LIBS}/g" ${TARGET_FILE}
}

function wlr_pkg_config_reset_pc_prefix {
    local TARGET_FILE="$1"

    sed -i "s/\(^prefix=\).*$/\1/g" ${TARGET_FILE}
    sed -i "s|${WLR_OUTPUT}|\$\{prefix\}|g" ${TARGET_FILE}
}

function wlr_pkg_config_create_pc_file {
    local LIBRARY_NAME="$1"
    local VERSION="$2"
    local DESCRIPTION="$3"
    local LINK_FLAGS="$4"

    mkdir -p ${WLR_OUTPUT}/lib/wasm32-wasi/pkgconfig 2>/dev/null || exit 1
    local TARGET_FILE=${WLR_OUTPUT}/lib/wasm32-wasi/pkgconfig/${LIBRARY_NAME}.pc

    mkdir -p ${WLR_OUTPUT}/lib/wasm32-wasi/pkgconfig 2>/dev/null
    cat >$TARGET_FILE <<EOF
prefix=
exec_prefix=\${prefix}
libdir=\${prefix}/lib/wasm32-wasi
includedir=\${prefix}/include

Name: ${LIBRARY_NAME}
Description: ${DESCRIPTION}
Version: ${VERSION}
Libs: -L\${libdir} ${LINK_FLAGS}
Cflags: -I\${includedir}
EOF
}
