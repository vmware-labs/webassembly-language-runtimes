#!/usr/bin/env bash

if [[ ! -v WASMLABS_ENV ]]
then
    echo "Wasmlabs environment is not set"
    exit 1
fi

if [[ ! -v WASI_SDK_ROOT ]]
then
    echo "Please set WASI_SDK_ROOT and run again"
    exit 1
fi

function onExit {
    echo "=============================================================="
    echo "Build progress logs:"
    cat $WASMLABS_OUTPUT/wasmlabs-progress.log
    unset -f logStatus
}
trap onExit EXIT

echo "$(date --iso-8601=ns) | Using WASI_SDK_ROOT=$WASI_SDK_ROOT " >  $WASMLABS_OUTPUT/wasmlabs-progress.log

function logStatus {
    echo "$(date --iso-8601=ns) | $@" >>  $WASMLABS_OUTPUT/wasmlabs-progress.log
}

export -f logStatus

export WASI_SYSROOT="${WASI_SDK_ROOT}/share/wasi-sysroot"
export CC=${WASI_SDK_ROOT}/bin/clang
export LD=${WASI_SDK_ROOT}/bin/wasm-ld
export CXX=${WASI_SDK_ROOT}/bin/clang++
export NM=${WASI_SDK_ROOT}/bin/llvm-nm
export AR=${WASI_SDK_ROOT}/bin/llvm-ar
export RANLIB=${WASI_SDK_ROOT}/bin/llvm-ranlib

if [[ -f ${WASMLABS_ENV}/wl-build-deps.sh ]]
then
    source ${WASMLABS_ENV}/wl-build-deps.sh
fi

source ${WASMLABS_ENV}/wl-build.sh
