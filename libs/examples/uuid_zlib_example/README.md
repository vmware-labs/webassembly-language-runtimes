# About

Simple app that uses libuuid and zlib. This demonstrates how to build it for wasm32-wasi with pre-compiled libraries from WLR.

# The app

The app is defined in a standalone [CMakeLists.txt](./CMakeLists.txt), which uses pkg-config to get dependencies. The only Wasm-aware part of the [CMakeLists.txt](./CMakeLists.txt) is where we specify the executable suffix as `.wasm`.

```cmake
if(${CMAKE_SYSTEM_NAME} STREQUAL "WASI")
    set(CMAKE_EXECUTABLE_SUFFIX ".wasm")
endif()
```

The app itself is just a primer and may fail badly in any non-straightforward case. This is the basic usage:

```shell-session
./target/local/uuid_zlib_example --help
Usage: ./target/local/uuid_zlib_example [compress|decompress] INPUT_FILE OUTPUT_FILE
   OUTPUT_FILE always gets overwritten.

Usage: ./target/local/uuid_zlib_example [genuuid]
   Generates UUID and prints it to STDOUT

Program exits on any system error!
```

Everything is implemented in [main.c](./main.c) by using methods from libuuid and zlib.

# Build & test

We provide a simple [build.sh](./build.sh) script that wraps over CMake and can either build, run and test the app on the local platform, or for wasm32-wasi.

If you take a quick look at the script you will see that the `run_build` function performs a normal end-to-end `cmake` build, while the `run_tests` function does some poor man's testing of the implemented functionality.

## Local build

The local build relies on zlib and libuuid being installed in the current environment, so that `pkg-config` might find them.

```shell-session
./build.sh --local
Building target/local ...
...
-- Found PkgConfig: /usr/bin/pkg-config (found version "0.29.1")
-- Checking for one of the modules 'uuid>=1.0.0'
-- Checking for one of the modules 'zlib>=1.1.0'
...
[100%] Built target uuid_zlib_example
...
Testing target/local ...
genuuid OK.
compress/decompress OK.
```

## Wasm32-wasi build

The wasm32-wasi build requires:

 - `WASI_SDK_PATH` pointing to a [stable wasi-sdk release](https://github.com/WebAssembly/wasi-sdk/releases),
 - [Wasmtime](https://wasmtime.dev/) installed on `PATH`
 - `curl`, `tar`, `gzip` to get the pre-built dependencies

It is the default target for `build.sh` and it will roughly do this:

1. Download and extract dependencies in `target/wasm32-wasi/deps` as a "sysroot" with `include` and `lib` folders.
2. Configure `pkg-config` for cross-compiling by setting `PKG_CONFIG_LIBDIR`, `PKG_CONFIG_SYSROOT_DIR` etc.
3. Call `cmake` by using the toolchain defined in `${WASI_SDK_PATH}/share/cmake/wasi-sdk.cmake`

```shell-session
$$ export WASI_SDK_PATH=/home/User/work/wasi-sdk-19.0

$$ which wasmtime
/home/User/.wasmtime/bin/wasmtime

$$ ./build.sh
Getting target/wasm32-wasi/deps/lib/wasm32-wasi/libz.a from https://.../libz-1.2.13-wasi-sdk-19.0.tar.gz...
include/zconf.h
include/zlib.h
lib/wasm32-wasi/
lib/wasm32-wasi/libz.a
lib/wasm32-wasi/pkgconfig/
lib/wasm32-wasi/pkgconfig/zlib.pc
...
Getting target/wasm32-wasi/deps/lib/wasm32-wasi/libuuid.a from https://.../libuuid-1.0.3-wasi-sdk-19.0.tar.gz...
include/uuid/
include/uuid/uuid.h
lib/wasm32-wasi/
lib/wasm32-wasi/libuuid.a
lib/wasm32-wasi/pkgconfig/
lib/wasm32-wasi/pkgconfig/uuid.pc
...
Building target/wasm32-wasi ...
Preparing 'target/wasm32-wasi' with additional CMake args: '-DWASI_SDK_PREFIX=/home/User/wasi-sdk-19.0 -DCMAKE_TOOLCHAIN_FILE=/home/User/wasi-sdk-19.0/share/cmake/wasi-sdk.cmake'
...
-- Found PkgConfig: /usr/bin/pkg-config (found version "0.29.1")
-- Checking for one of the modules 'uuid>=1.0.0'
-- Checking for one of the modules 'zlib>=1.1.0'
...
[100%] Built target uuid_zlib_example
...
Testing target/wasm32-wasi ...
genuuid OK.
compress/decompress OK.
```


