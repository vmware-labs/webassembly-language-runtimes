#!/usr/bin/env bash

if [[ ! -v WLR_ENV ]]
then
    echo "WLR build environment is not set"
    exit 1
fi

cd ${WLR_SOURCE_PATH} || exit 1
mv -f ${WLR_ENV}/patches/* /tmp/
git format-patch -X ${WLR_REPO_BRANCH} -o ${WLR_ENV}/patches || exit 1
