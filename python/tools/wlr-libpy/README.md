# About

Helper crate for linking to the pre-built libpython from Webassembly Language Runtimes.

# Features

## build

This feature is intended for usage in `build.rs` scripts. It will download all needed pre-built static libraries for `wasm32-wasi` and configure the linker to use them.

To use this feature add this to your Cargo.toml

```toml
[build-dependencies]
wlr-libpy = { git = "https://github.com/vmware-labs/webassembly-language-runtimes.git", features = ["build"] }
```

Then, in the `build.rs` file of your project you only need to call `configure_static_libs().unwrap().emit_link_flags()` like this:

```rs
fn main() {
    // ...
    use wlr_libpy::bld_cfg::configure_static_libs;
    configure_static_libs().unwrap().emit_link_flags();
    // ...
}
```

Here is a list of the pre-built `wasm32-wasi` static libraries:

 - [wasi-sysroot-19.0.tar.gz](https://github.com/WebAssembly/wasi-sdk/releases/download/wasi-sdk-19/wasi-sysroot-19.0.tar.gz) provides some POSIX emulations
 - [libclang_rt.builtins-wasm32-wasi-19.0.tar.gz](https://github.com/WebAssembly/wasi-sdk/releases/download/wasi-sdk-19/libclang_rt.builtins-wasm32-wasi-19.0.tar.gz) provides some built-ins which may be required by code built via clang (like the `libpython` that we publish)
 - [libpython-3.11.3-wasi-sdk-19.0.tar](https://github.com/vmware-labs/webassembly-language-runtimes/releases/download/python%2F3.11.3%2B20230428-7d1b259/libpython-3.11.3-wasi-sdk-19.0.tar.gz) provides our pre-built version of `libpython`

## py_main

This feature is a helper, if you want to wrap the Python interpreter and call it's `Py_Main` method. This is useful when you want to add some python modules defined in Rust as builtin modules (e.g. via  `PyImport_AppendInittab`) and then call on the standard Python code. A typical use case would be whenever you want to provide Python bindings for Wasm host functions.

To use this feature add this to your Cargo.toml

```toml
[dependencies]
...
wlr-libpy = { git = "https://github.com/vmware-labs/webassembly-language-runtimes.git", features = ["py_main"] }
```

Then to call on the `Py_Main` method just do this:

```rs
fn main() {
    use wlr_libpy::py_main::py_main;
    py_main(std::env::args().collect());
}
```