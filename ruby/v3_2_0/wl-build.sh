#!/bin/bash

if [[ ! -v WASMLABS_ENV ]]
then
    echo "Wasmlabs environment is not set"
    exit 1
fi

cd "${WASMLABS_SOURCE_PATH}"

mkdir -p build

if [[ -z "$WASMLABS_SKIP_CONFIGURE" ]]; then
    logStatus "Downloading autotools data... "
    ruby tool/downloader.rb -d tool -e gnu config.guess config.sub

    logStatus "Generating configure script... "
    ./autogen.sh

    logStatus "Configuring ruby..."
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
else
    logStatus "Skipping configure..."
fi

logStatus "Building ruby..."
make ruby

logStatus "Preparing artifacts... "
mv ruby ${WASMLABS_OUTPUT}/bin/ruby.wasm || exit 1

logStatus "DONE. Artifacts in ${WASMLABS_OUTPUT}"
