#!/usr/bin/env bash

if [[ $1 == "--unset" ]]
then
    unset WASMLABS_REPO
    unset WASMLABS_REPO_NAME
    return
fi

export WASMLABS_REPO=https://github.com/madler/zlib
export WASMLABS_REPO_NAME=zlib
export WASMLABS_REPO_BRANCH=v1.2.13

