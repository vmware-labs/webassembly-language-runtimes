WASI_SDK_VERSION ?= 16
# NOTE - the default python build is failing with wasi-sdk-19

ROOT_DIR := $(dir $(realpath $(lastword $(MAKEFILE_LIST))))

include $(ROOT_DIR)../Makefile.helpers

.PHONY: python-builder
PYTHON_BUILDER_NAME := ghcr.io/vmware-labs/wasmlabs/python-builder:wasi-$(WASI_SDK_VERSION)
python-builder:
	@$(call make_builder_image,$(PYTHON_BUILDER_NAME),$(ROOT_DIR),$(WASI_SDK_VERSION))

.PHONY: push-python-builder
push-python-builder:
	@$(call push_container_image,$(PYTHON_BUILDER_NAME))

.PHONY: v*
v*:
	@$(call build_in_container,$(PYTHON_BUILDER_NAME),python/$@)

.PHONY: clean
clean:
	rm -rf build-output build-staging
