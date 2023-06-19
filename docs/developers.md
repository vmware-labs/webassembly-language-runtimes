This document is a work in progress.

# Processes

## Updating Wasi-Sdk version

 You will need ghcr.io credentials with rights to publish to `ghcr.io/vmware-labs/wasmlabs`!

 - Bump the `WASI_SDK_VERSION ?= ##.#` in [Makefile.helpers](../Makefile.helpers)
 - Build and publish all builder images with a new tag based on `WASI_SDK_VERSION`
    ```
    make -f Makefile.builders update-all-builders
    ```
 - Release all independent libraries
 - Bump URLs in the libraries/runtimes which depend on them, then publish them, too
