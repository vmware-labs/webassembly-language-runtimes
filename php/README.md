# About

Basic instructions on how to build different php versions.

# Prerequisites

All build operations rely on WASISDK. You would need to download and install it.

# 7.3.33 - patch-v2.diff

Assuming we are working from the current directory of this README.

This is work in progress and we're currently building only php-cgi.

**Note**: A build with this patch has some issues interpreting WP. We are working on it. 

1. Clone the 7.3.33 tag into a working folder

```bash
git clone --depth=1 -b php-7.3.33 https://github.com/php/php-src.git php-7.3.33-build && cd php-7.3.33-build
```

2. Apply the patch inside that folder

```bash
git apply ../patches/patch-v2.diff
```

3. Set the location to WASI SDK and run the build script 
```bash
export WASI_SDK_ROOT=/path/to/wasi-sdk-16.0
./wasmlabs-build.sh
```

4. You can find `php-cgi` in `sapi/cgi/php-cgi`

## Running a script with php-cgi

Don't forget to map the folder that contains the php script, which you want to run. For example:

```bash
wasmtime --mapdir=./::./ -- sapi/cgi/php-cgi ./Zend/bench.php
```
