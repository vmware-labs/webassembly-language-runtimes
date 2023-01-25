#!/usr/bin/env bash

if [[ ! -v WASMLABS_ENV ]]
then
    echo "Wasmlabs environment is not set"
    exit 1
fi

cd "${WASMLABS_SOURCE_PATH}"

# The PREFIX for builder-python MUST be outside of the current build as we need
# a distclean before building for WASI. The distclean will recursively remove
# all .so files in the current folder, so if builder-python is installed here
# it will be botched.
export BUILDER_PYTHON_PREFIX="$(realpath ${WASMLABS_SOURCE_PATH}/../builder-python)"

if ${BUILDER_PYTHON_PREFIX}/bin/python3.11 -c "import sys; import zipfile"
then
    logStatus "Using pre-built builder python (on host) from ${BUILDER_PYTHON_PREFIX}... "
else
    logStatus "Building builder python (on host) at ${BUILDER_PYTHON_PREFIX}... "
    mkdir ${BUILDER_PYTHON_PREFIX}
    make distclean
    ${WASMLABS_REPO_ROOT}/scripts/wl-hostbuild.sh ./configure --prefix ${BUILDER_PYTHON_PREFIX} || exit 1
    make install || exit 1
    make distclean || exit 1
fi

export CFLAGS_CONFIG="-O0"

export CFLAGS="${CFLAGS_CONFIG} ${CFLAGS_DEPENDENCIES} ${CFLAGS}"
export LDFLAGS="${LDFLAGS_DEPENDENCIES} ${LDFLAGS}"

export PYTHON_WASM_CONFIGURE="--with-build-python=${BUILDER_PYTHON_PREFIX}/bin/python3.11"

if [[ "${WASMLABS_RUNTIME}" == "wasmedge" ]]
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

logStatus "Optimizing python binary..."
wasm-opt -O2 -o python-optimized.wasm python.wasm || exit 1

if [[ "${WASMLABS_RUNTIME}" == "wasmedge" ]]
then
    logStatus "Patching python binary for wasmedge..."
    ${WASMLABS_REPO_ROOT}/scripts/build-helpers/patch_wasmedge_wat_sock_accept.sh python-optimized.wasm || exit 1
fi

logStatus "Preparing artifacts... "
TARGET_PYTHON_BINARY=${WASMLABS_OUTPUT}/bin/python${WASMLABS_RUNTIME:+-$WASMLABS_RUNTIME}.wasm

mkdir -p ${WASMLABS_OUTPUT}/bin 2>/dev/null || exit 1
mkdir -p ${WASMLABS_OUTPUT}/usr/local/lib 2>/dev/null || exit 1

cp python-optimized.wasm ${TARGET_PYTHON_BINARY} || exit 1
cp usr/local/lib/python311.zip ${WASMLABS_OUTPUT}/usr/local/lib/ || exit 1

logStatus "DONE. Artifacts in ${WASMLABS_OUTPUT}"
