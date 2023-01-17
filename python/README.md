# About

This folder and its subfolders contain the scripts used to build WASM ports of python versions.

The initially supported version is python 3.11.1.

The build is based on CPython's WASM+WASI support - https://pythondev.readthedocs.io/wasm.html

The initial version depends on pre-build WASM libraries found in https://github.com/singlestore-labs/python-wasi/tree/main/docker for `zlib` or `libuuid`. With time we will build those on our own during the build process.

# Prerequisites

To run this build you will need

 - the following list of build tools

```
sudo apt install -y autoconf automake build-essential clang git pkg-config wget

```
 - wasi-sdk from here - https://github.com/WebAssembly/wasi-sdk/releases


# Building

You can build Python by running the following:

```
export WASI_SDK_ROOT=/opt/wasi-sdk
wl-make.sh python/v3.11.1
```

# Running python.wasm

The build will provide you with a wasm binary and with a separate zip file that contains all scripts from python's standard library.

```
build-output/python/
└── v3.11.1
    ├── bin
    │   └── python.wasm
    ├── include
    ├── lib
    └── usr
        └── local
            └── lib
                └── python311.zip
```

The default PYTHONPATH includes `/usr/local/lib/python311.zip` so when running the binary you will need to ensure that python311.zip is mapped at the proper location in the WASM sandboxed environment. For example

```bash
# Running in build-output/python/v3.11.1

wasmtime run bin/python.wasm --mapdir /::.
Python 3.11.1 (tags/v3.11.1:a7a450f, Jan 14 2023, 01:44:50) [Clang 14.0.4 (https://github.com/llvm/llvm-project 29f1039a7285a5c3a9c353d05414 on wasi
Type "help", "copyright", "credits" or "license" for more information.
>>> import sys
>>> import pprint
>>> pprint.pprint(sys.path)
['',
 '/usr/local/lib/python311.zip',
 '/usr/local/lib/python3.11',
 '/usr/local/lib/python3.11/lib-dynload']
>>>
```

Of course, you could always have that zip file in another folder and provide the PYTHONPATH environment variable to point to it. For example:

```bash
# Running in build-output/python/v3.11.1

wasmtime run \
   --env PYTHONPATH=/mypath/python311.zip \
   --env PYTHONHOME=/mypath/python311.zip \
   --mapdir=/mypath::usr/local/lib/ bin/python.wasm \
   -- -c "import sys; import pprint; pprint.pprint(sys.path)"
['',
 '/mypath/python311.zip',
 '/mypath/python311.zip/lib/python311.zip',
 '/mypath/python311.zip/lib/python3.11',
 '/mypath/python311.zip/lib/python3.11/lib-dynload']
```
