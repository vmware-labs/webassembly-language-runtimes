#!/bin/bash

if [[ ! -v WASMLABS_ENV ]]
then
    echo "Wasmlabs environment is not set"
    exit 1
fi

# export CFLAGS_CONFIG="-O3 -g"
export CFLAGS_CONFIG="-g -ggdb3 -gembed-source -gdwarf -gcodeview"

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

if [[ -v WASMLABS_RUNTIME ]]
then
    export PHP_CONFIGURE=" --with-wasm-runtime=${WASMLABS_RUNTIME} ${PHP_CONFIGURE}"
fi

logStatus "Configuring build with '${PHP_CONFIGURE}'... "
# ./configure --host=wasm32-wasi host_alias=wasm32-musl-wasi --target=wasm32-wasi target_alias=wasm32-musl-wasi ${PHP_CONFIGURE} || exit 1

export MAKE_TARGETS='cgi'
if [[ "${WASMLABS_RUNTIME}" == "wasmedge" ]]
then
    export MAKE_TARGETS="${MAKE_TARGETS} cli"
fi

logStatus "Building '${MAKE_TARGETS}'... "
make -j ${MAKE_TARGETS} || exit 1

logStatus "Preparing artifacts... "
mkdir -p ${WASMLABS_OUTPUT}/bin 2>/dev/null || exit 1

logStatus "Optimizing... "
logStatus "> wasm-opt build-output/php/php-8.2.0/bin/php-cgi -O --asyncify -g --pass-arg=asyncify-ignore-imports -o ${WASMLABS_OUTPUT}/bin/php-cgi${WASMLABS_RUNTIME:+-$WASMLABS_RUNTIME}"
/home/alexandrov/work/localbld/binaryen/bin/wasm-opt sapi/cgi/php-cgi -O --asyncify -g --pass-arg=asyncify-ignore-imports -o ${WASMLABS_OUTPUT}/bin/php-cgi${WASMLABS_RUNTIME:+-$WASMLABS_RUNTIME} || exit 1

# cp sapi/cgi/php-cgi ${WASMLABS_OUTPUT}/bin/php-cgi${WASMLABS_RUNTIME:+-$WASMLABS_RUNTIME} || exit 1

if [[ "${WASMLABS_RUNTIME}" == "wasmedge" ]]
then
    cp sapi/cli/php ${WASMLABS_OUTPUT}/bin/php${WASMLABS_RUNTIME:+-$WASMLABS_RUNTIME} || exit 1
fi

logStatus "DONE. Artifacts in ${WASMLABS_OUTPUT}"
