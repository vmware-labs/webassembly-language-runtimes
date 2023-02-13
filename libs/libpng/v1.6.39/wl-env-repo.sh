#!/usr/bin/env bash

if [[ $1 == "--unset" ]]
then
    unset WASMLABS_REPO
    unset WASMLABS_REPO_NAME
    return
fi

export WASMLABS_REPO=https://github.com/glennrp/libpng
export WASMLABS_REPO_NAME=libpng
export WASMLABS_REPO_BRANCH=v1.6.39
