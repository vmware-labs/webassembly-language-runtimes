#!/usr/bin/env bash

if [[ ! -v WASMLABS_ENV ]]; then
    echo "Wasmlabs environment is not set"
    exit 1
fi

logStatus "Preparing artifacts..."

cp -TRv ${WASMLABS_DEPS_ROOT}/build-output/include ${WASMLABS_OUTPUT}/include || exit 1
cp -TRv ${WASMLABS_DEPS_ROOT}/build-output/lib ${WASMLABS_OUTPUT}/lib || exit 1

for file in ${WASMLABS_OUTPUT}/lib/wasm32-wasi/pkgconfig/*.pc; do
    sed -i "s|prefix=${WASMLABS_DEPS_ROOT}/build-output|prefix=|g" $file
done

logStatus "DONE. Artifacts in ${WASMLABS_OUTPUT}"
