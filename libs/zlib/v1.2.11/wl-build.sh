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
git sparse-checkout set docker/include/zconf.h docker/include/zlib.h docker/lib/libz.a
git checkout main
cd ..

logStatus "Preparing artifacts... "
mkdir -p ${WASMLABS_OUTPUT}/include 2>/dev/null || exit 1
mkdir -p ${WASMLABS_OUTPUT}/lib 2>/dev/null || exit 1

cp python-wasi/docker/include/zlib.h ${WASMLABS_OUTPUT}/include || exit 1
cp python-wasi/docker/include/zconf.h ${WASMLABS_OUTPUT}/include || exit 1
cp python-wasi/docker/lib/libz.a ${WASMLABS_OUTPUT}/lib || exit 1

rm -rf python-wasi
logStatus "DONE. Artifacts in ${WASMLABS_OUTPUT}"
