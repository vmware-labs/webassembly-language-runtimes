#!/usr/bin/env bash

if [[ "$1" == "--local" ]]; then
    if [[ ! -v WASI_SDK_PATH ]]; then
        echo "WASI_SDK_PATH is required. Download wasi-sdk and set the variable"
        exit 1
    fi

    check() {
        if ! command -v $1 &>/dev/null; then
            echo "$1 is required. Install it and ensure its on PATH"
            exit 1
        fi
    }

    check cmake
    check curl
    check tar
    check gzip

    check npm
    check node
else
    WASI_SDK_VERSION=20.0
    WASI_CMD="docker run -t -v$(pwd):/workdir -w /workdir ghcr.io/vmware-labs/wasmlabs/wasi-builder:${WASI_SDK_VERSION}"
    NODE_CMD="docker run -t -v$(pwd):/workdir -w /workdir node:16.20"
fi

fail() {
    echo "Command failed"
    exit 1
}

echo -e "\n\n------------------------------------" | tee -a build.log
echo "$(date --iso-8601=ns) Running '$0'" | tee -a build.log

echo -e "$(date --iso-8601=ns) | Building wasm-wrapper-c ${WASI_CMD:+with '$WASI_CMD' }(logs silenced to build.log)..."  | tee -a build.log
${WASI_CMD} bash -c "cd wasm-wrapper-c; ./build-wasm.sh --clean >>../build.log 2>&1" || fail

echo -e "$(date --iso-8601=ns) | Building se2-mock-runtime ${NODE_CMD:+with '$NODE_CMD' }(logs silenced to build.log)..."  | tee -a build.log
${NODE_CMD} bash -c "cd se2-mock-runtime; npm i >>../build.log 2>&1" || fail

echo -e "$(date --iso-8601=ns) | Running se2-mock-runtime ${NODE_CMD:+with '$NODE_CMD' }..." | tee -a build.log
${NODE_CMD} bash -c "cd se2-mock-runtime; set -x; \
    node --experimental-wasi-unstable-preview1 . \
        --wrapper ../wasm-wrapper-c/target/wasm32-wasi/wasm-wrapper-c.wasm \
        --plugin-root ../py-plugin/ \
        --python-usr-root ../wasm-wrapper-c/target/wasm32-wasi/deps/"
