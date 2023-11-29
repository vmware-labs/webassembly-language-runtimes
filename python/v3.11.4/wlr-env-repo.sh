#!/usr/bin/env bash

if [[ $1 == "--unset" ]]
then
    unset WLR_REPO
    unset WLR_REPO_BRANCH
    unset WLR_ENV_NAME
    unset WLR_PACKAGE_VERSION
    unset WLR_PACKAGE_NAME
    unset WLR_PY_BUILDER_VERSION
    return
fi

export WLR_REPO=https://github.com/python/cpython
export WLR_REPO_BRANCH=v3.11.4
export WLR_ENV_NAME=python/v3.11.4
export WLR_PACKAGE_VERSION=3.11.4
export WLR_PACKAGE_NAME=python
export WLR_PY_BUILDER_VERSION=3.11.4
