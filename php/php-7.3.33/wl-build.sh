#!/usr/bin/env bash

if [[ ! -v WASMLABS_ENV ]]
then
    echo "Wasmlabs environment is not set"
    exit 1
fi

# export CFLAGS_CONFIG="-O3 -g"
export CFLAGS_CONFIG="-O2"

export CFLAGS_WASI="--sysroot=${WASI_SYSROOT} -D_WASI_EMULATED_GETPID -D_WASI_EMULATED_SIGNAL -D_WASI_EMULATED_PROCESS_CLOCKS"
export LDFLAGS_WASI="--sysroot=${WASI_SYSROOT} -lwasi-emulated-getpid -lwasi-emulated-signal -lwasi-emulated-process-clocks"

export CFLAGS_SQLITE='-DSQLITE_OMIT_LOAD_EXTENSION=1 -DSQLITE_THREADSAFE=0 -DSQLITE_OMIT_WAL=1 -DSQLITE_DEFAULT_SYNCHRONOUS=0 -DSQLITE_PAGER_SYNCHRONOUS=1 -DSQLITE_OMIT_RANDOMNESS'

export CFLAGS_PHP='-D_POSIX_SOURCE=1 -D_GNU_SOURCE=1 -DHAVE_FORK=0 -DWASM_WASI'

# We need to add LDFLAGS ot CFLAGS because autoconf compiles(+links) to binary when checking stuff
export CFLAGS="${CFLAGS_CONFIG} ${CFLAGS_WASI} ${CFLAGS_SQLITE} ${CFLAGS_PHP} ${LDFLAGS_WASI}"
export LDFLAGS="${LDFLAGS_WASI}"

cd "${WASMLABS_CHECKOUT_PATH}"

logStatus "Generating configure script... "
./buildconf --force

export PHP_CONFIGURE=' --disable-libxml --disable-dom --without-iconv --without-openssl --disable-simplexml --disable-xml --disable-xmlreader --disable-xmlwriter --without-pear --disable-phar --disable-opcache --disable-zend-signals --without-pcre-jit --with-sqlite3 --enable-pdo --with-pdo-sqlite'

logStatus "Configuring build with '${PHP_CONFIGURE}'... "
./configure --host=wasm32-wasi host_alias=wasm32-musl-wasi --target=wasm32-wasi target_alias=wasm32-musl-wasi ${PHP_CONFIGURE} || exit 1

logStatus "Building php-cgi... "
# By exporting WASMLABS_SKIP_WASM_OPT envvar during the build, the
# wasm-opt wrapper in the wasm-base image will be a dummy wrapper that
# is effectively a NOP.
#
# This is due to https://github.com/llvm/llvm-project/issues/55781, so
# that we get to choose which optimization passes are executed after
# the artifacts have been built.
export WASMLABS_SKIP_WASM_OPT=1
make cgi || exit 1
unset WASMLABS_SKIP_WASM_OPT

logStatus "Preparing artifacts... "
mkdir -p ${WASMLABS_OUTPUT}/bin 2>/dev/null || exit 1

logStatus "Running wasm-opt with the asyncify pass on php-cgi..."
wasm-opt -O2 --asyncify --pass-arg=asyncify-ignore-imports -o ${WASMLABS_OUTPUT}/bin/php-cgi.wasm sapi/cgi/php-cgi || exit 1

logStatus "DONE. Artifacts in ${WASMLABS_OUTPUT}"
