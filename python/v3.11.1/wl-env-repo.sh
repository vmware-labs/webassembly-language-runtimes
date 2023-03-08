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

export WASMLABS_REPO=https://github.com/python/cpython
export WASMLABS_REPO_BRANCH=v3.11.1
export WASMLABS_ENV_NAME=python/v3.11.1
export WASMLABS_PACKAGE_VERSION=3.11.1
export WASMLABS_PACKAGE_NAME=python
