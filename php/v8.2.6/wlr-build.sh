#!/usr/bin/env bash
logStatus "Building 'php/php-8.2.6'"

if [[ ! -v WLR_ENV ]]
then
    echo "WLR build environment is not set"
    exit 1
fi

# Optimization is disabled during build as we might do some instrumentation at the end
export CFLAGS_CONFIG="-O0"

########## Setup the wasi related flags #############
export CFLAGS_WASI="--sysroot=${WASI_SYSROOT} -D_WASI_EMULATED_GETPID -D_WASI_EMULATED_SIGNAL -D_WASI_EMULATED_PROCESS_CLOCKS"
export LDFLAGS_WASI="--sysroot=${WASI_SYSROOT} -lwasi-emulated-getpid -lwasi-emulated-signal -lwasi-emulated-process-clocks"

########## Setup the flags for php #############
export CFLAGS_PHP='-D_POSIX_SOURCE=1 -D_GNU_SOURCE=1 -DHAVE_FORK=0 -DWASM_WASI'

if [[ "${WLR_BUILD_FLAVOR}" != *"slim"* ]]
then
    CFLAGS_PHP+=' -DPNG_USER_CONFIG'
fi

export LDFLAGS_WARNINGS='-Wno-unused-command-line-argument -Werror=implicit-function-declaration -Wno-incompatible-function-pointer-types'

# We need to add LDFLAGS ot CFLAGS because autoconf compiles(+links) to binary when checking stuff
export LDFLAGS="${LDFLAGS_WASI} ${LDFLAGS_DEPENDENCIES} ${LDFLAGS_WARNINGS}"
export CFLAGS="${CFLAGS_CONFIG} ${CFLAGS_WASI} ${CFLAGS_DEPENDENCIES} ${CFLAGS_PHP} ${LDFLAGS}"

logStatus "CFLAGS="${CFLAGS}
logStatus "LDFLAGS="${LDFLAGS}


cd "${WLR_SOURCE_PATH}"

if [[ -z "$WLR_SKIP_CONFIGURE" ]]; then
    logStatus "Generating configure script..."
    ./buildconf --force || exit 1

    export PHP_CONFIGURE=''
    PHP_CONFIGURE+=' --without-iconv'
    PHP_CONFIGURE+=' --without-openssl'
    PHP_CONFIGURE+=' --without-pear'
    PHP_CONFIGURE+=' --disable-phar'
    PHP_CONFIGURE+=' --disable-opcache'
    PHP_CONFIGURE+=' --disable-zend-signals'
    PHP_CONFIGURE+=' --without-pcre-jit'
    PHP_CONFIGURE+=' --disable-fiber-asm'

    if [[ "${WLR_BUILD_FLAVOR}" == *"slim"* ]]
    then
        PHP_CONFIGURE+=' --disable-all'
        PHP_CONFIGURE+=' --without-libxml'
        PHP_CONFIGURE+=' --disable-dom'
        PHP_CONFIGURE+=' --disable-simplexml'
        PHP_CONFIGURE+=' --disable-xml'
        PHP_CONFIGURE+=' --disable-xmlreader'
        PHP_CONFIGURE+=' --disable-xmlwriter'
        PHP_CONFIGURE+=' --without-sqlite3'
        PHP_CONFIGURE+=' --disable-pdo'
        PHP_CONFIGURE+=' --without-pdo-sqlite'
    else
        PHP_CONFIGURE+=' --with-sqlite3'
        PHP_CONFIGURE+=' --enable-pdo'
        PHP_CONFIGURE+=' --with-pdo-sqlite'
        PHP_CONFIGURE+=' --enable-mbstring'
        PHP_CONFIGURE+=' --enable-gd'
        PHP_CONFIGURE+=' --with-jpeg'
    fi

    if [[ "${WLR_BUILD_FLAVOR}" == *"wasmedge"* ]]
    then
        PHP_CONFIGURE+=' --enable-mysqlnd'
        PHP_CONFIGURE+=' --with-pdo-mysql'
        PHP_CONFIGURE+=' --with-mysqli'

        PHP_CONFIGURE="--with-wasm-runtime=wasmedge ${PHP_CONFIGURE}"
    fi

    logStatus "Configuring build with '${PHP_CONFIGURE}'... "
    ./configure \
        --config-cache \
        --host=wasm32-wasi \
        host_alias=wasm32-musl-wasi \
        --target=wasm32-wasi \
        target_alias=wasm32-musl-wasi \
        ${PHP_CONFIGURE} || exit 1
else
    logStatus "Skipping configure..."
fi

export MAKE_TARGETS='cgi'
if [[ "${WLR_BUILD_FLAVOR}" == *"wasmedge"* ]]
then
    export MAKE_TARGETS="${MAKE_TARGETS} cli"
fi

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

WASM_OPT_ARGS=-O3
# WASM_OPT_ARGS="${WASM_OPT_ARGS} --asyncify --pass-arg=asyncify-ignore-imports"

PHP_CGI_TARGET="${WLR_OUTPUT}/bin/php-cgi-${WLR_PACKAGE_VERSION}${WLR_BUILD_FLAVOR:+-$WLR_BUILD_FLAVOR}.wasm"
logStatus "Running wasm-opt with '${WASM_OPT_ARGS}' for ${PHP_CGI_TARGET}..."
wasm-opt ${WASM_OPT_ARGS} -o "${PHP_CGI_TARGET}" sapi/cgi/php-cgi || exit 1

if [[ "${WLR_BUILD_FLAVOR}" == *"wasmedge"* ]]
then
    PHP_CLI_TARGET="${WLR_OUTPUT}/bin/php-${WLR_PACKAGE_VERSION}${WLR_BUILD_FLAVOR:+-$WLR_BUILD_FLAVOR}.wasm"
    logStatus "Running wasm-opt with '${WASM_OPT_ARGS}' for ${PHP_CLI_TARGET}..."
    wasm-opt ${WASM_OPT_ARGS} -o ${PHP_CLI_TARGET} sapi/cli/php || exit 1
fi

cp -v ${WLR_OUTPUT}/bin/php-* ${WLR_OUTPUT_BASE}

logStatus "DONE. Artifacts in ${WLR_OUTPUT}"
