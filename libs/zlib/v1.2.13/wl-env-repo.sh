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

export WASMLABS_REPO=https://github.com/madler/zlib
export WASMLABS_REPO_BRANCH=v1.2.13
export WASMLABS_ENV_NAME=zlib/v1.2.13
export WASMLABS_PACKAGE_VERSION=1.2.13
export WASMLABS_PACKAGE_NAME=libz
