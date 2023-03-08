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
export WASMLABS_REPO_BRANCH=php-8.1.11
export WASMLABS_ENV_NAME=php/php-8.1.11
export WASMLABS_PACKAGE_VERSION=8.1.11
export WASMLABS_PACKAGE_NAME=php
