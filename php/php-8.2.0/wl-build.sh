#!/bin/bash
logStatus "Building libs 'php/php-8.2.0'"

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

logStatus "CFLAGS="${CFLAGS}
logStatus "LDFLAGS="${LDFLAGS}


cd "${WASMLABS_SOURCE_PATH}"

if [[ -z "$WASMLABS_SKIP_CONFIGURE" ]]; then
    logStatus "Generating configure script... "
    ./buildconf --force || exit 1

    export PHP_CONFIGURE='--without-iconv --without-openssl --without-pear --disable-phar --disable-opcache --disable-zend-signals --without-pcre-jit --with-sqlite3 --enable-pdo --with-pdo-sqlite --disable-fiber-asm'

    if [[ -v WASMLABS_RUNTIME ]]
    then
        export PHP_CONFIGURE="--with-wasm-runtime=${WASMLABS_RUNTIME} ${PHP_CONFIGURE}"
    fi

    logStatus "Configuring build with '${PHP_CONFIGURE}'... "
    ./configure --host=wasm32-wasi host_alias=wasm32-musl-wasi --target=wasm32-wasi target_alias=wasm32-musl-wasi ${PHP_CONFIGURE} || exit 1
else
    logStatus "Skipping configure..."
fi

export MAKE_TARGETS='cgi'
if [[ "${WASMLABS_RUNTIME}" == "wasmedge" ]]
then
    export MAKE_TARGETS="${MAKE_TARGETS} cli"
fi

logStatus "Building '${MAKE_TARGETS}'... "
# By exporting WASMLABS_SKIP_WASM_OPT envvar during the build, the
# wasm-opt wrapper in the wasm-base image will be a dummy wrapper that
# is effectively a NOP.
#
# This is due to https://github.com/llvm/llvm-project/issues/55781, so
# that we get to choose which optimization passes are executed after
# the artifacts have been built.
export WASMLABS_SKIP_WASM_OPT=1
make -j ${MAKE_TARGETS} || exit 1
unset WASMLABS_SKIP_WASM_OPT

logStatus "Preparing artifacts... "
mkdir -p ${WASMLABS_OUTPUT}/bin 2>/dev/null || exit 1

logStatus "Running wasm-opt with the asyncify pass on php-cgi.."
wasm-opt -O2 --asyncify --pass-arg=asyncify-ignore-imports -o ${WASMLABS_OUTPUT}/bin/php-cgi${WASMLABS_RUNTIME:+-$WASMLABS_RUNTIME}.wasm sapi/cgi/php-cgi || exit 1

if [[ "${WASMLABS_RUNTIME}" == "wasmedge" ]]
then
    logStatus "Running wasm-opt with the asyncify pass on php.."
    wasm-opt -O2 --asyncify --pass-arg=asyncify-ignore-imports -o ${WASMLABS_OUTPUT}/bin/php${WASMLABS_RUNTIME:+-$WASMLABS_RUNTIME}.wasm sapi/cli/php || exit 1
fi

logStatus "DONE. Artifacts in ${WASMLABS_OUTPUT}"
