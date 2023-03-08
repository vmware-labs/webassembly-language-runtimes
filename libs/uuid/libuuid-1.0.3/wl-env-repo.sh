#!/usr/bin/env bash

if [[ $1 == "--unset" ]]
then
    unset WASMLABS_REPO
    unset WASMLABS_REPO_BRANCH
    unset WASMLABS_ENV_NAME
    unset WASMLABS_PACKAGE_VERSION
    unset WASMLABS_PACKAGE_NAME
    return
fi

export WASMLABS_REPO=https://git.code.sf.net/p/libuuid/code
export WASMLABS_REPO_BRANCH=libuuid-1.0.3
export WASMLABS_ENV_NAME=uuid/libuuid-1.0.3
export WASMLABS_PACKAGE_VERSION=1.0.3
export WASMLABS_PACKAGE_NAME=libuuid
