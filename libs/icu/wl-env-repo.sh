#!/usr/bin/env bash

if [[ $1 == "--unset" ]]
then
    unset WASMLABS_REPO
    unset WASMLABS_REPO_NAME
    return
fi

export WASMLABS_REPO=https://github.com/unicode-org/icu.git
export WASMLABS_REPO_NAME=icu
