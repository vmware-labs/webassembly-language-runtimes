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

export WASMLABS_REPO=https://github.com/kkos/oniguruma
export WASMLABS_REPO_BRANCH=v6.9.8
export WASMLABS_ENV_NAME=oniguruma/v6.9.8
export WASMLABS_PACKAGE_VERSION=6.9.8
export WASMLABS_PACKAGE_NAME=libonig
