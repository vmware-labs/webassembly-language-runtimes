# About

Example that embeds CPython via libpython into a Wasm module written in Rust.

Uses the [cpython](http://dgrunwald.github.io/rust-cpython/doc/cpython/index.html) crate.

Take a look at the similar example in [../wasi-py-rs-pyo3](../wasi-py-rs-pyo3) to see how this works with the [pyo3](https://pyo3.rs/v0.19.0/) crate.

# How to run

Make sure you have `cargo` with the `wasm32-wasi` target. For running we use `wasmtime`, but the module will work with any WASI-compliant runtime.

Just run `./run_me.sh` in the current folder. You will see something like this

```
wlr/python/examples/embedding/wasi-py-rs-cpython $$ ./run_me.sh
   Compiling cpython v0.7.1
      ...
    Finished dev [unoptimized + debuginfo] target(s) in 26.43s

Calling a WASI Command which demonstrates usage of the 'cpython' crate :
+ wasmtime --mapdir /usr::target/wasm32-wasi/wasi-deps/usr target/wasm32-wasi/debug/wasi-py-rs-cpython.wasm
Hello! I'm Python 3.11.3 (tags/v3.11.3:f3909b8, Apr 28 2023, 09:45:45) [Clang 15.0.7 ], running on wasi/posix
+ set +x
```

# About the code

The code is adapted from [cpython crate's docs](https://github.com/dgrunwald/rust-cpython#usage).

# Build and dependencies

To get a wasm32-wasi version of `libpython` we provide a helper crate [wlr-libpy](../../../tools/wlr-libpy/), which can be used to fetch the pre-built library that this repository publishes.

The build and dependencies process is described in detail with the similar example in [../wasi-py-rs-pyo3](../wasi-py-rs-pyo3).
