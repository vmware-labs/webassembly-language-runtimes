# About

This folder and its subfolders contain the scripts used to build WASM ports of python versions.

The initially supported version is python 3.11.1.

The build is based on CPython's WASM+WASI support - https://pythondev.readthedocs.io/wasm.html

# Getting started

For more examples of how to use the released `python.wasm` see the [examples](./examples) folder.

# For developers

In case you want to build this on you own, you will need _Docker_ and _GNU make_.
## Building

Note: all commands and paths are relative to the root of the repository.

Building the default flavor is as easy as

```
make python/v3.11.1
```

You will get all the output files in `build-output/python`

```
build-output/python/
└── v3.11.1
    ├── bin
    │   └── python.wasm
    └── usr
        └── local
            └── lib
                └── python311.zip
```

All intermediary files, including the source CPython repository can be found in `build-staging/python/v3.11.1`.

## Running python.wasm

As you see the build provides a wasm binary and a separate zip file that contains all scripts from python's standard library.

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
