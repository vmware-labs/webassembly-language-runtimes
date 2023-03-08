#!/usr/bin/env bash

if [[ $1 == "--unset" ]]
then
    unset WASMLABS_REPO
    unset WASMLABS_REPO_NAME
    return
fi

export WASMLABS_REPO=https://github.com/libjpeg-turbo/libjpeg-turbo
export WASMLABS_REPO_NAME=libjpeg
export WASMLABS_REPO_BRANCH=2.1.5.1
