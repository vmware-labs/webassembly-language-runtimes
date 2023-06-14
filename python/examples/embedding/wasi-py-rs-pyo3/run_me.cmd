@echo off

rustup target list | find "installed" | find "wasm32-wasi"
if errorlevel 1 (
    echo "Please run 'rustup target add wasm32-wasi' first"
    exit /b
)

setlocal
set PYO3_NO_PYTHON=1
cargo build --target=wasm32-wasi
endlocal
echo on

@echo
@echo  [35mCalling a WASI Command which embeds Python (adding a custom module implemented in Rust) and calls a custom function: [0m
wasmtime ^
    --mapdir /usr::target/wasm32-wasi/wasi-deps/usr ^
    target/wasm32-wasi/debug/py-func-caller.wasm

@echo
@echo  [35mCalling a WASI Command which wraps the Python binary (adding a custom module implemented in Rust): [0m
wasmtime ^
    --mapdir /usr::target/wasm32-wasi/wasi-deps/usr ^
    target/wasm32-wasi/debug/py-wrapper.wasm ^
    -- -c ^
    "import person as p; pp = [p.Person('a', 1), p.Person('b', 2)]; pp[0].add_tag('X'); print('Filtered: ', p.filter_by_tag(pp, 'X'))"
