# About

Simple app that uses the SQLite C API to create a table, fill it with data and read the data.

This example demonstrates how to build and run such an app for wasm32-wasi using the [pre-built libsqlite3.a](https://github.com/vmware-labs/webassembly-language-runtimes/releases?q=libs%2Fsqlite) from WLR.

# The app

The app is defined in a standalone [CMakeLists.txt](./CMakeLists.txt), which uses pkg-config to get dependencies. The only Wasm-aware part of the [CMakeLists.txt](./CMakeLists.txt) is where we specify the executable suffix as `.wasm`.

```cmake
if(${CMAKE_SYSTEM_NAME} STREQUAL "WASI")
    set(CMAKE_EXECUTABLE_SUFFIX ".wasm")
endif()
```

The app itself is just a primer and may fail badly in any non-straightforward case. This is the basic usage:

```shell-session
$$ ./target/local/sqlite_example -h

Running with SQLite version 3.31.1
Usage: ./target/local/sqlite_example DB_FILE
   DB_FILE always gets overwritten with a database with basic 'Sample' table.

Program exits on any system error!
```

Everything is implemented in [main.c](./main.c) by using methods from the SQLite3 API.

# Build & test

We provide a simple [build.sh](./build.sh) script that wraps over CMake and can either build, run and test the app on the local platform, or for wasm32-wasi.

If you take a quick look at the script you will see that the `run_build` function performs a normal end-to-end `cmake` build, while the `run_tests` function just calls the application with a sample db file.

## Local build

The local build relies on libsqlite3 being installed in the current environment, so that `pkg-config` might find it.

```shell-session
./build.sh --local
Building target/local ...
...
-- Found PkgConfig: /usr/bin/pkg-config (found version "0.29.1")
-- Checking for one of the modules 'sqlite3>=3'
...
[100%] Built target sqlite_example
...
Testing target/local ...
1. Running with SQLite version 3.31.1
2. Using db file target/local/test/test.db
3. Creating 'Sample' table data...
4. Reading 'Sample' table data...
|Id                  |Name                |Description         |
+====================+====================+====================+
|1                   |First               |Original sample     |
|2                   |Second              |Secondary sample    |
|3                   |Third               |Last sample         |
3 total record(s).
```

## Wasm32-wasi build

The wasm32-wasi build requires:

 - `WASI_SDK_PATH` pointing to a [stable wasi-sdk release](https://github.com/WebAssembly/wasi-sdk/releases),
 - [Wasmtime](https://wasmtime.dev/) installed on `PATH`
 - `curl`, `tar`, `gzip` to get the pre-built dependency

It is the default target for `build.sh` and it will roughly do this:

1. Download and extract dependencies in `target/wasm32-wasi/deps` as a "sysroot" with `include` and `lib` folders.
2. Configure `pkg-config` for cross-compiling by setting `PKG_CONFIG_LIBDIR`, `PKG_CONFIG_SYSROOT_DIR` etc.
3. Call `cmake` by using the toolchain defined in `${WASI_SDK_PATH}/share/cmake/wasi-sdk.cmake`

```shell-session
$$ export WASI_SDK_PATH=/home/User/work/wasi-sdk-19.0

$$ which wasmtime
/home/User/.wasmtime/bin/wasmtime

$$ ./build.sh

Getting target/wasm32-wasi/deps/lib/wasm32-wasi/libsqlite3.a from https://.../libsqlite-3.41.2-wasi-sdk-19.0.tar.gz...
include/
include/sqlite3ext.h
include/sqlite3.h
lib/wasm32-wasi/
lib/wasm32-wasi/pkgconfig/
lib/wasm32-wasi/pkgconfig/sqlite3.pc
lib/wasm32-wasi/libsqlite3.a
...
Building target/wasm32-wasi ...
Preparing 'target/wasm32-wasi' with additional CMake args: '-DWASI_SDK_PREFIX=/home/User/wasi-sdk-19.0 -DCMAKE_TOOLCHAIN_FILE=/home/User/wasi-sdk-19.0/share/cmake/wasi-sdk.cmake'
...
-- Found PkgConfig: /usr/bin/pkg-config (found version "0.29.1")
-- Checking for one of the modules 'sqlite3>=3'
...
[100%] Built target sqlite_example
...
Testing target/wasm32-wasi ...
1. Running with SQLite version 3.41.2
2. Using db file target/wasm32-wasi/test/test.db
3. Creating 'Sample' table data...
4. Reading 'Sample' table data...
|Id                  |Name                |Description         |
+====================+====================+====================+
|1                   |First               |Original sample     |
|2                   |Second              |Secondary sample    |
|3                   |Third               |Last sample         |
3 total record(s).
```


