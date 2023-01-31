#!/usr/bin/env bash

if [[ $1 == "--unset" ]]
then
    unset WASMLABS_REPO
    unset WASMLABS_REPO_NAME
    return
fi

export WASMLABS_REPO=https://git.code.sf.net/p/libuuid/code
export WASMLABS_REPO_NAME=uuid
export WASMLABS_REPO_BRANCH=libuuid-1.0.3

