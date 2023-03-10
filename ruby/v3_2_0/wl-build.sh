#!/usr/bin/env bash

if [[ ! -v WLR_ENV ]]
then
    echo "Wasmlabs environment is not set"
    exit 1
fi

cd "${WLR_SOURCE_PATH}"

export PREFIX=/wlr-rubies
export XLDFLAGS="/wasi-vfs/lib/libwasi_vfs.a $XLDFLAGS"

if [[ -z "$WLR_SKIP_CONFIGURE" ]]; then
    logStatus "Downloading autotools data... "
    ruby tool/downloader.rb -d tool -e gnu config.guess config.sub

    logStatus "Generating configure script... "
    ./autogen.sh

    logStatus "Configuring ruby..."
    ./configure \
        --host wasm32-unknown-wasi \
        --prefix=$PREFIX \
        --with-ext=bigdecimal,cgi/escape,continuation,coverage,date,dbm,digest/bubblebabble,digest,digest/md5,digest/rmd160,digest/sha1,digest/sha2,etc,fcntl,fiber,gdbm,json,json/generator,json/parser,nkf,objspace,pathname,racc/cparse,rbconfig/sizeof,ripper,stringio,strscan,monitor \
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
mv $PREFIX/bin/ruby ruby
rm -rf $PREFIX/bin
wasi-vfs pack ruby --mapdir $PREFIX::$PREFIX -o ${WLR_OUTPUT}/bin/ruby.wasm || exit 1

logStatus "DONE. Artifacts in ${WLR_OUTPUT}"
