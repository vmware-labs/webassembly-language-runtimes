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

export WASMLABS_REPO=https://github.com/libjpeg-turbo/libjpeg-turbo
export WASMLABS_REPO_BRANCH=2.1.5.1
export WASMLABS_ENV_NAME=libjpeg/2.1.5.1
export WASMLABS_PACKAGE_VERSION=2.1.5.1
export WASMLABS_PACKAGE_NAME=libjpeg
