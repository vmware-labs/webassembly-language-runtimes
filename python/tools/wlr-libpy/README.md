# About

Helper crate for linking to the pre-built libpython from Webassembly Language Runtimes.

# Features

## py311 and py312

These features can be combined with the `build` feature below to chose which version of the static library gets downloaded.

The default is `py311` so if you want to use CPython 3.11, you don't need to specify a thing.

Otherwise you should use something like `default-features=false, features=["build", "py312"]` in your Cargo.toml

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

 - [wasi-sysroot-20.0.tar.gz](https://github.com/WebAssembly/wasi-sdk/releases/download/wasi-sdk-20/wasi-sysroot-20.0.tar.gz) provides some POSIX emulations
 - [libclang_rt.builtins-wasm32-wasi-20.0.tar.gz](https://github.com/WebAssembly/wasi-sdk/releases/download/wasi-sdk-20/libclang_rt.builtins-wasm32-wasi-20.0.tar.gz) provides some built-ins which may be required by code built via clang (like the `libpython` that we publish)
 - [libpython-3.11.4-wasi-sdk-20.0.tar](https://github.com/vmware-labs/webassembly-language-runtimes/releases/download/python%2F3.11.4%2B20230714-11be424/libpython-3.11.4-wasi-sdk-20.0.tar.gz) provides our pre-built version of `libpython3.11` (default feature)
 - [libpython-3.12.0-wasi-sdk-20.0.tar](https://github.com/vmware-labs/webassembly-language-runtimes/releases/download/python%2F3.12.0%2B20231211-040d5a6/libpython-3.12.0-wasi-sdk-20.0.tar.gz) provides our pre-built version of `libpython3.12` (`default-features=false, features=["py312"]`)

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