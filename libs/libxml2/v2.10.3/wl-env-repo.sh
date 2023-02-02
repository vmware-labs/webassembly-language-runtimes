#!/usr/bin/env bash

if [[ $1 == "--unset" ]]
then
    unset WASMLABS_REPO
    unset WASMLABS_REPO_NAME
    return
fi

export WASMLABS_REPO=https://github.com/GNOME/libxml2.git
export WASMLABS_REPO_NAME=libxml2
export WASMLABS_REPO_BRANCH=v2.10.3
