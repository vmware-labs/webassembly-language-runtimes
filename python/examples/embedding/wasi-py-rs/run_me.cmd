@echo off

rustup target list | find "installed" | find "wasm32-wasi"
if errorlevel 1 (
    echo "Please run 'rustup target add wasm32-wasi' first"
    exit /b
)

setlocal
set PYO3_NO_PYTHON=1
cargo build --target=wasm32-wasi
wasmtime ^
    --mapdir /usr::target/wasm32-wasi/wasi-deps/usr ^
    target/wasm32-wasi/debug/wasi-command-rs.wasm
endlocal
