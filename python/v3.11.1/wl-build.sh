#!/usr/bin/env bash

if [[ ! -v WASMLABS_ENV ]]
then
    echo "Wasmlabs environment is not set"
    exit 1
fi

cd "${WASMLABS_SOURCE_PATH}"

if [[ "${WASMLABS_BUILD_FLAVOR}" == *"aio"* ]]
then
    source ${WASMLABS_REPO_ROOT}/scripts/build-helpers/wasi_vfs.sh
    wasi_vfs_setup_dependencies || exit 1
fi

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

if [[ "${WASMLABS_BUILD_FLAVOR}" == *"wasmedge"* ]]
then
    if [[ ! -v WABT_ROOT ]]
    then
        echo "WABT_ROOT is needed to patch imports for wasmedge"
        exit 1
    fi
fi

# By exporting WASMLABS_SKIP_WASM_OPT envvar during the build, the
# wasm-opt wrapper in the wasm-base image will be a dummy wrapper that
# is effectively a NOP.
#
# This is due to https://github.com/llvm/llvm-project/issues/55781, so
# that we get to choose which optimization passes are executed after
# the artifacts have been built.
export WASMLABS_SKIP_WASM_OPT=1

if [[ -z "$WASMLABS_SKIP_CONFIGURE" ]]; then
    logStatus "Configuring build with '${PYTHON_WASM_CONFIGURE}'... "
    CONFIG_SITE=./Tools/wasm/config.site-wasm32-wasi ./configure -C --host=wasm32-wasi --build=$(./config.guess) ${PYTHON_WASM_CONFIGURE} || exit 1
else
    logStatus "Skipping configure..."
fi

export MAKE_TARGETS='python.wasm wasm_stdlib'

logStatus "Building '${MAKE_TARGETS}'... "
make -j ${MAKE_TARGETS} || exit 1

unset WASMLABS_SKIP_WASM_OPT

if [[ "${WASMLABS_BUILD_FLAVOR}" == *"aio"* ]]
then
    logStatus "Packing with wasi-vfs"
    wasi_vfs_cli pack python.wasm --mapdir /usr::$PWD/usr -o python.wasm || exit 1
fi

logStatus "Optimizing python binary..."
wasm-opt -O2 -o python-optimized.wasm python.wasm || exit 1

if [[ "${WASMLABS_BUILD_FLAVOR}" == *"wasmedge"* ]]
then
    logStatus "Patching python binary for wasmedge..."
    ${WASMLABS_REPO_ROOT}/scripts/build-helpers/patch_wasmedge_wat_sock_accept.sh python-optimized.wasm || exit 1
fi

logStatus "Preparing artifacts... "
TARGET_PYTHON_BINARY=${WASMLABS_OUTPUT}/bin/python.wasm

mkdir -p ${WASMLABS_OUTPUT}/bin 2>/dev/null || exit 1

if [[ "${WASMLABS_BUILD_FLAVOR}" == *"aio"* ]]
then
    cp -v python-optimized.wasm ${TARGET_PYTHON_BINARY} || exit 1
else
    mkdir -p ${WASMLABS_OUTPUT}/usr 2>/dev/null || exit 1
    cp -v python-optimized.wasm ${TARGET_PYTHON_BINARY} || exit 1
    cp -TRv usr ${WASMLABS_OUTPUT}/usr || exit 1
fi

logStatus "Install includes"
make inclinstall \
    prefix=${WASMLABS_OUTPUT} \
    libdir=${WASMLABS_OUTPUT}/lib/wasm32-wasi \
    pkgconfigdir=${WASMLABS_OUTPUT}/lib/wasm32-wasi/pkgconfig || exit 1

logStatus "Create libpython3.11-aio.a"
(${AR} -M <<EOF
create libpython3.11-aio.a
addlib libpython3.11.a
addlib ${WASMLABS_REPO_ROOT}/build-output/zlib/v1.2.13/lib/libz.a
addlib ${WASMLABS_REPO_ROOT}/build-output/sqlite/version-3.39.2/lib/libsqlite3.a
addlib ${WASMLABS_REPO_ROOT}/build-output/uuid/libuuid-1.0.3/lib/libuuid.a
addlib Modules/expat/libexpat.a
addlib Modules/_decimal/libmpdec/libmpdec.a
save
end
EOF
) || echo exit 1

mkdir -p ${WASMLABS_OUTPUT}/lib/wasm32-wasi/ 2>/dev/null || exit 1
cp -v libpython3.11-aio.a ${WASMLABS_OUTPUT}/lib/wasm32-wasi/libpython3.11.a || exit 1

logStatus "DONE. Artifacts in ${WASMLABS_OUTPUT}"
