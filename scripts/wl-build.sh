#!/usr/bin/env bash

if [[ ! -v WASMLABS_ENV ]]
then
    echo "Wasmlabs environment is not set"
    exit 1
fi

if [[ ! -v WASI_SDK_ROOT ]]
then
    echo WASMLABS_ENV=${WASMLABS_ENV}
    echo "Please set WASI_SDK_ROOT and run again"
    exit 1
fi

if [[ ! -v BINARYEN_PATH ]]
then
    echo WASMLABS_ENV=${WASMLABS_ENV}
    echo WASI_SDK_ROOT=${WASI_SDK_ROOT}
    echo "Please set BINARYEN_PATH and run again"
    exit 1
fi

function onExit {
    echo "=============================================================="
    echo "Build progress logs:"
    cat $WASMLABS_OUTPUT/wasmlabs-progress.log
    unset -f logStatus
}
trap onExit EXIT

echo "$(date --iso-8601=ns) | Using WASI_SDK_ROOT=$WASI_SDK_ROOT " | tee -a $WASMLABS_OUTPUT/wasmlabs-progress.log

function logStatus {
    echo "$(date --iso-8601=ns) | $@" | tee -a $WASMLABS_OUTPUT/wasmlabs-progress.log
}

export -f logStatus

logStatus WASMLABS_ENV=${WASMLABS_ENV}
logStatus WASI_SDK_ROOT=${WASI_SDK_ROOT}
logStatus BINARYEN_PATH=${BINARYEN_PATH}

export WASI_SYSROOT="${WASI_SDK_ROOT}/share/wasi-sysroot"
export CC=${WASI_SDK_ROOT}/bin/clang
export LD=${WASI_SDK_ROOT}/bin/wasm-ld
export CXX=${WASI_SDK_ROOT}/bin/clang++
export NM=${WASI_SDK_ROOT}/bin/llvm-nm
export AR=${WASI_SDK_ROOT}/bin/llvm-ar
export RANLIB=${WASI_SDK_ROOT}/bin/llvm-ranlib

if ! builtin type -P wasm-opt
then
    logStatus "Using wasm-opt wrapper from ${WASMLABS_REPO_ROOT}/scripts/wrappers"
    export PATH="${WASMLABS_REPO_ROOT}/scripts/wrappers:$PATH"
fi

if [[ -f ${WASMLABS_ENV}/wl-build-deps.sh ]]
then
    source ${WASMLABS_ENV}/wl-build-deps.sh
fi

source ${WASMLABS_ENV}/wl-build.sh
