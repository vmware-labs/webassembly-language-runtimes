#!/usr/bin/env bash

if [ "${BASH_SOURCE-}" = "$0" ]; then
    echo "You must source this script: \$ source $0" >&2
    return
fi
logStatus "Ensure we're using the latest config.guess and config.sub ... "

function wlr_update_autoconf {
    if [[ ! -f config.guess && "$1" != "--force" ]]; then
        cp ${WASI_SDK_PATH}/share/misc/config.guess . || return 1
        chmod +x config.guess
    fi

    if [[ ! -f config.sub && "$1" != "--force" ]]; then
        cp ${WASI_SDK_PATH}/share/misc/config.sub . || return 1
        chmod +x config.sub
    fi
}
