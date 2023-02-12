#!/usr/bin/env bash

if [[ $1 == "--unset" ]]
then
    unset WASMLABS_REPO
    unset WASMLABS_REPO_NAME
    return
fi

export WASMLABS_REPO=https://github.com/kkos/oniguruma
export WASMLABS_REPO_NAME=oniguruma
export WASMLABS_REPO_BRANCH=v6.9.8
