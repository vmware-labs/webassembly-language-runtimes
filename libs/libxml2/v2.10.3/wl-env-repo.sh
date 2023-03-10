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

export WLR_REPO=https://github.com/GNOME/libxml2.git
export WLR_REPO_BRANCH=v2.10.3
export WLR_ENV_NAME=libxml2/v2.10.3
export WLR_PACKAGE_VERSION=2.10.3
export WLR_PACKAGE_NAME=libxml2

