#!/usr/bin/env bash

if [[ $1 == "--unset" ]]
then
    unset WASMLABS_ENV_NAME
    unset WASMLABS_PACKAGE_NAME
    unset WASMLABS_PACKAGE_VERSION
    return
fi

export WASMLABS_ENV_NAME=bundle_wlr/0.1.0
export WASMLABS_PACKAGE_NAME=libbundle_wlr
export WASMLABS_PACKAGE_VERSION=0.1.0
