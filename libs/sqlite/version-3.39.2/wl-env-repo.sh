#!/usr/bin/env bash

if [[ $1 == "--unset" ]]
then
    unset WASMLABS_REPO
    unset WASMLABS_REPO_NAME
    return
fi

export WASMLABS_REPO=https://github.com/sqlite/sqlite.git
export WASMLABS_REPO_NAME=sqlite
export WASMLABS_REPO_BRANCH=version-3.39.2

