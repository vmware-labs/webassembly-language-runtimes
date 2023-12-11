#!/usr/bin/env bash

if [[ ! -v WLR_ENV ]]
then
    echo "WLR build environment is not set"
    exit 1
fi

pyenv local ${WLR_PY_BUILDER_VERSION}

cd "${WLR_SOURCE_PATH}"

if [[ "${WLR_BUILD_FLAVOR}" == *"aio"* ]]
then
    source ${WLR_REPO_ROOT}/scripts/build-helpers/wlr_wasi_vfs.sh
    export LDFLAGS="$(wlr_wasi_vfs_get_link_flags) ${LDFLAGS}"
fi

source ${WLR_REPO_ROOT}/scripts/build-helpers/wlr_pkg_config.sh

export CFLAGS_CONFIG="-O0"


# This fails with upgraded clang for wasi-sdk19 and later. Disabled on cpython main.
#
# PyModule_AddIntMacro(module, CLOCK_MONOTONIC) and the like cause this.
# In all POSIX variants CLOCK_MONOTONIC is a numeric constant, so python imports it as int macro
# However, in wasi-libc clockid_t is defined as a pointer to struct __clockid.

export CFLAGS_CONFIG="${CFLAGS_CONFIG} -Wno-int-conversion"

export CFLAGS="${CFLAGS_CONFIG} ${CFLAGS_DEPENDENCIES} ${CFLAGS}"
export LDFLAGS="${LDFLAGS_DEPENDENCIES} ${LDFLAGS}"

export PYTHON_WASM_CONFIGURE="--with-build-python=python3"

if [[ "${WLR_BUILD_FLAVOR}" == *"wasmedge"* ]]
then
    if [[ ! -v WABT_ROOT ]]
    then
        echo "WABT_ROOT is needed to patch imports for wasmedge"
        exit 1
    fi
fi

# By exporting WLR_SKIP_WASM_OPT envvar during the build, the
# wasm-opt wrapper in the wasm-base image will be a dummy wrapper that
# is effectively a NOP.
#
# This is due to https://github.com/llvm/llvm-project/issues/55781, so
# that we get to choose which optimization passes are executed after
# the artifacts have been built.
export WLR_SKIP_WASM_OPT=1

if [[ -z "$WLR_SKIP_CONFIGURE" ]]; then
    logStatus "Configuring build with '${PYTHON_WASM_CONFIGURE}'... "
    CONFIG_SITE=./Tools/wasm/config.site-wasm32-wasi ./configure -C --host=wasm32-wasi --build=$(./config.guess) ${PYTHON_WASM_CONFIGURE} || exit 1
else
    logStatus "Skipping configure..."
fi

export MAKE_TARGETS='python.wasm wasm_stdlib'

logStatus "Building '${MAKE_TARGETS}'... "
make -j ${MAKE_TARGETS} || exit 1

unset WLR_SKIP_WASM_OPT

if [[ "${WLR_BUILD_FLAVOR}" == *"aio"* ]]
then
    logStatus "Packing with wasi-vfs"
    wlr_wasi_vfs_cli pack python.wasm --mapdir /usr::$PWD/usr -o python.wasm || exit 1
fi

logStatus "Optimizing python binary..."
wasm-opt -O2 -o python-optimized.wasm python.wasm || exit 1

if [[ "${WLR_BUILD_FLAVOR}" == *"wasmedge"* ]]
then
    logStatus "Patching python binary for wasmedge..."
    ${WLR_REPO_ROOT}/scripts/build-helpers/patch_wasmedge_wat_sock_accept.sh python-optimized.wasm || exit 1
fi

logStatus "Preparing artifacts... "
TARGET_PYTHON_BINARY=bin/python-${WLR_PACKAGE_VERSION}.wasm

mkdir -p ${WLR_OUTPUT}/bin 2>/dev/null || exit 1

if [[ "${WLR_BUILD_FLAVOR}" == *"aio"* ]]
then
    cp -v python-optimized.wasm ${WLR_OUTPUT}/${TARGET_PYTHON_BINARY} || exit 1
else
    mkdir -p ${WLR_OUTPUT}/usr 2>/dev/null || exit 1
    cp -v python-optimized.wasm ${WLR_OUTPUT}/${TARGET_PYTHON_BINARY} || exit 1
    cp -TRv usr ${WLR_OUTPUT}/usr || exit 1
fi

if [[ "${WLR_BUILD_FLAVOR}" != *"aio"* && "${WLR_BUILD_FLAVOR}" != *"wasmedge"* ]]
then

    logStatus "Install includes..."
    make inclinstall \
        prefix=${WLR_OUTPUT} \
        libdir=${WLR_OUTPUT}/lib/wasm32-wasi \
        pkgconfigdir=${WLR_OUTPUT}/lib/wasm32-wasi/pkgconfig || exit 1

    logStatus "Create libpython3.12-aio.a"
(${AR} -M <<EOF
create libpython3.12-aio.a
addlib libpython3.12.a
addlib ${WLR_DEPS_ROOT}/build-output/lib/wasm32-wasi/libz.a
addlib ${WLR_DEPS_ROOT}/build-output/lib/wasm32-wasi/libbz2.a
addlib ${WLR_DEPS_ROOT}/build-output/lib/wasm32-wasi/libsqlite3.a
addlib ${WLR_DEPS_ROOT}/build-output/lib/wasm32-wasi/libuuid.a
addlib Modules/expat/libexpat.a
addlib Modules/_decimal/libmpdec/libmpdec.a
addlib Modules/_hacl/libHacl_Hash_SHA2.a
save
end
EOF
) || echo exit 1

    mkdir -p ${WLR_OUTPUT}/lib/wasm32-wasi/ 2>/dev/null || exit 1
    cp -v libpython3.12-aio.a ${WLR_OUTPUT}/lib/wasm32-wasi/libpython3.12.a || exit 1

    logStatus "Generating pkg-config file for libpython3.12.a"
    DESCRIPTION="libpython3.12 allows embedding the CPython interpreter"
    EXTRA_LINK_FLAGS="-lpython3.12 -Wl,-z,stack-size=524288 -Wl,--stack-first -Wl,--initial-memory=10485760 -lwasi-emulated-getpid -lwasi-emulated-signal -lwasi-emulated-process-clocks"

    PC_INCLUDE_SUBDIR=python3.12 wlr_pkg_config_create_pc_file "libpython3.12" "${WLR_PACKAGE_VERSION}" "${DESCRIPTION}" "${EXTRA_LINK_FLAGS}" || exit 1

    WLR_PACKAGE_EXTRA_DIRS=usr wlr_package_lib || exit 1
    WLR_PACKAGE_LIST="${TARGET_PYTHON_BINARY} usr" wlr_package || exit 1

elif [[ "${WLR_BUILD_FLAVOR}" == *"aio"* ]]; then
    # skip 'aio' in the name
    FLAVOR_SUFFIX=$(echo ${WLR_BUILD_FLAVOR} | sed 's/-\?aio//g')
    PUBLISHED_PYTHON_BINARY=python-${WLR_PACKAGE_VERSION}${FLAVOR_SUFFIX}.wasm
    cp -v ${WLR_OUTPUT}/${TARGET_PYTHON_BINARY} ${WLR_OUTPUT_BASE}/${PUBLISHED_PYTHON_BINARY} || exit 1

else
    WLR_PACKAGE_LIST="${TARGET_PYTHON_BINARY} usr" wlr_package || exit 1
fi

logStatus "DONE. Artifacts in ${WLR_OUTPUT}"
