#!/usr/bin/env bash

if ! (rustup target list | grep "installed" | grep -q "wasm32-wasi"); then
    echo "Please run 'rustup target add wasm32-wasi' first"
    exit 1
fi

set -e

PYO3_NO_PYTHON=1 cargo build --target=wasm32-wasi
echo -e "\n\033[35mCalling a WASI Command which embeds Python (adding a custom module implemented in Rust) and calls a custom function:\033[0m"
set -x
wasmtime \
    --mapdir /usr::target/wasm32-wasi/wasi-deps/usr \
    target/wasm32-wasi/debug/py-func-caller.wasm
set +x

echo -e "\n\033[35mCalling a WASI Command which wraps the Python binary (adding a custom module implemented in Rust):\033[0m"
set -x
read -r -d '\0' SAMPLE_SCRIPT <<- EOF
import person as p
pp = [p.Person('a', 1), p.Person('b', 2)]
pp[0].add_tag('X')
print('Filtered: ', p.filter_by_tag(pp, 'X'))
\0
EOF

wasmtime \
    --mapdir /usr::target/wasm32-wasi/wasi-deps/usr \
    target/wasm32-wasi/debug/py-wrapper.wasm \
    -- -c "${SAMPLE_SCRIPT}"
set +x
