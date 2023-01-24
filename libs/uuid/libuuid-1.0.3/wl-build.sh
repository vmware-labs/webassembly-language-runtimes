#!/usr/bin/env bash

if [[ ! -v WASMLABS_ENV ]]
then
    echo "Wasmlabs environment is not set"
    exit 1
fi

cd "${WASMLABS_SOURCE_PATH}"

logStatus "Downloading files from singlestore-labs/python-wasi... "
git clone --depth 1 --branch main --no-checkout https://github.com/singlestore-labs/python-wasi
cd python-wasi
git sparse-checkout set docker/include/uuid.h docker/lib/libuuid.a
git checkout main
cd ..

logStatus "Preparing artifacts... "
mkdir -p ${WASMLABS_OUTPUT}/include 2>/dev/null || exit 1
mkdir -p ${WASMLABS_OUTPUT}/lib 2>/dev/null || exit 1

cp python-wasi/docker/include/uuid.h ${WASMLABS_OUTPUT}/include || exit 1
cp python-wasi/docker/lib/libuuid.a ${WASMLABS_OUTPUT}/lib || exit 1

logStatus "DONE. Artifacts in ${WASMLABS_OUTPUT}"
