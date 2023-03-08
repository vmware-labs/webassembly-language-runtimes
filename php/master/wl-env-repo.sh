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

export WASMLABS_REPO=https://github.com/php/php-src.git
export WASMLABS_REPO_BRANCH=master
export WASMLABS_ENV_NAME=php/master
export WASMLABS_PACKAGE_VERSION=master
export WASMLABS_PACKAGE_NAME=php
