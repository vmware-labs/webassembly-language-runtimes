# About

A simple WASI Command (exports `_start`) Wasm module, written in Rust.

Embeds CPython via libpython and demonstrates interaction with simple Python code via [pyo3](https://pyo3.rs/v0.19.0/).

# How to run

Make sure you have `cargo` with the `wasm32-wasi` target. For running we use `wasmtime`, but the module will work with any WASI-compliant runtime.

Just run `./run_me.sh` in the current folder. You will see something like this

```
wlr/python/examples/embedding/wasi-command-rs $$ ./run_me.sh
   Compiling pyo3-build-config v0.18.3
   ...
    Finished dev [unoptimized + debuginfo] target(s) in 26.43s
Hello from Python(libpython3.11.a) in Wasm(Rust). args= ('a1', 'a2', 3, 4)
```

# About the code

This example is really simple and adopted from `pyo3`'s documentation on [calling Python from Rust](https://pyo3.rs/v0.18.3/python_from_rust).

Its main purpose is to show how to configure the build and dependencies.

# Build and dependencies

For pyo3 to work the final binary needs to link to `libpython3.11.a`. The WLR project provides a pre-build `libpython` static library, which depends on `wasi-sdk`. To setup the build properly you will need to provide several static libs and configure the linker to use them properly.

The build uses pre-built `wasm32-wasi` static libs, based on [wasi-sdk](https://github.com/WebAssembly/wasi-sdk). There is custom code in [build.rs](./build.rs), which downloads them and configures the linker to properly use them.

 - [wasi-sysroot-19.0.tar.gz](https://github.com/WebAssembly/wasi-sdk/releases/download/wasi-sdk-19/wasi-sysroot-19.0.tar.gz) provides some POSIX emulations
 - [libclang_rt.builtins-wasm32-wasi-19.0.tar.gz](https://github.com/WebAssembly/wasi-sdk/releases/download/wasi-sdk-19/libclang_rt.builtins-wasm32-wasi-19.0.tar.gz) provides some built-ins which may be required by code built via clang (like the `libpython` that we publish)
 - [libpython-3.11.3-wasi-sdk-19.0.tar](https://github.com/vmware-labs/webassembly-language-runtimes/releases/download/python%2F3.11.3%2B20230428-7d1b259/libpython-3.11.3-wasi-sdk-19.0.tar.gz) provides our pre-built version of `libpython`
