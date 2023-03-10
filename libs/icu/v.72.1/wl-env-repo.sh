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

export WLR_REPO=https://github.com/unicode-org/icu.git
export WLR_REPO_BRANCH=release-72-1
export WLR_ENV_NAME=icu/release-72-1
export WLR_PACKAGE_VERSION=72.1
export WLR_PACKAGE_NAME=libicu
