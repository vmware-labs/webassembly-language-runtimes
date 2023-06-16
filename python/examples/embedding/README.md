This folder shows examples of embedding Python in a Wasm module.

For Rust, we show how you can use the [`wlr-libpy`](../../tools/wlr-libpy) crate to get a pre-built `libpython` for wasm32-wasi. You can combine this with any typical Rust bindings for the C API by CPython.

We have examples based on two different crates, which both offer Python bindings:

 - [./wasi-py-rs-cpython](./wasi-py-rs-cpython/) using `wlr-libpy` along with the bindings by the [`cpython`](https://github.com/dgrunwald/rust-cpython) crate
 - [./wasi-py-rs-pyo3](./wasi-py-rs-pyo3/) using `wlr-libpy` along with the bindings by the [`pyo3`](https://pyo3.rs/) crate
