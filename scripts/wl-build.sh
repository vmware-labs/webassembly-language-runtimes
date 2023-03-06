#!/usr/bin/env bash

if [[ ! -v WASMLABS_ENV ]]
then
    echo "Wasmlabs environment is not set"
    exit 1
fi

if [[ ! -v WASI_SDK_PATH ]]
then
    echo WASMLABS_ENV=${WASMLABS_ENV}
    echo "Please set WASI_SDK_PATH and run again"
    exit 1
fi

if [[ ! -v BINARYEN_PATH ]]
then
    echo WASMLABS_ENV=${WASMLABS_ENV}
    echo WASI_SDK_PATH=${WASI_SDK_PATH}
    echo "Please set BINARYEN_PATH and run again"
    exit 1
fi

function onExit {
    echo "=============================================================="
    echo "Build progress logs for ${WASMLABS_ENV}:"
    cat $WASMLABS_OUTPUT/wasmlabs-progress.log
    unset -f logStatus
}
trap onExit EXIT

if [[ ! -v WASMLABS_PROGRESS_LOG ]]
then
    export WASMLABS_PROGRESS_LOG=${WASMLABS_OUTPUT}/wasmlabs-progress.log
    echo "$(date --iso-8601=ns) | Using WASI_SDK_PATH=$WASI_SDK_PATH " | tee ${WASMLABS_PROGRESS_LOG}
fi

function logStatus {
    echo "$(date --iso-8601=ns) | ${WASMLABS_ENV_NAME} | $@" | tee -a ${WASMLABS_PROGRESS_LOG}
}

export -f logStatus

for line in $(env | grep -E "WASMLABS_\w+="); do
    logStatus $line
done

logStatus WASI_SDK_PATH=${WASI_SDK_PATH}
logStatus BINARYEN_PATH=${BINARYEN_PATH}
logStatus WABT_ROOT=${WABT_ROOT}
logStatus WASI_VFS_ROOT=${WASI_VFS_ROOT}

export WASI_SYSROOT="${WASI_SDK_PATH}/share/wasi-sysroot"
export CC=${WASI_SDK_PATH}/bin/clang
export LD=${WASI_SDK_PATH}/bin/wasm-ld
export CXX=${WASI_SDK_PATH}/bin/clang++
export NM=${WASI_SDK_PATH}/bin/llvm-nm
export AR=${WASI_SDK_PATH}/bin/llvm-ar
export RANLIB=${WASI_SDK_PATH}/bin/llvm-ranlib

if ! builtin type -P wasm-opt
then
    logStatus "Using wasm-opt wrapper from ${WASMLABS_REPO_ROOT}/scripts/wrappers"
    export PATH="${WASMLABS_REPO_ROOT}/scripts/wrappers:$PATH"
fi

logStatus "Checking dependencies..."
if [[ -f ${WASMLABS_ENV}/wl-build-deps.sh ]]
then
    source ${WASMLABS_ENV}/wl-build-deps.sh
fi

logStatus "Building..."
source ${WASMLABS_ENV}/wl-build.sh

source ${WASMLABS_REPO_ROOT}/scripts/build-helpers/wlr_package.sh
wlr_package_lib
