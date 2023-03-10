#!/usr/bin/env bash

if [[ $1 == "--unset" ]]
then
    unset WLR_REPO
    unset WLR_REPO_BRANCH
    unset WLR_ENV_NAME
    unset WLR_PACKAGE_VERSION
    unset WLR_PACKAGE_NAME
    return
fi

export WLR_REPO=https://github.com/glennrp/libpng
export WLR_REPO_BRANCH=v1.6.39
export WLR_ENV_NAME=libpng/v1.6.39
export WLR_PACKAGE_VERSION=1.6.39
export WLR_PACKAGE_NAME=libpng

