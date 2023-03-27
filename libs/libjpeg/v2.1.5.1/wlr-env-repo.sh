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

export WLR_REPO=https://github.com/libjpeg-turbo/libjpeg-turbo
export WLR_REPO_BRANCH=2.1.5.1
export WLR_ENV_NAME=libjpeg/2.1.5.1
export WLR_PACKAGE_VERSION=2.1.5.1
export WLR_PACKAGE_NAME=jpeg
