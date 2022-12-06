#!/usr/bin/env bash

if [[ ! -v WASMLABS_ENV ]]
then
    echo "Wasmlabs environment is not set"
    exit 1
fi

if git clone --depth=1 -b ${WASMLABS_TAG} ${WASMLABS_REPO} ${WASMLABS_CHECKOUT_PATH}
then
    cd ${WASMLABS_CHECKOUT_PATH} || exit 1
    git config user.email "Wasm Labs Team"
    git config user.name "no-reply@wasmlabs.dev"
    if [ -d ${WASMLABS_ENV}/patches/ ]
    then
        for p in ${WASMLABS_ENV}/patches/*.patch
        do
            git am --no-gpg-sign $p || exit 1
        done
    fi
else
    echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
    echo "!!! Reusing previous contents of ${WASMLABS_CHECKOUT_PATH} "
    echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
fi
