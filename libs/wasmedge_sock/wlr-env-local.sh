#!/usr/bin/env bash

if [[ $1 == "--unset" ]]
then
    unset WLR_ENV_NAME
    unset WLR_PACKAGE_NAME
    unset WLR_PACKAGE_VERSION
    return
fi

export WLR_ENV_NAME=wasmedge_sock/0.1.0
export WLR_PACKAGE_NAME=wasmedge_sock
export WLR_PACKAGE_VERSION=0.1.0
