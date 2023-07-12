# webassembly-language-runtimes

WebAssembly Language Runtimes (or WLR for short) offers pre-built wasm32-wasi binaries for language runtimes and static builds of common open source libraries.

This repository contains the build scripts and patches that are used to do those builds, as well as examples on how to use them.

## Try it out

WLR is used in projects like [mod_wasm](https://github.com/vmware-labs/mod_wasm) for traditional deployments and [Wasm Workers Server](https://github.com/vmware-labs/wasm-workers-server) for the development of serverless apps. To get a glimpse of that you could:

 - [5 min] Run [WordPress with php.wasm, mod_wasm and Apache](https://wasmlabs.dev/articles/running-wordpress-with-mod-wasm/). (You'll need Docker for a container with Apache).
 - [10 min] Create and run a [Ruby worker on wws](https://workers.wasmlabs.dev/docs/languages/ruby).

The released assets are also easy to use with various platforms and tools.

 - [5 min] Take a look at how to [run the python-wasm Docker container](./python/examples/#running-the-docker-container). (You'll need the latest Docker Desktop with enabled containerd).
 - [10 min] Follow the steps in Fermyon's blog post on [PHP, Spin and Fermyon cloud](https://www.fermyon.com/blog/php-spin-fermyon-cloud).

If you are into porting of C-based apps to wasm32-wasi you could play with the libs.

 - [10 min] Build a [C-app that uses the libuuid and zlib](./libs/examples//uuid_zlib_example/#the-app) static libraries.
 - [1 day – 2 weeks] Port a static library. Take a look at the build scripts for [`libs/zlib`](./libs/zlib/) as an example. Pick a library you want to see ported. Try building it to wasm32-wasi. (Prior knowledge of building C apps with autotools, make, cmake, pkg-config will be an advantage).


## Releases

Here is a reference to the latest releases of all built projects.

| Language runtime          | Latest release            |
|---                        |---                        |
| [php](./php/)             | [8.2.0](https://github.com/vmware-labs/webassembly-language-runtimes/releases/tag/php%2F8.2.0%2B20230418-d75a618)             |
| [python](./python/)       | [3.11.3](https://github.com/vmware-labs/webassembly-language-runtimes/releases/tag/python%2F3.11.3%2B20230428-7d1b259)        |
| [ruby](./ruby/)           | [3.2.0](https://github.com/vmware-labs/webassembly-language-runtimes/releases/tag/ruby%2F3.2.0%2B20230215-1349da9)            |



| Library                                   | Latest release            |
|---                                        |---                        |
| [libs/bundle_wlr](./libs/bundle_wlr)      | [0.1.0](https://github.com/vmware-labs/webassembly-language-runtimes/releases/tag/libs%2Fbundle_wlr%2F0.1.0%2B20230310-ddace6c)   |
| [libs/bzip2](./libs/bzip2)                | [1.0.8](https://github.com/vmware-labs/webassembly-language-runtimes/releases/tag/libs%2Fbzip2%2F1.0.8%2B20230425-e1a7579)  |
| [libs/libjpeg](./libs/libjpeg)            | [2.1.5.1](https://github.com/vmware-labs/webassembly-language-runtimes/releases/tag/libs%2Flibjpeg%2F2.1.5.1%2B20230310-c46e363)  |
| [libs/libpng](./libs/libpng)              | [1.6.39](https://github.com/vmware-labs/webassembly-language-runtimes/releases/tag/libs%2Flibpng%2F1.6.39%2B20230310-13a5f2e)  |
| [libs/libuuid](./libs/libuuid)            | [1.0.3](https://github.com/vmware-labs/webassembly-language-runtimes/releases/tag/libs%2Flibuuid%2F1.0.3%2B20230310-c46e363)  |
| [libs/libxml2](./libs/libxml2)            | [2.10.3](https://github.com/vmware-labs/webassembly-language-runtimes/releases/tag/libs%2Flibxml2%2F2.10.3%2B20230310-c46e363)   |
| [libs/oniguruma](./libs/oniguruma)        | [6.9.8](https://github.com/vmware-labs/webassembly-language-runtimes/releases/tag/libs%2Foniguruma%2F6.9.8%2B20230310-c46e363)   |
| [libs/sqlite](./libs/sqlite)              | [3.41.2](https://github.com/vmware-labs/webassembly-language-runtimes/releases/tag/libs%2Fsqlite%2F3.41.2%2B20230329-43f9aea)  |
| [libs/zlib](./libs/zlib)                  | [1.2.13](https://github.com/vmware-labs/webassembly-language-runtimes/releases/tag/libs%2Fzlib%2F1.2.13%2B20230310-c46e363)   |

## For developers

The rest of this document will help you if you want to build some of the assets on your own, or contribute with a patch, or add support for new release targets.

### Getting started

All you need in order to run these builds is to have `docker` or `podman` available in your system. You can execute the following `Makefile` targets:

- `php/v7.3.33`, `php/v7.4.32`,
  `php/v8.1.11`, `php/v8.2.0`, `php/v8.2.0-wasmedge`
    - Resulting binaries are placed in `build-output/php`.

- `python/v3.11.3`
    - Resulting binaries are placed in `build-output/python`.

- `ruby/v3.2.0`
    - Resulting binaries are placed in `build-output/ruby`.

### Build strategy

If you are interested in knowing more about the build system and how it produces the final binaries, keep reading.

#### Code Organization

All build orchestration scripts are written in bash in this initial version. They start with a `wlr-` prefix (short for WebAssembly Language Runtimes). Review the [build orchestration scripts](#build-orchestration-scripts) section for more info.

All intermediary source code checkouts and build objects get created within the `build-staging` folder. The final output gets written to the `build-output` folder.

The patches and scripts to build different language runtimes are organized in a folder hierarchy that follows the tagged versions from the respective source code repositories. Several `wlr-` scripts are added around that to facilitate setup of a local clone of the repository, application of respective patches and building with respective build configuration options.

For language runtimes we have something like this.

```
${LANGUAGE_RUNTIME_NAME} (e.g. 'php')
├── README.md (generic notes about what was patched to build this language)
├── v${VERSION_FROM_TAG_IN_REPO} (e.g. 'v7.4.32' for the 'php-7.4.32 tag from the php repo)
│   ├── README.md (generic notes about what was patched to build this version)
│   ├── patches (consecutive patches on top of the tagged version, applied before building)
│   │   ├── (e.g. '0001-Initial-port-of-7.3.33-patch-to-7.4.32.patch')
│   │   ├── (e.g. '0002-Fix-mmap-issues.-Add-readme.patch')
│   │   └── Etc...
│   ├── wlr-build-deps.sh (script that builds dependencies)
│   └── wlr-build.sh (script that builds for this tag)
└── wlr-env-repo.sh (script that sets up the source code repository for given langauge and tag)
```

For common shared libraries we have something similar.
```
libs (common libraries, needed by different modules)
└── ${LIBRARY_NAME} (e.g. 'sqlite')
    ├── README.md (generic notes about what was patched to build this language)
    ├──${VERSION_TAG_IN_REPO} (e.g. 'version-3.39.2' from the sqlite repo)
    │   ├── patches (consecutive patches on top of the tagged version, applied before building)
    │   │   ├── (e.g. '0001-Patch-to-build-sqlite-3.39.2-for-wasm32-wasi.patch')
    │   │   ├── (e.g. '0002-Remove-build-script-from-patched-repo.patch')
    │   │   └── Etc...
    │   └── wlr-build.sh (script that builds for this tag)
    └── wlr-env-repo.sh (script that sets up the source code repository for given langauge and tag)
```

#### Build orchestration scripts

1. The main script used to build something is `wlr-make.sh` in the root folder. It gets called with a path to the folder for a respective tag of what we want to build.

2. It will first __source__ the `scripts/wlr-env.sh` script. This one sets all environment variables necessary to checkout and build the desired target. It gets the same path from `wlr-make.sh` and is useful when you try to build locally.

3. Then `wlr-make.sh` will call `scripts/wlr-setup-repo.sh` to create a shallow clone of the necessary repository only for the specific tag that we want to build. On top of that it applies any relevant patches from the `patches` subfolder of the tagged version folder.

4. As a final step `wlr-make.sh` will call `scripts/wlr-build.sh` which will build from the code in the respective repository.

5. Before building this will call a `$LANG/$TAG/wlr-build-deps.sh` if there is any to build required dependencies and setup CFLAGS or LDFLAGS for their artifacts. Then it will call the `$LANG/$TAG/wlr-build.sh` script to build the actual target itself.

#### Adding a new build target

To add a build setup for a new version of something that is already configured:

1. Add a subfolder for the respective tag version, like this:

```
mkdir php/v8.1.11
```

2. Create a `wlr-build.sh` script in the target folder, like this:

```console
touch php/v8.1.11/wlr-build.sh
```

3. Setup your build environment via `scripts/wlr-env.sh` with the target path then query the respective environment variables, like this:

```console
source scripts/wlr-env.sh php/v8.1.11
export | grep WLR_
```

4. Create a `wlr-env-repo.sh` script in the target folder and define repository, tag, version, etc., like this:

```console
export WLR_REPO=https://github.com/php/php-src.git
export WLR_REPO_BRANCH=php-8.1.11
export WLR_ENV_NAME=php/php-8.1.11
export WLR_PACKAGE_VERSION=8.1.11
export WLR_PACKAGE_NAME=php
```

5. Create a local clone of the respective tag in build-staging, like this:

```console
scripts/wlr-setup-repo.sh
```

6. Open your favorite IDE in the said clone to iterate building from the tag until it works, like this:

```console
code build-staging/php/v8.1.11/checkout
```

7. Patch the checked out code where necessary. Add flags and build commands to the `wlr-build.sh` script in the target folder and each time rebuild like this:

```console
scripts/wlr-build.sh
```

8. After you manage to get a working build, add proper lines at the end of your `wlr-build.sh` script to copy from the `build-staging` folder to the respective `build-output` location, like this:

```bash
...
logStatus "Preparing artifacts... "
mkdir -p ${WLR_OUTPUT}/bin 2>/dev/null || exit 1

cp sapi/cgi/php-cgi ${WLR_OUTPUT}/bin/ || exit 1

logStatus "DONE. Artifacts in ${WLR_OUTPUT}"

```

8. Commit the patch changes from 7. into the local shallow clone. If necessary, split them into commits. Then export them to the target folder (e.g. `php/v8.1.11/patches`) like this:

```console
scripts/wlr-update-patches.sh
```

9. Now add and commit the new target description folder containing the build script and respective patches to the current repository, like this:

```console
git add php/v8.1.11
git commit -m "Add support to build php version 8.1.11"
```

### Releasing

In order to release a new version, you first have to tag the project you want to release. You can create a tag by using the `scripts/wlr-tag.sh` script.

This script accepts the path to be released, and will create a local tag of the form `<project>/<version>+YYYYMMDD-<short-sha>`. All parameters will be automatically filled by the script, so in order to create a valid tag for PHP 8.1.11, for example, you only have to execute:

- `scripts/wlr-tag.sh php/v8.1.11`

This will create a tag like the following in your local repository: `php/8.1.11+20221123-d3d8901`.

When you push the tag to the remote repository, a GitHub release will be created automatically, and relevant artifacts will be automatically published to the release.
