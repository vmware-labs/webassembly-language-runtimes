#!/usr/bin/env bash

set -e

cargo build --target=wasm32-wasi
wasmtime \
    --mapdir /usr::target/wasm32-wasi/wasi-deps/usr \
    target/wasm32-wasi/debug/wasi-command-rs.wasm
