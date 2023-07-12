#!/usr/bin/env bash

if [[ ! -v WLR_ENV ]]; then
    echo "WLR build environment is not set"
    exit 1
fi

cd "${WLR_SOURCE_PATH}"

export PREFIX=/wlr-rubies

if [[ "${WLR_BUILD_FLAVOR}" != *"slim"* ]]; then
    source ${WLR_REPO_ROOT}/scripts/build-helpers/wlr_wasi_vfs.sh
    export XLDFLAGS="$(wlr_wasi_vfs_get_link_flags) ${XLDFLAGS}"
    echo "Added wasi-vfs to XDFLAGS. XLDFLAGS='${XLDFLAGS}'"
fi

if [[ -z "${WLR_SKIP_CONFIGURE}" ]]; then
    logStatus "Downloading autotools data... "
    ruby tool/downloader.rb -d tool -e gnu config.guess config.sub || exit 1

    logStatus "Generating configure script... "
    ./autogen.sh || exit 1

    CFG_WITH_EXT=''
    if [[ "${WLR_BUILD_FLAVOR}" != *"slim"* ]]; then
        CFG_WITH_EXT+='bigdecimal,'
        CFG_WITH_EXT+='cgi/escape,'
        CFG_WITH_EXT+='continuation,'
        CFG_WITH_EXT+='coverage,'
        CFG_WITH_EXT+='date,'
        CFG_WITH_EXT+='dbm,'
        CFG_WITH_EXT+='digest/bubblebabble,'
        CFG_WITH_EXT+='digest,'
        CFG_WITH_EXT+='digest/md5,'
        CFG_WITH_EXT+='digest/rmd160,'
        CFG_WITH_EXT+='digest/sha1,'
        CFG_WITH_EXT+='digest/sha2,'
        CFG_WITH_EXT+='etc,'
        CFG_WITH_EXT+='fcntl,'
        CFG_WITH_EXT+='fiber,'
        CFG_WITH_EXT+='gdbm,'
        CFG_WITH_EXT+='json,'
        CFG_WITH_EXT+='json/generator,'
        CFG_WITH_EXT+='json/parser,'
        CFG_WITH_EXT+='nkf,'
        CFG_WITH_EXT+='objspace,'
        CFG_WITH_EXT+='pathname,'
        CFG_WITH_EXT+='racc/cparse,'
        CFG_WITH_EXT+='rbconfig/sizeof,'
        CFG_WITH_EXT+='ripper,'
        CFG_WITH_EXT+='stringio,'
        CFG_WITH_EXT+='strscan,'
        CFG_WITH_EXT+='monitor'
    fi

    CFG_LDFLAGS=" -Xlinker --stack-first"
    CFG_LDFLAGS+=" -Xlinker -z"
    CFG_LDFLAGS+=" -Xlinker stack-size=16777216"

    logStatus "Configuring ruby..."
    ./configure \
        --host wasm32-unknown-wasi \
        --prefix=${PREFIX} \
        --with-ext="${CFG_WITH_EXT}" \
        --with-static-linked-ext \
        --disable-install-doc \
        LDFLAGS="${CFG_LDFLAGS}" \
        optflags="-O2" \
        debugflags="" \
        wasmoptflags="-O2" || exit 1
else
    logStatus "Skipping configure..."
fi

logStatus "Building ruby..."
make install || exit 1

logStatus "Preparing artifacts... "
mkdir -p ${WLR_OUTPUT}/bin 2>/dev/null || exit 1

if [[ "${WLR_BUILD_FLAVOR}" == *"slim"* ]]; then
    mv ${PREFIX}/bin/ruby ${WLR_OUTPUT}/bin/ruby.wasm || exit 1
else
    logStatus "Packing with wasi-vfs"
    mv ${PREFIX}/bin/ruby ruby
    wlr_wasi_vfs_cli pack ruby --mapdir ${PREFIX}::${PREFIX} -o ${WLR_OUTPUT}/bin/ruby.wasm || exit 1
fi

rm -rf ${PREFIX}/bin

PUBLISHED_RUBY_BINARY=ruby-${WLR_PACKAGE_VERSION}${WLR_BUILD_FLAVOR:+-$WLR_BUILD_FLAVOR}.wasm
cp -v ${WLR_OUTPUT}/bin/ruby.wasm ${WLR_OUTPUT_BASE}/${PUBLISHED_RUBY_BINARY}

logStatus "DONE. Artifacts in ${WLR_OUTPUT}"
