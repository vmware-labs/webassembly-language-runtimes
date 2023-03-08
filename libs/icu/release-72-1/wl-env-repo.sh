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

export WASMLABS_REPO=https://github.com/unicode-org/icu.git
export WASMLABS_REPO_BRANCH=release-72-1
export WASMLABS_ENV_NAME=icu/release-72-1
export WASMLABS_PACKAGE_VERSION=72.1
export WASMLABS_PACKAGE_NAME=libicu
