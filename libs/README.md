# About

This folder contains projects with build scripts and patches that allow us to build versions of common open-source libraries to wasm32-wasi.

All projects for external libraries are checked out from their respective repositories and patched during the build process. No submodules are used.

There are a few internal projects for libraries, which we support as part of the current repositories.

We also build a `bundle_wlr` project that packs all libraries into an all-in-one archive, which one can just download and unpack for easier build setup.

# Releases

The libraries are offered as static library archives (`.a` files) and can be linked to, when building your wasm32-wasi application. This will be augmented once we have a stable [component-model](https://github.com/WebAssembly/component-model) for WebAssembly.

All assets are published as GitHub releases for the current repository.

## Release names

Here is a [sample release of libjpeg](https://github.com/assambar/webassembly-language-runtimes/releases/tag/libs%2Flibjpeg%2F2.1.5.1%2B20230308-9c87db9).

The release names for the libraries follow the convention `libs/${PROJECT_NAME}-${LIBRARY_VERSION}+${RELEASE_DATE}-${TAGGED_WLR_COMMIT}` where

 - `PROJECT_NAME` is the popular name of the project that builds the library. For example, *zlib* builds `libz.a`, *oniguruma* builds `libonig.a`, etc.
 - `LIBRARY_VERSION` is the concrete version of that library. We may support several versions of a library in parallel.
 - `RELEASE_DATE` is self-explanatory.
 - `TAGGED_WLR_COMMIT` is a short hash of the commit from which the build and patch scripts were used to create this release.

It is possible to have several releases for the same library version. We will re-release versions when:

 - newer versions of [wasi-sdk](https://github.com/WebAssembly/wasi-sdk) and [wasi-libc](https://github.com/WebAssembly/wasi-libc) become available.
 - we update the patches for the released library so that we offer more functionality. Initially, a library may be ported to `wasm32-wasi` with the bare minimum of features and subsequently, we might re-build it with more things.
 - we add infrastructural changes - the way assets are packaged, documented, etc.

This is why we need the `RELEASE_DATE` and `TAGGED_WLR_COMMIT`. Even if we issue a newer release for some library, the old one will stay and still be accessible.

## Release assets

Take a look at the `libjpeg` assets from the [mentioned release](https://github.com/assambar/webassembly-language-runtimes/releases/tag/libs%2Flibjpeg%2F2.1.5.1%2B20230308-9c87db9).

The asset name follows the convention `${LIBRARY_NAME}[-bin]-${LIBRARY_VERSION}-wasi-sdk-${WASI_SDK_VERSION}.tar.gz`

 - `LIBRARY_NAME` is the name of the main library you link with (without the extension). For example, `libz.a`, `libonig.a`, `libjpeg.a`, etc.
 - `[-bin]` is added for assets that contain executable binaries. For example, for `libjpeg` those will be `cjpeg`, `djpeg`, `jpegtran`, etc. Naturally, those binaries are built as Wasm modules.
 - `LIBRARY_VERSION` is the concrete version of that library.
 - `WASI_SDK_VERSION` is the version of `wasi-sdk` used to build the asset.

A library asset will contain the header(s), static archive(s) and pkg-config file(s) for this library. The headers are in `include`, while the rest goes in `lib/wasm32-wasi`. For example for `libjpeg` we get:

```shell-session
$$ tar -ztvf libjpeg-2.1.5.1-wasi-sdk-19.0.tar.gz

drwxr-xr-x root/root         0 2023-03-09 09:52 include/
-rw-r--r-- root/root     15864 2023-03-09 09:52 include/jerror.h
-rw-r--r-- root/root      1091 2023-03-09 09:52 include/jconfig.h
-rw-r--r-- root/root     50281 2023-03-09 09:52 include/jpeglib.h
-rw-r--r-- root/root     14192 2023-03-09 09:52 include/jmorecfg.h
drwxr-xr-x root/root         0 2023-03-09 09:52 lib/
drwxr-xr-x root/root         0 2023-03-09 09:52 lib/wasm32-wasi/
drwxr-xr-x root/root         0 2023-03-09 09:52 lib/wasm32-wasi/pkgconfig/
-rw-r--r-- root/root       246 2023-03-09 09:52 lib/wasm32-wasi/pkgconfig/libjpeg.pc
-rw-r--r-- root/root    470134 2023-03-09 09:52 lib/wasm32-wasi/libjpeg.a
```

If there is also a `-bin` asset it will usually have just a `bin` folder with the binaries. For example, for `libjpeg-bin` we get:

```shell-session
$$ tar -ztvf libjpeg-bin-2.1.5.1-wasi-sdk-19.0.tar.gz

drwxr-xr-x root/root         0 2023-03-09 09:52 bin/
-rwxr-xr-x root/root     41328 2023-03-09 09:52 bin/rdjpgcom
-rwxr-xr-x root/root    390627 2023-03-09 09:52 bin/jpegtran
-rwxr-xr-x root/root     40453 2023-03-09 09:52 bin/wrjpgcom
-rwxr-xr-x root/root    213619 2023-03-09 09:52 bin/djpeg
-rwxr-xr-x root/root    360896 2023-03-09 09:52 bin/cjpeg
```

# How to use

To see how to use the released libraries with an end-to-end demo, take a look at the [libs/examples](./examples/) folder.

In short, you have two basic options:

1. Download and extract inside a `${WASI_SDK_PATH}/share/wasi-sysroot` folder. In this way you shouldn't need to setup include or link paths. This is most useful when you use a download a fresh wasi-sdk setup as part of your build process, but might get tricky if you overwrite those in your local development wasi-sdk environment.

2. Download and extract the files in some folder (e.g. `${SOME_TEMP_BUILD_FOLDER}/dependencies`) then add respectively the `include` and `lib/wasm32-wasi` folders to include dirs and library dirs. (e.g. `export CFLAGS="${CFLAGS} -I${SOME_TEMP_BUILD_FOLDER}/dependencies/include"` and `export CFLAGS="${CFLAGS} -L${SOME_TEMP_BUILD_FOLDER}/dependencies/lib/wasm32-wasi"`)

 If your build relies on `pkg-config`, to avoid it picking up headers and versions from your build machine, you could set it up for cross-compilation like this:

```bash
export PKG_CONFIG_ALLOW_SYSTEM_CFLAGS=1
export PKG_CONFIG_ALLOW_SYSTEM_LIBS=1
export PKG_CONFIG_PATH=""
export PKG_CONFIG_SYSROOT_DIR=${SOME_TEMP_BUILD_FOLDER}/dependencies
export PKG_CONFIG_LIBDIR=${PKG_CONFIG_SYSROOT_DIR}/lib/wasm32-wasi/pkgconfig
```

# Building on your own

We are providing public container images with the necessary build environment, so building a version of any of the libraries is as easy as running `make libs/${PROJECT_NAME}/${VERSION_DIR}` from the repository root.

 - `PROJECT_NAME` is, again, the popular name of the project that builds the library. We use it as a subfolder in `libs`
 - `VERSION_DIR` is usually a folder which follows the naming of the "tag" of the specific version in the original repository of the library. E.g. `libuuid-1.0.3` for *uuid* or `v1.2.13` for *zlib*

In the end, all the build assets (packed and unpacked) can be found in the `build-output` folder.

Here is an example:

```shell-session
(wlr-repo-root) $$ make libs/zlib/v1.2.13
...
2023-03-09T09:30:08,113901736+00:00 | zlib/v1.2.13 | Packaging... /wlr/build-output/libz-1.2.13-wasi-sdk-19.0.tar
2023-03-09T09:30:08,134959368+00:00 | zlib/v1.2.13 | DONE. Artifacts in /wlr/build-output/zlib/v1.2.13
...

(wlr-repo-root) $$ tree build-output/

build-output/
├── libz-1.2.13-wasi-sdk-19.0.tar.gz
└── zlib
    └── v1.2.13
        ├── include
        │   ├── zconf.h
        │   └── zlib.h
        ├── lib
        │   └── wasm32-wasi
        │       ├── libz.a
        │       └── pkgconfig
        │           └── zlib.pc
        ├── share
        │   └── man
        │       └── man3
        │           └── zlib.3
        └── wasmlabs-progress.log

9 directories, 7 files

(wlr-repo-root) $$ tar -ztvf build-output/libz-1.2.13-wasi-sdk-19.0.tar.gz

drwxr-xr-x root/root         0 2023-03-09 11:30 include/
-rw-r--r-- root/root     97323 2023-03-09 11:30 include/zlib.h
-rw-r--r-- root/root     16589 2023-03-09 11:30 include/zconf.h
drwxr-xr-x root/root         0 2023-03-09 11:30 lib/
drwxr-xr-x root/root         0 2023-03-09 11:30 lib/wasm32-wasi/
drwxr-xr-x root/root         0 2023-03-09 11:30 lib/wasm32-wasi/pkgconfig/
-rw-r--r-- root/root       261 2023-03-09 11:30 lib/wasm32-wasi/pkgconfig/zlib.pc
-rw-r--r-- root/root    249026 2023-03-09 11:30 lib/wasm32-wasi/libz.a
```

# For contributors

If you want to contribute by porting a library, or suggesting an improvement to how this is done, feel free to drop a not on the [Libs roadmap](https://github.com/vmware-labs/webassembly-language-runtimes/issues/78) issue.

We will expand this section with more information about the build scripts, as needed.
