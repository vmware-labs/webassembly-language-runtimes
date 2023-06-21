#!/usr/bin/env bash

if [[ ! -v WLR_ENV ]]
then
    echo "WLR build environment is not set"
    exit 1
fi

if [[ ! -v WASI_SDK_PATH ]]
then
    echo WLR_ENV=${WLR_ENV}
    echo "Please set WASI_SDK_PATH and run again"
    exit 1
fi

if [[ ! -v WASI_SDK_ASSET_NAME ]]; then
    echo "Please set WASI_SDK_ASSET_NAME (e.g. wasi-sdk-18.0) in order to create packages."
    exit 1
fi

if [[ ! -v BINARYEN_PATH ]]
then
    echo WLR_ENV=${WLR_ENV}
    echo WASI_SDK_PATH=${WASI_SDK_PATH}
    echo "Please set BINARYEN_PATH and run again"
    exit 1
fi

function onExit {
    echo "=============================================================="
    echo "Build progress logs for ${WLR_ENV}:"
    cat $WLR_OUTPUT/wlr-build-progress.log
    unset -f logStatus
}
trap onExit EXIT

if [[ ! -v WLR_PROGRESS_LOG ]]
then
    export WLR_PROGRESS_LOG=${WLR_OUTPUT}/wlr-build-progress.log
    echo "$(date --iso-8601=ns) | Using WASI_SDK_PATH=$WASI_SDK_PATH " | tee ${WLR_PROGRESS_LOG}
fi

function logStatus {
    echo "$(date --iso-8601=ns) | ${WLR_ENV_NAME}${WLR_BUILD_FLAVOR:+(${WLR_BUILD_FLAVOR})} | $@" | tee -a ${WLR_PROGRESS_LOG}
}

export -f logStatus

for line in $(env | grep -E "WLR_\w+="); do
    logStatus $line
done

logStatus WASI_SDK_PATH=${WASI_SDK_PATH}
logStatus WASI_SDK_ASSET_NAME=${WASI_SDK_ASSET_NAME}
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

logStatus CC+${CC}
logStatus LD+${LD}
logStatus CXX+${CXX}
logStatus NM+${NM}
logStatus AR+${AR}
logStatus RANLIB+${RANLIB}

if ! builtin type -P wasm-opt
then
    logStatus "Using wasm-opt wrapper from ${WLR_REPO_ROOT}/scripts/wrappers"
    export PATH="${WLR_REPO_ROOT}/scripts/wrappers:$PATH"
fi

logStatus "Checking dependencies..."
if [[ -f ${WLR_ENV}/wlr-info.json ]]
then
    source ${WLR_REPO_ROOT}/scripts/build-helpers/wlr_dependencies.sh
    wlr_dependencies_import ${WLR_ENV}/wlr-info.json
fi

source ${WLR_REPO_ROOT}/scripts/build-helpers/wlr_package.sh

logStatus "Building..."
source ${WLR_ENV}/wlr-build.sh
