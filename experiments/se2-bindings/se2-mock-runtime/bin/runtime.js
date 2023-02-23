#!/usr/bin/env node

const yargs = require("yargs");
const { WASI } = require('wasi');
const path = require('path');
const fs = require('fs');

const { WasmMemoryManager } = require('../mem-utils');

// Parse args
const options = yargs
    .usage("Usage: -wrapper WASM_MODULE_PATH -plugin PYTHON_PLUGIN_ROOT")
    .option("wrapper", { describe: "Path to the Wasm module to run", type: "string", demandOption: true })
    .option("plugin-root", { describe: "Path to root folder with plugin.py", type: "string", demandOption: true })
    .option("python-usr-root", { describe: "Path to folder containing python's stdlib. Inside this folder we expect to see usr/local/lib...", type: "string", demandOption: true })
    .argv;

const wasi = new WASI({
    args: [options.wrapper],
    env: {
        'PYTHONPATH': '/plugin'
    },
    preopens: {
        '/plugin': options.pluginRoot,
        '/usr': path.join(options.pythonUsrRoot, 'usr')
    },
});

memMgr = null;

const importObject = {
    "wasi_snapshot_preview1": {
        // sock_accept is not available, but is part of the wasi_snapshot_preview1 specification
        sock_accept(fd, flags) {
            return fd;
        },
        ...wasi.wasiImport
    },
    env: {
        return_result(result, result_len, ident) {
            const buf = memMgr.wrapBuf(result, result_len);
            const strResult = memMgr.strFromBuf(buf);
            console.log(`runtime.js | Returned result "${strResult}" with ident ${ident}`);
        },
        return_error(code, msg, msg_len, ident) {
            const buf = memMgr.wrapBuf(msg, msg_len);
            const strMsg = memMgr.strFromBuf(buf);
            console.log(`runtime.js | Returned error {code:${code}, message="${strMsg}"} with ident ${ident}`);
        },
    },
};

(async () => {
    console.log(`runtime.js | Loading module ${options.wrapper} ...`);
    const wasmBuffer = fs.readFileSync(options.wrapper);
    wasmModule = await WebAssembly.instantiate(wasmBuffer, importObject);
    memMgr = new WasmMemoryManager(wasmModule.instance.exports);

    if (Object.hasOwn(wasmModule.instance.exports, '_start'))
        wasi.start(wasmModule.instance);
    else if (Object.hasOwn(wasmModule.instance.exports, '_initialize'))
        wasi.initialize(wasmModule.instance);
    else
        throw Error('WASM module should export either _start or _initialize');

    console.log('runtime.js | Started wasm module');

    const strBuf = memMgr.bufFromString('Hello there');

    const ident = 12345;
    console.log(`runtime.js | Calling wasmModule.run_e(${strBuf.getPtr()}, ${strBuf.getSize()}, ${ident})...`);
    wasmModule.instance.exports.run_e(strBuf.getPtr(), strBuf.getSize(), ident);

    console.log('runtime.js | wasmModule.run_e returned');
    memMgr.deallocateBuf(strBuf);

})().catch(e => {
    console.log("runtime.js | Error: ", e);
});
