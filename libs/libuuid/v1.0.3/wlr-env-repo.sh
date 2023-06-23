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

export WLR_REPO=https://git.code.sf.net/p/libuuid/code
export WLR_REPO_BRANCH=libuuid-1.0.3
export WLR_ENV_NAME=libuuid/libuuid-1.0.3
export WLR_PACKAGE_VERSION=1.0.3
export WLR_PACKAGE_NAME=uuid
