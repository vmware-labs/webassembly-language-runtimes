#!/usr/bin/env bash

if [[ $1 == "--unset" ]]
then
    unset WASMLABS_REPO
    unset WASMLABS_REPO_NAME
    return
fi

export WASMLABS_REPO=https://github.com/php/php-src.git
export WASMLABS_REPO_NAME=php
export WASMLABS_REPO_BRANCH=php-8.2.0

