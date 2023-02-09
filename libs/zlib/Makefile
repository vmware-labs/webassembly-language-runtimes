WASI_SDK_VERSION ?= 19
# NOTE - the default python build is failing with wasi-sdk-19

ROOT_DIR := $(dir $(realpath $(lastword $(MAKEFILE_LIST))))
REPO_ROOT := $(ROOT_DIR)../..

include $(REPO_ROOT)/Makefile.helpers

.PHONY: zlib-builder
ZLIB_BUILDER_NAME := ghcr.io/vmware-labs/wasmlabs/wasi-builder:$(WASI_SDK_VERSION)

.PHONY: v*
v*:
	@$(call build_in_container,$(ZLIB_BUILDER_NAME),$(REPO_ROOT),libs/zlib/$@)

.PHONY: clean
clean:
	rm -rf $(REPO_ROOT)/build-output/zlib $(REPO_ROOT)/build-staging/zlib
