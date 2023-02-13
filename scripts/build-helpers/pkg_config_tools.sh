#!/usr/bin/env bash

if [ "${BASH_SOURCE-}" = "$0" ]; then
    echo "You must source this script: \$ source $0" >&2
    return
fi

export PKG_CONFIG_CONFIGURE_PREFIXES="--prefix= --libdir=\${exec_prefix}/lib/wasm32-wasi"

function add_pkg_config_Libs {
    TARGET_FILE="$1"
    EXTRA_LIBS="$2"

    sed -i "s/\(^Libs:.*$\)/\1 ${EXTRA_LIBS}/g" ${TARGET_FILE}
}
