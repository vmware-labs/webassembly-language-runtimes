#!/usr/bin/env bash

if ! (rustup target list | grep "installed" | grep -q "wasm32-wasi"); then
    echo "Please run 'rustup target add wasm32-wasi' first"
    exit 1
fi

set -e

PYO3_NO_PYTHON=1 cargo build --target=wasm32-wasi
wasmtime \
    --mapdir /usr::target/wasm32-wasi/wasi-deps/usr \
    target/wasm32-wasi/debug/wasi-command-rs.wasm
