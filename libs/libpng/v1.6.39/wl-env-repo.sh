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

export WASMLABS_REPO=https://github.com/glennrp/libpng
export WASMLABS_REPO_BRANCH=v1.6.39
export WASMLABS_ENV_NAME=libpng/v1.6.39
export WASMLABS_PACKAGE_VERSION=1.6.39
export WASMLABS_PACKAGE_NAME=libpng

