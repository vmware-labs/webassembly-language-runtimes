# Prerequisites

 - wasi-sdk, cmake, curl, tar, gzip - for the `wasm-wrapper-c` module
 - `WASI_SDK_PATH` env variable set to point to the wasi-sdk installation
 - npm, node - for the `se2-mock-runtime`

# How to build and run

The fastest thing would be to just run the `run-e2e.sh` script.

Or you can do things one by one, following the steps below:

1. First build the wasm module in `wasm-wrapper-c` using `build-wasm.sh` in that folder.

    - This will build the wasm wrapper in `wasm-wrapper-c/target/wasm32-wasi/wasm-wrapper-c.wasm`
    - It will download libpython3.11 along with its standard libraries into `wasm-wrapper-c/target/wasm32-wasi/deps`
    - Note, that the binaries are initially downloaded from an [unofficial release on my public fork](https://github.com/assambar/webassembly-language-runtimes/releases/tag/python%2F3.11.1%2B20230223-8a6223c) - will update this once we officially roll out libpython3.11.

2. Then in `se2-mock-runtime` run `npm i` to get all node dependencies
3. Then again in `se2-mock-runtime` call with
   ```
   node --experimental-wasi-unstable-preview1 . \
        --wrapper ../wasm-wrapper-c/target/wasm32-wasi/wasm-wrapper-c.wasm \
        --plugin-root ../py-plugin/ \
        --python-usr-root ../wasm-wrapper-c/target/wasm32-wasi/deps/
   ```

   - `wrapper` is a path to the wasm translation error between the Python plugin and the runtime
   - `plugin-root` is added to `PYTHONPATH` and a `plugin.py` which defines `run_e` is expected to be found there. There could be any other pure Python libraries in that folder, and they can be imported in `plugin.py`
   - `python-usr-root` is the path where the `usr/local/lib/...` path, containing Python's standard libraries is located. In this case I reuse what was downloaded while building `wasm-wrapper-c`

# The output

For easier understanding I tried to add simple logs in all functions along the line of data in all the layers.

 - all se2-mock-runtime logs start at the beginning of the line
 - all wasm-wrapper-c logs start after one tab
 - all plugin.py logs start after two tabs 

Output from a sample run

```
se2-mock-runtime $$ node --experimental-wasi-unstable-preview1 . --wrapper ../wasm-wrapper-c/target/wasm32-wasi/wasm-wrapper-c.wasm --plugin-root ../py-plugin/ --python-usr-root ../wasm-wrapper-c/target/wasm32-wasi/deps/
runtime.js | Loading module ../wasm-wrapper-c/target/wasm32-wasi/wasm-wrapper-c.wasm ...
(node:440879) ExperimentalWarning: WASI is an experimental feature. This feature could change at any time
(Use `node --trace-warnings ...` to show where the warning was created)
        utils.c | Current working dir: /
runtime.js | Started wasm module
        wasm_shim.c | called allocate(12)
runtime.js | Calling wasmModule.run_e(4497632, 12, 12345)...
        wasm_shim.c | id=12345 | called run_e(0x44a0e0, 12, 12345).
                plugin.py | id=12345 | Received payload "Hello there"
                plugin.py | id=12345 | Returning result "ereht olleH"...
        sdk_module.c | id=12345 | called return_result(0x449fb8, 12, 12345).
runtime.js | Returned result "ereht olleH" with ident 12345
                plugin.py | id=12345 | Result returned for 12345.
        wasm_shim.c | id=12345 | run_e: completed.
runtime.js | wasmModule.run_e returned
        wasm_shim.c | called deallocate(0x44a0e0, 12)
```

# Shallow dive

Take a look at the diagram to get to know what's going on.

![se2-runtime calls](se2-mock-runtime.drawio.png)

 - Each call is outlined by a different color
 - Numbers indicated the overall order as it happens in the basic flow in `runtime.js`

## se2-mock-runtime

Main entry point is in `bin/runtime.js`

 - Allocate buffer from wasm
 - Write string to buffer
 - Call `run_e` with buffer
 - On `return_result` or `return_error` print logs
 - After `run_e` completes, deallocate buffer from wasm

## wasm-wrapper-c

 - Exports/imports declared in `wasm_shim.h`. Note - `_initialize` is not exported, because the SE2 engine uses `_start`.
 - `pyhost` - initialization of embedded Python + loading of modules
 - `main.c` - initialization and loading of `plugin.py` happens here. We don't destroy the embedded Python engine, because `main` is called during `_start` and later we will call other functions. Uses `_initialize` from `wasm_shim.c` for this.
 - `wash_shim.c` defines `allocate`, `deallocate`, `run_e`. The latter translates the incoming call to a call of `run_e` within the `plugin.py` module
 - `sdk_module` defines a C-implemented Python module called 'sdk'. It offers the `return_result` and `return_error` functions, which can be called from within `plugin.py`. They translate from the Python function calls to the imported host functions provided by the runtime. 

## py-plugin

 - `run_e` accepts a UTF-8 string payload and reverses it
 - `sdk.return_result` is used to return the result
 
