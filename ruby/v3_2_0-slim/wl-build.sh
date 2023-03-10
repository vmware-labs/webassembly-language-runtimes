#!/usr/bin/env bash

if [[ ! -v WLR_ENV ]]
then
    echo "Wasmlabs environment is not set"
    exit 1
fi

cd "${WLR_SOURCE_PATH}"

export PREFIX=/wlr-rubies

if [[ -z "$WLR_SKIP_CONFIGURE" ]]; then
    logStatus "Downloading autotools data... "
    ruby tool/downloader.rb -d tool -e gnu config.guess config.sub

    logStatus "Generating configure script... "
    ./autogen.sh

    logStatus "Configuring ruby..."
    ./configure \
        --host wasm32-unknown-wasi \
        --prefix=$PREFIX \
        --with-ext="" \
        --with-static-linked-ext \
        --disable-install-doc \
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
make install

logStatus "Preparing artifacts... "
mkdir -p ${WLR_OUTPUT}/bin 2>/dev/null || exit 1
mv $PREFIX/bin/ruby ${WLR_OUTPUT}/bin/ruby.wasm || exit 1

logStatus "DONE. Artifacts in ${WLR_OUTPUT}"
