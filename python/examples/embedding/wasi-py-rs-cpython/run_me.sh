#!/usr/bin/env bash

if ! (rustup target list | grep "installed" | grep -q "wasm32-wasi"); then
    echo "Please run 'rustup target add wasm32-wasi' first"
    exit 1
fi

set -e

PYO3_NO_PYTHON=1 cargo build --target=wasm32-wasi
echo -e "\n\033[35mCalling a WASI Command which demonstrates usage of the 'cpython' crate :\033[0m"
set -x
wasmtime \
    --mapdir /usr::target/wasm32-wasi/wasi-deps/usr \
    target/wasm32-wasi/debug/wasi-py-rs-cpython.wasm
set +x
