#!/usr/bin/env bash
logStatus "Building libs 'php/php-8.2.0-slim'"

if [[ ! -v WLR_ENV ]]
then
    echo "WLR build environment is not set"
    exit 1
fi

export CFLAGS_CONFIG="-Oz"

########## Setup the wasi related flags #############
export CFLAGS_WASI="--sysroot=${WASI_SYSROOT} -D_WASI_EMULATED_GETPID -D_WASI_EMULATED_SIGNAL -D_WASI_EMULATED_PROCESS_CLOCKS"
export LDFLAGS_WASI="--sysroot=${WASI_SYSROOT} -lwasi-emulated-getpid -lwasi-emulated-signal -lwasi-emulated-process-clocks"

########## Setup the flags for php #############
export CFLAGS_PHP='-D_POSIX_SOURCE=1 -D_GNU_SOURCE=1 -DHAVE_FORK=0 -DWASM_WASI'

# We need to add LDFLAGS ot CFLAGS because autoconf compiles(+links) to binary when checking stuff
export LDFLAGS="${LDFLAGS_WASI} ${LDFLAGS_DEPENDENCIES} ${LDFLAGS_SQLITE}"
export CFLAGS="${CFLAGS_CONFIG} ${CFLAGS_WASI} ${CFLAGS_DEPENDENCIES} ${CFLAGS_PHP} ${LDFLAGS}"

logStatus "CFLAGS="${CFLAGS}
logStatus "LDFLAGS="${LDFLAGS}


cd "${WLR_SOURCE_PATH}"

if [[ -z "$WLR_SKIP_CONFIGURE" ]]; then
    logStatus "Generating configure script..."
    ./buildconf --force || exit 1

    export PHP_CONFIGURE='--without-openssl --without-libxml --without-pear --disable-phar --disable-opcache --disable-zend-signals --without-pcre-jit --disable-fiber-asm --disable-posix --disable-dom --disable-xml --disable-simplexml --without-libxml --disable-xmlreader --disable-xmlwriter --disable-fileinfo --disable-session --disable-all --disable-dom --disable-inifile --disable-flatfile --disable-ctype --disable-dom --disable-fileinfo --disable-filter --disable-mbregex --disable-opcache --disable-huge-code-pages --disable-opcache-jit --disable-phar --disable-posix --disable-session --disable-simplexml --disable-tokenizer --disable-xml --disable-xmlreader --disable-xmlwriter --disable-mysqlnd-compression-support --disable-fiber-asm --disable-zend-signals --without-cdb --with-sqlite3 --enable-pdo --with-pdo-sqlite'

    if [[ -v WLR_RUNTIME ]]
    then
        export PHP_CONFIGURE="--with-wasm-runtime=${WLR_RUNTIME} ${PHP_CONFIGURE}"
    fi

    logStatus "Configuring build with '${PHP_CONFIGURE}'..."
    ./configure --host=wasm32-wasi host_alias=wasm32-musl-wasi --target=wasm32-wasi target_alias=wasm32-musl-wasi ${PHP_CONFIGURE} || exit 1
else
    logStatus "Skipping configure..."
fi

export MAKE_TARGETS='cgi'

logStatus "Building '${MAKE_TARGETS}'..."
# By exporting WLR_SKIP_WASM_OPT envvar during the build, the
# wasm-opt wrapper in the wasm-base image will be a dummy wrapper that
# is effectively a NOP.
#
# This is due to https://github.com/llvm/llvm-project/issues/55781, so
# that we get to choose which optimization passes are executed after
# the artifacts have been built.
export WLR_SKIP_WASM_OPT=1
make -j ${MAKE_TARGETS} || exit 1
unset WLR_SKIP_WASM_OPT

logStatus "Preparing artifacts..."
mkdir -p ${WLR_OUTPUT}/bin 2>/dev/null || exit 1

logStatus "Running wasm-opt with the asyncify pass on php-cgi..."
wasm-opt -O4 -o ${WLR_OUTPUT}/bin/php-cgi${WLR_RUNTIME:+-$WLR_RUNTIME}.wasm sapi/cgi/php-cgi || exit 1

logStatus "DONE. Artifacts in ${WLR_OUTPUT}"
