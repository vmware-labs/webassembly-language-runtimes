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

echo -e "\n" | tee -a build.log
echo -e "Building wasm-wrapper-c (logs silenced to build.log)..." | ts "%Y-%m-%dT%H:%M:%S" | tee -a build.log
(
    cd wasm-wrapper-c
    ./build-wasm.sh --clean
) 2>&1 | ts "%Y-%m-%dT%H:%M:%S" >>build.log

echo -e "\n" | tee -a build.log
echo -e "Building se2-mock-runtime (logs silenced to build.log)..." | ts "%Y-%m-%dT%H:%M:%S" | tee -a build.log
(
    cd se2-mock-runtime
    npm i
) 2>&1 | ts "%Y-%m-%dT%H:%M:%S" >>build.log

echo -e "\n" | tee -a build.log
echo -e "Running se2-mock-runtime..." | ts "%Y-%m-%dT%H:%M:%S" | tee -a build.log
(
    cd se2-mock-runtime
    set -x
    node --experimental-wasi-unstable-preview1 . \
        --wrapper ../wasm-wrapper-c/target/wasm32-wasi/wasm-wrapper-c.wasm \
        --plugin-root ../py-plugin/ \
        --python-usr-root ../wasm-wrapper-c/target/wasm32-wasi/deps/
) 2>&1 | ts "%Y-%m-%dT%H:%M:%S" | tee -a build.log
