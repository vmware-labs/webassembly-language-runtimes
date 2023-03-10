#!/usr/bin/env bash

if [[ ! -v WLR_ENV ]]
then
    echo "WLR build environment is not set"
    exit 1
fi

if [[ ! -v WLR_REPO ]]
then
    echo "Building from current repository"
    exit 0
fi

if git clone --depth=1 -b ${WLR_REPO_BRANCH} ${WLR_REPO} ${WLR_SOURCE_PATH}
then
    cd ${WLR_SOURCE_PATH} || exit 1
    git config user.email "Wasm Labs Team"
    git config user.name "no-reply@wasmlabs.dev"
    if [ -d ${WLR_ENV}/patches/ ]
    then
        git am --no-gpg-sign --ignore-space-change --ignore-whitespace ${WLR_ENV}/patches/*.patch
    fi
else
    echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
    echo "!!! Reusing previous contents of ${WLR_SOURCE_PATH} "
    echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
fi
