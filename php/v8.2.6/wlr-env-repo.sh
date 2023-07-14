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

export WLR_REPO=https://github.com/php/php-src.git
export WLR_REPO_BRANCH=php-8.2.6
export WLR_ENV_NAME=php/php-8.2.6
export WLR_PACKAGE_VERSION=8.2.6
export WLR_PACKAGE_NAME=php
