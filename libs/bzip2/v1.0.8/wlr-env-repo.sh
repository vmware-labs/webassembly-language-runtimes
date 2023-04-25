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

export WLR_REPO=https://gitlab.com/bzip2/bzip2
export WLR_REPO_BRANCH=bzip2-1.0.8
export WLR_ENV_NAME=bzip2/v1.0.8
export WLR_PACKAGE_VERSION=1.0.8
export WLR_PACKAGE_NAME=bzip2
