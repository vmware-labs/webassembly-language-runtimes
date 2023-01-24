#!/usr/bin/env bash

if [[ ! -v WASMLABS_ENV ]]
then
    echo "Wasmlabs environment is not set"
    exit 1
fi

set_available_runtime() {
    if [ -x "$(command -v $1)" ]
    then
        export WASMLABS_TEST_RUNTIME=$1
        return 0
    fi
    return 1
}

if [[ -v WASMLABS_RUNTIME ]]
then
    set_available_runtime $WASMLABS_RUNTIME
else
    # Checking first for wasmtime as the reference implementation
    set_available_runtime wasmtime || \
    set_available_runtime wasmedge
fi

if ! [[ -v WASMLABS_TEST_RUNTIME ]]
then
    echo "No wasm runtime in PATH."
fi

export WASMLABS_TEST_RUNTIME_WRAPPER=${WASMLABS_REPO_ROOT}/scripts/wrappers/${WASMLABS_TEST_RUNTIME}.sh

if ! [ -x ${WASMLABS_TEST_RUNTIME_WRAPPER} ]
then
    echo "Missing test runtime wrapper in '${WASMLABS_TEST_RUNTIME_WRAPPER}'"
    exit 1
fi

if [ -f ${WASMLABS_ENV}/wl-test.sh ]
then
    source ${WASMLABS_ENV}/wl-test.sh
else
    echo "No tests for '${WASMLABS_ENV}'"
fi
