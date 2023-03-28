#!/usr/bin/env bash

if [[ ! -v WLR_ENV ]]
then
    echo "WLR build environment is not set"
    exit 1
fi

set_available_runtime() {
    if [ -x "$(command -v $1)" ]
    then
        export WLR_TEST_RUNTIME=$1
        return 0
    fi
    return 1
}

if [[ "${WLR_BUILD_FLAVOR}" == *"wasmedge"* ]]
then
    set_available_runtime wasmedge || \
    exit 1
else
    # Checking first for wasmtime as the reference implementation
    set_available_runtime wasmtime || \
    set_available_runtime wasmedge || \
    exit 1
fi

if ! [[ -v WLR_TEST_RUNTIME ]]
then
    echo "No wasm runtime in PATH."
fi

export WLR_TEST_RUNTIME_WRAPPER=${WLR_REPO_ROOT}/scripts/wrappers/${WLR_TEST_RUNTIME}.sh

if ! [ -x ${WLR_TEST_RUNTIME_WRAPPER} ]
then
    echo "Missing test runtime wrapper in '${WLR_TEST_RUNTIME_WRAPPER}'"
    exit 1
fi

if [ -f ${WLR_ENV}/wlr-test.sh ]
then
    source ${WLR_ENV}/wlr-test.sh
else
    echo "No tests for '${WLR_ENV}'"
fi
