#!/usr/bin/env bash

if [[ $1 == "--unset" ]]
then
    unset WASMLABS_REPO
    unset WASMLABS_REPO_NAME
    return
fi

export WASMLABS_REPO=https://github.com/python/cpython
export WASMLABS_REPO_NAME=python
export WASMLABS_REPO_BRANCH=v3.11.1

