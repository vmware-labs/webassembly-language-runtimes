@echo off

rustup target list | find "installed" | find "wasm32-wasi"
if errorlevel 1 (
    echo "Please run 'rustup target add wasm32-wasi' first"
    exit /b
)

python3 --version >nul 2>&1 || (
    echo "python3 is required by 'rust-cpython'. Install it and ensure its on PATH"
    exit /b
)

setlocal
set PYO3_NO_PYTHON=1
cargo build --target=wasm32-wasi
endlocal
echo on

@echo
@echo  [35mCalling a WASI Command which demonstrates usage of the 'cpython' crate: [0m
wasmtime ^
    --mapdir /usr::target/wasm32-wasi/wasi-deps/usr ^
    target/wasm32-wasi/debug/wasi-py-rs-cpython.wasm
