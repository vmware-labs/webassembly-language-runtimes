#!/usr/bin/env bash

if [[ $1 == "--unset" ]]
then
    unset WASMLABS_ENV_NAME
    unset WASMLABS_PACKAGE_NAME
    unset WASMLABS_PACKAGE_VERSION
    return
fi

export WASMLABS_ENV_NAME=wasmedge_sock/0.1.0
export WASMLABS_PACKAGE_NAME=libwasmedge_sock
export WASMLABS_PACKAGE_VERSION=0.1.0
