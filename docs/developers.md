_Wasm Language Runtimes is evolving constantly so this is a live document. If you find any issue, typo or missing information, feel free to [open an issue](https://github.com/vmware-labs/webassembly-language-runtimes/issues/new/choose) or create a PR directly_

# Terminology

 - *language runtime* - this is some interpreted language runtime, which we build for wasm32-wasi. Running this runtime (interpreter) as a Wasm module allows people to run interpreted workloads on top of a Wasm Runtime.
 - *external library* - there are many common low-level system libraries at the core of traditional glibc apps. We build the statically for wasm32-wasi so they can be reused in the interpreter runtimes or when porting other glibc-based apps.
 - *internal library* - these are static wasm32-wasi libraries, which we provide to avoid code duplication.

# Getting started

All you need in order to run these builds is to have *GNU Make* along with `docker` or `podman` in your system.

 - To build any of the major runtimes you could start with `make php/`, `make python/` or `make/ruby`, then `<tab><tab>` to see the available targets (versions and flavors).

   Here is an example build of PHP:

   ```shell-session
   /home/ubuntu/wlr/ $$  make php/v8.2.6-slim

   WLR_BUILD_FLAVOR=slim make -C php v8.2.6
   make[1]: Entering directory '/home/ubuntu/wlr/php'
   Cloning into '/wlr/build-staging/php/php-8.2.6-slim/checkout'...
   ...
   Using WASI_SDK_PATH=/wasi-sdk
   php/php-8.2.6(slim) | Checking dependencies...
   php/php-8.2.6(slim) | Getting dependencies for php/php-8.2.6 ...
   ...
   Building 'php/php-8.2.6'
   ...
   php/php-8.2.6(slim) | DONE. Artifacts in /wlr/build-output/php/php-8.2.6-slim
   make[1]: Leaving directory '/home/ubuntu/wlr/php'
   ```

 - To build an external library you could do the same with say `make libs/libxml2/`, then `<tab><tab>` to see the available targets (versions and flavors) .

 - To build an internal library you only need to specify the path to it, as in `make libs/wlr_bundle`

Both runtimes and external libraries will have a subfolder that contains the build scripts and patches for the supported versions. These folder names usually follow the format `v${VERSION_MAJOR}.${VERSION_MINOR}.${VERSION_BUILD}`. For example `make php/v8.2.6` or `'libs/libxml2/v2.11.4`.

# The build scripts

All build orchestration scripts are written in bash in this initial version. They start with a `wlr-` prefix (short for WebAssembly Language Runtimes). Review the [build execution](#build-execution) section for more info on what happens during a build.

## File organization

### At build time
We use two working folders at build time - `build-staging` and `build-output`.

 - `build-staging` - contains all intermediary source code checkouts and build objects. It also contains the checkouts and builds of dependencies. Each target uses only its own subfolder, for example `build-staging/php/php-8.2.6-slim`.
 - `build-output` - contains the final output. The built binaries can be organized in `bin`, `include`, `lib`, etc. in the build target's own subfolder (e.g. `build-output/php/php-8.2.6-slim`) for local use or testing. Publishable assets (`*{.wasm,gz,txt}`) are placed at the `build-output` root during build.

### Build scripts and patches
The patches and build scripts are organized in sub-folders for each tagged version of the target runtime or external library. Several `wlr-` scripts are added around that to facilitate setup of a local clone of the repository, application of respective patches and building with respective build configuration options.

For language runtimes we have something like this.

```
${LANGUAGE_RUNTIME_NAME} (e.g. 'php')
├── README.md (generic notes about what was patched to build this language)
└── v${VERSION_FROM_TAG_IN_REPO} (e.g. 'v7.4.32' for the 'php-7.4.32 tag from the php repo)
    ├── README.md (generic notes about what was patched to build this version)
    ├── patches (consecutive patches on top of the tagged version, applied before building)
    │   ├── (e.g. '0001-Initial-port-of-7.3.33-patch-to-7.4.32.patch')
    │   ├── (e.g. '0002-Fix-mmap-issues.-Add-readme.patch')
    │   └── Etc...
    ├── wlr-build.sh (script that builds for this version - might contain specific manually set commands, flags, etc)
    ├── wlr-env-repo.sh (describes version, repository and tag from which we build this version)
    ├── wlr-info.json [optional] (build metadata - currently only describes build dependencies)
    └── wlr-tag.sh [optional] (describes the tag format used to release a build from this version)
```

For common shared libraries we have something similar.
```
libs (common libraries, needed by different modules)
└── ${LIBRARY_NAME} (e.g. 'sqlite')
    ├── README.md (generic notes about what was patched to build this language)
    └──${VERSION_TAG_IN_REPO} (e.g. 'version-3.39.2' from the sqlite repo)
        ├── patches (consecutive patches on top of the tagged version, applied before building)
        │   ├── (e.g. '0001-Patch-to-build-sqlite-3.39.2-for-wasm32-wasi.patch')
        │   ├── (e.g. '0002-Remove-build-script-from-patched-repo.patch')
        │   └── Etc...
        ├── wlr-build.sh (script that builds for this version - might contain specific manually set commands, flags, etc)
        ├── wlr-env-repo.sh (describes version, repository and tag from which we build this version)
        ├── wlr-info.json [optional] (build metadata - currently only describes build dependencies)
        └── wlr-tag.sh [optional] (describes the tag format used to release a build from this version)
```

### Helper scripts

There is a bunch of GNU Make macros and constants in [Makefile.helpers](../Makefile.helpers), which reduce the code repetition in Makefiles. Macros should be well documented within the file itself. Some of them create targets dynamically and should be invoked via `$(eval $(call ...))`/

Most of the build helper scripts are located in the [scripts](../scripts/) folder. Where available, documentation for them is in-place.

## Build execution

The GNU Make makefiles will use build containers that have all necessary dependencies for a build. Inside the container they call on the `wlr-make.sh` script.

1. The main script used to build something is `wlr-make.sh` in the root folder. It gets called with a path to the the `${TARGET_FOLDER}` folder that we want to build. For example `php/v8.2.6`. Build flavors (like `slim`, `wasmedge`, etc are passed via the `WLR_BUILD_FLAVOR` env variable).

2. `wlr-make.sh` will first __source__ the `scripts/wlr-env.sh` script. This one sets all environment variables necessary to checkout and build the desired target. The staging or output folders configured here may be different depending on whether the target is built as a standalone one or as a dependency of another target.

3. Then `wlr-make.sh` will call `scripts/wlr-setup-repo.sh` to create a shallow clone of the necessary repository only for the specific tag that we want to build. On top of that it applies any relevant patches from the `patches` subfolder of the tagged version folder.

4. As a final step `wlr-make.sh` will call `scripts/wlr-build.sh` which will build from the code in the respective repository.

5. First `scripts/wlr-build.sh` will use `${TARGET_FOLDER}/wlr-info.json` to determine if we need to also build or download any required dependencies. Then those are either built locally (by calling `wlr-make.sh` respectively) or downloaded.

6. After we have all dependencies `scripts/wlr-build.sh` will call the `${TARGET_FOLDER}/wlr-build.sh` script to build the actual target itself.

# GH Actions

We usually have two types of actions for each project - `build-*` and `release-*`. The first is triggered on any PR change in files that affect the project, while the latter is triggered on the push of a release tag.

**Note**: In case of several release tags on the same commit, push them to github one by one. Otherwise the `release-*` GH actions will not be triggered!

We have a few reusable workflows, each starts with the `reusable-` prefix. They are documented and can be found in the [.github/workflows/](../.github/workflows/) folder.

# Processes

## Releasing

In order to release a new version, you first have to tag the project you want to release. You can create a tag by using the `scripts/wlr-tag.sh` script.

This script accepts the path to be released, and will create a local tag of the form `<project>/<version>+YYYYMMDD-<short-sha>`. All parameters will be automatically filled by the script, so in order to create a valid tag for PHP 8.1.11, for example, you only have to execute:

```shell-session
$$ scripts/wlr-tag.sh php/v8.1.11
```

This will create a tag like the following in your local repository: `php/8.1.11+20221123-d3d8901`.

When you push the tag to the remote repository, a GitHub release will be created automatically, and relevant artifacts will be automatically published to the release.

**Note**: See [GH Actions](#gh-actions). In case of several release tags on the same commit, push them to github one by one. Otherwise the `release-*` GH actions will not be triggered!

## Updating Wasi-Sdk version

 You will need ghcr.io credentials with rights to publish to `ghcr.io/vmware-labs/wasmlabs`!

 - Bump the `WASI_SDK_VERSION ?= ##.#` in [Makefile.helpers](../Makefile.helpers)
 - Build and publish all builder images with a new tag based on `WASI_SDK_VERSION`
    ```
    make -f Makefile.builders update-all-builders
    ```
 - Build and release all independent libraries with the new WASI SDK version (without a `"deps"` section in a `wlr-info.json`).
 - Bump `"url": "..."` fields in all `wlr-info.json` for the libraries/runtimes, which depend on them, then release them, too.

**Note**: When you bump up the WASI SDK version this may bring in a newer version of the CLang toolchain. Often times this leads to changes in the default handling of certain warnings - e.g. what used to be only warnings are now errors. The fix is usually to add the respective flags to ignore the warning in the `wlr-build.sh` for the failing target.

## Adding a new build target

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
