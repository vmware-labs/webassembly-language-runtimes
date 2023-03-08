#!/usr/bin/env bash

if [[ $1 == "--unset" ]]
then
    unset WASMLABS_REPO
    unset WASMLABS_REPO_NAME
    return
fi

export WASMLABS_ENV_NAME=libs-internal/wasmedge_sock
export WASMLABS_BUILD_VERSION=0.1.0
