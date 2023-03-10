#!/usr/bin/env bash

if [[ ! -v WLR_ENV ]]; then
    echo "Wasmlabs environment is not set"
    exit 1
fi

logStatus "Preparing artifacts..."

cp -TRv ${WLR_DEPS_ROOT}/build-output/include ${WLR_OUTPUT}/include || exit 1
cp -TRv ${WLR_DEPS_ROOT}/build-output/lib ${WLR_OUTPUT}/lib || exit 1

wlr_package_lib

logStatus "DONE. Artifacts in ${WLR_OUTPUT}"
