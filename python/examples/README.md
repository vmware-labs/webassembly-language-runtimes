This folder offers various examples of how to use Python in wasm modules.

 - [./basic](./basic/) is a collection of small snippets that demonstrate how to run `python.wasm` from the command line or via [Docker](https://docs.docker.com/get-docker/)
 - [./embedding/](./embedding/) shows how one can embed the static wasm32-wasi `libpython` into a WASI command module
 - [./bindings](./bindings/) is a sample application that demonstrates how one can use host-to-python and python-to-host bindings

 Note: `build.rs` does not have any download or performance optimization - the necessary `wasm32-wasi` dependencies are fetched and unpacked on each build run.
