# About

Build scripts and patches for the sqlite3 library.
# Prerequisites

1. All build operations rely on WASISDK. You could get it from here - https://github.com/WebAssembly/wasi-sdk

2. The sqlite build uses autoconf make and libtool. On a ubuntu machine you may need to do

```console
sudo apt update && sudo apt install autoconf make libtool-bin -y
```

3. Before building define WASI_SDK_ROOT to point to a local installation of WasiSDK. For example

```console
export WASI_SDK_ROOT=/opt/wasi-sdk
```

# References

The patch and approach have been greatly influenced by the changes in [rcarmo/wasi-sqlite](https://github.com/rcarmo/wasi-sqlite)
