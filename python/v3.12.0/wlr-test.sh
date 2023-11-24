#!/usr/bin/env bash

if [[ ! -v WLR_ENV ]]
then
    echo "WLR build environment is not set"
    exit 1
fi

if [[ "${WLR_BUILD_FLAVOR}" == *"wasmedge"* ]]
then
    WLR_BINARY_WUFFIX=-wasmedge
fi

export WLR_TESTED_MODULE="${WLR_OUTPUT}/bin/python-${WLR_PACKAGE_VERSION}${WLR_BINARY_WUFFIX}.wasm"
export TEST_ROOT=${WLR_ENV}/../test

(cd ${TEST_ROOT}; ./run_me.sh)
