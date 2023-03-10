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

export WLR_REPO=https://github.com/kkos/oniguruma
export WLR_REPO_BRANCH=v6.9.8
export WLR_ENV_NAME=oniguruma/v6.9.8
export WLR_PACKAGE_VERSION=6.9.8
export WLR_PACKAGE_NAME=libonig
