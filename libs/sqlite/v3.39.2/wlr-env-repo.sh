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

export WLR_REPO=https://github.com/sqlite/sqlite.git
export WLR_REPO_BRANCH=version-3.39.2
export WLR_ENV_NAME=sqlite/v3.39.2
export WLR_PACKAGE_VERSION=3.39.2
export WLR_PACKAGE_NAME=libsqlite
