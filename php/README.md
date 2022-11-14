# About

Basic instructions on how to build different php versions.

# Prerequisites

1. All build operations rely on WASISDK. You could get it from here - https://github.com/WebAssembly/wasi-sdk

2. The php build uses autoconf make and libtool. On a ubuntu machine you may need to do

```console
sudo apt update && sudo apt install autoconf make libtool-bin -y
```

3. Before building define WASI_SDK_ROOT to point to a local installation of WasiSDK. For example

```console
export WASI_SDK_ROOT=/opt/wasi-sdk
```

# 7.3.33 - patch.v2.diff

This is work in progress and we're currently building only php-cgi.

**Note**: A build with this patch has some issues interpreting WP. We are working on it. 

1. To build just run `php/patches/7.3.33/build.sh`

2. You can find `php-cgi` in `$WASMLABS_BUILD_OUTPUT/bin/php-cgi`

# 7.4.32 - patch.v1.diff

This is work in progress and we're currently building only php-cgi.

This build also downloads and builds sqlite3(3.39.2) and links it into the php binary

**Note**: A build with this patch has some issues interpreting WP. We are working on it. 

1. To build just run `php/patches/7.4.32/build.sh`

2. You can find `php-cgi` in `$WASMLABS_BUILD_OUTPUT/bin/php-cgi`

# Running a script with php-cgi

Don't forget to map the folder that contains the php script, which you want to run. For example:

```bash
wasmtime --mapdir=./::./ -- php-cgi my-script.php
```
