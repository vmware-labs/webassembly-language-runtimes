#!/bin/bash

if [[ ! -v WASMLABS_ENV ]]
then
    echo "Wasmlabs environment is not set"
    exit 1
fi

cd "${WASMLABS_CHECKOUT_PATH}"

mkdir build

ruby tool/downloader.rb -d tool -e gnu config.guess config.sub

./autogen.sh

./configure \
    --host wasm32-unknown-wasi \
    --with-ext=ripper,monitor \
    --with-static-linked-ext \
    LDFLAGS=" \
      -Xlinker --stack-first \
      -Xlinker -z -Xlinker stack-size=16777216 \
    " \
    optflags="-O2" \
    debugflags="" \
    wasmoptflags="-O2"

make ruby

cp ruby ${WASMLABS_OUTPUT}/bin/ || exit 1

logStatus "DONE. Artifacts in ${WASMLABS_OUTPUT}"
