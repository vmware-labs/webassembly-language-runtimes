# webassembly-language-runtimes

## Overview

This repository contains patches provided for language runtimes to be compiled for the wasm32-wasi target.

## Getting started

All you need in order to run these builds is to have `docker` or `podman` available in your system. You can execute the following `Makefile` targets:

- `php/php-7.3.33`, `php/php-7.4.32`, `php/wasmedge-php-7.4.32`,
  `php/php-8.1.11`, `php/php-8.2.0`
    - Resulting binaries are placed in `php/build-output/php`.

- `python/v3.11.1`
    - Resulting binaries are placed in `python/build-output/python`.

- `ruby/v3_2_0`
    - Resulting binaries are placed in `ruby/build-output/ruby`.

## Build strategy

If you are interested in knowing more about the build system and how it produces the final binaries, keep reading.

### Code Organization

All build orchestration scripts are written in bash in this initial version. They start with a `wl-` prefix (short for WasmLabs). Review the [build orchestration scripts](#build-orchestration-scripts) section for more info.

All intermediary source code checkouts and build objects get created within the `build-staging` folder. The final output gets written to the `build-output` folder.

The patches and scripts to build different language runtimes are organized in a folder hierarchy that follows the tagged versions from the respective source code repositories. Several `wl-` scripts are added around that to facilitate setup of a local clone of the repository, application of respective patches and building with respective build configuration options.

For language runtimes we have something like this.

```
${LANGUAGE_RUNTIME_NAME} (e.g. 'php')
├── README.md (generic notes about what was patched to build this language)
├── ${VERSION_TAG_IN_REPO} (e.g. 'php-7.4.32' from the php repo)
│   ├── README.md (generic notes about what was patched to build this version)
│   ├── patches (consecutive patches on top of the tagged version, applied before building)
│   │   ├── (e.g. '0001-Initial-port-of-7.3.33-patch-to-7.4.32.patch')
│   │   ├── (e.g. '0002-Fix-mmap-issues.-Add-readme.patch')
│   │   └── Etc...
│   ├── wl-build-deps.sh (script that builds dependencies)
│   └── wl-build.sh (script that builds for this tag)
└── wl-env-repo.sh (script that sets up the source code repository for given langauge and tag)
```

For common shared libraries we have something limilar.
```
libs (common libraries, needed by different modules)
└── ${LIBRARY_NAME} (e.g. 'sqlite')
    ├── README.md (generic notes about what was patched to build this language)
    ├──${VERSION_TAG_IN_REPO} (e.g. 'version-3.39.2' from the sqlite repo)
    │   ├── patches (consecutive patches on top of the tagged version, applied before building)
    │   │   ├── (e.g. '0001-Patch-to-build-sqlite-3.39.2-for-wasm32-wasi.patch')
    │   │   ├── (e.g. '0002-Remove-build-script-from-patched-repo.patch')
    │   │   └── Etc...
    │   └── wl-build.sh (script that builds for this tag)
    └── wl-env-repo.sh (script that sets up the source code repository for given langauge and tag)
```

### Build orchestration scripts

1. The main script used to build something is `wl-make.sh` in the root folder. It gets called with a path to the folder for a respective tag of what we want to build.

2. It will first __source__ the `scripts/wl-env.sh` script. This one sets all environment variables necessary to checkout and build the desired target. It gets the same path from `wl-make.sh` and is useful when you try to build locally.

3. Then `wl-make.sh` will call `scripts/wl-setup-repo.sh` to create a shallow clone of the necessary repository only for the specific tag that we want to build. On top of that it applies any relevant patches from the `patches` subfolder of the tagged version folder.

4. As a final step `wl-make.sh` will call `scripts/wl-build.sh` which will build from the code in the respective repository.

5. Before building this will call a `$LANG/$TAG/wl-build-deps.sh` if there is any to build required dependencies and setup CFLAGS or LDFLAGS for their artifacts. Then it will call the `$LANG/$TAG/wl-build.sh` script to build the actual target itself.

### Adding a new build target

To add a build setup for a new version of something that is already configured:

1. Add a subfolder with the respective tag, like this:

```
mkdir php/php-7.3.33
```

2. Create a `wl-build.sh` script in the target folder, like this:

```console
touch php/php-7.3.33/wl-build.sh
```

3. Setup your build environment via `scripts/wl-env.sh` with the target path then query the respective environment variables, like this:

```console
source scripts/wl-env.sh php/php-7.3.33
export | grep WASMLABS_
```

4. Create a local clone of the respective tag in build-staging, like this:

```console
scripts/wl-setup-repo.sh
```

5. Open your favorite IDE in the said clone to iterate building from the tag until it works, like this:

```console
code build-staging/php/php-7.3.33/checkout
```

6. Patch the checked out code where necessary. Add flags and build commands to the `wl-build.sh` script in the target folder and each time rebuild like this:

```console
scripts/wl-build.sh
```

7. After you manage to get a working build, add proper lines at the end of your `wl-build.sh` script to copy from the `build-staging` folder to the respective `build-output` location, like this:

```bash
...
logStatus "Preparing artifacts... "
mkdir -p ${WASMLABS_OUTPUT}/bin 2>/dev/null || exit 1

cp sapi/cgi/php-cgi ${WASMLABS_OUTPUT}/bin/ || exit 1

logStatus "DONE. Artifacts in ${WASMLABS_OUTPUT}"

```

8. Commit the patch changes from 6. into the local shallow clone. If necessary, split them into commits. Then export them to the target folder (e.g. `php/php-7.3.33/patches`) like this:

```console
scripts/wl-update-patches.sh
```

9. Now add and commit the new target description folder containing the build script and respective patches to the current repository, like this:

```console
git add php/php-7.3.33
git commit -m "Add support to build php version 7.3.33"
```

## Releasing

In order to release a new version, you first have to tag the project you want to release. You can create a tag by using the `scripts/wl-tag.sh` script.

This script accepts the path to be released, and will create a local tag of the form `<project>/<version>+YYYYMMDD-<short-sha>`. All parameters will be automatically filled by the script, so in order to create a valid tag for PHP 7.3.33, for example, you only have to execute:

- `scripts/wl-tag.sh php/php-7.3.33`

This will create a tag like the following in your local repository: `php/7.3.33+20221123-d3d8901`.

When you push the tag to the remote repository, a GitHub release will be created automatically, and relevant artifacts will be automatically published to the release.
