#!/bin/bash

if [[ ! -v WASMLABS_ENV ]]
then
    echo "Wasmlabs environment is not set"
    exit 1
fi

# export CFLAGS_CONFIG="-O3 -g"
export CFLAGS_CONFIG="-O2"

########## Setup the wasi related flags #############
export CFLAGS_WASI="--sysroot=${WASI_SYSROOT} -D_WASI_EMULATED_GETPID -D_WASI_EMULATED_SIGNAL -D_WASI_EMULATED_PROCESS_CLOCKS"
export LDFLAGS_WASI="--sysroot=${WASI_SYSROOT} -lwasi-emulated-getpid -lwasi-emulated-signal -lwasi-emulated-process-clocks"

########## Setup the libsql related flags #############
export CFLAGS_SQLITE='-DSQLITE_OMIT_LOAD_EXTENSION=1'
export LDFLAGS_SQLITE='-lsqlite3'

########## Setup the flags for php #############
export CFLAGS_PHP='-D_POSIX_SOURCE=1 -D_GNU_SOURCE=1 -DHAVE_FORK=0 -DWASM_WASI'

# We need to add LDFLAGS ot CFLAGS because autoconf compiles(+links) to binary when checking stuff
export LDFLAGS="${LDFLAGS_WASI} ${LDFLAGS_DEPENDENCIES} ${LDFLAGS_SQLITE}"
export CFLAGS="${CFLAGS_CONFIG} ${CFLAGS_WASI} ${CFLAGS_SQLITE} ${CFLAGS_DEPENDENCIES} ${CFLAGS_PHP} ${LDFLAGS}"

cd "${WASMLABS_CHECKOUT_PATH}"

logStatus "Generating configure script... "
./buildconf --force || exit 1

export PHP_CONFIGURE=' --without-libxml --disable-dom --without-iconv --without-openssl --disable-simplexml --disable-xml --disable-xmlreader --disable-xmlwriter --without-pear --disable-phar --disable-opcache --disable-zend-signals --without-pcre-jit --with-sqlite3 --enable-pdo --with-pdo-sqlite --disable-fiber-asm'

logStatus "Configuring build with '${PHP_CONFIGURE}'... "
./configure --host=wasm32-wasi host_alias=wasm32-musl-wasi --target=wasm32-wasi target_alias=wasm32-musl-wasi ${PHP_CONFIGURE} || exit 1

logStatus "Building php-cgi... "
make cgi  || exit 1

logStatus "Preparing artifacts... "
mkdir -p ${WASMLABS_OUTPUT}/bin 2>/dev/null || exit 1

wasm-opt -O2 --asyncify --pass-arg=asyncify-ignore-imports -o ${WASMLABS_OUTPUT}/bin/php-cgi.wasm sapi/cgi/php-cgi || exit 1

logStatus "DONE. Artifacts in ${WASMLABS_OUTPUT}"
