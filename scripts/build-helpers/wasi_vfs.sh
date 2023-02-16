#!/usr/bin/env bash

# This script defines a set of functions that can assist
# in downloading and using wasi-vfs

if [ "${BASH_SOURCE-}" = "$0" ]; then
    echo "You must source this script: \$ source $0" >&2
    return
fi

if [[ ! -v WASI_VFS_ROOT ]]
then
    echo "WASI_VFS_ROOT is not set"
    exit 1
fi

function wasi_vfs_setup_dependencies {
    export LDFLAGS_DEPENDENCIES="${LDFLAGS_DEPENDENCIES} -L${WASI_VFS_ROOT}/lib -lwasi_vfs "
}

function wasi_vfs_cli {
    ${WASI_VFS_ROOT}/bin/wasi-vfs $@
}

export -f wasi_vfs_setup_dependencies
export -f wasi_vfs_cli
